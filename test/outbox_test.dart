import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/domain/hlc.dart';
import 'package:tas/domain/models.dart';
import 'package:tas/sync/protocol.dart';
import 'package:tas/sync/sync_client.dart';
import 'package:tas/sync/sync_log.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('outbox queues local edits and stays quiet without a sync URL', () async {
    final repo = await _repo(deviceId: 'device-a', at: DateTime(2026, 10, 1, 9));
    final before = await repo.pendingOps();
    final id = await repo.quickAdd('牛乳', board: TaskBoard.inbox);
    await repo.setNotes(id, '低脂肪');
    final ops = await repo.pendingOps();
    expect(ops.length, greaterThan(before.length));
    final taskOps = ops.where((op) => op.entityId == id).toList();
    expect(taskOps, isNotEmpty);
    expect(taskOps.any((op) => op.fields['title']?.value == '牛乳'), isTrue);
    expect(taskOps.any((op) => op.fields['notes']?.value == '低脂肪'), isTrue);

    final queued = ops.length;
    await repo.flushSync();
    expect(repo.syncMessage, contains('未設定'));
    expect((await repo.pendingOps()).length, queued);
    expect(repo.taskById(id)!.notes, '低脂肪');
  });

  test('remote field merge keeps a delete, and only an explicit restore clears it', () async {
    var now = DateTime(2026, 6, 1, 9);
    final repo = await _repo(deviceId: 'local', at: now, clock: () => now);
    final id = await repo.quickAdd('下書き', board: TaskBoard.inbox);
    final localTitle = (await _taskOp(repo, id)).fields['title']!.hlc;

    now = DateTime(2026, 6, 2, 9);
    final notesClock = Hlc(now.millisecondsSinceEpoch, 0, 'remote');
    await repo.applyRemoteOps([
      SyncOp(
        opId: 'remote-notes',
        entityType: entityTask,
        entityId: id,
        deviceId: 'remote',
        createdAt: notesClock.physical,
        fields: {'notes': FieldValue('追記', notesClock)},
      ),
    ]);
    expect(repo.taskById(id)!.title, '下書き');
    expect(repo.taskById(id)!.notes, '追記');
    expect(localTitle.compareWall(notesClock), lessThan(0));

    final deleteClock = Hlc(notesClock.physical, notesClock.logical, 'aaa');
    await repo.applyRemoteOps([
      SyncOp(
        opId: 'remote-delete',
        entityType: entityTask,
        entityId: id,
        deviceId: 'aaa',
        createdAt: deleteClock.physical,
        fields: const {},
        deleteHlc: deleteClock,
      ),
    ]);
    expect(repo.taskById(id)!.deleted, isTrue);
    expect(repo.taskById(id)!.title, '下書き');
    expect(repo.taskById(id)!.notes, '追記');

    final edited = Hlc(deleteClock.physical + 1, 0, 'zzz');
    await repo.applyRemoteOps([
      SyncOp(
        opId: 'remote-edit',
        entityType: entityTask,
        entityId: id,
        deviceId: 'zzz',
        createdAt: edited.physical,
        fields: {'title': FieldValue('更新', edited)},
      ),
    ]);
    expect(repo.taskById(id)!.deleted, isTrue);
    expect(repo.taskById(id)!.title, '更新');
    expect(repo.taskById(id)!.notes, '追記');

    final restore = Hlc(edited.physical + 1, 0, 'local');
    await repo.applyRemoteOps([
      SyncOp(
        opId: 'remote-restore',
        entityType: entityTask,
        entityId: id,
        deviceId: 'local',
        createdAt: restore.physical,
        fields: const {},
        restoreHlc: restore,
      ),
    ]);
    expect(repo.taskById(id)!.deleted, isFalse);
    expect(repo.taskById(id)!.title, '更新');
    expect(repo.taskById(id)!.notes, '追記');
  });

  test('undo after delete restores the task and syncs that restore', () async {
    final log = SyncLog();
    final client = SyncClient(
      handler: ({required baseUrl, required deviceId, required cursor, required ops}) async {
        return log.pushPull(since: cursor, incoming: ops);
      },
    );
    final now = DateTime(2026, 7, 1, 9);
    final repo = await _repo(deviceId: 'local', at: now, client: client);
    final other = await _repo(deviceId: 'other', at: now, client: client);
    final id = await repo.quickAdd('戻す', board: TaskBoard.inbox);
    await repo.deleteTask(id);
    expect(repo.taskById(id)!.deleted, isTrue);
    await repo.undo();
    expect(repo.taskById(id)!.deleted, isFalse);
    expect(repo.taskById(id)!.title, '戻す');

    final ops = await repo.pendingOps();
    final delete = ops.lastWhere((op) => op.entityId == id && op.deleteHlc != null);
    final restore = ops.lastWhere((op) => op.entityId == id && op.restoreHlc != null);
    expect(restore.restoreHlc!.compareTo(delete.deleteHlc!), greaterThan(0));
    expect(restore.fields, isEmpty);

    const url = 'http://127.0.0.1:8787';
    await repo.setSyncUrl(url);
    await other.setSyncUrl(url);
    expect(other.taskById(id)!.deleted, isFalse);
    expect(other.taskById(id)!.title, '戻す');
  });

  test('batch sync merges non-overlapping edits and retries are idempotent', () async {
    final log = SyncLog();
    final client = SyncClient(
      handler: ({required baseUrl, required deviceId, required cursor, required ops}) async {
        return log.pushPull(since: cursor, incoming: ops);
      },
    );

    var aNow = DateTime(2026, 4, 1, 8);
    var bNow = DateTime(2026, 4, 1, 8);
    final a = await _repo(deviceId: 'aaa', at: aNow, clock: () => aNow, client: client);
    final b = await _repo(deviceId: 'zzz', at: bNow, clock: () => bNow, client: client);
    final id = await a.quickAdd('買い物', board: TaskBoard.inbox);

    const url = 'http://127.0.0.1:8787';
    await a.setSyncUrl(url);
    await b.setSyncUrl(url);
    expect(b.taskById(id), isNotNull);

    aNow = DateTime(2026, 4, 2, 8);
    bNow = DateTime(2026, 4, 2, 9);
    await a.setNotes(id, '牛乳');
    await b.setTitle(id, '買い出し');
    await a.flushSync();
    await b.flushSync();
    await a.flushSync();

    expect(a.taskById(id)!.title, '買い出し');
    expect(a.taskById(id)!.notes, '牛乳');
    expect(b.taskById(id)!.title, '買い出し');
    expect(b.taskById(id)!.notes, '牛乳');

    final before = log.ops.length;
    await a.flushSync();
    expect(log.ops.length, before);
    expect(await a.pendingOps(), isEmpty);
  });

  test('exact HLC tie: delete wins over an update from a higher device id', () async {
    final when = DateTime(2026, 8, 1, 12);
    final low = await _repo(deviceId: 'aaa', at: when);
    final high = await _repo(deviceId: 'zzz', at: when);
    final id = await high.quickAdd('同着', board: TaskBoard.inbox);
    await high.applyRemoteOps([]);
    final created = await _taskOp(high, id);
    final tie = Hlc(when.millisecondsSinceEpoch + 86400000, 0, 'tie');
    // Jump both clocks forward with one local write at the same instant.
    final later = DateTime.fromMillisecondsSinceEpoch(tie.physical);
    final deleter = await _repo(deviceId: 'aaa', at: later);
    final editor = await _repo(deviceId: 'zzz', at: later);
    await editor.applyRemoteOps([created]);
    await deleter.applyRemoteOps([created]);
    await editor.setTitle(id, '更新');
    await deleter.deleteTask(id);
    final update = (await editor.pendingOps()).lastWhere((op) => op.entityId == id && op.fields.containsKey('title'));
    final delete = (await deleter.pendingOps()).lastWhere((op) => op.entityId == id && op.deleteHlc != null);
    expect(update.fields['title']!.hlc.physical, delete.deleteHlc!.physical);
    expect(update.fields['title']!.hlc.logical, delete.deleteHlc!.logical);
    expect(update.fields['title']!.hlc.deviceId.compareTo(delete.deleteHlc!.deviceId), greaterThan(0));

    final merged = mergeEntities(update.toEntity(), delete.toEntity());
    expect(merged.isDeleted, isTrue);
    expect(merged.deletedHlc, delete.deleteHlc);
    expect(merged.fields['title']!.value, '更新');
    // Silence unused repo warning if the first pair is only for setup.
    expect(low.deviceId, 'aaa');
  });

  test('turning a tag back on restores the link instead of editing fields', () async {
    final repo = await _repo(deviceId: 'local', at: DateTime(2026, 9, 1, 9));
    final taskId = await repo.quickAdd('タグ', board: TaskBoard.inbox);
    final tagId = await repo.createTag('仕事');
    await repo.toggleTag(taskId, tagId);
    expect(repo.tagsFor(taskId).map((tag) => tag.id), contains(tagId));

    await repo.toggleTag(taskId, tagId);
    expect(repo.tagsFor(taskId), isEmpty);

    await repo.toggleTag(taskId, tagId);
    expect(repo.tagsFor(taskId).map((tag) => tag.id), contains(tagId));

    final linkId = '$taskId:$tagId';
    final ops = await repo.pendingOps();
    final delete = ops.lastWhere((op) => op.entityId == linkId && op.deleteHlc != null);
    final restore = ops.lastWhere((op) => op.entityId == linkId && op.restoreHlc != null);
    expect(restore.fields, isEmpty);
    expect(restore.restoreHlc!.compareTo(delete.deleteHlc!), greaterThan(0));
  });
}

Future<TaskRepository> _repo({
  required String deviceId,
  required DateTime at,
  DateTime Function()? clock,
  SyncClient? client,
}) async {
  final repo = TaskRepository(
    TasDatabase.memory(),
    deviceId: deviceId,
    now: clock ?? () => at,
    syncClient: client,
  );
  await repo.init();
  return repo;
}

Future<SyncOp> _taskOp(TaskRepository repo, String id) async {
  final ops = await repo.pendingOps();
  return ops.lastWhere((op) => op.entityId == id && op.fields.containsKey('title'));
}
