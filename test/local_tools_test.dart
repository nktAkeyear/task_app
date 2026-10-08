import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/data/local_tools.dart';
import 'package:tas/data/tas_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('habits, diary, matrix, and pomodoro stay in sqlite', () async {
    final db = TasDatabase.memory();
    var now = DateTime(2026, 10, 1, 9);
    final tools = LocalTools(db, now: () => now, onChanged: () {});
    await tools.load();

    await tools.addHabit('水を飲む');
    await tools.toggleHabitToday(tools.habits.single.id);
    expect(tools.habits.single.checkedToday, isTrue);
    expect(tools.habits.single.streak, 1);

    await tools.saveDiary('2026-10-01', '晴れ');
    await tools.placeTask('task-1', 0);
    expect(tools.placements['task-1'], 0);

    await tools.startPomo();
    now = now.add(const Duration(minutes: 26));
    await tools.tickPomo();
    expect(tools.finishedSessions, 1);
    expect(tools.pomoFocus, isFalse);
    expect(tools.pomoRunning, isFalse);

    final again = LocalTools(db, now: () => now, onChanged: () {});
    await again.load();
    expect(again.habits.single.name, '水を飲む');
    expect(again.habits.single.streak, 1);
    expect(again.diary['2026-10-01'], '晴れ');
    expect(again.placements['task-1'], 0);
    expect(again.finishedSessions, 1);
    expect(again.pomoFocus, isFalse);
  });

  test('a quantity goal counts a slide as one step and streaks only when met', () async {
    final db = TasDatabase.memory();
    final tools = LocalTools(
      db,
      now: () => DateTime(2026, 10, 1, 9),
      onChanged: () {},
    );
    await tools.load();

    await tools.addHabit('水を飲む', goal: 3);
    final id = tools.habits.single.id;
    await tools.logHabit(id);
    expect(tools.habits.single.progress, 1);
    expect(tools.habits.single.goal, 3);
    expect(tools.habits.single.checkedToday, isFalse);
    expect(tools.habits.single.streak, 0);

    await tools.logHabit(id);
    expect(tools.habits.single.streak, 0);
    await tools.logHabit(id);
    expect(tools.habits.single.progress, 3);
    expect(tools.habits.single.checkedToday, isTrue);
    expect(tools.habits.single.streak, 1);
  });

  test('a one-step habit completes on one slide and on one tap', () async {
    final db = TasDatabase.memory();
    final tools = LocalTools(
      db,
      now: () => DateTime(2026, 10, 1, 9),
      onChanged: () {},
    );
    await tools.load();

    await tools.addHabit('読む');
    final id = tools.habits.single.id;
    await tools.logHabit(id);
    expect(tools.habits.single.streak, 1);
    await tools.logHabit(id);
    expect(tools.habits.single.streak, 0);
    await tools.logHabit(id, toggle: true);
    expect(tools.habits.single.streak, 1);
    await tools.logHabit(id, toggle: true);
    expect(tools.habits.single.streak, 0);
  });
}
