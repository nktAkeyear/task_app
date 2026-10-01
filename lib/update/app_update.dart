import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/copy.dart';
import 'package_installer.dart';

class ReleaseOffer {
  const ReleaseOffer({
    required this.version,
    required this.pageUrl,
    this.apkUrl,
  });

  final String version;
  final String pageUrl;
  final String? apkUrl;
}

class UpdateLookup {
  const UpdateLookup({required this.failed, this.offer});

  final bool failed;
  final ReleaseOffer? offer;
}

const latestReleaseUrl =
    'https://api.github.com/repos/nktAkeyear/task_app/releases/latest';

int compareVersions(String installed, String remote) {
  final a = _parts(installed);
  final b = _parts(remote);
  final length = a.length > b.length ? a.length : b.length;
  for (var index = 0; index < length; index++) {
    final left = index < a.length ? a[index] : 0;
    final right = index < b.length ? b[index] : 0;
    if (left != right) {
      return left.compareTo(right);
    }
  }
  return 0;
}

List<int> _parts(String raw) {
  final cleaned = raw.trim().replaceFirst(RegExp(r'^[vV]'), '');
  final core = cleaned.split('+').first.split('-').first;
  if (core.isEmpty) {
    return const [0];
  }
  return [for (final piece in core.split('.')) int.tryParse(piece) ?? 0];
}

ReleaseOffer? parseLatestRelease(String body, String installed) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) {
    return null;
  }
  final tag = decoded['tag_name']?.toString() ?? '';
  final page = decoded['html_url']?.toString() ?? '';
  if (tag.isEmpty || page.isEmpty || compareVersions(installed, tag) >= 0) {
    return null;
  }
  String? apk;
  final assets = decoded['assets'];
  if (assets is List) {
    for (final asset in assets) {
      if (asset is! Map) {
        continue;
      }
      final name = asset['name']?.toString() ?? '';
      final url = asset['browser_download_url']?.toString() ?? '';
      if (!name.endsWith('.apk') || url.isEmpty) {
        continue;
      }
      apk = url;
      if (name.contains('release')) {
        break;
      }
    }
  }
  return ReleaseOffer(
    version: tag.replaceFirst(RegExp(r'^[vV]'), ''),
    pageUrl: page,
    apkUrl: apk,
  );
}

Future<UpdateLookup> lookupLatestRelease(String installed) async {
  final client = HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 6);
    final request = await client.getUrl(Uri.parse(latestReleaseUrl));
    request.headers.set(HttpHeaders.userAgentHeader, 'Tas');
    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/vnd.github+json',
    );
    final response = await request.close().timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      return const UpdateLookup(failed: true);
    }
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 8));
    return UpdateLookup(
      failed: false,
      offer: parseLatestRelease(body, installed),
    );
  } catch (_) {
    return const UpdateLookup(failed: true);
  } finally {
    client.close(force: true);
  }
}

Future<File?> downloadApk(String url) async {
  final client = HttpClient();
  try {
    client.connectionTimeout = const Duration(seconds: 8);
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'Tas');
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      return null;
    }
    final bytes = await response.fold<List<int>>(
      <int>[],
      (list, chunk) => list..addAll(chunk),
    );
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/updates/tas-update.apk');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    return file;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

Future<void> checkForUpdate(
  BuildContext context, {
  required bool fromSettings,
}) async {
  final copy = Copy.of(context);
  String installed;
  try {
    installed = (await PackageInfo.fromPlatform()).version;
  } catch (_) {
    return;
  }
  if (!context.mounted) {
    return;
  }
  final lookup = await lookupLatestRelease(installed);
  if (!context.mounted) {
    return;
  }
  if (lookup.failed) {
    return;
  }
  final offer = lookup.offer;
  if (offer == null) {
    if (fromSettings) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(copy.upToDate)));
    }
    return;
  }
  final yes = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(copy.updateTitle),
      content: Text(copy.updateBody(offer.version)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(copy.later),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(copy.download),
        ),
      ],
    ),
  );
  if (yes != true || !context.mounted) {
    return;
  }
  if (offer.apkUrl == null) {
    await _offerPage(context, offer.pageUrl, copy.downloadFailed);
    return;
  }
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 16),
          Expanded(child: Text(copy.downloading)),
        ],
      ),
    ),
  );
  final file = await downloadApk(offer.apkUrl!);
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  if (!context.mounted) {
    return;
  }
  if (file == null) {
    await _offerPage(context, offer.pageUrl, copy.downloadFailed);
    return;
  }
  final allowed = await PackageInstaller.canInstall();
  if (!context.mounted) {
    return;
  }
  if (!allowed) {
    await _offerPage(context, offer.pageUrl, copy.installBlocked);
    return;
  }
  await PackageInstaller.install(file.path);
}

Future<void> _offerPage(
  BuildContext context,
  String url,
  String message,
) async {
  final copy = Copy.of(context);
  final open = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 12),
          SelectableText(url),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(copy.close),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(copy.openRelease),
        ),
      ],
    ),
  );
  if (open == true) {
    await PackageInstaller.openUrl(url);
  }
}
