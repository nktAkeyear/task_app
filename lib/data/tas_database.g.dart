// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tas_database.dart';

// ignore_for_file: type=lint
class $TaskListsTable extends TaskLists
    with TableInfo<$TaskListsTable, TaskListRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isInboxMeta = const VerificationMeta(
    'isInbox',
  );
  @override
  late final GeneratedColumn<bool> isInbox = GeneratedColumn<bool>(
    'is_inbox',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_inbox" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredHlcMeta = const VerificationMeta(
    'restoredHlc',
  );
  @override
  late final GeneratedColumn<String> restoredHlc = GeneratedColumn<String>(
    'restored_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldClocksMeta = const VerificationMeta(
    'fieldClocks',
  );
  @override
  late final GeneratedColumn<String> fieldClocks = GeneratedColumn<String>(
    'field_clocks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    sortOrder,
    isInbox,
    archived,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskListRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_inbox')) {
      context.handle(
        _isInboxMeta,
        isInbox.isAcceptableOrUnknown(data['is_inbox']!, _isInboxMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    }
    if (data.containsKey('restored_hlc')) {
      context.handle(
        _restoredHlcMeta,
        restoredHlc.isAcceptableOrUnknown(
          data['restored_hlc']!,
          _restoredHlcMeta,
        ),
      );
    }
    if (data.containsKey('field_clocks')) {
      context.handle(
        _fieldClocksMeta,
        fieldClocks.isAcceptableOrUnknown(
          data['field_clocks']!,
          _fieldClocksMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskListRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskListRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isInbox: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_inbox'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      ),
      restoredHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restored_hlc'],
      ),
      fieldClocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_clocks'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TaskListsTable createAlias(String alias) {
    return $TaskListsTable(attachedDatabase, alias);
  }
}

class TaskListRow extends DataClass implements Insertable<TaskListRow> {
  final String id;
  final String name;
  final int color;
  final int sortOrder;
  final bool isInbox;
  final bool archived;
  final bool deleted;
  final String? deletedHlc;
  final String? restoredHlc;
  final String fieldClocks;
  final int createdAt;
  final int updatedAt;
  const TaskListRow({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.isInbox,
    required this.archived,
    required this.deleted,
    this.deletedHlc,
    this.restoredHlc,
    required this.fieldClocks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_inbox'] = Variable<bool>(isInbox);
    map['archived'] = Variable<bool>(archived);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deletedHlc != null) {
      map['deleted_hlc'] = Variable<String>(deletedHlc);
    }
    if (!nullToAbsent || restoredHlc != null) {
      map['restored_hlc'] = Variable<String>(restoredHlc);
    }
    map['field_clocks'] = Variable<String>(fieldClocks);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TaskListsCompanion toCompanion(bool nullToAbsent) {
    return TaskListsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      sortOrder: Value(sortOrder),
      isInbox: Value(isInbox),
      archived: Value(archived),
      deleted: Value(deleted),
      deletedHlc: deletedHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedHlc),
      restoredHlc: restoredHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredHlc),
      fieldClocks: Value(fieldClocks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskListRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskListRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isInbox: serializer.fromJson<bool>(json['isInbox']),
      archived: serializer.fromJson<bool>(json['archived']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deletedHlc: serializer.fromJson<String?>(json['deletedHlc']),
      restoredHlc: serializer.fromJson<String?>(json['restoredHlc']),
      fieldClocks: serializer.fromJson<String>(json['fieldClocks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isInbox': serializer.toJson<bool>(isInbox),
      'archived': serializer.toJson<bool>(archived),
      'deleted': serializer.toJson<bool>(deleted),
      'deletedHlc': serializer.toJson<String?>(deletedHlc),
      'restoredHlc': serializer.toJson<String?>(restoredHlc),
      'fieldClocks': serializer.toJson<String>(fieldClocks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TaskListRow copyWith({
    String? id,
    String? name,
    int? color,
    int? sortOrder,
    bool? isInbox,
    bool? archived,
    bool? deleted,
    Value<String?> deletedHlc = const Value.absent(),
    Value<String?> restoredHlc = const Value.absent(),
    String? fieldClocks,
    int? createdAt,
    int? updatedAt,
  }) => TaskListRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    isInbox: isInbox ?? this.isInbox,
    archived: archived ?? this.archived,
    deleted: deleted ?? this.deleted,
    deletedHlc: deletedHlc.present ? deletedHlc.value : this.deletedHlc,
    restoredHlc: restoredHlc.present ? restoredHlc.value : this.restoredHlc,
    fieldClocks: fieldClocks ?? this.fieldClocks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskListRow copyWithCompanion(TaskListsCompanion data) {
    return TaskListRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isInbox: data.isInbox.present ? data.isInbox.value : this.isInbox,
      archived: data.archived.present ? data.archived.value : this.archived,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      restoredHlc: data.restoredHlc.present
          ? data.restoredHlc.value
          : this.restoredHlc,
      fieldClocks: data.fieldClocks.present
          ? data.fieldClocks.value
          : this.fieldClocks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskListRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isInbox: $isInbox, ')
          ..write('archived: $archived, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    sortOrder,
    isInbox,
    archived,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskListRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.isInbox == this.isInbox &&
          other.archived == this.archived &&
          other.deleted == this.deleted &&
          other.deletedHlc == this.deletedHlc &&
          other.restoredHlc == this.restoredHlc &&
          other.fieldClocks == this.fieldClocks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TaskListsCompanion extends UpdateCompanion<TaskListRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<int> sortOrder;
  final Value<bool> isInbox;
  final Value<bool> archived;
  final Value<bool> deleted;
  final Value<String?> deletedHlc;
  final Value<String?> restoredHlc;
  final Value<String> fieldClocks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TaskListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isInbox = const Value.absent(),
    this.archived = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskListsCompanion.insert({
    required String id,
    required String name,
    required int color,
    this.sortOrder = const Value.absent(),
    this.isInbox = const Value.absent(),
    this.archived = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskListRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? sortOrder,
    Expression<bool>? isInbox,
    Expression<bool>? archived,
    Expression<bool>? deleted,
    Expression<String>? deletedHlc,
    Expression<String>? restoredHlc,
    Expression<String>? fieldClocks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isInbox != null) 'is_inbox': isInbox,
      if (archived != null) 'archived': archived,
      if (deleted != null) 'deleted': deleted,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (restoredHlc != null) 'restored_hlc': restoredHlc,
      if (fieldClocks != null) 'field_clocks': fieldClocks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskListsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<int>? sortOrder,
    Value<bool>? isInbox,
    Value<bool>? archived,
    Value<bool>? deleted,
    Value<String?>? deletedHlc,
    Value<String?>? restoredHlc,
    Value<String>? fieldClocks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TaskListsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      isInbox: isInbox ?? this.isInbox,
      archived: archived ?? this.archived,
      deleted: deleted ?? this.deleted,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      restoredHlc: restoredHlc ?? this.restoredHlc,
      fieldClocks: fieldClocks ?? this.fieldClocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isInbox.present) {
      map['is_inbox'] = Variable<bool>(isInbox.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (restoredHlc.present) {
      map['restored_hlc'] = Variable<String>(restoredHlc.value);
    }
    if (fieldClocks.present) {
      map['field_clocks'] = Variable<String>(fieldClocks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isInbox: $isInbox, ')
          ..write('archived: $archived, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<String> listId = GeneratedColumn<String>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueHasTimeMeta = const VerificationMeta(
    'dueHasTime',
  );
  @override
  late final GeneratedColumn<bool> dueHasTime = GeneratedColumn<bool>(
    'due_has_time',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("due_has_time" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _recurrenceMeta = const VerificationMeta(
    'recurrence',
  );
  @override
  late final GeneratedColumn<String> recurrence = GeneratedColumn<String>(
    'recurrence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _reminderMeta = const VerificationMeta(
    'reminder',
  );
  @override
  late final GeneratedColumn<String> reminder = GeneratedColumn<String>(
    'reminder',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _reminderAtMeta = const VerificationMeta(
    'reminderAt',
  );
  @override
  late final GeneratedColumn<int> reminderAt = GeneratedColumn<int>(
    'reminder_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderFiredMeta = const VerificationMeta(
    'reminderFired',
  );
  @override
  late final GeneratedColumn<bool> reminderFired = GeneratedColumn<bool>(
    'reminder_fired',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reminder_fired" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredHlcMeta = const VerificationMeta(
    'restoredHlc',
  );
  @override
  late final GeneratedColumn<String> restoredHlc = GeneratedColumn<String>(
    'restored_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldClocksMeta = const VerificationMeta(
    'fieldClocks',
  );
  @override
  late final GeneratedColumn<String> fieldClocks = GeneratedColumn<String>(
    'field_clocks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    listId,
    title,
    notes,
    dueAt,
    dueHasTime,
    priority,
    recurrence,
    reminder,
    reminderAt,
    reminderFired,
    sortOrder,
    completedAt,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('due_has_time')) {
      context.handle(
        _dueHasTimeMeta,
        dueHasTime.isAcceptableOrUnknown(
          data['due_has_time']!,
          _dueHasTimeMeta,
        ),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('recurrence')) {
      context.handle(
        _recurrenceMeta,
        recurrence.isAcceptableOrUnknown(data['recurrence']!, _recurrenceMeta),
      );
    }
    if (data.containsKey('reminder')) {
      context.handle(
        _reminderMeta,
        reminder.isAcceptableOrUnknown(data['reminder']!, _reminderMeta),
      );
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
        _reminderAtMeta,
        reminderAt.isAcceptableOrUnknown(data['reminder_at']!, _reminderAtMeta),
      );
    }
    if (data.containsKey('reminder_fired')) {
      context.handle(
        _reminderFiredMeta,
        reminderFired.isAcceptableOrUnknown(
          data['reminder_fired']!,
          _reminderFiredMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    }
    if (data.containsKey('restored_hlc')) {
      context.handle(
        _restoredHlcMeta,
        restoredHlc.isAcceptableOrUnknown(
          data['restored_hlc']!,
          _restoredHlcMeta,
        ),
      );
    }
    if (data.containsKey('field_clocks')) {
      context.handle(
        _fieldClocksMeta,
        fieldClocks.isAcceptableOrUnknown(
          data['field_clocks']!,
          _fieldClocksMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}list_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      dueHasTime: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}due_has_time'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      recurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurrence'],
      )!,
      reminder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder'],
      )!,
      reminderAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_at'],
      ),
      reminderFired: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reminder_fired'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      ),
      restoredHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restored_hlc'],
      ),
      fieldClocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_clocks'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final String id;
  final String listId;
  final String title;
  final String notes;
  final int? dueAt;
  final bool dueHasTime;
  final int priority;
  final String recurrence;
  final String reminder;
  final int? reminderAt;
  final bool reminderFired;
  final int sortOrder;
  final int? completedAt;
  final bool deleted;
  final String? deletedHlc;
  final String? restoredHlc;
  final String fieldClocks;
  final int createdAt;
  final int updatedAt;
  const TaskRow({
    required this.id,
    required this.listId,
    required this.title,
    required this.notes,
    this.dueAt,
    required this.dueHasTime,
    required this.priority,
    required this.recurrence,
    required this.reminder,
    this.reminderAt,
    required this.reminderFired,
    required this.sortOrder,
    this.completedAt,
    required this.deleted,
    this.deletedHlc,
    this.restoredHlc,
    required this.fieldClocks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['list_id'] = Variable<String>(listId);
    map['title'] = Variable<String>(title);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['due_has_time'] = Variable<bool>(dueHasTime);
    map['priority'] = Variable<int>(priority);
    map['recurrence'] = Variable<String>(recurrence);
    map['reminder'] = Variable<String>(reminder);
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<int>(reminderAt);
    }
    map['reminder_fired'] = Variable<bool>(reminderFired);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deletedHlc != null) {
      map['deleted_hlc'] = Variable<String>(deletedHlc);
    }
    if (!nullToAbsent || restoredHlc != null) {
      map['restored_hlc'] = Variable<String>(restoredHlc);
    }
    map['field_clocks'] = Variable<String>(fieldClocks);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      listId: Value(listId),
      title: Value(title),
      notes: Value(notes),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      dueHasTime: Value(dueHasTime),
      priority: Value(priority),
      recurrence: Value(recurrence),
      reminder: Value(reminder),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      reminderFired: Value(reminderFired),
      sortOrder: Value(sortOrder),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      deleted: Value(deleted),
      deletedHlc: deletedHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedHlc),
      restoredHlc: restoredHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredHlc),
      fieldClocks: Value(fieldClocks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<String>(json['id']),
      listId: serializer.fromJson<String>(json['listId']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String>(json['notes']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      dueHasTime: serializer.fromJson<bool>(json['dueHasTime']),
      priority: serializer.fromJson<int>(json['priority']),
      recurrence: serializer.fromJson<String>(json['recurrence']),
      reminder: serializer.fromJson<String>(json['reminder']),
      reminderAt: serializer.fromJson<int?>(json['reminderAt']),
      reminderFired: serializer.fromJson<bool>(json['reminderFired']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deletedHlc: serializer.fromJson<String?>(json['deletedHlc']),
      restoredHlc: serializer.fromJson<String?>(json['restoredHlc']),
      fieldClocks: serializer.fromJson<String>(json['fieldClocks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listId': serializer.toJson<String>(listId),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String>(notes),
      'dueAt': serializer.toJson<int?>(dueAt),
      'dueHasTime': serializer.toJson<bool>(dueHasTime),
      'priority': serializer.toJson<int>(priority),
      'recurrence': serializer.toJson<String>(recurrence),
      'reminder': serializer.toJson<String>(reminder),
      'reminderAt': serializer.toJson<int?>(reminderAt),
      'reminderFired': serializer.toJson<bool>(reminderFired),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'completedAt': serializer.toJson<int?>(completedAt),
      'deleted': serializer.toJson<bool>(deleted),
      'deletedHlc': serializer.toJson<String?>(deletedHlc),
      'restoredHlc': serializer.toJson<String?>(restoredHlc),
      'fieldClocks': serializer.toJson<String>(fieldClocks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TaskRow copyWith({
    String? id,
    String? listId,
    String? title,
    String? notes,
    Value<int?> dueAt = const Value.absent(),
    bool? dueHasTime,
    int? priority,
    String? recurrence,
    String? reminder,
    Value<int?> reminderAt = const Value.absent(),
    bool? reminderFired,
    int? sortOrder,
    Value<int?> completedAt = const Value.absent(),
    bool? deleted,
    Value<String?> deletedHlc = const Value.absent(),
    Value<String?> restoredHlc = const Value.absent(),
    String? fieldClocks,
    int? createdAt,
    int? updatedAt,
  }) => TaskRow(
    id: id ?? this.id,
    listId: listId ?? this.listId,
    title: title ?? this.title,
    notes: notes ?? this.notes,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    dueHasTime: dueHasTime ?? this.dueHasTime,
    priority: priority ?? this.priority,
    recurrence: recurrence ?? this.recurrence,
    reminder: reminder ?? this.reminder,
    reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
    reminderFired: reminderFired ?? this.reminderFired,
    sortOrder: sortOrder ?? this.sortOrder,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    deleted: deleted ?? this.deleted,
    deletedHlc: deletedHlc.present ? deletedHlc.value : this.deletedHlc,
    restoredHlc: restoredHlc.present ? restoredHlc.value : this.restoredHlc,
    fieldClocks: fieldClocks ?? this.fieldClocks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskRow copyWithCompanion(TasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      listId: data.listId.present ? data.listId.value : this.listId,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      dueHasTime: data.dueHasTime.present
          ? data.dueHasTime.value
          : this.dueHasTime,
      priority: data.priority.present ? data.priority.value : this.priority,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      reminder: data.reminder.present ? data.reminder.value : this.reminder,
      reminderAt: data.reminderAt.present
          ? data.reminderAt.value
          : this.reminderAt,
      reminderFired: data.reminderFired.present
          ? data.reminderFired.value
          : this.reminderFired,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      restoredHlc: data.restoredHlc.present
          ? data.restoredHlc.value
          : this.restoredHlc,
      fieldClocks: data.fieldClocks.present
          ? data.fieldClocks.value
          : this.fieldClocks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('dueHasTime: $dueHasTime, ')
          ..write('priority: $priority, ')
          ..write('recurrence: $recurrence, ')
          ..write('reminder: $reminder, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('reminderFired: $reminderFired, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('completedAt: $completedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    listId,
    title,
    notes,
    dueAt,
    dueHasTime,
    priority,
    recurrence,
    reminder,
    reminderAt,
    reminderFired,
    sortOrder,
    completedAt,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.listId == this.listId &&
          other.title == this.title &&
          other.notes == this.notes &&
          other.dueAt == this.dueAt &&
          other.dueHasTime == this.dueHasTime &&
          other.priority == this.priority &&
          other.recurrence == this.recurrence &&
          other.reminder == this.reminder &&
          other.reminderAt == this.reminderAt &&
          other.reminderFired == this.reminderFired &&
          other.sortOrder == this.sortOrder &&
          other.completedAt == this.completedAt &&
          other.deleted == this.deleted &&
          other.deletedHlc == this.deletedHlc &&
          other.restoredHlc == this.restoredHlc &&
          other.fieldClocks == this.fieldClocks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<String> id;
  final Value<String> listId;
  final Value<String> title;
  final Value<String> notes;
  final Value<int?> dueAt;
  final Value<bool> dueHasTime;
  final Value<int> priority;
  final Value<String> recurrence;
  final Value<String> reminder;
  final Value<int?> reminderAt;
  final Value<bool> reminderFired;
  final Value<int> sortOrder;
  final Value<int?> completedAt;
  final Value<bool> deleted;
  final Value<String?> deletedHlc;
  final Value<String?> restoredHlc;
  final Value<String> fieldClocks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.listId = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.dueHasTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.reminder = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.reminderFired = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String listId,
    required String title,
    this.notes = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.dueHasTime = const Value.absent(),
    this.priority = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.reminder = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.reminderFired = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       listId = Value(listId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskRow> custom({
    Expression<String>? id,
    Expression<String>? listId,
    Expression<String>? title,
    Expression<String>? notes,
    Expression<int>? dueAt,
    Expression<bool>? dueHasTime,
    Expression<int>? priority,
    Expression<String>? recurrence,
    Expression<String>? reminder,
    Expression<int>? reminderAt,
    Expression<bool>? reminderFired,
    Expression<int>? sortOrder,
    Expression<int>? completedAt,
    Expression<bool>? deleted,
    Expression<String>? deletedHlc,
    Expression<String>? restoredHlc,
    Expression<String>? fieldClocks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listId != null) 'list_id': listId,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
      if (dueAt != null) 'due_at': dueAt,
      if (dueHasTime != null) 'due_has_time': dueHasTime,
      if (priority != null) 'priority': priority,
      if (recurrence != null) 'recurrence': recurrence,
      if (reminder != null) 'reminder': reminder,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (reminderFired != null) 'reminder_fired': reminderFired,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (completedAt != null) 'completed_at': completedAt,
      if (deleted != null) 'deleted': deleted,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (restoredHlc != null) 'restored_hlc': restoredHlc,
      if (fieldClocks != null) 'field_clocks': fieldClocks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith({
    Value<String>? id,
    Value<String>? listId,
    Value<String>? title,
    Value<String>? notes,
    Value<int?>? dueAt,
    Value<bool>? dueHasTime,
    Value<int>? priority,
    Value<String>? recurrence,
    Value<String>? reminder,
    Value<int?>? reminderAt,
    Value<bool>? reminderFired,
    Value<int>? sortOrder,
    Value<int?>? completedAt,
    Value<bool>? deleted,
    Value<String?>? deletedHlc,
    Value<String?>? restoredHlc,
    Value<String>? fieldClocks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueAt: dueAt ?? this.dueAt,
      dueHasTime: dueHasTime ?? this.dueHasTime,
      priority: priority ?? this.priority,
      recurrence: recurrence ?? this.recurrence,
      reminder: reminder ?? this.reminder,
      reminderAt: reminderAt ?? this.reminderAt,
      reminderFired: reminderFired ?? this.reminderFired,
      sortOrder: sortOrder ?? this.sortOrder,
      completedAt: completedAt ?? this.completedAt,
      deleted: deleted ?? this.deleted,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      restoredHlc: restoredHlc ?? this.restoredHlc,
      fieldClocks: fieldClocks ?? this.fieldClocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listId.present) {
      map['list_id'] = Variable<String>(listId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (dueHasTime.present) {
      map['due_has_time'] = Variable<bool>(dueHasTime.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(recurrence.value);
    }
    if (reminder.present) {
      map['reminder'] = Variable<String>(reminder.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<int>(reminderAt.value);
    }
    if (reminderFired.present) {
      map['reminder_fired'] = Variable<bool>(reminderFired.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (restoredHlc.present) {
      map['restored_hlc'] = Variable<String>(restoredHlc.value);
    }
    if (fieldClocks.present) {
      map['field_clocks'] = Variable<String>(fieldClocks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('listId: $listId, ')
          ..write('title: $title, ')
          ..write('notes: $notes, ')
          ..write('dueAt: $dueAt, ')
          ..write('dueHasTime: $dueHasTime, ')
          ..write('priority: $priority, ')
          ..write('recurrence: $recurrence, ')
          ..write('reminder: $reminder, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('reminderFired: $reminderFired, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('completedAt: $completedAt, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredHlcMeta = const VerificationMeta(
    'restoredHlc',
  );
  @override
  late final GeneratedColumn<String> restoredHlc = GeneratedColumn<String>(
    'restored_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldClocksMeta = const VerificationMeta(
    'fieldClocks',
  );
  @override
  late final GeneratedColumn<String> fieldClocks = GeneratedColumn<String>(
    'field_clocks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    }
    if (data.containsKey('restored_hlc')) {
      context.handle(
        _restoredHlcMeta,
        restoredHlc.isAcceptableOrUnknown(
          data['restored_hlc']!,
          _restoredHlcMeta,
        ),
      );
    }
    if (data.containsKey('field_clocks')) {
      context.handle(
        _fieldClocksMeta,
        fieldClocks.isAcceptableOrUnknown(
          data['field_clocks']!,
          _fieldClocksMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      ),
      restoredHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restored_hlc'],
      ),
      fieldClocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_clocks'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final int color;
  final bool deleted;
  final String? deletedHlc;
  final String? restoredHlc;
  final String fieldClocks;
  final int createdAt;
  final int updatedAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.color,
    required this.deleted,
    this.deletedHlc,
    this.restoredHlc,
    required this.fieldClocks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deletedHlc != null) {
      map['deleted_hlc'] = Variable<String>(deletedHlc);
    }
    if (!nullToAbsent || restoredHlc != null) {
      map['restored_hlc'] = Variable<String>(restoredHlc);
    }
    map['field_clocks'] = Variable<String>(fieldClocks);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      deleted: Value(deleted),
      deletedHlc: deletedHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedHlc),
      restoredHlc: restoredHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredHlc),
      fieldClocks: Value(fieldClocks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deletedHlc: serializer.fromJson<String?>(json['deletedHlc']),
      restoredHlc: serializer.fromJson<String?>(json['restoredHlc']),
      fieldClocks: serializer.fromJson<String>(json['fieldClocks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'deleted': serializer.toJson<bool>(deleted),
      'deletedHlc': serializer.toJson<String?>(deletedHlc),
      'restoredHlc': serializer.toJson<String?>(restoredHlc),
      'fieldClocks': serializer.toJson<String>(fieldClocks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    int? color,
    bool? deleted,
    Value<String?> deletedHlc = const Value.absent(),
    Value<String?> restoredHlc = const Value.absent(),
    String? fieldClocks,
    int? createdAt,
    int? updatedAt,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    deleted: deleted ?? this.deleted,
    deletedHlc: deletedHlc.present ? deletedHlc.value : this.deletedHlc,
    restoredHlc: restoredHlc.present ? restoredHlc.value : this.restoredHlc,
    fieldClocks: fieldClocks ?? this.fieldClocks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      restoredHlc: data.restoredHlc.present
          ? data.restoredHlc.value
          : this.restoredHlc,
      fieldClocks: data.fieldClocks.present
          ? data.fieldClocks.value
          : this.fieldClocks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.deleted == this.deleted &&
          other.deletedHlc == this.deletedHlc &&
          other.restoredHlc == this.restoredHlc &&
          other.fieldClocks == this.fieldClocks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<bool> deleted;
  final Value<String?> deletedHlc;
  final Value<String?> restoredHlc;
  final Value<String> fieldClocks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required int color,
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<bool>? deleted,
    Expression<String>? deletedHlc,
    Expression<String>? restoredHlc,
    Expression<String>? fieldClocks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (deleted != null) 'deleted': deleted,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (restoredHlc != null) 'restored_hlc': restoredHlc,
      if (fieldClocks != null) 'field_clocks': fieldClocks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<bool>? deleted,
    Value<String?>? deletedHlc,
    Value<String?>? restoredHlc,
    Value<String>? fieldClocks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      deleted: deleted ?? this.deleted,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      restoredHlc: restoredHlc ?? this.restoredHlc,
      fieldClocks: fieldClocks ?? this.fieldClocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (restoredHlc.present) {
      map['restored_hlc'] = Variable<String>(restoredHlc.value);
    }
    if (fieldClocks.present) {
      map['field_clocks'] = Variable<String>(fieldClocks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskTagsTable extends TaskTags
    with TableInfo<$TaskTagsTable, TaskTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredHlcMeta = const VerificationMeta(
    'restoredHlc',
  );
  @override
  late final GeneratedColumn<String> restoredHlc = GeneratedColumn<String>(
    'restored_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldClocksMeta = const VerificationMeta(
    'fieldClocks',
  );
  @override
  late final GeneratedColumn<String> fieldClocks = GeneratedColumn<String>(
    'field_clocks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    tagId,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    }
    if (data.containsKey('restored_hlc')) {
      context.handle(
        _restoredHlcMeta,
        restoredHlc.isAcceptableOrUnknown(
          data['restored_hlc']!,
          _restoredHlcMeta,
        ),
      );
    }
    if (data.containsKey('field_clocks')) {
      context.handle(
        _fieldClocksMeta,
        fieldClocks.isAcceptableOrUnknown(
          data['field_clocks']!,
          _fieldClocksMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      ),
      restoredHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restored_hlc'],
      ),
      fieldClocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_clocks'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TaskTagsTable createAlias(String alias) {
    return $TaskTagsTable(attachedDatabase, alias);
  }
}

class TaskTagRow extends DataClass implements Insertable<TaskTagRow> {
  final String id;
  final String taskId;
  final String tagId;
  final bool deleted;
  final String? deletedHlc;
  final String? restoredHlc;
  final String fieldClocks;
  final int createdAt;
  final int updatedAt;
  const TaskTagRow({
    required this.id,
    required this.taskId,
    required this.tagId,
    required this.deleted,
    this.deletedHlc,
    this.restoredHlc,
    required this.fieldClocks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['tag_id'] = Variable<String>(tagId);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deletedHlc != null) {
      map['deleted_hlc'] = Variable<String>(deletedHlc);
    }
    if (!nullToAbsent || restoredHlc != null) {
      map['restored_hlc'] = Variable<String>(restoredHlc);
    }
    map['field_clocks'] = Variable<String>(fieldClocks);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TaskTagsCompanion toCompanion(bool nullToAbsent) {
    return TaskTagsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      tagId: Value(tagId),
      deleted: Value(deleted),
      deletedHlc: deletedHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedHlc),
      restoredHlc: restoredHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredHlc),
      fieldClocks: Value(fieldClocks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TaskTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskTagRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deletedHlc: serializer.fromJson<String?>(json['deletedHlc']),
      restoredHlc: serializer.fromJson<String?>(json['restoredHlc']),
      fieldClocks: serializer.fromJson<String>(json['fieldClocks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'tagId': serializer.toJson<String>(tagId),
      'deleted': serializer.toJson<bool>(deleted),
      'deletedHlc': serializer.toJson<String?>(deletedHlc),
      'restoredHlc': serializer.toJson<String?>(restoredHlc),
      'fieldClocks': serializer.toJson<String>(fieldClocks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TaskTagRow copyWith({
    String? id,
    String? taskId,
    String? tagId,
    bool? deleted,
    Value<String?> deletedHlc = const Value.absent(),
    Value<String?> restoredHlc = const Value.absent(),
    String? fieldClocks,
    int? createdAt,
    int? updatedAt,
  }) => TaskTagRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    tagId: tagId ?? this.tagId,
    deleted: deleted ?? this.deleted,
    deletedHlc: deletedHlc.present ? deletedHlc.value : this.deletedHlc,
    restoredHlc: restoredHlc.present ? restoredHlc.value : this.restoredHlc,
    fieldClocks: fieldClocks ?? this.fieldClocks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TaskTagRow copyWithCompanion(TaskTagsCompanion data) {
    return TaskTagRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      restoredHlc: data.restoredHlc.present
          ? data.restoredHlc.value
          : this.restoredHlc,
      fieldClocks: data.fieldClocks.present
          ? data.fieldClocks.value
          : this.fieldClocks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    tagId,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskTagRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.tagId == this.tagId &&
          other.deleted == this.deleted &&
          other.deletedHlc == this.deletedHlc &&
          other.restoredHlc == this.restoredHlc &&
          other.fieldClocks == this.fieldClocks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TaskTagsCompanion extends UpdateCompanion<TaskTagRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> tagId;
  final Value<bool> deleted;
  final Value<String?> deletedHlc;
  final Value<String?> restoredHlc;
  final Value<String> fieldClocks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TaskTagsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskTagsCompanion.insert({
    required String id,
    required String taskId,
    required String tagId,
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       tagId = Value(tagId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TaskTagRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? tagId,
    Expression<bool>? deleted,
    Expression<String>? deletedHlc,
    Expression<String>? restoredHlc,
    Expression<String>? fieldClocks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (tagId != null) 'tag_id': tagId,
      if (deleted != null) 'deleted': deleted,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (restoredHlc != null) 'restored_hlc': restoredHlc,
      if (fieldClocks != null) 'field_clocks': fieldClocks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskTagsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? tagId,
    Value<bool>? deleted,
    Value<String?>? deletedHlc,
    Value<String?>? restoredHlc,
    Value<String>? fieldClocks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TaskTagsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      tagId: tagId ?? this.tagId,
      deleted: deleted ?? this.deleted,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      restoredHlc: restoredHlc ?? this.restoredHlc,
      fieldClocks: fieldClocks ?? this.fieldClocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (restoredHlc.present) {
      map['restored_hlc'] = Variable<String>(restoredHlc.value);
    }
    if (fieldClocks.present) {
      map['field_clocks'] = Variable<String>(fieldClocks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskTagsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('tagId: $tagId, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChecklistItemsTable extends ChecklistItems
    with TableInfo<$ChecklistItemsTable, ChecklistRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedHlcMeta = const VerificationMeta(
    'deletedHlc',
  );
  @override
  late final GeneratedColumn<String> deletedHlc = GeneratedColumn<String>(
    'deleted_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restoredHlcMeta = const VerificationMeta(
    'restoredHlc',
  );
  @override
  late final GeneratedColumn<String> restoredHlc = GeneratedColumn<String>(
    'restored_hlc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldClocksMeta = const VerificationMeta(
    'fieldClocks',
  );
  @override
  late final GeneratedColumn<String> fieldClocks = GeneratedColumn<String>(
    'field_clocks',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    title,
    done,
    sortOrder,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checklist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChecklistRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('deleted_hlc')) {
      context.handle(
        _deletedHlcMeta,
        deletedHlc.isAcceptableOrUnknown(data['deleted_hlc']!, _deletedHlcMeta),
      );
    }
    if (data.containsKey('restored_hlc')) {
      context.handle(
        _restoredHlcMeta,
        restoredHlc.isAcceptableOrUnknown(
          data['restored_hlc']!,
          _restoredHlcMeta,
        ),
      );
    }
    if (data.containsKey('field_clocks')) {
      context.handle(
        _fieldClocksMeta,
        fieldClocks.isAcceptableOrUnknown(
          data['field_clocks']!,
          _fieldClocksMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChecklistRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChecklistRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      deletedHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_hlc'],
      ),
      restoredHlc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}restored_hlc'],
      ),
      fieldClocks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_clocks'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChecklistItemsTable createAlias(String alias) {
    return $ChecklistItemsTable(attachedDatabase, alias);
  }
}

class ChecklistRow extends DataClass implements Insertable<ChecklistRow> {
  final String id;
  final String taskId;
  final String title;
  final bool done;
  final int sortOrder;
  final bool deleted;
  final String? deletedHlc;
  final String? restoredHlc;
  final String fieldClocks;
  final int createdAt;
  final int updatedAt;
  const ChecklistRow({
    required this.id,
    required this.taskId,
    required this.title,
    required this.done,
    required this.sortOrder,
    required this.deleted,
    this.deletedHlc,
    this.restoredHlc,
    required this.fieldClocks,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['task_id'] = Variable<String>(taskId);
    map['title'] = Variable<String>(title);
    map['done'] = Variable<bool>(done);
    map['sort_order'] = Variable<int>(sortOrder);
    map['deleted'] = Variable<bool>(deleted);
    if (!nullToAbsent || deletedHlc != null) {
      map['deleted_hlc'] = Variable<String>(deletedHlc);
    }
    if (!nullToAbsent || restoredHlc != null) {
      map['restored_hlc'] = Variable<String>(restoredHlc);
    }
    map['field_clocks'] = Variable<String>(fieldClocks);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return ChecklistItemsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      done: Value(done),
      sortOrder: Value(sortOrder),
      deleted: Value(deleted),
      deletedHlc: deletedHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedHlc),
      restoredHlc: restoredHlc == null && nullToAbsent
          ? const Value.absent()
          : Value(restoredHlc),
      fieldClocks: Value(fieldClocks),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChecklistRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChecklistRow(
      id: serializer.fromJson<String>(json['id']),
      taskId: serializer.fromJson<String>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      done: serializer.fromJson<bool>(json['done']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      deletedHlc: serializer.fromJson<String?>(json['deletedHlc']),
      restoredHlc: serializer.fromJson<String?>(json['restoredHlc']),
      fieldClocks: serializer.fromJson<String>(json['fieldClocks']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'taskId': serializer.toJson<String>(taskId),
      'title': serializer.toJson<String>(title),
      'done': serializer.toJson<bool>(done),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'deleted': serializer.toJson<bool>(deleted),
      'deletedHlc': serializer.toJson<String?>(deletedHlc),
      'restoredHlc': serializer.toJson<String?>(restoredHlc),
      'fieldClocks': serializer.toJson<String>(fieldClocks),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  ChecklistRow copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? done,
    int? sortOrder,
    bool? deleted,
    Value<String?> deletedHlc = const Value.absent(),
    Value<String?> restoredHlc = const Value.absent(),
    String? fieldClocks,
    int? createdAt,
    int? updatedAt,
  }) => ChecklistRow(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    done: done ?? this.done,
    sortOrder: sortOrder ?? this.sortOrder,
    deleted: deleted ?? this.deleted,
    deletedHlc: deletedHlc.present ? deletedHlc.value : this.deletedHlc,
    restoredHlc: restoredHlc.present ? restoredHlc.value : this.restoredHlc,
    fieldClocks: fieldClocks ?? this.fieldClocks,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChecklistRow copyWithCompanion(ChecklistItemsCompanion data) {
    return ChecklistRow(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      done: data.done.present ? data.done.value : this.done,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      deletedHlc: data.deletedHlc.present
          ? data.deletedHlc.value
          : this.deletedHlc,
      restoredHlc: data.restoredHlc.present
          ? data.restoredHlc.value
          : this.restoredHlc,
      fieldClocks: data.fieldClocks.present
          ? data.fieldClocks.value
          : this.fieldClocks,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistRow(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    title,
    done,
    sortOrder,
    deleted,
    deletedHlc,
    restoredHlc,
    fieldClocks,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChecklistRow &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.done == this.done &&
          other.sortOrder == this.sortOrder &&
          other.deleted == this.deleted &&
          other.deletedHlc == this.deletedHlc &&
          other.restoredHlc == this.restoredHlc &&
          other.fieldClocks == this.fieldClocks &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ChecklistItemsCompanion extends UpdateCompanion<ChecklistRow> {
  final Value<String> id;
  final Value<String> taskId;
  final Value<String> title;
  final Value<bool> done;
  final Value<int> sortOrder;
  final Value<bool> deleted;
  final Value<String?> deletedHlc;
  final Value<String?> restoredHlc;
  final Value<String> fieldClocks;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ChecklistItemsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChecklistItemsCompanion.insert({
    required String id,
    required String taskId,
    required String title,
    this.done = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.deleted = const Value.absent(),
    this.deletedHlc = const Value.absent(),
    this.restoredHlc = const Value.absent(),
    this.fieldClocks = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       taskId = Value(taskId),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ChecklistRow> custom({
    Expression<String>? id,
    Expression<String>? taskId,
    Expression<String>? title,
    Expression<bool>? done,
    Expression<int>? sortOrder,
    Expression<bool>? deleted,
    Expression<String>? deletedHlc,
    Expression<String>? restoredHlc,
    Expression<String>? fieldClocks,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (done != null) 'done': done,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (deleted != null) 'deleted': deleted,
      if (deletedHlc != null) 'deleted_hlc': deletedHlc,
      if (restoredHlc != null) 'restored_hlc': restoredHlc,
      if (fieldClocks != null) 'field_clocks': fieldClocks,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChecklistItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? taskId,
    Value<String>? title,
    Value<bool>? done,
    Value<int>? sortOrder,
    Value<bool>? deleted,
    Value<String?>? deletedHlc,
    Value<String?>? restoredHlc,
    Value<String>? fieldClocks,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChecklistItemsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      done: done ?? this.done,
      sortOrder: sortOrder ?? this.sortOrder,
      deleted: deleted ?? this.deleted,
      deletedHlc: deletedHlc ?? this.deletedHlc,
      restoredHlc: restoredHlc ?? this.restoredHlc,
      fieldClocks: fieldClocks ?? this.fieldClocks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (deletedHlc.present) {
      map['deleted_hlc'] = Variable<String>(deletedHlc.value);
    }
    if (restoredHlc.present) {
      map['restored_hlc'] = Variable<String>(restoredHlc.value);
    }
    if (fieldClocks.present) {
      map['field_clocks'] = Variable<String>(fieldClocks.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChecklistItemsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('done: $done, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('deleted: $deleted, ')
          ..write('deletedHlc: $deletedHlc, ')
          ..write('restoredHlc: $restoredHlc, ')
          ..write('fieldClocks: $fieldClocks, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxOpsTable extends OutboxOps
    with TableInfo<$OutboxOpsTable, OutboxRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxOpsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  @override
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    opId,
    entityType,
    entityId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {opId};
  @override
  OutboxRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxRow(
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxOpsTable createAlias(String alias) {
    return $OutboxOpsTable(attachedDatabase, alias);
  }
}

class OutboxRow extends DataClass implements Insertable<OutboxRow> {
  final String opId;
  final String entityType;
  final String entityId;
  final String payload;
  final int createdAt;
  const OutboxRow({
    required this.opId,
    required this.entityType,
    required this.entityId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['op_id'] = Variable<String>(opId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxOpsCompanion toCompanion(bool nullToAbsent) {
    return OutboxOpsCompanion(
      opId: Value(opId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxRow(
      opId: serializer.fromJson<String>(json['opId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'opId': serializer.toJson<String>(opId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxRow copyWith({
    String? opId,
    String? entityType,
    String? entityId,
    String? payload,
    int? createdAt,
  }) => OutboxRow(
    opId: opId ?? this.opId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxRow copyWithCompanion(OutboxOpsCompanion data) {
    return OutboxRow(
      opId: data.opId.present ? data.opId.value : this.opId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxRow(')
          ..write('opId: $opId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(opId, entityType, entityId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxRow &&
          other.opId == this.opId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class OutboxOpsCompanion extends UpdateCompanion<OutboxRow> {
  final Value<String> opId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OutboxOpsCompanion({
    this.opId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxOpsCompanion.insert({
    required String opId,
    required String entityType,
    required String entityId,
    required String payload,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : opId = Value(opId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<OutboxRow> custom({
    Expression<String>? opId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (opId != null) 'op_id': opId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxOpsCompanion copyWith({
    Value<String>? opId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? payload,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxOpsCompanion(
      opId: opId ?? this.opId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxOpsCompanion(')
          ..write('opId: $opId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String settingKey;
  final String value;
  const SettingRow({required this.settingKey, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(
      settingKey: Value(settingKey),
      value: Value(value),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? settingKey, String? value}) => SettingRow(
    settingKey: settingKey ?? this.settingKey,
    value: value ?? this.value,
  );
  SettingRow copyWithCompanion(SettingEntriesCompanion data) {
    return SettingRow(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.settingKey == this.settingKey &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> settingKey;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.settingKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String settingKey,
    required String value,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? settingKey,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
      settingKey: settingKey ?? this.settingKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TasDatabase extends GeneratedDatabase {
  _$TasDatabase(QueryExecutor e) : super(e);
  $TasDatabaseManager get managers => $TasDatabaseManager(this);
  late final $TaskListsTable taskLists = $TaskListsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaskTagsTable taskTags = $TaskTagsTable(this);
  late final $ChecklistItemsTable checklistItems = $ChecklistItemsTable(this);
  late final $OutboxOpsTable outboxOps = $OutboxOpsTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskLists,
    tasks,
    tags,
    taskTags,
    checklistItems,
    outboxOps,
    settingEntries,
  ];
}

typedef $$TaskListsTableCreateCompanionBuilder = TaskListsCompanion Function({
  required String id,
  required String name,
  required int color,
  Value<int> sortOrder,
  Value<bool> isInbox,
  Value<bool> archived,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TaskListsTableUpdateCompanionBuilder = TaskListsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> color,
  Value<int> sortOrder,
  Value<bool> isInbox,
  Value<bool> archived,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$TaskListsTableFilterComposer
    extends Composer<_$TasDatabase, $TaskListsTable> {
  $$TaskListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isInbox => $composableBuilder(
    column: $table.isInbox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskListsTableOrderingComposer
    extends Composer<_$TasDatabase, $TaskListsTable> {
  $$TaskListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isInbox => $composableBuilder(
    column: $table.isInbox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskListsTableAnnotationComposer
    extends Composer<_$TasDatabase, $TaskListsTable> {
  $$TaskListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isInbox =>
      $composableBuilder(column: $table.isInbox, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TaskListsTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $TaskListsTable,
          TaskListRow,
          $$TaskListsTableFilterComposer,
          $$TaskListsTableOrderingComposer,
          $$TaskListsTableAnnotationComposer,
          $$TaskListsTableCreateCompanionBuilder,
          $$TaskListsTableUpdateCompanionBuilder,
          (
            TaskListRow,
            BaseReferences<_$TasDatabase, $TaskListsTable, TaskListRow>,
          ),
          TaskListRow,
          PrefetchHooks Function()
        > {
  $$TaskListsTableTableManager(_$TasDatabase db, $TaskListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isInbox = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskListsCompanion(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                isInbox: isInbox,
                archived: archived,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isInbox = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskListsCompanion.insert(
                id: id,
                name: name,
                color: color,
                sortOrder: sortOrder,
                isInbox: isInbox,
                archived: archived,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskListsTable, TaskListRow>(table),
                  BaseReferences<_$TasDatabase, $TaskListsTable, TaskListRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskListsTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $TaskListsTable,
      TaskListRow,
      $$TaskListsTableFilterComposer,
      $$TaskListsTableOrderingComposer,
      $$TaskListsTableAnnotationComposer,
      $$TaskListsTableCreateCompanionBuilder,
      $$TaskListsTableUpdateCompanionBuilder,
      (
        TaskListRow,
        BaseReferences<_$TasDatabase, $TaskListsTable, TaskListRow>,
      ),
      TaskListRow,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String listId,
  required String title,
  Value<String> notes,
  Value<int?> dueAt,
  Value<bool> dueHasTime,
  Value<int> priority,
  Value<String> recurrence,
  Value<String> reminder,
  Value<int?> reminderAt,
  Value<bool> reminderFired,
  Value<int> sortOrder,
  Value<int?> completedAt,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> listId,
  Value<String> title,
  Value<String> notes,
  Value<int?> dueAt,
  Value<bool> dueHasTime,
  Value<int> priority,
  Value<String> recurrence,
  Value<String> reminder,
  Value<int?> reminderAt,
  Value<bool> reminderFired,
  Value<int> sortOrder,
  Value<int?> completedAt,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$TasDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reminderFired => $composableBuilder(
    column: $table.reminderFired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$TasDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get listId => $composableBuilder(
    column: $table.listId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminder => $composableBuilder(
    column: $table.reminder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reminderFired => $composableBuilder(
    column: $table.reminderFired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$TasDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get listId =>
      $composableBuilder(column: $table.listId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<bool> get dueHasTime => $composableBuilder(
    column: $table.dueHasTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reminder =>
      $composableBuilder(column: $table.reminder, builder: (column) => column);

  GeneratedColumn<int> get reminderAt => $composableBuilder(
    column: $table.reminderAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reminderFired => $composableBuilder(
    column: $table.reminderFired,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $TasksTable,
          TaskRow,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (TaskRow, BaseReferences<_$TasDatabase, $TasksTable, TaskRow>),
          TaskRow,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$TasDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> listId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<bool> dueHasTime = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String> reminder = const Value.absent(),
                Value<int?> reminderAt = const Value.absent(),
                Value<bool> reminderFired = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                listId: listId,
                title: title,
                notes: notes,
                dueAt: dueAt,
                dueHasTime: dueHasTime,
                priority: priority,
                recurrence: recurrence,
                reminder: reminder,
                reminderAt: reminderAt,
                reminderFired: reminderFired,
                sortOrder: sortOrder,
                completedAt: completedAt,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String listId,
                required String title,
                Value<String> notes = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<bool> dueHasTime = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<String> recurrence = const Value.absent(),
                Value<String> reminder = const Value.absent(),
                Value<int?> reminderAt = const Value.absent(),
                Value<bool> reminderFired = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                listId: listId,
                title: title,
                notes: notes,
                dueAt: dueAt,
                dueHasTime: dueHasTime,
                priority: priority,
                recurrence: recurrence,
                reminder: reminder,
                reminderAt: reminderAt,
                reminderFired: reminderFired,
                sortOrder: sortOrder,
                completedAt: completedAt,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, TaskRow>(table),
                  BaseReferences<_$TasDatabase, $TasksTable, TaskRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $TasksTable,
      TaskRow,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (TaskRow, BaseReferences<_$TasDatabase, $TasksTable, TaskRow>),
      TaskRow,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  required int color,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> color,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$TasDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$TasDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$TasDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, BaseReferences<_$TasDatabase, $TagsTable, TagRow>),
          TagRow,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$TasDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                color: color,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  BaseReferences<_$TasDatabase, $TagsTable, TagRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, BaseReferences<_$TasDatabase, $TagsTable, TagRow>),
      TagRow,
      PrefetchHooks Function()
    >;
typedef $$TaskTagsTableCreateCompanionBuilder = TaskTagsCompanion Function({
  required String id,
  required String taskId,
  required String tagId,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$TaskTagsTableUpdateCompanionBuilder = TaskTagsCompanion Function({
  Value<String> id,
  Value<String> taskId,
  Value<String> tagId,
  Value<bool> deleted,
  Value<String?> deletedHlc,
  Value<String?> restoredHlc,
  Value<String> fieldClocks,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$TaskTagsTableFilterComposer
    extends Composer<_$TasDatabase, $TaskTagsTable> {
  $$TaskTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskTagsTableOrderingComposer
    extends Composer<_$TasDatabase, $TaskTagsTable> {
  $$TaskTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskTagsTableAnnotationComposer
    extends Composer<_$TasDatabase, $TaskTagsTable> {
  $$TaskTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TaskTagsTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $TaskTagsTable,
          TaskTagRow,
          $$TaskTagsTableFilterComposer,
          $$TaskTagsTableOrderingComposer,
          $$TaskTagsTableAnnotationComposer,
          $$TaskTagsTableCreateCompanionBuilder,
          $$TaskTagsTableUpdateCompanionBuilder,
          (
            TaskTagRow,
            BaseReferences<_$TasDatabase, $TaskTagsTable, TaskTagRow>,
          ),
          TaskTagRow,
          PrefetchHooks Function()
        > {
  $$TaskTagsTableTableManager(_$TasDatabase db, $TaskTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskTagsCompanion(
                id: id,
                taskId: taskId,
                tagId: tagId,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String tagId,
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TaskTagsCompanion.insert(
                id: id,
                taskId: taskId,
                tagId: tagId,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskTagsTable, TaskTagRow>(table),
                  BaseReferences<_$TasDatabase, $TaskTagsTable, TaskTagRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $TaskTagsTable,
      TaskTagRow,
      $$TaskTagsTableFilterComposer,
      $$TaskTagsTableOrderingComposer,
      $$TaskTagsTableAnnotationComposer,
      $$TaskTagsTableCreateCompanionBuilder,
      $$TaskTagsTableUpdateCompanionBuilder,
      (TaskTagRow, BaseReferences<_$TasDatabase, $TaskTagsTable, TaskTagRow>),
      TaskTagRow,
      PrefetchHooks Function()
    >;
typedef $$ChecklistItemsTableCreateCompanionBuilder =
    ChecklistItemsCompanion Function({
      required String id,
      required String taskId,
      required String title,
      Value<bool> done,
      Value<int> sortOrder,
      Value<bool> deleted,
      Value<String?> deletedHlc,
      Value<String?> restoredHlc,
      Value<String> fieldClocks,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ChecklistItemsTableUpdateCompanionBuilder =
    ChecklistItemsCompanion Function({
      Value<String> id,
      Value<String> taskId,
      Value<String> title,
      Value<bool> done,
      Value<int> sortOrder,
      Value<bool> deleted,
      Value<String?> deletedHlc,
      Value<String?> restoredHlc,
      Value<String> fieldClocks,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ChecklistItemsTableFilterComposer
    extends Composer<_$TasDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChecklistItemsTableOrderingComposer
    extends Composer<_$TasDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChecklistItemsTableAnnotationComposer
    extends Composer<_$TasDatabase, $ChecklistItemsTable> {
  $$ChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get deletedHlc => $composableBuilder(
    column: $table.deletedHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get restoredHlc => $composableBuilder(
    column: $table.restoredHlc,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fieldClocks => $composableBuilder(
    column: $table.fieldClocks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChecklistItemsTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $ChecklistItemsTable,
          ChecklistRow,
          $$ChecklistItemsTableFilterComposer,
          $$ChecklistItemsTableOrderingComposer,
          $$ChecklistItemsTableAnnotationComposer,
          $$ChecklistItemsTableCreateCompanionBuilder,
          $$ChecklistItemsTableUpdateCompanionBuilder,
          (
            ChecklistRow,
            BaseReferences<_$TasDatabase, $ChecklistItemsTable, ChecklistRow>,
          ),
          ChecklistRow,
          PrefetchHooks Function()
        > {
  $$ChecklistItemsTableTableManager(
    _$TasDatabase db,
    $ChecklistItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChecklistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChecklistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChecklistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChecklistItemsCompanion(
                id: id,
                taskId: taskId,
                title: title,
                done: done,
                sortOrder: sortOrder,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String taskId,
                required String title,
                Value<bool> done = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String?> deletedHlc = const Value.absent(),
                Value<String?> restoredHlc = const Value.absent(),
                Value<String> fieldClocks = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChecklistItemsCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                done: done,
                sortOrder: sortOrder,
                deleted: deleted,
                deletedHlc: deletedHlc,
                restoredHlc: restoredHlc,
                fieldClocks: fieldClocks,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChecklistItemsTable, ChecklistRow>(table),
                  BaseReferences<
                    _$TasDatabase,
                    $ChecklistItemsTable,
                    ChecklistRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChecklistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $ChecklistItemsTable,
      ChecklistRow,
      $$ChecklistItemsTableFilterComposer,
      $$ChecklistItemsTableOrderingComposer,
      $$ChecklistItemsTableAnnotationComposer,
      $$ChecklistItemsTableCreateCompanionBuilder,
      $$ChecklistItemsTableUpdateCompanionBuilder,
      (
        ChecklistRow,
        BaseReferences<_$TasDatabase, $ChecklistItemsTable, ChecklistRow>,
      ),
      ChecklistRow,
      PrefetchHooks Function()
    >;
typedef $$OutboxOpsTableCreateCompanionBuilder = OutboxOpsCompanion Function({
  required String opId,
  required String entityType,
  required String entityId,
  required String payload,
  required int createdAt,
  Value<int> rowid,
});
typedef $$OutboxOpsTableUpdateCompanionBuilder = OutboxOpsCompanion Function({
  Value<String> opId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> payload,
  Value<int> createdAt,
  Value<int> rowid,
});

class $$OutboxOpsTableFilterComposer
    extends Composer<_$TasDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxOpsTableOrderingComposer
    extends Composer<_$TasDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxOpsTableAnnotationComposer
    extends Composer<_$TasDatabase, $OutboxOpsTable> {
  $$OutboxOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxOpsTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $OutboxOpsTable,
          OutboxRow,
          $$OutboxOpsTableFilterComposer,
          $$OutboxOpsTableOrderingComposer,
          $$OutboxOpsTableAnnotationComposer,
          $$OutboxOpsTableCreateCompanionBuilder,
          $$OutboxOpsTableUpdateCompanionBuilder,
          (
            OutboxRow,
            BaseReferences<_$TasDatabase, $OutboxOpsTable, OutboxRow>,
          ),
          OutboxRow,
          PrefetchHooks Function()
        > {
  $$OutboxOpsTableTableManager(_$TasDatabase db, $OutboxOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> opId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion(
                opId: opId,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String opId,
                required String entityType,
                required String entityId,
                required String payload,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxOpsCompanion.insert(
                opId: opId,
                entityType: entityType,
                entityId: entityId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxOpsTable, OutboxRow>(table),
                  BaseReferences<_$TasDatabase, $OutboxOpsTable, OutboxRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $OutboxOpsTable,
      OutboxRow,
      $$OutboxOpsTableFilterComposer,
      $$OutboxOpsTableOrderingComposer,
      $$OutboxOpsTableAnnotationComposer,
      $$OutboxOpsTableCreateCompanionBuilder,
      $$OutboxOpsTableUpdateCompanionBuilder,
      (OutboxRow, BaseReferences<_$TasDatabase, $OutboxOpsTable, OutboxRow>),
      OutboxRow,
      PrefetchHooks Function()
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String settingKey,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> settingKey,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$TasDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$TasDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$TasDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$TasDatabase,
          $SettingEntriesTable,
          SettingRow,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$TasDatabase, $SettingEntriesTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$TasDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion(
                settingKey: settingKey,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                settingKey: settingKey,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingRow>(table),
                  BaseReferences<
                    _$TasDatabase,
                    $SettingEntriesTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$TasDatabase,
      $SettingEntriesTable,
      SettingRow,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$TasDatabase, $SettingEntriesTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;

class $TasDatabaseManager {
  final _$TasDatabase _db;
  $TasDatabaseManager(this._db);
  $$TaskListsTableTableManager get taskLists =>
      $$TaskListsTableTableManager(_db, _db.taskLists);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaskTagsTableTableManager get taskTags =>
      $$TaskTagsTableTableManager(_db, _db.taskTags);
  $$ChecklistItemsTableTableManager get checklistItems =>
      $$ChecklistItemsTableTableManager(_db, _db.checklistItems);
  $$OutboxOpsTableTableManager get outboxOps =>
      $$OutboxOpsTableTableManager(_db, _db.outboxOps);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
}
