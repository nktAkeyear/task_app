import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'tas_database.dart';

class HabitView {
  const HabitView({
    required this.id,
    required this.name,
    required this.checkedToday,
    required this.streak,
  });

  final String id;
  final String name;
  final bool checkedToday;
  final int streak;
}

class LocalTools {
  LocalTools(this.db, {required this.now, required this.onChanged});

  final TasDatabase db;
  final DateTime Function() now;
  final void Function() onChanged;
  final _uuid = const Uuid();

  static const focusMs = 25 * 60 * 1000;
  static const breakMs = 5 * 60 * 1000;

  Map<String, int> placements = {};
  List<HabitView> habits = const [];
  final Map<String, String> diary = {};
  int finishedSessions = 0;
  String? pomoTaskId;
  bool pomoFocus = true;
  int pomoRemainingMs = focusMs;
  bool pomoRunning = false;
  int? pomoAnchorMs;

  int get displayRemainingMs {
    if (!pomoRunning || pomoAnchorMs == null) {
      return pomoRemainingMs;
    }
    final elapsed = now().millisecondsSinceEpoch - pomoAnchorMs!;
    final left = pomoRemainingMs - elapsed;
    return left < 0 ? 0 : left;
  }

  Future<void> load() async {
    final placed = await db.select(db.taskPlacements).get();
    placements = {for (final row in placed) row.taskId: row.quadrant};
    finishedSessions = await db.select(db.pomodoroSessions).get().then((rows) => rows.length);
    final state = await (db.select(db.pomodoroStates)..where((row) => row.id.equals(1))).getSingleOrNull();
    if (state == null) {
      await db.into(db.pomodoroStates).insert(
        PomodoroStatesCompanion.insert(id: const Value(1), remainingMs: focusMs),
      );
      pomoTaskId = null;
      pomoFocus = true;
      pomoRemainingMs = focusMs;
      pomoRunning = false;
      pomoAnchorMs = null;
    } else {
      pomoTaskId = state.taskId;
      pomoFocus = state.focus;
      pomoRemainingMs = state.remainingMs;
      pomoRunning = state.running;
      pomoAnchorMs = state.anchorMs;
      if (pomoRunning) {
        await _catchUp();
      }
    }
    await _loadHabits();
    final entries = await db.select(db.diaryEntries).get();
    diary
      ..clear()
      ..addAll({for (final row in entries) row.day: row.body});
  }

  Future<void> placeTask(String taskId, int quadrant) async {
    await db.into(db.taskPlacements).insertOnConflictUpdate(
      TaskPlacementsCompanion(taskId: Value(taskId), quadrant: Value(quadrant)),
    );
    placements[taskId] = quadrant;
    onChanged();
  }

  Future<void> clearPlacement(String taskId) async {
    await (db.delete(db.taskPlacements)..where((row) => row.taskId.equals(taskId))).go();
    placements.remove(taskId);
    onChanged();
  }

  Future<void> addHabit(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await db.into(db.habits).insert(
      HabitsCompanion.insert(
        id: _uuid.v4(),
        name: trimmed,
        createdAt: now().millisecondsSinceEpoch,
        sortOrder: Value(habits.length),
      ),
    );
    await _loadHabits();
    onChanged();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final day = dayKey(now());
    final existing = await (db.select(db.habitChecks)
          ..where((row) => row.habitId.equals(habitId) & row.day.equals(day)))
        .getSingleOrNull();
    if (existing == null) {
      await db.into(db.habitChecks).insert(HabitChecksCompanion.insert(habitId: habitId, day: day));
    } else {
      await (db.delete(db.habitChecks)..where((row) => row.habitId.equals(habitId) & row.day.equals(day))).go();
    }
    await _loadHabits();
    onChanged();
  }

  Future<void> saveDiary(String day, String body) async {
    await db.into(db.diaryEntries).insertOnConflictUpdate(
      DiaryEntriesCompanion(day: Value(day), body: Value(body), updatedAt: Value(now().millisecondsSinceEpoch)),
    );
    diary[day] = body;
    onChanged();
  }

  Future<void> setPomoTask(String? taskId) async {
    pomoTaskId = taskId;
    await _writePomo();
    onChanged();
  }

  Future<void> startPomo() async {
    if (pomoRunning) {
      await _catchUp();
    }
    if (pomoRemainingMs <= 0) {
      await _finishPhase();
    }
    pomoRunning = true;
    pomoAnchorMs = now().millisecondsSinceEpoch;
    await _writePomo();
    onChanged();
  }

  Future<void> pausePomo() async {
    pomoRemainingMs = displayRemainingMs;
    pomoRunning = false;
    pomoAnchorMs = null;
    await _writePomo();
    onChanged();
  }

  Future<void> resetPomo() async {
    pomoFocus = true;
    pomoRemainingMs = focusMs;
    pomoRunning = false;
    pomoAnchorMs = null;
    await _writePomo();
    onChanged();
  }

  Future<void> tickPomo() async {
    if (!pomoRunning) {
      return;
    }
    final left = displayRemainingMs;
    if (left > 0) {
      onChanged();
      return;
    }
    await _finishPhase();
    onChanged();
  }

  Future<void> _finishPhase() async {
    final wasFocus = pomoFocus;
    if (wasFocus) {
      await db.into(db.pomodoroSessions).insert(
        PomodoroSessionsCompanion.insert(
          id: _uuid.v4(),
          finishedAt: now().millisecondsSinceEpoch,
          taskId: Value(pomoTaskId),
        ),
      );
      finishedSessions += 1;
    }
    pomoFocus = !wasFocus;
    pomoRemainingMs = pomoFocus ? focusMs : breakMs;
    pomoRunning = false;
    pomoAnchorMs = null;
    await _writePomo();
  }

  Future<void> _catchUp() async {
    if (!pomoRunning || pomoAnchorMs == null) {
      return;
    }
    final elapsed = now().millisecondsSinceEpoch - pomoAnchorMs!;
    final left = pomoRemainingMs - elapsed;
    if (left <= 0) {
      await _finishPhase();
      return;
    }
    pomoRemainingMs = left;
    pomoAnchorMs = now().millisecondsSinceEpoch;
    await _writePomo();
  }

  Future<void> _writePomo() async {
    await db.into(db.pomodoroStates).insertOnConflictUpdate(
      PomodoroStatesCompanion(
        id: const Value(1),
        taskId: Value(pomoTaskId),
        focus: Value(pomoFocus),
        remainingMs: Value(pomoRemainingMs),
        running: Value(pomoRunning),
        anchorMs: Value(pomoAnchorMs),
      ),
    );
  }

  Future<void> _loadHabits() async {
    final rows = await (db.select(db.habits)..where((row) => row.deleted.equals(false))).get();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final checks = await db.select(db.habitChecks).get();
    final byHabit = <String, Set<String>>{};
    for (final check in checks) {
      byHabit.putIfAbsent(check.habitId, () => {}).add(check.day);
    }
    final today = dayKey(now());
    habits = [
      for (final row in rows)
        HabitView(
          id: row.id,
          name: row.name,
          checkedToday: byHabit[row.id]?.contains(today) ?? false,
          streak: _streak(byHabit[row.id] ?? const {}),
        ),
    ];
  }

  int _streak(Set<String> days) {
    var cursor = DateTime(now().year, now().month, now().day);
    if (!days.contains(dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var count = 0;
    while (days.contains(dayKey(cursor))) {
      count += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return count;
  }
}

String dayKey(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

const quadrantLabels = <String>[
  '重要かつ緊急',
  '重要だが緊急ではない',
  '緊急だが重要ではない',
  'どちらでもない',
];
