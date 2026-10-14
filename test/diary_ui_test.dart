import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/local_tools.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/ui/tools_pane.dart';

void main() {
  testWidgets(
    'past entries open directly and today restores the current draft',
    (tester) async {
      final repo = TaskRepository(TasDatabase.memory());
      await repo.init();
      final now = DateTime.now();
      final past = DateTime(now.year, now.month, now.day - 10);
      await repo.tools.saveDiary(dayKey(past), 'A memorable day');
      await tester.pumpWidget(
        RepoScope(
          repository: repo,
          child: const MaterialApp(home: Scaffold(body: DiaryPage())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('diary-body')),
        'Today in progress',
      );
      await tester.tap(find.byKey(const Key('diary-history')));
      await tester.pumpAndSettle();
      expect(find.text('A memorable day'), findsOneWidget);
      await tester.tap(find.byKey(Key('diary-entry-${dayKey(past)}')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('diary-body')))
            .controller!
            .text,
        'A memorable day',
      );
      await tester.tap(find.byKey(const Key('diary-today')));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('diary-body')))
            .controller!
            .text,
        'Today in progress',
      );
      expect(repo.tools.diary[dayKey(now)], 'Today in progress');
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.db.close();
    },
  );

  testWidgets('diary editor fits narrow keyboard-sized space', (tester) async {
    final repo = TaskRepository(TasDatabase.memory());
    await repo.init();
    tester.view.physicalSize = const Size(320, 280);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepoScope(
        repository: repo,
        child: const MaterialApp(home: Scaffold(body: DiaryPage())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('diary-body')),
      'Small screen draft',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.db.close();
  });
}
