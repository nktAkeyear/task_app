import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/models.dart';
import '../domain/recurrence.dart';
import '../l10n/copy.dart';
import 'widgets.dart';

class DetailPane extends StatefulWidget {
  const DetailPane({required this.taskId, this.embedded = false, super.key});

  final String taskId;
  final bool embedded;

  @override
  State<DetailPane> createState() => _DetailPaneState();
}

class _DetailPaneState extends State<DetailPane> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late final TextEditingController _check;
  final _titleFocus = FocusNode();
  final _notesFocus = FocusNode();
  Timer? _titleTimer;
  Timer? _notesTimer;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _notes = TextEditingController();
    _check = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) {
      return;
    }
    _seeded = true;
    final task = RepoScope.of(context).taskById(widget.taskId);
    _title.text = task?.title ?? '';
    _notes.text = task?.notes ?? '';
  }

  @override
  void didUpdateWidget(DetailPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final task = RepoScope.of(context).taskById(widget.taskId);
    if (task == null) {
      return;
    }
    if (!_titleFocus.hasFocus && task.title != _title.text) {
      _title.text = task.title;
    }
    if (!_notesFocus.hasFocus && task.notes != _notes.text) {
      _notes.text = task.notes;
    }
  }

  @override
  void dispose() {
    _titleTimer?.cancel();
    _notesTimer?.cancel();
    _title.dispose();
    _notes.dispose();
    _check.dispose();
    _titleFocus.dispose();
    _notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final task = repo.taskById(widget.taskId);
    final scheme = Theme.of(context).colorScheme;
    final copy = Copy.of(context);
    if (task == null || task.deleted) {
      return EmptyHint(message: copy.taskGone, icon: Icons.delete_outline);
    }
    final items = repo.checklistFor(task.id);
    final lists = repo.lists.where((list) => !list.deleted).toList()
      ..sort((a, b) {
        if (a.isInbox != b.isInbox) {
          return a.isInbox ? -1 : 1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        TextField(
          controller: _title,
          focusNode: _titleFocus,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
          decoration: InputDecoration(
            hintText: copy.taskName,
            border: InputBorder.none,
            filled: false,
          ),
          onChanged: (value) {
            _titleTimer?.cancel();
            _titleTimer = Timer(
              const Duration(milliseconds: 120),
              () => repo.setTitle(task.id, value),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          focusNode: _notesFocus,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(hintText: copy.notes),
          onChanged: (value) {
            _notesTimer?.cancel();
            _notesTimer = Timer(
              const Duration(milliseconds: 120),
              () => repo.setNotes(task.id, value),
            );
          },
        ),
        const SizedBox(height: 16),
        _Label(copy.lists),
        DropdownButtonFormField<String>(
          key: ValueKey(task.listId),
          initialValue: lists.any((list) => list.id == task.listId)
              ? task.listId
              : inboxId,
          items: [
            for (final list in lists)
              DropdownMenuItem(
                value: list.id,
                child: Text(list.name, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              repo.moveToList(task.id, value);
            }
          },
        ),
        const SizedBox(height: 16),
        _Label(copy.dueLabel),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pickDate(task),
              icon: const Icon(Icons.event_outlined),
              label: Text(
                task.dueAt == null
                    ? copy.pickDate
                    : copy.due(
                        task.dueAt!,
                        hasTime: false,
                        now: DateTime.now(),
                      ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: task.dueAt == null ? null : () => _pickTime(task),
              icon: const Icon(Icons.schedule),
              label: Text(
                task.dueHasTime && task.dueAt != null
                    ? _clock(task.dueAt!)
                    : copy.time,
              ),
            ),
            if (task.dueAt != null)
              TextButton(
                onPressed: () => repo.setDue(task.id, null, hasTime: false),
                child: Text(copy.clearDue),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Label(copy.priorityLabel),
        Wrap(
          spacing: 8,
          children: [
            for (final level in const [0, 1, 2, 3])
              ChoiceChip(
                label: Text(copy.priority(level)),
                selected: task.priority == level,
                onSelected: (_) => repo.setPriority(task.id, level),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Label(copy.tags),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in repo.tags.where((tag) => !tag.deleted))
              FilterChip(
                label: Text(tag.name),
                selected: repo
                    .tagsFor(task.id)
                    .any((item) => item.id == tag.id),
                avatar: CircleAvatar(
                  backgroundColor: Color(tag.color),
                  radius: 6,
                ),
                onSelected: (_) => repo.toggleTag(task.id, tag.id),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text(copy.addTag),
              onPressed: () => _createTag(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Label(copy.checklist),
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
        const SizedBox(height: 16),
        _Label(copy.repeat),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in const [
              recurrenceNone,
              recurrenceDaily,
              recurrenceWeekly,
              recurrenceMonthly,
              recurrenceWeekdays,
            ])
              ChoiceChip(
                label: Text(copy.recurrence(preset)),
                selected: task.recurrence == preset,
                onSelected: (_) => repo.setRecurrence(task.id, preset),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Label(copy.reminderLabel),
        Wrap(
          spacing: 8,
          children: [
            for (final preset in const [
              reminderNone,
              reminderOnTime,
              reminder5m,
              reminder15m,
              reminder1h,
              reminder1d,
            ])
              ChoiceChip(
                label: Text(copy.reminder(preset)),
                selected: task.reminder == preset,
                onSelected: (_) => repo.setReminder(task.id, preset),
              ),
          ],
        ),
        if (task.reminderAt != null) ...[
          const SizedBox(height: 8),
          Text(
            copy.notifyAt(
              copy.due(task.reminderAt!, hasTime: true, now: DateTime.now()),
            ),
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
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

  Future<void> _addCheck(String taskId, String raw) async {
    if (raw.trim().isEmpty) {
      return;
    }
    await RepoScope.of(context).addChecklistItem(taskId, raw);
    if (mounted) {
      _check.clear();
    }
  }

  Future<void> _pickDate(TaskModel task) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: task.dueAt ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('ja'),
    );
    if (picked == null || !mounted) {
      return;
    }
    final due = task.dueHasTime && task.dueAt != null
        ? DateTime(
            picked.year,
            picked.month,
            picked.day,
            task.dueAt!.hour,
            task.dueAt!.minute,
          )
        : DateTime(picked.year, picked.month, picked.day);
    await RepoScope.of(context).setDue(task.id, due, hasTime: task.dueHasTime);
  }

  Future<void> _pickTime(TaskModel task) async {
    final due = task.dueAt;
    if (due == null) {
      return;
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(due),
    );
    if (picked == null || !mounted) {
      return;
    }
    await RepoScope.of(context).setDue(
      task.id,
      DateTime(due.year, due.month, due.day, picked.hour, picked.minute),
      hasTime: true,
    );
  }

  Future<void> _createTag(BuildContext context) async {
    final copy = Copy.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.addTag),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: copy.tagName),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(copy.add),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !context.mounted) {
      return;
    }
    final repo = RepoScope.of(context);
    try {
      final id = await repo.createTag(name);
      await repo.toggleTag(widget.taskId, id);
    } on FormatException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  String _clock(DateTime value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
