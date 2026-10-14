import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/domain/tab_layout.dart';

void main() {
  test('legacy tools expand in place preserving hidden preferences', () {
    final items = parseTabLayout('settings,-tools,today,lists,calendar');
    expect(items.map((e) => e.id), [
      'settings',
      ...independentToolTabs,
      'today',
      'lists',
      'calendar',
    ]);
    expect(
      items
          .where((e) => independentToolTabs.contains(e.id))
          .every((e) => !e.visible),
      isTrue,
    );
    final explicit = parseTabLayout('tools,-diary');
    expect(explicit.singleWhere((e) => e.id == 'diary').visible, isFalse);
    expect(explicit.map((e) => e.id).toSet().length, explicit.length);
    expect(
      encodeTabLayout(parseTabLayout(encodeTabLayout(items))),
      encodeTabLayout(items),
    );
  });

  testWidgets('tab editor moves individual features and persists visibility', (
    tester,
  ) async {
    final db = TasDatabase.memory();
    final repo = TaskRepository(db);
    await repo.init();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
      repo.dispose();
      await db.close();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(TasApp(repository: repo));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('edit-tabs')));
    await tester.pumpAndSettle();
    final diaryRow = find.byKey(const ValueKey('diary'));
    await tester.tap(
      find.descendant(of: diaryRow, matching: find.byTooltip('上に移動')),
    );
    await tester.pumpAndSettle();
    expect(parseTabLayout(repo.tabLayout)[2].id, 'diary');
    final habitRow = find.byKey(const ValueKey('habits'));
    await tester.tap(
      find.descendant(of: habitRow, matching: find.byType(Switch)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav-habits')), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('nav-diary')));
    await tester.tap(find.byKey(const Key('nav-diary')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('diary-body')), findsOneWidget);
    final stored = TaskRepository(db);
    await stored.init();
    expect(stored.tabLayout, repo.tabLayout);
    expect(parseTabLayout(stored.tabLayout)[2].id, 'diary');
    stored.dispose();
    expect(tester.takeException(), isNull);
  });
}
