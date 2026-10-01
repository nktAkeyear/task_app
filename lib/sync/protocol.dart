import '../domain/hlc.dart';

const entityList = 'list';
const entityTask = 'task';
const entityTag = 'tag';
const entityTaskTag = 'task_tag';
const entityChecklist = 'checklist';

class FieldValue {
  const FieldValue(this.value, this.hlc);

  final Object? value;
  final Hlc hlc;

  Map<String, Object?> toJson() => {'value': value, 'hlc': hlc.toJson()};

  factory FieldValue.fromJson(Map<String, Object?> json) {
    final hlcRaw = json['hlc'];
    if (hlcRaw is! Map) {
      throw const FormatException('Field clock is missing');
    }
    return FieldValue(
      json['value'],
      Hlc.fromJson(hlcRaw.map((key, value) => MapEntry(key.toString(), value))),
    );
  }
}

class SyncEntity {
  const SyncEntity({
    required this.type,
    required this.id,
    required this.fields,
    this.deletedHlc,
    this.restoredHlc,
  });

  final String type;
  final String id;
  final Map<String, FieldValue> fields;
  final Hlc? deletedHlc;
  final Hlc? restoredHlc;

  /// True whenever a tombstone is still set. A field edit does not clear it.
  bool get isDeleted => deletedHlc != null;

  Map<String, Object?> toJson() => {
    'type': type,
    'id': id,
    'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
    'deletedHlc': deletedHlc?.toJson(),
    'restoredHlc': restoredHlc?.toJson(),
  };

  factory SyncEntity.fromJson(Map<String, Object?> json) {
    final rawFields = json['fields'];
    final fields = <String, FieldValue>{};
    if (rawFields is Map) {
      for (final entry in rawFields.entries) {
        final value = entry.value;
        if (value is Map) {
          fields[entry.key.toString()] = FieldValue.fromJson(
            value.map((key, item) => MapEntry(key.toString(), item)),
          );
        }
      }
    }
    final deleted = json['deletedHlc'];
    final restored = json['restoredHlc'];
    return SyncEntity(
      type: json['type']! as String,
      id: json['id']! as String,
      fields: fields,
      deletedHlc: deleted is Map
          ? Hlc.fromJson(deleted.map((key, value) => MapEntry(key.toString(), value)))
          : null,
      restoredHlc: restored is Map
          ? Hlc.fromJson(restored.map((key, value) => MapEntry(key.toString(), value)))
          : null,
    );
  }
}

class SyncOp {
  const SyncOp({
    required this.opId,
    required this.entityType,
    required this.entityId,
    required this.deviceId,
    required this.fields,
    required this.createdAt,
    this.deleteHlc,
    this.restoreHlc,
  });

  final String opId;
  final String entityType;
  final String entityId;
  final String deviceId;
  final Map<String, FieldValue> fields;
  final int createdAt;
  final Hlc? deleteHlc;
  final Hlc? restoreHlc;

  SyncEntity toEntity() {
    return SyncEntity(
      type: entityType,
      id: entityId,
      fields: fields,
      deletedHlc: deleteHlc,
      restoredHlc: restoreHlc,
    );
  }

  Map<String, Object?> toJson() => {
    'opId': opId,
    'entityType': entityType,
    'entityId': entityId,
    'deviceId': deviceId,
    'fields': fields.map((key, value) => MapEntry(key, value.toJson())),
    'createdAt': createdAt,
    'deleteHlc': deleteHlc?.toJson(),
    'restoreHlc': restoreHlc?.toJson(),
  };

  factory SyncOp.fromJson(Map<String, Object?> json) {
    final rawFields = json['fields'];
    final fields = <String, FieldValue>{};
    if (rawFields is Map) {
      for (final entry in rawFields.entries) {
        final value = entry.value;
        if (value is Map) {
          fields[entry.key.toString()] = FieldValue.fromJson(
            value.map((key, item) => MapEntry(key.toString(), item)),
          );
        }
      }
    }
    final deleted = json['deleteHlc'];
    final restored = json['restoreHlc'];
    return SyncOp(
      opId: json['opId']! as String,
      entityType: json['entityType']! as String,
      entityId: json['entityId']! as String,
      deviceId: json['deviceId']! as String,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0,
      fields: fields,
      deleteHlc: deleted is Map
          ? Hlc.fromJson(deleted.map((key, value) => MapEntry(key.toString(), value)))
          : null,
      restoreHlc: restored is Map
          ? Hlc.fromJson(restored.map((key, value) => MapEntry(key.toString(), value)))
          : null,
    );
  }
}

class SyncBatchResult {
  const SyncBatchResult({
    required this.cursor,
    required this.acked,
    required this.ops,
  });

  final int cursor;
  final List<String> acked;
  final List<SyncOp> ops;

  Map<String, Object?> toJson() => {
    'cursor': cursor,
    'acked': acked,
    'ops': ops.map((op) => op.toJson()).toList(),
  };

  factory SyncBatchResult.fromJson(Map<String, Object?> json) {
    final rawOps = json['ops'];
    final ops = <SyncOp>[];
    if (rawOps is List) {
      for (final item in rawOps) {
        if (item is Map) {
          ops.add(SyncOp.fromJson(item.map((key, value) => MapEntry(key.toString(), value))));
        }
      }
    }
    final rawAcked = json['acked'];
    return SyncBatchResult(
      cursor: (json['cursor'] as num?)?.toInt() ?? 0,
      acked: rawAcked is List ? rawAcked.map((item) => item.toString()).toList() : const [],
      ops: ops,
    );
  }
}

/// Field-level last-writer-wins.
///
/// Non-overlapping fields are both kept. The same field keeps the higher clock
/// (physical, then logical, then device id). A delete keeps its field values.
/// A field edit never clears a tombstone. An explicit restore clears the
/// tombstone only when its clock is strictly newer than the delete.
SyncEntity mergeEntities(SyncEntity local, SyncEntity remote) {
  final fields = <String, FieldValue>{};
  final keys = <String>{...local.fields.keys, ...remote.fields.keys};
  for (final key in keys) {
    final left = local.fields[key];
    final right = remote.fields[key];
    if (left == null) {
      fields[key] = right!;
    } else if (right == null) {
      fields[key] = left;
    } else if (right.hlc.compareTo(left.hlc) > 0) {
      fields[key] = right;
    } else {
      fields[key] = left;
    }
  }

  var deleted = _laterClock(local.deletedHlc, remote.deletedHlc);
  final restored = _laterClock(local.restoredHlc, remote.restoredHlc);
  if (restored != null && (deleted == null || restored.compareTo(deleted) > 0)) {
    deleted = null;
  }

  return SyncEntity(
    type: local.type.isNotEmpty ? local.type : remote.type,
    id: local.id.isNotEmpty ? local.id : remote.id,
    fields: fields,
    deletedHlc: deleted,
    restoredHlc: restored,
  );
}

Hlc? _laterClock(Hlc? left, Hlc? right) {
  if (left == null) {
    return right;
  }
  if (right == null) {
    return left;
  }
  return right.compareTo(left) > 0 ? right : left;
}
