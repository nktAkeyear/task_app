import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'protocol.dart';

class StoredOp {
  const StoredOp(this.seq, this.op);

  final int seq;
  final SyncOp op;
}

/// Append-only op log. Replayed ops with the same id are ignored.
class SyncLog {
  SyncLog();

  int cursor = 0;
  final List<StoredOp> ops = [];
  final Map<String, int> seen = {};
  Future<void> _lock = Future<void>.value();

  SyncBatchResult pushPull({required int since, required List<SyncOp> incoming}) {
    final acked = <String>[];
    for (final op in incoming) {
      if (!seen.containsKey(op.opId)) {
        cursor += 1;
        seen[op.opId] = cursor;
        ops.add(StoredOp(cursor, op));
      }
      acked.add(op.opId);
    }
    final remote = ops.where((stored) => stored.seq > since).map((stored) => stored.op).toList();
    return SyncBatchResult(cursor: cursor, acked: acked, ops: remote);
  }

  Future<T> synchronized<T>(Future<T> Function() body) {
    final previous = _lock;
    final gate = Completer<void>();
    _lock = gate.future;
    return previous.then((_) => body()).whenComplete(gate.complete);
  }

  Map<String, Object?> toJson() => {
    'cursor': cursor,
    'ops': ops
        .map(
          (stored) => {
            'seq': stored.seq,
            'op': stored.op.toJson(),
          },
        )
        .toList(),
  };

  void loadJson(Map<String, Object?> json) {
    cursor = (json['cursor'] as num?)?.toInt() ?? 0;
    ops.clear();
    seen.clear();
    final raw = json['ops'];
    if (raw is! List) {
      return;
    }
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      final seq = (item['seq'] as num?)?.toInt();
      final opRaw = item['op'];
      if (seq == null || opRaw is! Map) {
        continue;
      }
      final op = SyncOp.fromJson(opRaw.map((key, value) => MapEntry(key.toString(), value)));
      ops.add(StoredOp(seq, op));
      seen[op.opId] = seq;
    }
    if (cursor < seen.length) {
      cursor = seen.values.fold(0, (max, seq) => seq > max ? seq : max);
    }
  }

  static Future<SyncLog> fromFile(File file) async {
    final log = SyncLog();
    if (await file.exists()) {
      final raw = jsonDecode(await file.readAsString());
      if (raw is Map) {
        log.loadJson(raw.map((key, value) => MapEntry(key.toString(), value)));
      }
    }
    return log;
  }

  Future<void> saveFile(File file) async {
    await file.parent.create(recursive: true);
    final tmp = File('${file.path}.tmp');
    await tmp.writeAsString(const JsonEncoder.withIndent('  ').convert(toJson()));
    await tmp.rename(file.path);
  }
}
