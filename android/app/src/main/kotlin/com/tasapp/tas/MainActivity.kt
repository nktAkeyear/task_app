package com.tasapp.tas

import android.app.DownloadManager
import android.content.Context
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tas/install").setMethodCallHandler { call, result ->
            when (call.method) {
                "canInstall" -> {
                    val allowed = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        packageManager.canRequestPackageInstalls()
                    } else {
                        true
                    }
                    result.success(allowed)
                }
                "install" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("path", "missing", null)
                        return@setMethodCallHandler
                    }
                    val file = File(path)
                    val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
                    val intent = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(uri, "application/vnd.android.package-archive")
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    }
                    startActivity(intent)
                    result.success(null)
                }
                "openUrl" -> {
                    val url = call.argument<String>("url")
                    if (url == null) {
                        result.error("url", "missing", null)
                        return@setMethodCallHandler
                    }
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
                    result.success(null)
                }
                "enqueueUpdate" -> {
                    val url = call.argument<String>("url")
                    val version = call.argument<String>("version")
                    val fileName = call.argument<String>("fileName")
                    val installed = call.argument<String>("installed")
                    if (url == null || version == null || fileName == null || installed == null) {
                        result.success(false)
                        return@setMethodCallHandler
                    }
                    result.success(enqueueUpdate(url, version, fileName, installed))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun enqueueUpdate(
        url: String,
        version: String,
        fileName: String,
        installed: String,
    ): Boolean {
        val manager = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
        purgeOlderUpdates(manager, installed)
        File(updatesDir(), "tas-${safeUpdateToken(version)}.apk.part").delete()
        val rows = matchingDownloads(manager, fileName, url)
        val finished = rows.any { row ->
            row.status == DownloadManager.STATUS_SUCCESSFUL && row.bytes > 0L
        }
        if (finished || publicFileReady(fileName)) {
            return openDownloads()
        }
        val active = rows.any { row ->
            row.status == DownloadManager.STATUS_RUNNING ||
                row.status == DownloadManager.STATUS_PENDING ||
                row.status == DownloadManager.STATUS_PAUSED
        }
        if (active) {
            return openDownloads()
        }
        for (row in rows) {
            if (row.status == DownloadManager.STATUS_FAILED ||
                (row.status == DownloadManager.STATUS_SUCCESSFUL && row.bytes <= 0L)
            ) {
                manager.remove(row.id)
            }
        }
        return try {
            val request = DownloadManager.Request(Uri.parse(url))
                .setTitle("Tas $version")
                .setDescription(fileName)
                .setMimeType("application/vnd.android.package-archive")
                .setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                .setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)
            manager.enqueue(request)
            openDownloads()
        } catch (_: Exception) {
            false
        }
    }

    private fun openDownloads(): Boolean {
        return try {
            startActivity(
                Intent(DownloadManager.ACTION_VIEW_DOWNLOADS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun purgeOlderUpdates(manager: DownloadManager, installed: String) {
        updatesDir().listFiles()?.forEach { file ->
            if (shouldDeleteUpdateFile(file.name, installed)) {
                file.delete()
            }
        }
        val cursor = manager.query(DownloadManager.Query())
        cursor?.use {
            while (it.moveToNext()) {
                val name = downloadName(it)
                if (name != null && shouldDeleteUpdateFile(name, installed)) {
                    val id = it.longOf(DownloadManager.COLUMN_ID)
                    if (id != null) {
                        manager.remove(id)
                    }
                }
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val projection = arrayOf(
                MediaStore.Downloads._ID,
                MediaStore.Downloads.DISPLAY_NAME,
            )
            contentResolver.query(collection, projection, null, null, null)?.use { media ->
                val idIndex = media.getColumnIndex(MediaStore.Downloads._ID)
                val nameIndex = media.getColumnIndex(MediaStore.Downloads.DISPLAY_NAME)
                while (media.moveToNext()) {
                    if (nameIndex < 0 || idIndex < 0) {
                        continue
                    }
                    val name = media.getString(nameIndex) ?: continue
                    if (!shouldDeleteUpdateFile(name, installed)) {
                        continue
                    }
                    val id = media.getLong(idIndex)
                    contentResolver.delete(android.content.ContentUris.withAppendedId(collection, id), null, null)
                }
            }
        } else {
            val dir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
            dir.listFiles()?.forEach { file ->
                if (shouldDeleteUpdateFile(file.name, installed)) {
                    file.delete()
                }
            }
        }
    }

    private fun publicFileReady(fileName: String): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            val collection = MediaStore.Downloads.EXTERNAL_CONTENT_URI
            val projection = arrayOf(MediaStore.Downloads.SIZE)
            contentResolver.query(
                collection,
                projection,
                "${MediaStore.Downloads.DISPLAY_NAME}=?",
                arrayOf(fileName),
                null,
            )?.use { cursor ->
                val sizeIndex = cursor.getColumnIndex(MediaStore.Downloads.SIZE)
                while (cursor.moveToNext()) {
                    val size = if (sizeIndex >= 0 && !cursor.isNull(sizeIndex)) cursor.getLong(sizeIndex) else 0L
                    if (size > 0L) {
                        return true
                    }
                }
            }
            return false
        }
        val file = File(
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS),
            fileName,
        )
        return file.isFile && file.length() > 0L
    }

    private fun matchingDownloads(
        manager: DownloadManager,
        fileName: String,
        url: String,
    ): List<DownloadHit> {
        val hits = mutableListOf<DownloadHit>()
        val cursor = manager.query(DownloadManager.Query()) ?: return hits
        cursor.use {
            while (it.moveToNext()) {
                val id = it.longOf(DownloadManager.COLUMN_ID) ?: continue
                val status = it.intOf(DownloadManager.COLUMN_STATUS) ?: continue
                val local = it.stringOf(DownloadManager.COLUMN_LOCAL_URI).orEmpty()
                val remote = it.stringOf(DownloadManager.COLUMN_URI).orEmpty()
                val description = it.stringOf(DownloadManager.COLUMN_DESCRIPTION).orEmpty()
                val bytes = it.longOf(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR) ?: 0L
                val total = it.longOf(DownloadManager.COLUMN_TOTAL_SIZE_BYTES) ?: 0L
                val size = maxOf(bytes, if (status == DownloadManager.STATUS_SUCCESSFUL) total else 0L)
                val localName = Uri.decode(local.substringAfterLast('/').substringBefore('?'))
                val sameName = localName == fileName || description == fileName
                val sameUrl = url.isNotEmpty() && remote == url
                if (sameName || sameUrl) {
                    hits.add(DownloadHit(id, status, size))
                }
            }
        }
        return hits
    }

    private fun downloadName(cursor: Cursor): String? {
        val description = cursor.stringOf(DownloadManager.COLUMN_DESCRIPTION)
        if (!description.isNullOrEmpty() && description.endsWith(".apk")) {
            return description
        }
        val local = cursor.stringOf(DownloadManager.COLUMN_LOCAL_URI) ?: return description
        val name = Uri.decode(local.substringAfterLast('/').substringBefore('?'))
        return name.ifEmpty { null }
    }

    private fun updatesDir(): File {
        val dir = File(cacheDir, "updates")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }
}

private data class DownloadHit(val id: Long, val status: Int, val bytes: Long)

private fun Cursor.longOf(column: String): Long? {
    val index = getColumnIndex(column)
    if (index < 0 || isNull(index)) {
        return null
    }
    return getLong(index)
}

private fun Cursor.intOf(column: String): Int? {
    val index = getColumnIndex(column)
    if (index < 0 || isNull(index)) {
        return null
    }
    return getInt(index)
}

private fun Cursor.stringOf(column: String): String? {
    val index = getColumnIndex(column)
    if (index < 0 || isNull(index)) {
        return null
    }
    return getString(index)
}

internal fun safeUpdateToken(version: String): String {
    return version.replace(Regex("[^0-9A-Za-z._-]"), "_")
}

internal fun compareVersions(installed: String, remote: String): Int {
    fun parts(raw: String): List<Int> {
        val cleaned = raw.trim().removePrefix("v").removePrefix("V")
        val core = cleaned.substringBefore('+').substringBefore('-')
        if (core.isEmpty()) {
            return listOf(0)
        }
        return core.split('.').map { it.toIntOrNull() ?: 0 }
    }
    val left = parts(installed)
    val right = parts(remote)
    val length = maxOf(left.size, right.size)
    for (index in 0 until length) {
        val a = left.getOrElse(index) { 0 }
        val b = right.getOrElse(index) { 0 }
        if (a != b) {
            return a.compareTo(b)
        }
    }
    return 0
}

internal fun shouldDeleteUpdateFile(fileName: String, installed: String): Boolean {
    var base = fileName
    if (base.endsWith(".part")) {
        base = base.removeSuffix(".part")
    }
    if (base == "tas-update.apk") {
        return true
    }
    val match = Regex("^(?:tas|Tas)-(.+)\\.apk$").matchEntire(base) ?: return false
    return compareVersions(installed, match.groupValues[1]) > 0
}
