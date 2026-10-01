import 'package:flutter/material.dart';

import '../domain/models.dart';

class TasMark extends StatelessWidget {
  const TasMark({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(Icons.check_rounded, color: scheme.onPrimary, size: size * 0.72),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint({required this.message, super.key, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurface, fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickAddBar extends StatefulWidget {
  const QuickAddBar({required this.onSubmit, required this.focusNode, super.key});

  final Future<void> Function(String raw) onSubmit;
  final FocusNode focusNode;

  @override
  State<QuickAddBar> createState() => _QuickAddBarState();
}

class _QuickAddBarState extends State<QuickAddBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final raw = _controller.text;
    if (raw.trim().isEmpty) {
      return;
    }
    await widget.onSubmit(raw);
    if (mounted) {
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('quick-add-field'),
                controller: _controller,
                focusNode: widget.focusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'タスクを追加（例: 資料を送る 明日 10時）',
                  prefixIcon: Icon(Icons.add_task_outlined),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              key: const Key('quick-add-submit'),
              tooltip: '追加',
              onPressed: _submit,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.selected,
    required this.onOpen,
    required this.onToggle,
    required this.subtitle,
    super.key,
  });

  final TaskModel task;
  final bool selected;
  final VoidCallback onOpen;
  final VoidCallback onToggle;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final overdue = task.dueAt != null && isOverdue(task.dueAt!, now, completed: task.isCompleted);
    return Material(
      color: selected ? scheme.primaryContainer.withValues(alpha: 0.55) : Colors.transparent,
      child: InkWell(
        onTap: onOpen,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Container(width: 3, height: 36, color: priorityColor(task.priority)),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  tooltip: task.isCompleted ? '未完了に戻す' : '完了にする',
                  onPressed: onToggle,
                  icon: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: task.isCompleted ? scheme.primary : scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? scheme.onSurfaceVariant : scheme.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: overdue ? scheme.error : scheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String action,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
      ],
    ),
  );
  return result ?? false;
}

void showUndoSnack(BuildContext context, String message, Future<void> Function() undo) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      action: SnackBarAction(label: '元に戻す', onPressed: () => undo()),
    ),
  );
}

String taskSubtitle({
  required TaskModel task,
  required String? listName,
  required List<TagModel> tags,
  required int checklistDone,
  required int checklistTotal,
  required DateTime now,
  required bool showList,
}) {
  final parts = <String>[];
  if (task.dueAt != null) {
    parts.add(formatDue(task.dueAt!, hasTime: task.dueHasTime, now: now));
  }
  if (task.priority > 0) {
    parts.add(priorityLabel(task.priority));
  }
  if (showList && listName != null) {
    parts.add(listName);
  }
  if (tags.isNotEmpty) {
    parts.add(tags.map((tag) => tag.name).join(' · '));
  }
  if (checklistTotal > 0) {
    parts.add('$checklistDone/$checklistTotal');
  }
  if (task.recurrence != 'none') {
    parts.add(recurrenceLabel(task.recurrence));
  }
  return parts.join('  ·  ');
}
