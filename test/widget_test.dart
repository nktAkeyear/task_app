import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/domain/filters.dart';
import 'package:tas/domain/models.dart';
import 'package:tas/l10n/copy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('text import parses 今日 and waits to confirm', (tester) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();

    expect(find.text('今日のタスクはありません。'), findsOneWidget);
    expect(find.byKey(const Key('quick-add-field')), findsNothing);

    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('タスクを作成'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('create-title')), '下書き');
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('下書き'), findsNothing);
    expect(find.text('今日のタスクはありません。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('text-import')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(
      find.byKey(const Key('text-import-input')),
      '資料を送る 今日\nいつか読む',
    );
    await tester.pump();
    expect(find.text('資料を送る'), findsWidgets);
    expect(find.text('いつか読む'), findsWidgets);

    await tester.tap(find.byKey(const Key('text-import-save')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('資料を送る'), findsWidgets);
    expect(find.text('いつか読む'), findsNothing);
  });

  testWidgets('desktop shows three panes', (tester) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();

    expect(find.byKey(const Key('pane-lists')), findsOneWidget);
    expect(find.byKey(const Key('pane-tasks')), findsOneWidget);
    expect(find.byKey(const Key('pane-detail')), findsOneWidget);
    expect(find.text('タスクを選ぶと、メモや期限を編集できます。'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('create-title')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('create-title')), '机を片付ける');
    await tester.tap(find.byKey(const Key('create-save')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('机を片付ける'), findsWidgets);
    expect(tester.getTopLeft(find.byKey(const Key('pane-lists'))).dy, 0);
  });

  testWidgets('status bar inset keeps the header below the clock', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 48, bottom: 24);
    tester.view.viewPadding = const FakeViewPadding(top: 48, bottom: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();

    expect(tester.getTopLeft(find.text('今日').first).dy, greaterThanOrEqualTo(48));
    expect(
      tester.getBottomLeft(find.byType(NavigationBar)).dy,
      lessThanOrEqualTo(844 - 24),
    );
  });

  testWidgets('tabs do not stack and system back leaves only the home tab', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();
    expect(find.byKey(const Key('back-in-app')), findsNothing);
    expect(find.text('今日のタスクはありません。'), findsOneWidget);

    await tester.tap(find.text('リスト').first);
    await tester.pump();
    expect(find.byKey(const Key('back-in-app')), findsNothing);
    await tester.tap(find.text('受信箱').first);
    await tester.pump();
    expect(find.text('リストへ戻る'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('タスクを作成'), findsOneWidget);
    expect(find.byKey(const Key('create-title')), findsOneWidget);
    expect(find.text('メモ'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('タスクを作成'), findsNothing);
    expect(find.text('リストへ戻る'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('back-in-app')), findsNothing);
    expect(find.text('受信箱'), findsWidgets);

    final leftHome = await tester.binding.handlePopRoute();
    await tester.pump();
    expect(leftHome, isTrue);
    expect(find.text('今日のタスクはありません。'), findsOneWidget);
    expect(find.byKey(const Key('back-in-app')), findsNothing);

    await tester.tap(find.text('リスト').first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('nav-today')));
    await tester.pump();
    expect(find.byKey(const Key('back-in-app')), findsNothing);
    final leave = await tester.binding.handlePopRoute();
    expect(leave, isFalse);
  });

  testWidgets('English and Korean cover the same navigation labels', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    await repo.setLanguage('en');
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();
    expect(find.text('Today'), findsWidgets);
    expect(find.text('Lists'), findsWidgets);
    expect(find.text('Nothing due today.'), findsOneWidget);

    await repo.setLanguage('ko');
    await tester.pump();
    expect(find.text('오늘'), findsWidgets);
    expect(find.text('목록'), findsWidgets);
    expect(find.text('오늘 할 일이 없습니다.'), findsOneWidget);

    await repo.setLanguage('ja');
    await tester.pump();
    expect(find.text('今日'), findsWidgets);
    expect(find.text('今日のタスクはありません。'), findsOneWidget);
  });

  testWidgets('tools keep habits, the matrix, and the diary offline', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();

    await tester.tap(find.byKey(const Key('nav-tools')));
    await tester.pump();
    expect(find.text('ポモドーロ'), findsOneWidget);
    expect(find.text('マトリックス'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tool-habits')));
    await tester.pump();
    expect(find.text('習慣はまだありません。'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '水を飲む');
    await tester.tap(find.text('追加'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('水を飲む'), findsOneWidget);
    expect(find.text('連続 0 日'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('連続 1 日'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.check).first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('連続 0 日'), findsOneWidget);

    await tester.tap(find.text('戻る'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tool-matrix')));
    await tester.pump();
    expect(find.text('この区分のタスクはありません。'), findsWidgets);

    await tester.tap(find.text('戻る'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tool-diary')));
    await tester.pump();
    expect(find.text('この日の日記はまだありません。'), findsOneWidget);
    expect(find.byKey(const Key('diary-date')), findsOneWidget);

    await tester.tap(find.text('戻る'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tool-pomodoro')));
    await tester.pump();
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('開始'), findsOneWidget);
  });

  testWidgets('a habit goal above one shows partial progress before the streak', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();
    await tester.tap(find.byKey(const Key('nav-tools')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('tool-habits')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('habit-goal-more')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('habit-goal-more')));
    await tester.pump();
    expect(find.text('1日の目標 3'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '水を飲む');
    await tester.tap(find.text('追加'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('0/3'), findsOneWidget);
    expect(find.text('連続 0 日'), findsOneWidget);

    await tester.drag(find.byIcon(Icons.check), const Offset(80, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('1/3'), findsOneWidget);
    expect(find.text('連続 0 日'), findsOneWidget);

    await tester.drag(find.byIcon(Icons.check), const Offset(80, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('2/3'), findsOneWidget);
    expect(find.text('連続 0 日'), findsOneWidget);

    await tester.drag(find.byIcon(Icons.check), const Offset(80, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('3/3'), findsOneWidget);
    expect(find.text('連続 1 日'), findsOneWidget);
  });

  test('inbox and backup dialog titles follow the language', () {
    final inbox = ListModel(
      id: inboxId,
      name: '受信箱',
      color: 0,
      sortOrder: 0,
      isInbox: true,
      archived: false,
      deleted: false,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    final named = ListModel(
      id: 'work',
      name: '仕事',
      color: 0,
      sortOrder: 1,
      isInbox: false,
      archived: false,
      deleted: false,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(const Copy('ja').listTitle(inbox), '受信箱');
    expect(const Copy('en').listTitle(inbox), 'Inbox');
    expect(const Copy('ko').listTitle(inbox), '받은편지함');
    expect(const Copy('en').listTitle(named), '仕事');
    expect(const Copy('ja').exportDialog, 'バックアップを書き出す');
    expect(const Copy('en').exportDialog, 'Export backup');
    expect(const Copy('ko').exportDialog, '백업 내보내기');
    expect(const Copy('ja').importDialog, 'バックアップを読み込む');
    expect(const Copy('en').importDialog, 'Import backup');
    expect(const Copy('ko').importDialog, '백업 가져오기');
  });

  testWidgets('English inbox label and calendar follow the app language', (
    tester,
  ) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    await repo.setLanguage('en');
    final today = DateTime.now();
    await repo.createTask(
      title: 'Read later',
      listId: inboxId,
      due: DateTime(today.year, today.month, today.day),
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();
    expect(find.text('Today  ·  Inbox'), findsOneWidget);

    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Inbox'), findsWidgets);
    expect(find.text('受信箱'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Read later'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Inbox'), findsWidgets);

    await tester.tap(find.byKey(const Key('open-editor')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Edit task'), findsOneWidget);
    await tester.tap(find.byKey(const Key('composer-start-date')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('October 2026'), findsOneWidget);
  });

  test('an empty end is one day and a set end covers the range', () {
    final point = _task(due: DateTime(2026, 10, 2));
    expect(coversDay(point, DateTime(2026, 10, 2)), isTrue);
    expect(coversDay(point, DateTime(2026, 10, 3)), isFalse);

    final range = _task(
      due: DateTime(2026, 10, 1, 9),
      ends: DateTime(2026, 10, 3, 18),
      hasTime: true,
    );
    expect(coversDay(range, DateTime(2026, 9, 30)), isFalse);
    expect(coversDay(range, DateTime(2026, 10, 1)), isTrue);
    expect(coversDay(range, DateTime(2026, 10, 2)), isTrue);
    expect(coversDay(range, DateTime(2026, 10, 3)), isTrue);
    expect(coversDay(range, DateTime(2026, 10, 4)), isFalse);
  });

  testWidgets('all-day hides times until it is switched off', (tester) async {
    final repo = TaskRepository(
      TasDatabase.memory(),
      now: () => DateTime(2026, 10, 1, 9),
    );
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pump();
    await tester.tap(find.byKey(const Key('create-task')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const Key('composer-start-time')), findsNothing);
    expect(find.byKey(const Key('composer-end-date')), findsOneWidget);

    await tester.tap(find.byKey(const Key('composer-all-day')));
    await tester.pump();
    expect(find.byKey(const Key('composer-start-time')), findsOneWidget);
    expect(find.byKey(const Key('composer-end-time')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('create-title')), '範囲');
    await tester.tap(find.byKey(const Key('create-save')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('範囲'), findsWidgets);
    expect(repo.tasks.where((task) => task.title == '範囲'), isNotEmpty);
  });
}

TaskModel _task({required DateTime due, DateTime? ends, bool hasTime = false}) {
  return TaskModel(
    id: 't',
    listId: inboxId,
    title: '予定',
    notes: '',
    dueAt: due,
    dueHasTime: hasTime,
    endsAt: ends,
    priority: 0,
    recurrence: 'none',
    reminder: 'none',
    reminderAt: null,
    reminderFired: false,
    sortOrder: 0,
    completedAt: null,
    deleted: false,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );
}
