import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;

part 'tas_database.g.dart';

@DataClassName('TaskListRow')
class TaskLists extends Table {
  @override
  String get tableName => 'task_lists';

  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isInbox => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deletedHlc => text().nullable()();
  TextColumn get restoredHlc => text().nullable()();
  TextColumn get fieldClocks => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskRow')
class Tasks extends Table {
  TextColumn get id => text()();
  TextColumn get listId => text()();
  TextColumn get title => text()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get dueAt => integer().nullable()();
  BoolColumn get dueHasTime => boolean().withDefault(const Constant(false))();
  IntColumn get priority => integer().withDefault(const Constant(0))();
  TextColumn get recurrence => text().withDefault(const Constant('none'))();
  TextColumn get reminder => text().withDefault(const Constant('none'))();
  IntColumn get reminderAt => integer().nullable()();
  BoolColumn get reminderFired =>
      boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get completedAt => integer().nullable()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deletedHlc => text().nullable()();
  TextColumn get restoredHlc => text().nullable()();
  TextColumn get fieldClocks => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TagRow')
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deletedHlc => text().nullable()();
  TextColumn get restoredHlc => text().nullable()();
  TextColumn get fieldClocks => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('TaskTagRow')
class TaskTags extends Table {
  @override
  String get tableName => 'task_tags';

  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get tagId => text()();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deletedHlc => text().nullable()();
  TextColumn get restoredHlc => text().nullable()();
  TextColumn get fieldClocks => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ChecklistRow')
class ChecklistItems extends Table {
  @override
  String get tableName => 'checklist_items';

  TextColumn get id => text()();
  TextColumn get taskId => text()();
  TextColumn get title => text()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  TextColumn get deletedHlc => text().nullable()();
  TextColumn get restoredHlc => text().nullable()();
  TextColumn get fieldClocks => text().withDefault(const Constant('{}'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('OutboxRow')
class OutboxOps extends Table {
  @override
  String get tableName => 'outbox';

  TextColumn get opId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {opId};
}

@DataClassName('SettingRow')
class SettingEntries extends Table {
  @override
  String get tableName => 'settings';

  TextColumn get settingKey => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {settingKey};
}

@DataClassName('TaskPlacementRow')
class TaskPlacements extends Table {
  @override
  String get tableName => 'task_placements';

  TextColumn get taskId => text()();
  IntColumn get quadrant => integer()();

  @override
  Set<Column<Object>> get primaryKey => {taskId};
}

@DataClassName('HabitRow')
class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get color => integer().withDefault(const Constant(0xFF1F4B4A))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinute => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('HabitCheckRow')
class HabitChecks extends Table {
  @override
  String get tableName => 'habit_checks';

  TextColumn get habitId => text()();
  TextColumn get day => text()();

  @override
  Set<Column<Object>> get primaryKey => {habitId, day};
}

@DataClassName('DiaryRow')
class DiaryEntries extends Table {
  @override
  String get tableName => 'diary_entries';

  TextColumn get day => text()();
  TextColumn get body => text().withDefault(const Constant(''))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {day};
}

@DataClassName('PomodoroSessionRow')
class PomodoroSessions extends Table {
  @override
  String get tableName => 'pomodoro_sessions';

  TextColumn get id => text()();
  TextColumn get taskId => text().nullable()();
  IntColumn get finishedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PomodoroStateRow')
class PomodoroStates extends Table {
  @override
  String get tableName => 'pomodoro_state';

  IntColumn get id => integer()();
  TextColumn get taskId => text().nullable()();
  BoolColumn get focus => boolean().withDefault(const Constant(true))();
  TextColumn get phase => text().withDefault(const Constant('focus'))();
  IntColumn get remainingMs => integer()();
  BoolColumn get running => boolean().withDefault(const Constant(false))();
  IntColumn get anchorMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    TaskLists,
    Tasks,
    Tags,
    TaskTags,
    ChecklistItems,
    OutboxOps,
    SettingEntries,
    TaskPlacements,
    Habits,
    HabitChecks,
    DiaryEntries,
    PomodoroSessions,
    PomodoroStates,
  ],
)
class TasDatabase extends _$TasDatabase {
  TasDatabase(super.executor);

  factory TasDatabase.file(File file) {
    return TasDatabase(NativeDatabase.createInBackground(file));
  }

  factory TasDatabase.memory() {
    return TasDatabase(NativeDatabase.memory());
  }

  static Future<TasDatabase> openDefault() async {
    final override = Platform.environment['TAS_DB_PATH'];
    final File file;
    if (override != null && override.isNotEmpty) {
      file = File(override);
    } else {
      final home = Platform.environment['HOME'] ?? Directory.current.path;
      file = File(p.join(home, '.local', 'share', 'tas', 'tas.sqlite'));
    }
    await file.parent.create(recursive: true);
    return TasDatabase.file(file);
  }

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(taskLists, taskLists.restoredHlc);
        await migrator.addColumn(tasks, tasks.restoredHlc);
        await migrator.addColumn(tags, tags.restoredHlc);
        await migrator.addColumn(taskTags, taskTags.restoredHlc);
        await migrator.addColumn(checklistItems, checklistItems.restoredHlc);
      }
      if (from < 3) {
        await migrator.createTable(taskPlacements);
        await migrator.createTable(habits);
        await migrator.createTable(habitChecks);
        await migrator.createTable(diaryEntries);
        await migrator.createTable(pomodoroSessions);
        await migrator.createTable(pomodoroStates);
      }
      if (from < 4) {
        await migrator.addColumn(habits, habits.color);
        await migrator.addColumn(habits, habits.archived);
        await migrator.addColumn(habits, habits.reminderMinute);
        await migrator.addColumn(pomodoroStates, pomodoroStates.phase);
        await migrator.database.customStatement(
          "UPDATE pomodoro_state SET phase = 'short' WHERE focus = 0",
        );
      }
    },
  );
}
