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
    final repo = TaskRepository(TasDatabase.memory(), now: () => DateTime(2026, 10, 1, 9));
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

    await tester.enterText(find.byKey(const Key('quick-add-field')), '資料を送る 今日');
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
    final repo = TaskRepository(TasDatabase.memory(), now: () => DateTime(2026, 10, 1, 9));
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
  });
}
