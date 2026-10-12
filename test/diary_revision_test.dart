import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tas/app.dart';
import 'package:tas/data/local_tools.dart';
import 'package:tas/data/task_repository.dart';
import 'package:tas/data/tas_database.dart';
import 'package:tas/ui/tools_pane.dart';

void main() {
  testWidgets('an older matching save cannot discard a newer diary revision', (
    tester,
  ) async {
    final repo = _ControlledRepository(TasDatabase.memory());
    await tester.pumpWidget(
      RepoScope(
        repository: repo,
        child: const MaterialApp(home: Scaffold(body: DiaryPage())),
      ),
    );
    final editor = find.byType(TextField);
    await tester.enterText(editor, 'A');
    await tester.pump(const Duration(milliseconds: 301));
    expect(repo.tools.writes, ['A']);

    await tester.enterText(editor, 'B');
    await tester.pump(const Duration(milliseconds: 301));
    // B is queued behind the still-pending first A write.
    await tester.enterText(editor, 'A');
    repo.tools.completeNext();
    await tester.pump();
    expect(repo.tools.writes, ['A', 'B']);
    await tester.pump(const Duration(milliseconds: 301));
    repo.tools.completeNext();
    await tester.pump();
    expect(repo.tools.writes, ['A', 'B', 'A']);
    expect(tester.widget<TextField>(editor).controller!.text, 'A');
    repo.tools.completeNext();
    await tester.pump();
    expect(repo.tools.diary.values.single, 'A');
    await tester.pumpWidget(const SizedBox.shrink());
    repo.dispose();
    await repo.db.close();
  });
}

class _ControlledRepository extends TaskRepository {
  _ControlledRepository(super.db) {
    controlledTools = _ControlledTools(db, onChanged: notifyListeners);
  }

  late final _ControlledTools controlledTools;

  @override
  _ControlledTools get tools => controlledTools;
}

class _ControlledTools extends LocalTools {
  _ControlledTools(super.db, {required super.onChanged})
    : super(now: DateTime.now);

  final writes = <String>[];
  final _completions = <Completer<void>>[];

  void completeNext() => _completions.removeAt(0).complete();

  @override
  Future<void> saveDiary(String day, String body) async {
    writes.add(body);
    final completion = Completer<void>();
    _completions.add(completion);
    await completion.future;
    diary[day] = body;
    onChanged();
  }
}
