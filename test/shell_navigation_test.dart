import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/domain/tab_layout.dart';

void main() {
  Future<TaskRepository> launch(
    WidgetTester tester, {
    bool desktop = false,
  }) async {
    final repo = TaskRepository(TasDatabase.memory());
    await repo.init();
    tester.view.physicalSize = desktop
        ? const Size(1400, 900)
        : const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      await repo.db.close();
      repo.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('back returns to a visible home when preferred home is hidden', (
    tester,
  ) async {
    final repo = await launch(tester);
    await repo.setTabLayout(
      parseTabLayout('-today,lists,calendar,tools,settings'),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-layout')), findsNothing);
    await tester.tap(find.byKey(const Key('nav-calendar')));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-layout')), findsNothing);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
    expect(await tester.binding.handlePopRoute(), isFalse);
  });

  testWidgets('hiding every tab keeps settings available to restore them', (
    tester,
  ) async {
    final repo = await launch(tester);
    await repo.setTabLayout([for (final id in tabIds) TabItem(id, false)]);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('タブの並び'), findsOneWidget);
    await repo.setTabLayout(parseTabLayout(defaultTabLayout));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('desktop search shortcut opens a search field from home', (
    tester,
  ) async {
    await launch(tester, desktop: true);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    final editable = tester.widget<EditableText>(
      find.byType(EditableText).first,
    );
    expect(editable.focusNode.hasFocus, isTrue);
  });

  testWidgets('desktop settings replaces an open tool', (tester) async {
    await launch(tester, desktop: true);
    await tester.tap(find.widgetWithText(ListTile, 'ポモドーロ'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, '設定'));
    await tester.pumpAndSettle();
    expect(find.text('タブの並び'), findsOneWidget);
  });
}
