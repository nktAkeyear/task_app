import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'tas_database.dart';

class HabitView {
  const HabitView({
    required this.id,
    required this.name,
    required this.color,
    required this.archived,
    required this.reminderMinute,
    required this.checkedToday,
    required this.streak,
    required this.week,
  });

  final String id;
  final String name;
  final int color;
  final bool archived;
  final int? reminderMinute;
  final bool checkedToday;
  final int streak;
  final List<bool> week;
}

class LocalTools {
  LocalTools(this.db, {required this.now, required this.onChanged});

  final TasDatabase db;
  final DateTime Function() now;
  final void Function() onChanged;
  final _uuid = const Uuid();

  int focusMin = 25;
  int shortMin = 5;
  int longMin = 15;

  Map<String, int> placements = {};
  List<HabitView> habits = const [];
  List<HabitView> archivedHabits = const [];
  final Map<String, String> diary = {};
  int finishedSessions = 0;
  String? pomoTaskId;
  String phase = 'focus';
  int pomoRemainingMs = 25 * 60 * 1000;
  bool pomoRunning = false;
  int? pomoAnchorMs;

  bool get pomoFocus => phase == 'focus';

  int get displayRemainingMs {
    if (!pomoRunning || pomoAnchorMs == null) {
      return pomoRemainingMs;
    }
    final elapsed = now().millisecondsSinceEpoch - pomoAnchorMs!;
    final left = pomoRemainingMs - elapsed;
    return left < 0 ? 0 : left;
  }

  int _phaseMs([String? which]) {
    return switch (which ?? phase) {
      'short' => shortMin * 60 * 1000,
      'long' => longMin * 60 * 1000,
      _ => focusMin * 60 * 1000,
    };
  }

  Future<void> load() async {
    focusMin = await _minutes('pomoFocusMin', 25);
    shortMin = await _minutes('pomoShortMin', 5);
    longMin = await _minutes('pomoLongMin', 15);
    final placed = await db.select(db.taskPlacements).get();
    placements = {for (final row in placed) row.taskId: row.quadrant};
    finishedSessions = await db
        .select(db.pomodoroSessions)
        .get()
        .then((rows) => rows.length);
    final state = await (db.select(
      db.pomodoroStates,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    if (state == null) {
      phase = 'focus';
      pomoRemainingMs = _phaseMs();
      await db
          .into(db.pomodoroStates)
          .insert(
            PomodoroStatesCompanion.insert(
              id: const Value(1),
              remainingMs: pomoRemainingMs,
              phase: const Value('focus'),
            ),
          );
      pomoTaskId = null;
      pomoRunning = false;
      pomoAnchorMs = null;
    } else {
      pomoTaskId = state.taskId;
      phase = state.phase;
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

  Future<void> applyDurations({
    required int focus,
    required int shortBreak,
    required int longBreak,
  }) async {
    final previous = _phaseMs();
    focusMin = focus.clamp(1, 180);
    shortMin = shortBreak.clamp(1, 90);
    longMin = longBreak.clamp(1, 90);
    if (!pomoRunning && pomoRemainingMs == previous) {
      pomoRemainingMs = _phaseMs();
      await _writePomo();
    }
    onChanged();
  }

  Future<void> placeTask(String taskId, int quadrant) async {
    await db
        .into(db.taskPlacements)
        .insertOnConflictUpdate(
          TaskPlacementsCompanion(
            taskId: Value(taskId),
            quadrant: Value(quadrant),
          ),
        );
    placements[taskId] = quadrant;
    onChanged();
  }

  Future<void> clearPlacement(String taskId) async {
    await (db.delete(
      db.taskPlacements,
    )..where((row) => row.taskId.equals(taskId))).go();
    placements.remove(taskId);
    onChanged();
  }

  Future<void> addHabit(String name, {int color = 0xFF1F4B4A}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await db
        .into(db.habits)
        .insert(
          HabitsCompanion.insert(
            id: _uuid.v4(),
            name: trimmed,
            createdAt: now().millisecondsSinceEpoch,
            sortOrder: Value(habits.length),
            color: Value(color),
          ),
        );
    await _loadHabits();
    onChanged();
  }

  Future<void> renameHabit(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await (db.update(db.habits)..where((row) => row.id.equals(id))).write(
      HabitsCompanion(name: Value(trimmed)),
    );
    await _loadHabits();
    onChanged();
  }

  Future<void> setHabitColor(String id, int color) async {
    await (db.update(db.habits)..where((row) => row.id.equals(id))).write(
      HabitsCompanion(color: Value(color)),
    );
    await _loadHabits();
    onChanged();
  }

  Future<void> setHabitReminder(String id, int? minute) async {
    await (db.update(db.habits)..where((row) => row.id.equals(id))).write(
      HabitsCompanion(reminderMinute: Value(minute)),
    );
    await _loadHabits();
    onChanged();
  }

  Future<void> setHabitArchived(String id, bool archived) async {
    await (db.update(db.habits)..where((row) => row.id.equals(id))).write(
      HabitsCompanion(archived: Value(archived)),
    );
    await _loadHabits();
    onChanged();
  }

  Future<void> toggleHabitToday(String habitId) async {
    final day = dayKey(now());
    final existing =
        await (db.select(db.habitChecks)..where(
              (row) => row.habitId.equals(habitId) & row.day.equals(day),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await db
          .into(db.habitChecks)
          .insert(HabitChecksCompanion.insert(habitId: habitId, day: day));
    } else {
      await (db.delete(db.habitChecks)
            ..where((row) => row.habitId.equals(habitId) & row.day.equals(day)))
          .go();
    }
    await _loadHabits();
    onChanged();
  }

  Future<void> saveDiary(String day, String body) async {
    await db
        .into(db.diaryEntries)
        .insertOnConflictUpdate(
          DiaryEntriesCompanion(
            day: Value(day),
            body: Value(body),
            updatedAt: Value(now().millisecondsSinceEpoch),
          ),
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
    phase = 'focus';
    pomoRemainingMs = _phaseMs();
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
    if (phase == 'focus') {
      await db
          .into(db.pomodoroSessions)
          .insert(
            PomodoroSessionsCompanion.insert(
              id: _uuid.v4(),
              finishedAt: now().millisecondsSinceEpoch,
              taskId: Value(pomoTaskId),
            ),
          );
      finishedSessions += 1;
      phase = finishedSessions % 4 == 0 ? 'long' : 'short';
    } else {
      phase = 'focus';
    }
    pomoRemainingMs = _phaseMs();
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
    await db
        .into(db.pomodoroStates)
        .insertOnConflictUpdate(
          PomodoroStatesCompanion(
            id: const Value(1),
            taskId: Value(pomoTaskId),
            focus: Value(phase == 'focus'),
            phase: Value(phase),
            remainingMs: Value(pomoRemainingMs),
            running: Value(pomoRunning),
            anchorMs: Value(pomoAnchorMs),
          ),
        );
  }

  Future<int> _minutes(String key, int fallback) async {
    final raw = await _setting(key);
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed < 1) {
      return fallback;
    }
    return parsed;
  }

  Future<String?> _setting(String key) async {
    final row = await (db.select(
      db.settingEntries,
    )..where((item) => item.settingKey.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _loadHabits() async {
    final rows = await (db.select(
      db.habits,
    )..where((row) => row.deleted.equals(false))).get();
    rows.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final checks = await db.select(db.habitChecks).get();
    final byHabit = <String, Set<String>>{};
    for (final check in checks) {
      byHabit.putIfAbsent(check.habitId, () => {}).add(check.day);
    }
    final today = DateTime(now().year, now().month, now().day);
    HabitView view(HabitRow row) {
      final days = byHabit[row.id] ?? const <String>{};
      return HabitView(
        id: row.id,
        name: row.name,
        color: row.color,
        archived: row.archived,
        reminderMinute: row.reminderMinute,
        checkedToday: days.contains(dayKey(today)),
        streak: _streak(days),
        week: [
          for (var offset = 6; offset >= 0; offset--)
            days.contains(dayKey(today.subtract(Duration(days: offset)))),
        ],
      );
    }

    habits = [for (final row in rows.where((row) => !row.archived)) view(row)];
    archivedHabits = [
      for (final row in rows.where((row) => row.archived)) view(row),
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

String clockLabel(int milliseconds) {
  final left = Duration(milliseconds: milliseconds < 0 ? 0 : milliseconds);
  final minutes = left.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = left.inSeconds.remainder(60).toString().padLeft(2, '0');
  final hours = left.inHours;
  if (hours > 0) {
    return '$hours:$minutes:$seconds';
  }
  return '$minutes:$seconds';
}
