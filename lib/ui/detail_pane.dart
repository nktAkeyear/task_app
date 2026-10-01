import 'package:flutter/material.dart';

import '../app.dart';
import '../l10n/copy.dart';
import 'task_composer.dart';
import 'widgets.dart';

class DetailPane extends StatefulWidget {
  const DetailPane({required this.taskId, this.embedded = false, super.key});

  final String taskId;
  final bool embedded;

  @override
  State<DetailPane> createState() => _DetailPaneState();
}

class _DetailPaneState extends State<DetailPane> {
  final _check = TextEditingController();

  @override
  void dispose() {
    _check.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final task = repo.taskById(widget.taskId);
    final copy = Copy.of(context);
    if (task == null || task.deleted) {
      return EmptyHint(message: copy.taskGone, icon: Icons.delete_outline);
    }
    final items = repo.checklistFor(task.id);
    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        Row(
          children: [
            const Spacer(),
            TextButton.icon(
              key: const Key('open-editor'),
              onPressed: _edit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(copy.edit),
            ),
          ],
        ),
        TaskFactView(task: task, onEdit: _edit),
        if (task.reminderAt != null) ...[
          const SizedBox(height: 8),
          Text(
            copy.notifyAt(
              copy.due(task.reminderAt!, hasTime: true, now: DateTime.now()),
            ),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          copy.checklist,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        for (final item in items)
          Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Checkbox(
                  value: item.done,
                  onChanged: (_) => repo.toggleChecklistItem(item.id),
                ),
              ),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.done ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              IconButton(
                tooltip: copy.deleteItem,
                onPressed: () => repo.deleteChecklistItem(item.id),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _check,
                decoration: InputDecoration(hintText: copy.addItem),
                onSubmitted: (value) => _addCheck(task.id, value),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: copy.addItem,
              onPressed: () => _addCheck(task.id, _check.text),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () async {
            final ok = await confirmAction(
              context,
              title: copy.deleteTask,
              message: copy.deleteTaskAsk(task.title),
              action: copy.delete,
            );
            if (!ok || !context.mounted) {
              return;
            }
            final message = await repo.deleteTask(task.id);
            if (context.mounted) {
              showUndoSnack(context, message, repo.undo);
              if (!widget.embedded && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: Text(copy.deleteTask),
        ),
      ],
    );

    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(copy.detail),
        actions: [
          IconButton(
            tooltip: task.isCompleted ? copy.markUndone : copy.markDone,
            onPressed: () async {
              final message = await repo.toggleComplete(task.id);
              if (context.mounted) {
                showUndoSnack(context, message, repo.undo);
              }
            },
            icon: Icon(
              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            ),
          ),
        ],
      ),
      body: body,
    );
  }

  void _edit() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TaskComposerPage(taskId: widget.taskId),
      ),
    );
  }

  Future<void> _addCheck(String taskId, String raw) async {
    if (raw.trim().isEmpty) {
      return;
    }
    await RepoScope.of(context).addChecklistItem(taskId, raw);
    if (mounted) {
      _check.clear();
    }
  }
}
