import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/local_tools.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/domain/home_layout.dart';
import 'package:tas/ui/home_layout_page.dart';
import 'package:tas/ui/today_home.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'legacy layout preserves order and hidden blocks while adding tools',
    () {
      final blocks = parseHomeLayout('habits,-week,schedule,overdue');
      expect(blocks.map((block) => block.id), [
        'habits',
        'week',
        'schedule',
        'overdue',
        'pomodoro',
        'diary',
        'matrix',
      ]);
      expect(blocks[1].visible, isFalse);
      expect(blocks.skip(4).every((block) => block.visible), isTrue);
    },
  );

  test('layout normalization ignores unknown and repeated blocks', () {
    final blocks = parseHomeLayout('diary,unknown,-diary,-pomodoro,, week');
    final encoded = encodeHomeLayout(blocks);
    expect(encoded, 'diary,-pomodoro,week,schedule,overdue,habits,matrix');
    expect(encodeHomeLayout(parseHomeLayout(encoded)), encoded);
    expect(
      encodeHomeLayout([
        const HomeBlock('diary', false),
        const HomeBlock('diary', true),
        const HomeBlock('unknown', true),
      ]),
      '-diary,week,schedule,overdue,habits,pomodoro,matrix',
    );
  });

  test('layout order and visibility survive repository reload', () async {
    final db = TasDatabase.memory();
    final repo = TaskRepository(db);
    await repo.init();
    final layout = parseHomeLayout(
      'diary,-pomodoro,matrix,habits,overdue,schedule,-week',
    );
    await repo.setHomeLayout(layout);
    final reopened = TaskRepository(db);
    await reopened.init();
    expect(reopened.homeLayout, encodeHomeLayout(layout));
    repo.dispose();
    reopened.dispose();
    await db.close();
  });

  testWidgets('home edits every block, including Pomodoro and Diary', (
    tester,
  ) async {
    final repo = await _repository();
    _largeScreen(tester);
    await tester.pumpWidget(_app(repo, TodayHome(onOpen: (_) {})));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-layout')));
    await tester.pumpAndSettle();
    for (final id in homeSectionIds) {
      expect(find.byKey(ValueKey('home-inline-drag-$id')), findsOneWidget);
      expect(find.byKey(ValueKey('home-inline-visible-$id')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('home-inline-up-diary')));
    await tester.pumpAndSettle();
    expect(
      parseHomeLayout(repo.homeLayout).map((block) => block.id).toList()[4],
      'diary',
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('home-block-diary'))).dy,
      lessThan(
        tester.getTopLeft(find.byKey(const Key('home-block-pomodoro'))).dy,
      ),
    );
    await tester.tap(find.byKey(const Key('home-inline-visible-pomodoro')));
    await tester.pumpAndSettle();
    expect(
      parseHomeLayout(repo.homeLayout)
          .firstWhere((block) => block.id == 'pomodoro')
          .visible,
      isFalse,
    );
    await tester.tap(find.byKey(const Key('home-layout')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-block-pomodoro')), findsNothing);
    await _close(tester, repo);
  });

  testWidgets('home drag handle saves the new order', (tester) async {
    final repo = await _repository(
      'pomodoro,diary,week,schedule,overdue,habits,matrix',
    );
    _largeScreen(tester);
    await tester.pumpWidget(_app(repo, TodayHome(onOpen: (_) {})));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-layout')));
    await tester.pumpAndSettle();
    final from = tester.getCenter(
      find.byKey(const Key('home-inline-drag-pomodoro')),
    );
    final belowDiary =
        tester.getBottomLeft(find.byKey(const Key('home-block-diary'))).dy + 10;
    final gesture = await tester.startGesture(from);
    await tester.pump();
    await gesture.moveBy(Offset(0, belowDiary - from.dy));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(parseHomeLayout(repo.homeLayout).first.id, 'diary');
    await _close(tester, repo);
  });

  testWidgets('layout settings reorder and hide tool blocks on a phone', (
    tester,
  ) async {
    final repo = await _repository();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(_app(repo, const HomeLayoutPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-up-diary')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-visible-pomodoro')));
    await tester.pumpAndSettle();
    final blocks = parseHomeLayout(repo.homeLayout);
    expect(blocks[4].id, 'diary');
    expect(blocks[5].id, 'pomodoro');
    expect(blocks[5].visible, isFalse);
    expect(tester.takeException(), isNull);
    await _close(tester, repo);
  });

  testWidgets('home diary stays on its original day when switching the week', (
    tester,
  ) async {
    final repo = await _repository(
      'week,diary,-schedule,-overdue,-habits,-pomodoro,-matrix',
    );
    _largeScreen(tester);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final other = today.add(
      Duration(days: today.weekday == DateTime.sunday ? -1 : 1),
    );
    await repo.tools.saveDiary(dayKey(other), '別の日の記録');
    await tester.pumpWidget(_app(repo, TodayHome(onOpen: (_) {})));
    await tester.pumpAndSettle();
    final diary = find.byKey(const Key('home-diary-body'));
    await tester.enterText(diary, '今日の下書き');
    // Switch before the debounce has saved the original day's draft.
    await tester.tap(
      find.byKey(Key('week-${other.year}-${other.month}-${other.day}')),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(diary).controller!.text, '別の日の記録');
    expect(repo.tools.diary[dayKey(today)], '今日の下書き');
    expect(repo.tools.diary[dayKey(other)], '別の日の記録');
    await _close(tester, repo);
  });

  testWidgets('repository notifications do not replace a pending diary draft', (
    tester,
  ) async {
    final repo = await _repository(
      'diary,-week,-schedule,-overdue,-habits,-pomodoro,-matrix',
    );
    await tester.pumpWidget(_app(repo, TodayHome(onOpen: (_) {})));
    await tester.pumpAndSettle();
    final diary = find.byKey(const Key('home-diary-body'));
    await tester.enterText(diary, '保存前の文章');
    // A timer tick or any other repository notification used to reload old text.
    await repo.tools.saveDiary('2000-01-01', 'unrelated entry');
    await tester.pump();
    expect(tester.widget<TextField>(diary).controller!.text, '保存前の文章');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(repo.tools.diary[dayKey(DateTime.now())], '保存前の文章');
    await _close(tester, repo);
  });

  testWidgets('moving diary preserves its controller and unsaved text', (
    tester,
  ) async {
    final repo = await _repository(
      'diary,pomodoro,-week,-schedule,-overdue,-habits,-matrix',
    );
    _largeScreen(tester);
    await tester.pumpWidget(_app(repo, TodayHome(onOpen: (_) {})));
    await tester.pumpAndSettle();
    final diary = find.byKey(const Key('home-diary-body'));
    final controller = tester.widget<TextField>(diary).controller;
    await tester.enterText(diary, '並べ替え中の文章');
    await tester.tap(find.byKey(const Key('home-layout')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('home-inline-down-diary')));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(diary).controller, same(controller));
    expect(controller!.text, '並べ替え中の文章');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(repo.tools.diary[dayKey(DateTime.now())], '並べ替え中の文章');
    await _close(tester, repo);
  });
}

Future<TaskRepository> _repository([String? layout]) async {
  final repo = TaskRepository(TasDatabase.memory());
  await repo.init();
  if (layout != null) await repo.setHomeLayout(parseHomeLayout(layout));
  return repo;
}

Widget _app(TaskRepository repo, Widget home) => RepoScope(
  repository: repo,
  child: MaterialApp(home: home),
);

void _largeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(720, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _close(WidgetTester tester, TaskRepository repo) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  repo.dispose();
  await repo.db.close();
}
