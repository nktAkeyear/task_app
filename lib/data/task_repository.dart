import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../domain/date_phrase.dart';
import '../domain/filters.dart';
import '../domain/hlc.dart';
import '../domain/models.dart';
import '../domain/recurrence.dart';
import '../sync/protocol.dart';
import '../sync/sync_client.dart';
import 'local_tools.dart';
import 'tas_database.dart';

class _Mutex {
  Future<void> _tail = Future<void>.value();

  Future<T> run<T>(Future<T> Function() action) {
    final previous = _tail;
    final done = Completer<void>();
    _tail = done.future;
    return previous.then((_) => action()).whenComplete(done.complete);
  }
}

class _Undo {
  _Undo(this.apply);
  final Future<void> Function() apply;
}

class TaskRepository extends ChangeNotifier {
  TaskRepository(
    this.db, {
    String? deviceId,
    DateTime Function()? now,
    SyncClient? syncClient,
  }) : _deviceOverride = deviceId,
       _now = now ?? DateTime.now,
       _sync = syncClient ?? SyncClient() {
    _clock = HlcClock(_deviceOverride ?? 'boot', now: _now);
    tools = LocalTools(db, now: _now, onChanged: notifyListeners);
  }

  late final LocalTools tools;

  final TasDatabase db;
  final String? _deviceOverride;
  final DateTime Function() _now;
  final SyncClient _sync;
  final _mutex = _Mutex();
  final _uuid = const Uuid();

  late HlcClock _clock;
  _Undo? _undo;
  bool _flushing = false;

  bool ready = false;
  List<ListModel> lists = const [];
  List<TaskModel> tasks = const [];
  List<TagModel> tags = const [];
  List<ChecklistModel> checklist = const [];
  List<TaskTagModel> taskTags = const [];
  ThemeMode themeMode = ThemeMode.system;
  String deviceId = '';
  String deviceName = 'この端末';
  String syncBaseUrl = '';
  String syncMessage = '同期先は未設定です。データはこの端末に保存されます。';
  int syncCursor = 0;
  int outboxCount = 0;

  List<ListModel> get userLists {
    final rows = lists.where((list) => !list.deleted && !list.isInbox && !list.archived).toList();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return rows;
  }

  List<ListModel> get archivedLists {
    final rows = lists.where((list) => !list.deleted && !list.isInbox && list.archived).toList();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return rows;
  }

  TaskModel? taskById(String id) {
    for (final task in tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  ListModel? listById(String id) {
    for (final list in lists) {
      if (list.id == id) {
        return list;
      }
    }
    return null;
  }

  List<TagModel> tagsFor(String taskId) {
    final ids = taskTags.where((link) => link.taskId == taskId && !link.deleted).map((link) => link.tagId).toSet();
    final rows = tags.where((tag) => ids.contains(tag.id) && !tag.deleted).toList();
    rows.sort((a, b) => a.name.compareTo(b.name));
    return rows;
  }

  List<ChecklistModel> checklistFor(String taskId) {
    final rows = checklist.where((item) => item.taskId == taskId && !item.deleted).toList();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return rows;
  }

  List<TaskModel> tasksFor({
    required TaskBoard board,
    String? listId,
    DateTime? day,
    String query = '',
  }) {
    return filterTasks(
      tasks: tasks,
      board: board,
      listId: listId,
      day: day,
      query: query,
      now: _now(),
    );
  }

  List<TaskModel> pendingReminders([DateTime? now]) {
    final clock = now ?? _now();
    return tasks.where((task) {
      final at = task.reminderAt;
      return !task.deleted && !task.isCompleted && !task.reminderFired && at != null && !at.isAfter(clock);
    }).toList();
  }

  Future<void> init() {
    return _mutex.run(() async {
      await db.transaction(() async {
        await _loadIdentity();
        await _ensureInbox();
        await _saveClock();
      });
      await _reload();
      await tools.load();
      ready = true;
      if (syncBaseUrl.isEmpty) {
        syncMessage = '同期先は未設定です。データはこの端末に保存されます。';
      }
      notifyListeners();
    });
  }

  Future<String> quickAdd(
    String raw, {
    required TaskBoard board,
    String? listId,
    DateTime? day,
  }) {
    final parsed = parseQuickAdd(raw, now: _now());
    if (raw.trim().isEmpty || parsed.title.isEmpty) {
      return Future.error(const FormatException('タスク名を入力してください。'));
    }
    return _commit(() async {
      var due = parsed.due;
      var hasTime = parsed.hasTime;
      if (due == null && board == TaskBoard.today) {
        due = startOfDay(_now());
        hasTime = false;
      } else if (due == null && board == TaskBoard.upcoming) {
        due = startOfDay(_now()).add(const Duration(days: 1));
        hasTime = false;
      } else if (due == null && board == TaskBoard.calendar && day != null) {
        due = startOfDay(day);
        hasTime = false;
      }
      final targetList = board == TaskBoard.list && listId != null ? listId : inboxId;
      return _insertTask(
        listId: targetList,
        title: parsed.title,
        due: due,
        hasTime: hasTime && due != null,
      );
    });
  }

  Future<String> createTask({
    required String title,
    required String listId,
    String notes = '',
    DateTime? due,
    bool hasTime = false,
    int priority = 0,
  }) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future.error(const FormatException('タスク名を入力してください。'));
    }
    return _commit(
      () => _insertTask(
        listId: listId,
        title: trimmed,
        notes: notes.trim(),
        due: due,
        hasTime: hasTime && due != null,
        priority: priority,
      ),
    );
  }

  Future<void> setTitle(String id, String title) {
    final trimmed = title.trim().isEmpty ? '無題' : title.trim();
    return _commit(() => _writeTaskFields(id, {'title': trimmed}));
  }

  Future<void> setNotes(String id, String notes) {
    return _commit(() => _writeTaskFields(id, {'notes': notes}));
  }

  Future<void> setDue(String id, DateTime? due, {required bool hasTime}) {
    return _commit(
      () => _writeTaskFields(id, {
        'dueAt': due?.millisecondsSinceEpoch,
        'dueHasTime': due != null && hasTime,
      }),
    );
  }

  Future<void> setPriority(String id, int priority) {
    return _commit(() => _writeTaskFields(id, {'priority': priority.clamp(0, 3)}));
  }

  Future<void> setRecurrence(String id, String recurrence) {
    return _commit(() async {
      final row = await _task(id);
      if (row == null) {
        return;
      }
      final changes = <String, Object?>{'recurrence': recurrence};
      if (recurrence != recurrenceNone && row.dueAt == null) {
        changes['dueAt'] = startOfDay(_now()).millisecondsSinceEpoch;
        changes['dueHasTime'] = false;
      }
      await _writeTaskFields(id, changes);
    });
  }

  Future<void> setReminder(String id, String reminder) {
    return _commit(() async {
      final row = await _task(id);
      if (row == null) {
        return;
      }
      final changes = <String, Object?>{'reminder': reminder};
      if (reminder != reminderNone && row.dueAt == null) {
        changes['dueAt'] = startOfDay(_now()).millisecondsSinceEpoch;
        changes['dueHasTime'] = false;
      }
      await _writeTaskFields(id, changes);
    });
  }

  Future<void> moveToList(String id, String listId) {
    return _commit(() => _writeTaskFields(id, {'listId': listId}));
  }

  Future<String> toggleComplete(String id) {
    return _commit(() async {
      final row = await _task(id);
      if (row == null || row.deleted) {
        return 'タスクが見つかりません';
      }
      if (row.completedAt != null) {
        final previous = row.completedAt;
        await _writeTaskFields(id, {'completedAt': null});
        _undo = _Undo(() => _commit(() => _writeTaskFields(id, {'completedAt': previous})));
        return '未完了に戻しました';
      }
      if (row.recurrence != recurrenceNone && row.dueAt != null) {
        final cloneId = await _cloneCompleted(row);
        final next = nextOccurrenceAfter(
          from: DateTime.fromMillisecondsSinceEpoch(row.dueAt!),
          recurrence: row.recurrence,
          notBefore: _now(),
        );
        final previousDue = row.dueAt;
        final previousHasTime = row.dueHasTime;
        final previousReminder = row.reminder;
        await _writeTaskFields(id, {
          'dueAt': next.millisecondsSinceEpoch,
          'dueHasTime': row.dueHasTime,
        });
        _undo = _Undo(
          () => _commit(() async {
            await _tombstone(entityTask, cloneId, await _task(cloneId));
            await _writeTaskFields(id, {
              'dueAt': previousDue,
              'dueHasTime': previousHasTime,
              'reminder': previousReminder,
            });
          }),
        );
        return 'この回を完了し、次の予定を作りました';
      }
      final completedAt = _now().millisecondsSinceEpoch;
      await _writeTaskFields(id, {'completedAt': completedAt});
      _undo = _Undo(() => _commit(() => _writeTaskFields(id, {'completedAt': null})));
      return '完了にしました';
    });
  }

  Future<String> deleteTask(String id) {
    return _commit(() async {
      final row = await _task(id);
      if (row == null || row.deleted) {
        return 'タスクが見つかりません';
      }
      await _tombstone(entityTask, id, row);
      _undo = _Undo(() => _commit(() => _restore(entityTask, id)));
      return '削除しました';
    });
  }

  Future<void> undo() async {
    final action = _undo;
    _undo = null;
    if (action != null) {
      await action.apply();
    }
  }

  Future<void> reorderTasks(List<String> ids) {
    return _commit(() async {
      final stamp = _clock.tick();
      for (var index = 0; index < ids.length; index++) {
        await _writeTaskFields(ids[index], {'sortOrder': (index + 1) * 1024}, stamp: stamp);
      }
    });
  }

  Future<String> createList(String name, {int? color}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.error(const FormatException('名前を入力してください。'));
    }
    return _commit(() async {
      final id = _uuid.v4();
      final hlc = _clock.tick();
      final now = _now().millisecondsSinceEpoch;
      final existing = await db.select(db.taskLists).get();
      final sort = existing.fold<int>(0, (max, row) => row.sortOrder > max ? row.sortOrder : max) + 1024;
      final chosen = color ?? listColors[existing.length % listColors.length];
      final values = <String, Object?>{
        'name': trimmed,
        'color': chosen,
        'sortOrder': sort,
        'isInbox': false,
        'archived': false,
      };
      await db.into(db.taskLists).insert(
        TaskListsCompanion(
          id: Value(id),
          name: Value(trimmed),
          color: Value(chosen),
          sortOrder: Value(sort),
          isInbox: const Value(false),
          archived: const Value(false),
          deleted: const Value(false),
          fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await _enqueue(type: entityList, id: id, values: values, hlc: hlc);
      return id;
    });
  }

  Future<void> renameList(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || id == inboxId) {
      return Future<void>.value();
    }
    return _commit(() => _writeListFields(id, {'name': trimmed}));
  }

  Future<void> recolorList(String id, int color) {
    return _commit(() => _writeListFields(id, {'color': color}));
  }

  Future<void> setListArchived(String id, bool archived) {
    if (id == inboxId) {
      return Future<void>.value();
    }
    return _commit(() => _writeListFields(id, {'archived': archived}));
  }

  Future<String> deleteList(String id) {
    if (id == inboxId) {
      return Future<String>.value('受信箱は削除できません。');
    }
    return _commit(() async {
      final rows = await (db.select(db.tasks)..where((row) => row.listId.equals(id) & row.deleted.equals(false))).get();
      for (final row in rows) {
        await _writeTaskFields(row.id, {'listId': inboxId});
      }
      final list = await _list(id);
      await _tombstone(entityList, id, list);
      return 'リストを削除し、タスクを受信箱へ移しました。';
    });
  }

  Future<void> reorderLists(List<String> ids) {
    return _commit(() async {
      final stamp = _clock.tick();
      for (var index = 0; index < ids.length; index++) {
        await _writeListFields(ids[index], {'sortOrder': (index + 1) * 1024}, stamp: stamp);
      }
    });
  }

  Future<String> createTag(String name, {int? color}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future.error(const FormatException('タグ名を入力してください。'));
    }
    return _commit(() async {
      final id = _uuid.v4();
      final hlc = _clock.tick();
      final now = _now().millisecondsSinceEpoch;
      final existing = await db.select(db.tags).get();
      final chosen = color ?? listColors[(existing.length + 3) % listColors.length];
      final values = <String, Object?>{'name': trimmed, 'color': chosen};
      await db.into(db.tags).insert(
        TagsCompanion(
          id: Value(id),
          name: Value(trimmed),
          color: Value(chosen),
          deleted: const Value(false),
          fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await _enqueue(type: entityTag, id: id, values: values, hlc: hlc);
      return id;
    });
  }

  Future<void> renameTag(String id, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return Future<void>.value();
    }
    return _commit(() => _writeTagFields(id, {'name': trimmed}));
  }

  Future<void> deleteTag(String id) {
    return _commit(() async {
      final row = await _tag(id);
      await _tombstone(entityTag, id, row);
      final links = await (db.select(db.taskTags)..where((link) => link.tagId.equals(id) & link.deleted.equals(false))).get();
      for (final link in links) {
        await _tombstone(entityTaskTag, link.id, link);
      }
    });
  }

  Future<void> toggleTag(String taskId, String tagId) {
    final id = '$taskId:$tagId';
    return _commit(() async {
      final row = await _taskTag(id);
      if (row == null) {
        await _insertTaskTag(id, taskId, tagId);
        return;
      }
      final entity = _taskTagToEntity(row);
      if (entity.isDeleted) {
        await _restore(entityTaskTag, id);
      } else {
        await _tombstone(entityTaskTag, id, row);
      }
    });
  }

  Future<void> addChecklistItem(String taskId, String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future<void>.value();
    }
    return _commit(() async {
      final id = _uuid.v4();
      final hlc = _clock.tick();
      final now = _now().millisecondsSinceEpoch;
      final existing = await (db.select(db.checklistItems)..where((row) => row.taskId.equals(taskId))).get();
      final sort = existing.fold<int>(0, (max, row) => row.sortOrder > max ? row.sortOrder : max) + 1024;
      final values = <String, Object?>{
        'taskId': taskId,
        'title': trimmed,
        'done': false,
        'sortOrder': sort,
      };
      await db.into(db.checklistItems).insert(
        ChecklistItemsCompanion(
          id: Value(id),
          taskId: Value(taskId),
          title: Value(trimmed),
          done: const Value(false),
          sortOrder: Value(sort),
          deleted: const Value(false),
          fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      await _enqueue(type: entityChecklist, id: id, values: values, hlc: hlc);
    });
  }

  Future<void> toggleChecklistItem(String id) {
    return _commit(() async {
      final row = await _checklist(id);
      if (row == null) {
        return;
      }
      await _writeChecklistFields(id, {'done': !row.done});
    });
  }

  Future<void> renameChecklistItem(String id, String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      return Future<void>.value();
    }
    return _commit(() => _writeChecklistFields(id, {'title': trimmed}));
  }

  Future<void> deleteChecklistItem(String id) {
    return _commit(() async {
      final row = await _checklist(id);
      await _tombstone(entityChecklist, id, row);
    });
  }

  Future<void> setTheme(ThemeMode mode) {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _commit(() => _setSetting('theme', value));
  }

  Future<void> setDeviceName(String name) {
    final trimmed = name.trim().isEmpty ? 'この端末' : name.trim();
    return _commit(() => _setSetting('deviceName', trimmed));
  }

  Future<String?> setSyncUrl(String raw) async {
    final error = validateSyncUrl(raw);
    if (error != null) {
      return error;
    }
    await _commit(() => _setSetting('syncBaseUrl', raw.trim()));
    await flushSync();
    return null;
  }

  Future<void> flushSync() async {
    if (_flushing) {
      return;
    }
    _flushing = true;
    try {
      if (syncBaseUrl.trim().isEmpty) {
        _setMessage('同期先は未設定です。データはこの端末に保存されます。');
        return;
      }
      final snapshot = await _mutex.run(() async {
        return (cursor: syncCursor, ops: await _readOps());
      });
      final result = await _sync.exchange(
        baseUrl: syncBaseUrl.trim(),
        deviceId: deviceId,
        cursor: snapshot.cursor,
        ops: snapshot.ops,
      );
      await _mutex.run(() async {
        await db.transaction(() async {
          for (final op in result.ops) {
            await _applyOp(op);
          }
          if (result.acked.isNotEmpty) {
            await (db.delete(db.outboxOps)..where((row) => row.opId.isIn(result.acked))).go();
          }
          await _setSetting('syncCursor', '${result.cursor}');
          await _saveClock();
        });
        await _reload();
      });
      _setMessage('同期しました', force: true);
    } catch (_) {
      _setMessage('同期できませんでした。データはこの端末に残っています。');
    } finally {
      _flushing = false;
    }
  }

  Future<void> markRemindersFired(Iterable<String> ids) {
    return _commit(() async {
      final now = _now().millisecondsSinceEpoch;
      for (final id in ids) {
        await (db.update(db.tasks)..where((row) => row.id.equals(id))).write(
          TasksCompanion(reminderFired: const Value(true), updatedAt: Value(now)),
        );
      }
    });
  }

  Future<String> exportJson() {
    return _mutex.run(() async {
      final entities = <SyncEntity>[];
      for (final row in await db.select(db.taskLists).get()) {
        entities.add(_listToEntity(row));
      }
      for (final row in await db.select(db.tasks).get()) {
        entities.add(_taskToEntity(row));
      }
      for (final row in await db.select(db.tags).get()) {
        entities.add(_tagToEntity(row));
      }
      for (final row in await db.select(db.taskTags).get()) {
        entities.add(_taskTagToEntity(row));
      }
      for (final row in await db.select(db.checklistItems).get()) {
        entities.add(_checklistToEntity(row));
      }
      return const JsonEncoder.withIndent('  ').convert({
        'format': 'tas.backup',
        'version': 1,
        'exportedAt': _now().toUtc().toIso8601String(),
        'entities': entities.map((entity) => entity.toJson()).toList(),
      });
    });
  }

  Future<void> importJson(String raw) async {
    final decoded = jsonDecode(raw);
    if (decoded is! Map || decoded['format'] != 'tas.backup' || decoded['version'] != 1) {
      throw const FormatException('バックアップの形式を確認してください。');
    }
    final rawEntities = decoded['entities'];
    if (rawEntities is! List) {
      throw const FormatException('バックアップの形式を確認してください。');
    }
    final entities = <SyncEntity>[];
    for (final item in rawEntities) {
      if (item is Map) {
        entities.add(SyncEntity.fromJson(item.map((key, value) => MapEntry(key.toString(), value))));
      }
    }
    await _commit(() async {
      for (final remote in entities) {
        for (final field in remote.fields.values) {
          _clock.observe(field.hlc);
        }
        if (remote.deletedHlc != null) {
          _clock.observe(remote.deletedHlc!);
        }
        if (remote.restoredHlc != null) {
          _clock.observe(remote.restoredHlc!);
        }
        final local = await _entityOf(remote.type, remote.id);
        final merged = mergeEntities(local, remote);
        await _writeEntity(merged);
        if (jsonEncode(local.toJson()) != jsonEncode(merged.toJson())) {
          await _enqueue(
            type: merged.type,
            id: merged.id,
            values: {for (final entry in merged.fields.entries) entry.key: entry.value.value},
            clocks: {for (final entry in merged.fields.entries) entry.key: entry.value.hlc},
            deleteHlc: merged.deletedHlc,
            restoreHlc: merged.restoredHlc,
          );
        }
      }
    });
  }

  Future<List<SyncOp>> pendingOps() => _mutex.run(_readOps);

  Future<void> applyRemoteOps(List<SyncOp> ops) {
    return _commit(() async {
      for (final op in ops) {
        await _applyOp(op);
      }
    });
  }

  Future<T> _commit<T>(Future<T> Function() body) {
    return _mutex.run(() async {
      final value = await db.transaction(() async {
        final result = await body();
        await _saveClock();
        return result;
      });
      await _reload();
      notifyListeners();
      return value;
    });
  }

  void _setMessage(String message, {bool force = false}) {
    final changed = syncMessage != message;
    syncMessage = message;
    if (changed || force) {
      notifyListeners();
    }
  }

  Future<void> _loadIdentity() async {
    final storedDevice = await _setting('deviceId');
    deviceId = storedDevice ?? _deviceOverride ?? _uuid.v4();
    if (storedDevice == null) {
      await _setSetting('deviceId', deviceId);
    }
    final storedName = await _setting('deviceName');
    if (storedName == null) {
      await _setSetting('deviceName', 'この端末');
    }
    final storedHlc = await _setting('hlc');
    _clock = HlcClock(
      deviceId,
      last: storedHlc == null ? null : Hlc.parse(storedHlc),
      now: _now,
    );
  }

  Future<void> _ensureInbox() async {
    final existing = await _list(inboxId);
    if (existing != null) {
      return;
    }
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    final values = <String, Object?>{
      'name': '受信箱',
      'color': listColors.first,
      'sortOrder': 0,
      'isInbox': true,
      'archived': false,
    };
    await db.into(db.taskLists).insert(
      TaskListsCompanion(
        id: const Value(inboxId),
        name: const Value('受信箱'),
        color: Value(listColors.first),
        sortOrder: const Value(0),
        isInbox: const Value(true),
        archived: const Value(false),
        deleted: const Value(false),
        fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(type: entityList, id: inboxId, values: values, hlc: hlc);
  }

  Future<void> _reload() async {
    lists = (await db.select(db.taskLists).get()).map(_listModel).toList();
    tasks = (await db.select(db.tasks).get()).map(_taskModel).toList();
    tags = (await db.select(db.tags).get()).map(_tagModel).toList();
    checklist = (await db.select(db.checklistItems).get()).map(_checklistModel).toList();
    taskTags = (await db.select(db.taskTags).get()).map(_taskTagModel).toList();
    themeMode = switch (await _setting('theme')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    deviceName = await _setting('deviceName') ?? 'この端末';
    syncBaseUrl = await _setting('syncBaseUrl') ?? '';
    syncCursor = int.tryParse(await _setting('syncCursor') ?? '') ?? 0;
    outboxCount = (await db.select(db.outboxOps).get()).length;
    final storedDevice = await _setting('deviceId');
    if (storedDevice != null) {
      deviceId = storedDevice;
    }
  }

  Future<String> _insertTask({
    required String listId,
    required String title,
    String notes = '',
    DateTime? due,
    bool hasTime = false,
    int priority = 0,
    String recurrence = recurrenceNone,
    String reminder = reminderNone,
    int? completedAt,
    int? sortOrder,
  }) async {
    final id = _uuid.v4();
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    final siblings = await (db.select(db.tasks)..where((row) => row.listId.equals(listId))).get();
    final sort = sortOrder ?? siblings.fold<int>(0, (max, row) => row.sortOrder > max ? row.sortOrder : max) + 1024;
    final dueMs = due?.millisecondsSinceEpoch;
    final remind = reminderInstant(due: due, dueHasTime: hasTime, preset: reminder)?.millisecondsSinceEpoch;
    final values = <String, Object?>{
      'listId': listId,
      'title': title,
      'notes': notes,
      'dueAt': dueMs,
      'dueHasTime': hasTime,
      'priority': priority,
      'recurrence': recurrence,
      'reminder': reminder,
      'reminderAt': remind,
      'sortOrder': sort,
      'completedAt': completedAt,
    };
    await db.into(db.tasks).insert(
      TasksCompanion(
        id: Value(id),
        listId: Value(listId),
        title: Value(title),
        notes: Value(notes),
        dueAt: Value(dueMs),
        dueHasTime: Value(hasTime),
        priority: Value(priority),
        recurrence: Value(recurrence),
        reminder: Value(reminder),
        reminderAt: Value(remind),
        reminderFired: const Value(false),
        sortOrder: Value(sort),
        completedAt: Value(completedAt),
        deleted: const Value(false),
        fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(type: entityTask, id: id, values: values, hlc: hlc);
    return id;
  }

  Future<String> _cloneCompleted(TaskRow row) async {
    final cloneId = await _insertTask(
      listId: row.listId,
      title: row.title,
      notes: row.notes,
      due: row.dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.dueAt!),
      hasTime: row.dueHasTime,
      priority: row.priority,
      completedAt: _now().millisecondsSinceEpoch,
    );
    final items = await (db.select(db.checklistItems)..where((item) => item.taskId.equals(row.id) & item.deleted.equals(false))).get();
    for (final item in items) {
      await _insertChecklist(cloneId, item.title, item.done, item.sortOrder);
    }
    final links = await (db.select(db.taskTags)..where((link) => link.taskId.equals(row.id) & link.deleted.equals(false))).get();
    for (final link in links) {
      await _insertTaskTag('$cloneId:${link.tagId}', cloneId, link.tagId);
    }
    return cloneId;
  }

  Future<void> _insertChecklist(String taskId, String title, bool done, int sort) async {
    final id = _uuid.v4();
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    final values = <String, Object?>{'taskId': taskId, 'title': title, 'done': done, 'sortOrder': sort};
    await db.into(db.checklistItems).insert(
      ChecklistItemsCompanion(
        id: Value(id),
        taskId: Value(taskId),
        title: Value(title),
        done: Value(done),
        sortOrder: Value(sort),
        deleted: const Value(false),
        fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(type: entityChecklist, id: id, values: values, hlc: hlc);
  }

  Future<void> _insertTaskTag(String id, String taskId, String tagId) async {
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    final values = <String, Object?>{'taskId': taskId, 'tagId': tagId};
    await db.into(db.taskTags).insertOnConflictUpdate(
      TaskTagsCompanion(
        id: Value(id),
        taskId: Value(taskId),
        tagId: Value(tagId),
        deleted: const Value(false),
        deletedHlc: const Value(null),
        fieldClocks: Value(_encodeClocks({for (final key in values.keys) key: hlc})),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(type: entityTaskTag, id: id, values: values, hlc: hlc);
  }

  Future<void> _writeTaskFields(String id, Map<String, Object?> changes, {Hlc? stamp}) async {
    final row = await _task(id);
    if (row == null) {
      return;
    }
    final values = _taskValues(row);
    values.addAll(changes);
    var reminderFired = row.reminderFired;
    if (changes.containsKey('dueAt') || changes.containsKey('dueHasTime') || changes.containsKey('reminder')) {
      final dueMs = values['dueAt'] as int?;
      final instant = reminderInstant(
        due: dueMs == null ? null : DateTime.fromMillisecondsSinceEpoch(dueMs),
        dueHasTime: values['dueHasTime'] as bool? ?? false,
        preset: values['reminder'] as String? ?? reminderNone,
      );
      values['reminderAt'] = instant?.millisecondsSinceEpoch;
      if (values['reminderAt'] != row.reminderAt) {
        reminderFired = false;
      }
    }
    final clocks = _decodeClocks(row.fieldClocks);
    final hlc = stamp ?? _clock.tick();
    final changedKeys = <String>{...changes.keys};
    if (values['reminderAt'] != row.reminderAt) {
      changedKeys.add('reminderAt');
    }
    for (final key in changedKeys) {
      clocks[key] = hlc;
    }
    final deleted = row.deletedHlc != null;
    await (db.update(db.tasks)..where((item) => item.id.equals(id))).write(
      TasksCompanion(
        listId: Value(values['listId'] as String),
        title: Value(values['title'] as String),
        notes: Value(values['notes'] as String? ?? ''),
        dueAt: Value(values['dueAt'] as int?),
        dueHasTime: Value(values['dueHasTime'] as bool? ?? false),
        priority: Value(values['priority'] as int? ?? 0),
        recurrence: Value(values['recurrence'] as String? ?? recurrenceNone),
        reminder: Value(values['reminder'] as String? ?? reminderNone),
        reminderAt: Value(values['reminderAt'] as int?),
        reminderFired: Value(reminderFired),
        sortOrder: Value(values['sortOrder'] as int? ?? 0),
        completedAt: Value(values['completedAt'] as int?),
        deleted: Value(deleted),
        fieldClocks: Value(_encodeClocks(clocks)),
        updatedAt: Value(_now().millisecondsSinceEpoch),
      ),
    );
    await _enqueue(
      type: entityTask,
      id: id,
      values: {for (final key in changedKeys) key: values[key]},
      hlc: hlc,
    );
  }

  Future<void> _writeListFields(String id, Map<String, Object?> changes, {Hlc? stamp}) async {
    final row = await _list(id);
    if (row == null) {
      return;
    }
    final values = _listValues(row);
    values.addAll(changes);
    final clocks = _decodeClocks(row.fieldClocks);
    final hlc = stamp ?? _clock.tick();
    for (final key in changes.keys) {
      clocks[key] = hlc;
    }
    await (db.update(db.taskLists)..where((item) => item.id.equals(id))).write(
      TaskListsCompanion(
        name: Value(values['name'] as String),
        color: Value(values['color'] as int),
        sortOrder: Value(values['sortOrder'] as int),
        isInbox: Value(values['isInbox'] as bool),
        archived: Value(values['archived'] as bool),
        deleted: Value(row.deletedHlc != null),
        fieldClocks: Value(_encodeClocks(clocks)),
        updatedAt: Value(_now().millisecondsSinceEpoch),
      ),
    );
    await _enqueue(type: entityList, id: id, values: changes, hlc: hlc);
  }

  Future<void> _writeTagFields(String id, Map<String, Object?> changes, {Hlc? stamp}) async {
    final row = await _tag(id);
    if (row == null) {
      return;
    }
    final values = _tagValues(row);
    values.addAll(changes);
    final clocks = _decodeClocks(row.fieldClocks);
    final hlc = stamp ?? _clock.tick();
    for (final key in changes.keys) {
      clocks[key] = hlc;
    }
    await (db.update(db.tags)..where((item) => item.id.equals(id))).write(
      TagsCompanion(
        name: Value(values['name'] as String),
        color: Value(values['color'] as int),
        deleted: Value(row.deletedHlc != null),
        fieldClocks: Value(_encodeClocks(clocks)),
        updatedAt: Value(_now().millisecondsSinceEpoch),
      ),
    );
    await _enqueue(type: entityTag, id: id, values: changes, hlc: hlc);
  }

  Future<void> _writeChecklistFields(String id, Map<String, Object?> changes, {Hlc? stamp}) async {
    final row = await _checklist(id);
    if (row == null) {
      return;
    }
    final values = _checklistValues(row);
    values.addAll(changes);
    final clocks = _decodeClocks(row.fieldClocks);
    final hlc = stamp ?? _clock.tick();
    for (final key in changes.keys) {
      clocks[key] = hlc;
    }
    await (db.update(db.checklistItems)..where((item) => item.id.equals(id))).write(
      ChecklistItemsCompanion(
        taskId: Value(values['taskId'] as String),
        title: Value(values['title'] as String),
        done: Value(values['done'] as bool),
        sortOrder: Value(values['sortOrder'] as int),
        deleted: Value(row.deletedHlc != null),
        fieldClocks: Value(_encodeClocks(clocks)),
        updatedAt: Value(_now().millisecondsSinceEpoch),
      ),
    );
    await _enqueue(type: entityChecklist, id: id, values: changes, hlc: hlc);
  }

  Future<void> _tombstone(String type, String id, Object? row) async {
    if (row == null) {
      return;
    }
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    switch (type) {
      case entityTask:
        await (db.update(db.tasks)..where((item) => item.id.equals(id))).write(
          TasksCompanion(deleted: const Value(true), deletedHlc: Value(hlc.encode()), updatedAt: Value(now)),
        );
      case entityList:
        await (db.update(db.taskLists)..where((item) => item.id.equals(id))).write(
          TaskListsCompanion(deleted: const Value(true), deletedHlc: Value(hlc.encode()), updatedAt: Value(now)),
        );
      case entityTag:
        await (db.update(db.tags)..where((item) => item.id.equals(id))).write(
          TagsCompanion(deleted: const Value(true), deletedHlc: Value(hlc.encode()), updatedAt: Value(now)),
        );
      case entityTaskTag:
        await (db.update(db.taskTags)..where((item) => item.id.equals(id))).write(
          TaskTagsCompanion(deleted: const Value(true), deletedHlc: Value(hlc.encode()), updatedAt: Value(now)),
        );
      case entityChecklist:
        await (db.update(db.checklistItems)..where((item) => item.id.equals(id))).write(
          ChecklistItemsCompanion(deleted: const Value(true), deletedHlc: Value(hlc.encode()), updatedAt: Value(now)),
        );
    }
    await _enqueue(type: type, id: id, values: const {}, deleteHlc: hlc);
  }

  Future<void> _restore(String type, String id) async {
    final hlc = _clock.tick();
    final now = _now().millisecondsSinceEpoch;
    switch (type) {
      case entityTask:
        await (db.update(db.tasks)..where((item) => item.id.equals(id))).write(
          TasksCompanion(
            deleted: const Value(false),
            deletedHlc: const Value(null),
            restoredHlc: Value(hlc.encode()),
            updatedAt: Value(now),
          ),
        );
      case entityList:
        await (db.update(db.taskLists)..where((item) => item.id.equals(id))).write(
          TaskListsCompanion(
            deleted: const Value(false),
            deletedHlc: const Value(null),
            restoredHlc: Value(hlc.encode()),
            updatedAt: Value(now),
          ),
        );
      case entityTag:
        await (db.update(db.tags)..where((item) => item.id.equals(id))).write(
          TagsCompanion(
            deleted: const Value(false),
            deletedHlc: const Value(null),
            restoredHlc: Value(hlc.encode()),
            updatedAt: Value(now),
          ),
        );
      case entityTaskTag:
        await (db.update(db.taskTags)..where((item) => item.id.equals(id))).write(
          TaskTagsCompanion(
            deleted: const Value(false),
            deletedHlc: const Value(null),
            restoredHlc: Value(hlc.encode()),
            updatedAt: Value(now),
          ),
        );
      case entityChecklist:
        await (db.update(db.checklistItems)..where((item) => item.id.equals(id))).write(
          ChecklistItemsCompanion(
            deleted: const Value(false),
            deletedHlc: const Value(null),
            restoredHlc: Value(hlc.encode()),
            updatedAt: Value(now),
          ),
        );
    }
    await _enqueue(type: type, id: id, values: const {}, restoreHlc: hlc);
  }

  Future<void> _applyOp(SyncOp op) async {
    for (final field in op.fields.values) {
      _clock.observe(field.hlc);
    }
    if (op.deleteHlc != null) {
      _clock.observe(op.deleteHlc!);
    }
    if (op.restoreHlc != null) {
      _clock.observe(op.restoreHlc!);
    }
    final local = await _entityOf(op.entityType, op.entityId);
    final merged = mergeEntities(local, op.toEntity());
    await _writeEntity(merged);
  }

  Future<void> _writeEntity(SyncEntity entity) async {
    final now = _now().millisecondsSinceEpoch;
    final clocks = {for (final entry in entity.fields.entries) entry.key: entry.value.hlc};
    final deleted = entity.isDeleted;
    final deletedHlc = entity.deletedHlc?.encode();
    final restoredHlc = entity.restoredHlc?.encode();
    switch (entity.type) {
      case entityList:
        final existing = await _list(entity.id);
        await db.into(db.taskLists).insertOnConflictUpdate(
          TaskListsCompanion(
            id: Value(entity.id),
            name: Value(_str(entity, 'name', existing?.name ?? 'リスト')),
            color: Value(_int(entity, 'color', existing?.color ?? listColors.first)),
            sortOrder: Value(_int(entity, 'sortOrder', existing?.sortOrder ?? 0)),
            isInbox: Value(_bool(entity, 'isInbox', existing?.isInbox ?? entity.id == inboxId)),
            archived: Value(_bool(entity, 'archived', existing?.archived ?? false)),
            deleted: Value(deleted),
            deletedHlc: Value(deletedHlc),
            restoredHlc: Value(restoredHlc),
            fieldClocks: Value(_encodeClocks(clocks)),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      case entityTask:
        final existing = await _task(entity.id);
        final reminderAt = entity.fields.containsKey('reminderAt')
            ? _intOpt(entity, 'reminderAt')
            : existing?.reminderAt;
        final fired = existing != null && existing.reminderAt == reminderAt && existing.reminderFired;
        await db.into(db.tasks).insertOnConflictUpdate(
          TasksCompanion(
            id: Value(entity.id),
            listId: Value(_str(entity, 'listId', existing?.listId ?? inboxId)),
            title: Value(_str(entity, 'title', existing?.title ?? '無題')),
            notes: Value(_str(entity, 'notes', existing?.notes ?? '')),
            dueAt: Value(entity.fields.containsKey('dueAt') ? _intOpt(entity, 'dueAt') : existing?.dueAt),
            dueHasTime: Value(_bool(entity, 'dueHasTime', existing?.dueHasTime ?? false)),
            priority: Value(_int(entity, 'priority', existing?.priority ?? 0)),
            recurrence: Value(_str(entity, 'recurrence', existing?.recurrence ?? recurrenceNone)),
            reminder: Value(_str(entity, 'reminder', existing?.reminder ?? reminderNone)),
            reminderAt: Value(reminderAt),
            reminderFired: Value(fired),
            sortOrder: Value(_int(entity, 'sortOrder', existing?.sortOrder ?? 0)),
            completedAt: Value(
              entity.fields.containsKey('completedAt') ? _intOpt(entity, 'completedAt') : existing?.completedAt,
            ),
            deleted: Value(deleted),
            deletedHlc: Value(deletedHlc),
            restoredHlc: Value(restoredHlc),
            fieldClocks: Value(_encodeClocks(clocks)),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      case entityTag:
        final existing = await _tag(entity.id);
        await db.into(db.tags).insertOnConflictUpdate(
          TagsCompanion(
            id: Value(entity.id),
            name: Value(_str(entity, 'name', existing?.name ?? 'タグ')),
            color: Value(_int(entity, 'color', existing?.color ?? listColors[1])),
            deleted: Value(deleted),
            deletedHlc: Value(deletedHlc),
            restoredHlc: Value(restoredHlc),
            fieldClocks: Value(_encodeClocks(clocks)),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      case entityTaskTag:
        final existing = await _taskTag(entity.id);
        await db.into(db.taskTags).insertOnConflictUpdate(
          TaskTagsCompanion(
            id: Value(entity.id),
            taskId: Value(_str(entity, 'taskId', existing?.taskId ?? '')),
            tagId: Value(_str(entity, 'tagId', existing?.tagId ?? '')),
            deleted: Value(deleted),
            deletedHlc: Value(deletedHlc),
            restoredHlc: Value(restoredHlc),
            fieldClocks: Value(_encodeClocks(clocks)),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
      case entityChecklist:
        final existing = await _checklist(entity.id);
        await db.into(db.checklistItems).insertOnConflictUpdate(
          ChecklistItemsCompanion(
            id: Value(entity.id),
            taskId: Value(_str(entity, 'taskId', existing?.taskId ?? '')),
            title: Value(_str(entity, 'title', existing?.title ?? '')),
            done: Value(_bool(entity, 'done', existing?.done ?? false)),
            sortOrder: Value(_int(entity, 'sortOrder', existing?.sortOrder ?? 0)),
            deleted: Value(deleted),
            deletedHlc: Value(deletedHlc),
            restoredHlc: Value(restoredHlc),
            fieldClocks: Value(_encodeClocks(clocks)),
            createdAt: Value(existing?.createdAt ?? now),
            updatedAt: Value(now),
          ),
        );
    }
  }

  Future<SyncEntity> _entityOf(String type, String id) async {
    switch (type) {
      case entityList:
        final row = await _list(id);
        return row == null ? SyncEntity(type: type, id: id, fields: const {}) : _listToEntity(row);
      case entityTask:
        final row = await _task(id);
        return row == null ? SyncEntity(type: type, id: id, fields: const {}) : _taskToEntity(row);
      case entityTag:
        final row = await _tag(id);
        return row == null ? SyncEntity(type: type, id: id, fields: const {}) : _tagToEntity(row);
      case entityTaskTag:
        final row = await _taskTag(id);
        return row == null ? SyncEntity(type: type, id: id, fields: const {}) : _taskTagToEntity(row);
      case entityChecklist:
        final row = await _checklist(id);
        return row == null ? SyncEntity(type: type, id: id, fields: const {}) : _checklistToEntity(row);
      default:
        return SyncEntity(type: type, id: id, fields: const {});
    }
  }

  Future<void> _enqueue({
    required String type,
    required String id,
    required Map<String, Object?> values,
    Hlc? hlc,
    Map<String, Hlc>? clocks,
    Hlc? deleteHlc,
    Hlc? restoreHlc,
  }) async {
    final fields = <String, FieldValue>{};
    values.forEach((key, value) {
      final clock = clocks?[key] ?? hlc;
      if (clock != null) {
        fields[key] = FieldValue(value, clock);
      }
    });
    final op = SyncOp(
      opId: _uuid.v4(),
      entityType: type,
      entityId: id,
      deviceId: deviceId,
      fields: fields,
      createdAt: _now().millisecondsSinceEpoch,
      deleteHlc: deleteHlc,
      restoreHlc: restoreHlc,
    );
    await db.into(db.outboxOps).insert(
      OutboxOpsCompanion(
        opId: Value(op.opId),
        entityType: Value(type),
        entityId: Value(id),
        payload: Value(jsonEncode(op.toJson())),
        createdAt: Value(op.createdAt),
      ),
    );
  }

  Future<List<SyncOp>> _readOps() async {
    final rows = await (db.select(db.outboxOps)..orderBy([
      (row) => OrderingTerm.asc(row.createdAt),
      (row) => OrderingTerm.asc(row.opId),
    ])).get();
    return rows.map((row) {
      final decoded = jsonDecode(row.payload);
      return SyncOp.fromJson((decoded as Map).map((key, value) => MapEntry(key.toString(), value)));
    }).toList();
  }

  Future<void> _saveClock() async {
    final last = _clock.last;
    if (last != null) {
      await _setSetting('hlc', last.encode());
    }
  }

  Future<String?> _setting(String key) async {
    final row = await (db.select(db.settingEntries)..where((item) => item.settingKey.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _setSetting(String key, String value) {
    return db.into(db.settingEntries).insertOnConflictUpdate(
      SettingEntriesCompanion(settingKey: Value(key), value: Value(value)),
    );
  }

  Future<TaskListRow?> _list(String id) =>
      (db.select(db.taskLists)..where((row) => row.id.equals(id))).getSingleOrNull();
  Future<TaskRow?> _task(String id) => (db.select(db.tasks)..where((row) => row.id.equals(id))).getSingleOrNull();
  Future<TagRow?> _tag(String id) => (db.select(db.tags)..where((row) => row.id.equals(id))).getSingleOrNull();
  Future<TaskTagRow?> _taskTag(String id) =>
      (db.select(db.taskTags)..where((row) => row.id.equals(id))).getSingleOrNull();
  Future<ChecklistRow?> _checklist(String id) =>
      (db.select(db.checklistItems)..where((row) => row.id.equals(id))).getSingleOrNull();
}

Map<String, Object?> _taskValues(TaskRow row) => {
  'listId': row.listId,
  'title': row.title,
  'notes': row.notes,
  'dueAt': row.dueAt,
  'dueHasTime': row.dueHasTime,
  'priority': row.priority,
  'recurrence': row.recurrence,
  'reminder': row.reminder,
  'reminderAt': row.reminderAt,
  'sortOrder': row.sortOrder,
  'completedAt': row.completedAt,
};

Map<String, Object?> _listValues(TaskListRow row) => {
  'name': row.name,
  'color': row.color,
  'sortOrder': row.sortOrder,
  'isInbox': row.isInbox,
  'archived': row.archived,
};

Map<String, Object?> _tagValues(TagRow row) => {'name': row.name, 'color': row.color};

Map<String, Object?> _checklistValues(ChecklistRow row) => {
  'taskId': row.taskId,
  'title': row.title,
  'done': row.done,
  'sortOrder': row.sortOrder,
};

Map<String, Object?> _taskTagValues(TaskTagRow row) => {'taskId': row.taskId, 'tagId': row.tagId};

String _encodeClocks(Map<String, Hlc> clocks) =>
    jsonEncode(clocks.map((key, value) => MapEntry(key, value.encode())));

Map<String, Hlc> _decodeClocks(String raw) {
  if (raw.isEmpty) {
    return {};
  }
  final decoded = jsonDecode(raw);
  if (decoded is! Map) {
    return {};
  }
  return decoded.map((key, value) => MapEntry(key.toString(), Hlc.parse(value as String)));
}

SyncEntity _withClocks({
  required String type,
  required String id,
  required Map<String, Object?> values,
  required String clocksRaw,
  required String? deletedHlc,
  required String? restoredHlc,
}) {
  final clocks = _decodeClocks(clocksRaw);
  final fields = <String, FieldValue>{};
  for (final entry in values.entries) {
    final clock = clocks[entry.key];
    if (clock != null) {
      fields[entry.key] = FieldValue(entry.value, clock);
    }
  }
  return SyncEntity(
    type: type,
    id: id,
    fields: fields,
    deletedHlc: deletedHlc == null ? null : Hlc.parse(deletedHlc),
    restoredHlc: restoredHlc == null ? null : Hlc.parse(restoredHlc),
  );
}

SyncEntity _listToEntity(TaskListRow row) => _withClocks(
  type: entityList,
  id: row.id,
  values: _listValues(row),
  clocksRaw: row.fieldClocks,
  deletedHlc: row.deletedHlc,
  restoredHlc: row.restoredHlc,
);

SyncEntity _taskToEntity(TaskRow row) => _withClocks(
  type: entityTask,
  id: row.id,
  values: _taskValues(row),
  clocksRaw: row.fieldClocks,
  deletedHlc: row.deletedHlc,
  restoredHlc: row.restoredHlc,
);

SyncEntity _tagToEntity(TagRow row) => _withClocks(
  type: entityTag,
  id: row.id,
  values: _tagValues(row),
  clocksRaw: row.fieldClocks,
  deletedHlc: row.deletedHlc,
  restoredHlc: row.restoredHlc,
);

SyncEntity _checklistToEntity(ChecklistRow row) => _withClocks(
  type: entityChecklist,
  id: row.id,
  values: _checklistValues(row),
  clocksRaw: row.fieldClocks,
  deletedHlc: row.deletedHlc,
  restoredHlc: row.restoredHlc,
);

SyncEntity _taskTagToEntity(TaskTagRow row) => _withClocks(
  type: entityTaskTag,
  id: row.id,
  values: _taskTagValues(row),
  clocksRaw: row.fieldClocks,
  deletedHlc: row.deletedHlc,
  restoredHlc: row.restoredHlc,
);

ListModel _listModel(TaskListRow row) {
  final entity = _listToEntity(row);
  return ListModel(
    id: row.id,
    name: row.name,
    color: row.color,
    sortOrder: row.sortOrder,
    isInbox: row.isInbox,
    archived: row.archived,
    deleted: entity.isDeleted,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
  );
}

TaskModel _taskModel(TaskRow row) {
  final entity = _taskToEntity(row);
  return TaskModel(
    id: row.id,
    listId: row.listId,
    title: row.title,
    notes: row.notes,
    dueAt: row.dueAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.dueAt!),
    dueHasTime: row.dueHasTime,
    priority: row.priority,
    recurrence: row.recurrence,
    reminder: row.reminder,
    reminderAt: row.reminderAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.reminderAt!),
    reminderFired: row.reminderFired,
    sortOrder: row.sortOrder,
    completedAt: row.completedAt == null ? null : DateTime.fromMillisecondsSinceEpoch(row.completedAt!),
    deleted: entity.isDeleted,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
  );
}

TagModel _tagModel(TagRow row) => TagModel(
  id: row.id,
  name: row.name,
  color: row.color,
  deleted: _tagToEntity(row).isDeleted,
);

ChecklistModel _checklistModel(ChecklistRow row) => ChecklistModel(
  id: row.id,
  taskId: row.taskId,
  title: row.title,
  done: row.done,
  sortOrder: row.sortOrder,
  deleted: _checklistToEntity(row).isDeleted,
);

TaskTagModel _taskTagModel(TaskTagRow row) => TaskTagModel(
  id: row.id,
  taskId: row.taskId,
  tagId: row.tagId,
  deleted: _taskTagToEntity(row).isDeleted,
);

String _str(SyncEntity entity, String key, String fallback) {
  final value = entity.fields[key]?.value;
  return value is String ? value : fallback;
}

int _int(SyncEntity entity, String key, int fallback) {
  final value = entity.fields[key]?.value;
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return fallback;
}

int? _intOpt(SyncEntity entity, String key) {
  final value = entity.fields[key]?.value;
  if (value == null) {
    return null;
  }
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return null;
}

bool _bool(SyncEntity entity, String key, bool fallback) {
  final value = entity.fields[key]?.value;
  return value is bool ? value : fallback;
}
