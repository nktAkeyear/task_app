import 'dart:convert';
import 'dart:io';

import '../domain/models.dart';
import 'protocol.dart';

class SyncException implements Exception {
  SyncException(this.message);
  final String message;

  @override
  String toString() => message;
}

typedef SyncHandler =
    Future<SyncBatchResult> Function({
      required String baseUrl,
      required String deviceId,
      required int cursor,
      required List<SyncOp> ops,
    });

class SyncClient {
  SyncClient({Duration? timeout, this.handler}) : timeout = timeout ?? const Duration(seconds: 12);

  final Duration timeout;
  final SyncHandler? handler;

  Future<SyncBatchResult> exchange({
    required String baseUrl,
    required String deviceId,
    required int cursor,
    required List<SyncOp> ops,
  }) async {
    final custom = handler;
    if (custom != null) {
      return custom(baseUrl: baseUrl, deviceId: deviceId, cursor: cursor, ops: ops);
    }
    final uri = syncEndpoint(baseUrl);
    final client = HttpClient();
    try {
      final request = await client.postUrl(uri).timeout(timeout);
      request.headers.contentType = ContentType.json;
      request.add(
        utf8.encode(
          jsonEncode({
            'deviceId': deviceId,
            'cursor': cursor,
            'ops': ops.map((op) => op.toJson()).toList(),
          }),
        ),
      );
      final response = await request.close().timeout(timeout);
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw SyncException('同期サーバーが ${response.statusCode} を返しました。');
      }
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw SyncException('同期サーバーの応答を読めませんでした。');
      }
      return SyncBatchResult.fromJson(decoded.map((key, value) => MapEntry(key.toString(), value)));
    } on SyncException {
      rethrow;
    } catch (_) {
      throw SyncException('同期サーバーに接続できませんでした。');
    } finally {
      client.close(force: true);
    }
  }
}
