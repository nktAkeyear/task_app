import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/ui/add_sheet.dart';

void main() {
  for (final systemBack in [false, true]) {
    testWidgets(
      'text import ${systemBack ? 'system' : 'toolbar'} back preserves task draft',
      (tester) async {
        final repo = TaskRepository(TasDatabase.memory());
        await repo.init();
        final listId = await repo.createList('Draft destination');
        final day = DateTime(2026, 10, 20);
        addTearDown(() async {
          await tester.pumpWidget(const SizedBox.shrink());
          await repo.db.close();
          repo.dispose();
        });
        await tester.pumpWidget(
          RepoScope(
            repository: repo,
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () =>
                        showAddSheet(context, listId: listId, day: day),
                    child: const Text('Open composer'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open composer'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('create-title')),
          'Draft task',
        );
        await tester.enterText(
          find.byKey(const Key('create-notes')),
          'Draft memo',
        );
        await tester.ensureVisible(find.byKey(const Key('text-import')));
        await tester.tap(find.byKey(const Key('text-import')));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('text-import-input')), findsOneWidget);
        await tester.enterText(
          find.byKey(const Key('text-import-input')),
          'Uncommitted import',
        );
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(find.byType(BackButton));
        }
        await tester.pumpAndSettle();
        expect(find.byType(AddSheet), findsOneWidget);
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('create-title')))
              .controller!
              .text,
          'Draft task',
        );
        expect(
          tester
              .widget<TextField>(find.byKey(const Key('create-notes')))
              .controller!
              .text,
          'Draft memo',
        );
        expect(repo.tasks, isEmpty);
        await tester.tap(find.byKey(const Key('create-save')));
        await tester.pumpAndSettle();
        final task = repo.tasks.single;
        expect(task.title, 'Draft task');
        expect(task.notes, 'Draft memo');
        expect(task.listId, listId);
        expect(task.dueAt, day);
        expect(find.text('Open composer'), findsOneWidget);
      },
    );
  }
}
