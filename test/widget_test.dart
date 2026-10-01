import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/data/task_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  testWidgets('quick add parses 今日 and shows the task on 今日', (tester) async {
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

    await tester.tap(find.byKey(const Key('nav-today')));
    await tester.pump();
    expect(find.text('今日のタスクはありません。'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('quick-add-field')),
      '資料を送る 今日',
    );
    await tester.tap(find.byKey(const Key('quick-add-submit')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('資料を送る'), findsWidgets);

    await tester.tap(find.text('リスト').first);
    await tester.pump();
    await tester.tap(find.text('受信箱').first);
    await tester.pump();
    await tester.enterText(find.byKey(const Key('quick-add-field')), 'いつか読む');
    await tester.tap(find.byKey(const Key('quick-add-submit')));
    await tester.pump();

    await tester.tap(find.byKey(const Key('nav-today')));
    await tester.pump();
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

    await tester.enterText(find.byKey(const Key('quick-add-field')), '机を片付ける');
    await tester.tap(find.byKey(const Key('quick-add-submit')));
    await tester.pump();
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
    expect(find.text('優先度'), findsOneWidget);

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
}
