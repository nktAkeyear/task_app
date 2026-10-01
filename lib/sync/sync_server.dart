import 'dart:convert';
import 'dart:io';

import 'protocol.dart';
import 'sync_log.dart';

class SyncServer {
  SyncServer(this.log, {this.file});

  final SyncLog log;
  final File? file;
  HttpServer? _server;

  Future<Uri> start({String host = '127.0.0.1', int port = 8787}) async {
    final server = await HttpServer.bind(host, port);
    _server = server;
    server.listen(_handle);
    return Uri.parse('http://$host:${server.port}');
  }

  Future<void> close() async {
    await _server?.close(force: true);
    _server = null;
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    response.headers.set('Access-Control-Allow-Origin', '*');
    response.headers.set('Access-Control-Allow-Headers', 'content-type');
    response.headers.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    try {
      if (request.method == 'OPTIONS') {
        response.statusCode = 204;
        await response.close();
        return;
      }
      if (request.method == 'GET' && request.uri.path == '/health') {
        response.statusCode = 200;
        response.headers.contentType = ContentType.json;
        response.write(jsonEncode({'ok': true}));
        await response.close();
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/v1/sync') {
        final body = await utf8.decoder.bind(request).join();
        final decoded = jsonDecode(body);
        if (decoded is! Map) {
          response.statusCode = 400;
          response.write('invalid json');
          await response.close();
          return;
        }
        final json = decoded.map((key, value) => MapEntry(key.toString(), value));
        final rawOps = json['ops'];
        final incoming = <SyncOp>[];
        if (rawOps is List) {
          for (final item in rawOps) {
            if (item is Map) {
              incoming.add(SyncOp.fromJson(item.map((key, value) => MapEntry(key.toString(), value))));
            }
          }
        }
        final since = (json['cursor'] as num?)?.toInt() ?? 0;
        final result = await log.synchronized(() async {
          final batch = log.pushPull(since: since, incoming: incoming);
          final destination = file;
          if (destination != null) {
            await log.saveFile(destination);
          }
          return batch;
        });
        response.statusCode = 200;
        response.headers.contentType = ContentType.json;
        response.write(jsonEncode(result.toJson()));
        await response.close();
        return;
      }
      response.statusCode = 404;
      await response.close();
    } catch (error) {
      response.statusCode = 500;
      response.write('sync failed');
      await response.close();
    }
  }
}
