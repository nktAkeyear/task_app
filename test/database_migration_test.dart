import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/data/tas_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  for (final version in [1, 2, 3, 4]) {
    test('upgrades schema v$version and preserves existing data', () async {
      final directory = await Directory.systemTemp.createTemp('tas-migration-');
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/tas.sqlite');
      final old = TasDatabase(NativeDatabase(file));
      await old
          .into(old.tasks)
          .insert(
            TasksCompanion.insert(
              id: 'existing-task',
              listId: 'inbox',
              title: 'Keep this task',
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      // Build historical layouts by removing columns and tables that had not
      // shipped yet, then reopen through the normal Drift upgrade path.
      await old.customStatement('ALTER TABLE tasks DROP COLUMN ends_at');
      if (version < 3) {
        for (final table in [
          'task_placements',
          'habits',
          'habit_checks',
          'diary_entries',
          'pomodoro_sessions',
          'pomodoro_state',
        ]) {
          await old.customStatement('DROP TABLE $table');
        }
      } else {
        await old
            .into(old.habits)
            .insert(
              HabitsCompanion.insert(id: 'habit', name: 'Read', createdAt: 1),
            );
        await old
            .into(old.pomodoroStates)
            .insert(
              PomodoroStatesCompanion.insert(
                id: const Value(1),
                focus: const Value(false),
                phase: const Value('short'),
                remainingMs: 300000,
              ),
            );
        if (version < 4) {
          for (final column in ['color', 'archived', 'reminder_minute']) {
            await old.customStatement('ALTER TABLE habits DROP COLUMN $column');
          }
          await old.customStatement(
            'ALTER TABLE pomodoro_state DROP COLUMN phase',
          );
        }
      }
      if (version < 2) {
        for (final table in [
          'task_lists',
          'tasks',
          'tags',
          'task_tags',
          'checklist_items',
        ]) {
          await old.customStatement(
            'ALTER TABLE $table DROP COLUMN restored_hlc',
          );
        }
      }
      await old.customStatement('PRAGMA user_version = $version');
      await old.close();

      final upgraded = TasDatabase(NativeDatabase(file));
      addTearDown(upgraded.close);
      final task = await upgraded.select(upgraded.tasks).getSingle();
      expect(task.title, 'Keep this task');
      expect(task.endsAt, isNull);
      expect(task.restoredHlc, isNull);
      final habits = await upgraded.select(upgraded.habits).get();
      if (version >= 3) {
        expect(habits.single.name, 'Read');
        expect(habits.single.archived, isFalse);
        final state = await upgraded
            .select(upgraded.pomodoroStates)
            .getSingle();
        expect(state.phase, 'short');
        expect(state.remainingMs, 300000);
      } else {
        expect(habits, isEmpty);
        await upgraded
            .into(upgraded.habits)
            .insert(
              HabitsCompanion.insert(
                id: 'new-habit',
                name: 'Read',
                createdAt: 2,
              ),
            );
        expect(
          (await upgraded.select(upgraded.habits).getSingle()).archived,
          isFalse,
        );
      }
    });
  }
}
