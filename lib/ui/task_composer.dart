import 'package:flutter/material.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/filters.dart';
import '../domain/models.dart';
import '../domain/recurrence.dart';
import '../l10n/copy.dart';
import 'when_picker.dart';

class TaskComposerPage extends StatefulWidget {
  const TaskComposerPage({
    this.taskId,
    this.listId,
    this.initialTitle = '',
    this.initialNotes = '',
    this.initialStart,
    this.initialEnd,
    this.initialHasTime = false,
    this.initialPriority = 0,
    this.initialRecurrence = recurrenceNone,
    this.initialReminder = reminderNone,
    this.initialTagIds = const [],
    this.applyBoardDate = false,
    this.board,
    this.day,
    super.key,
  });

  final String? taskId;
  final String? listId;
  final String initialTitle;
  final String initialNotes;
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final bool initialHasTime;
  final int initialPriority;
  final String initialRecurrence;
  final String initialReminder;
  final List<String> initialTagIds;
  final bool applyBoardDate;
  final TaskBoard? board;
  final DateTime? day;

  @override
  State<TaskComposerPage> createState() => _TaskComposerPageState();
}

class _TaskComposerPageState extends State<TaskComposerPage> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  var _seeded = false;
  var _saving = false;
  var _allDay = true;
  var _priority = 0;
  var _recurrence = recurrenceNone;
  var _reminder = reminderNone;
  String _listId = inboxId;
  DateTime? _start;
  DateTime? _end;
  final _tagIds = <String>{};
  final _newTagNames = <String>[];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) {
      return;
    }
    _seeded = true;
    final repo = RepoScope.of(context);
    final task = widget.taskId == null ? null : repo.taskById(widget.taskId!);
    if (task != null) {
      _title.text = task.title;
      _notes.text = task.notes;
      _listId = task.listId;
      _start = task.dueAt;
      _end = task.endsAt;
      _allDay = task.dueAt == null || !task.dueHasTime;
      _priority = task.priority;
      _recurrence = task.recurrence;
      _reminder = task.reminder;
      _tagIds.addAll(repo.tagsFor(task.id).map((tag) => tag.id));
      return;
    }
    _title.text = widget.initialTitle;
    _notes.text = widget.initialNotes;
    _listId = widget.listId ?? inboxId;
    _priority = widget.initialPriority;
    _recurrence = widget.initialRecurrence;
    _reminder = widget.initialReminder;
    _end = widget.initialEnd;
    _tagIds.addAll(widget.initialTagIds);
    if (widget.initialStart != null) {
      _start = widget.initialStart;
      _allDay = !widget.initialHasTime;
      return;
    }
    if (!widget.applyBoardDate) {
      return;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (widget.board == TaskBoard.today) {
      _start = today;
    } else if (widget.board == TaskBoard.upcoming) {
      _start = today.add(const Duration(days: 1));
    } else if (widget.board == TaskBoard.calendar && widget.day != null) {
      final day = widget.day!;
      _start = DateTime(day.year, day.month, day.day);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final editing = widget.taskId != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? copy.editTask : copy.createTask),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              children: [
                TextField(
                  key: const Key('create-title'),
                  controller: _title,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: copy.titleHint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                ScheduleCard(
                  copy: copy,
                  scheme: scheme,
                  allDay: _allDay,
                  start: _start,
                  end: _end,
                  onAllDay: _setAllDay,
                  onStartDate: () => _pickDate(isEnd: false),
                  onEndDate: () => _pickDate(isEnd: true),
                  onStartTime: () => _pickTime(isEnd: false),
                  onEndTime: () => _pickTime(isEnd: true),
                  onClearEnd: () => setState(() => _end = null),
                ),
                const SizedBox(height: 12),
                _FactCard(
                  children: [
                    _FactRow(
                      icon: Icons.repeat,
                      label: copy.repeat,
                      value: copy.recurrence(_recurrence),
                      onTap: _pickRepeat,
                    ),
                    _FactRow(
                      icon: Icons.notifications_none,
                      label: copy.reminderLabel,
                      value: copy.reminder(_reminder),
                      onTap: _pickReminder,
                    ),
                    _FactRow(
                      icon: Icons.circle,
                      iconColor: Color(_listColor(repo)),
                      label: copy.lists,
                      value: _listLabel(repo, copy),
                      onTap: () => _pickList(repo, copy),
                    ),
                    _FactRow(
                      icon: Icons.flag_outlined,
                      label: copy.priorityLabel,
                      value: copy.priority(_priority),
                      onTap: () => _pickPriority(copy),
                    ),
                    _FactRow(
                      icon: Icons.label_outline,
                      label: copy.tags,
                      value: _tagLabel(repo, copy),
                      onTap: () => _pickTags(repo, copy),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('create-notes'),
                  controller: _notes,
                  minLines: 4,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: copy.memo,
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          Material(
            elevation: 6,
            color: scheme.surface,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    key: const Key('create-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(copy.save),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _listColor(TaskRepository repo) {
    for (final list in repo.lists) {
      if (list.id == _listId) {
        return list.color;
      }
    }
    return listColors.first;
  }

  String _listLabel(TaskRepository repo, Copy copy) {
    for (final list in repo.lists) {
      if (list.id == _listId) {
        return copy.listTitle(list);
      }
    }
    return copy.inbox;
  }

  String _tagLabel(TaskRepository repo, Copy copy) {
    final names = <String>[
      for (final id in _tagIds)
        for (final tag in repo.tags)
          if (tag.id == id && !tag.deleted) tag.name,
      ..._newTagNames,
    ];
    if (names.isEmpty) {
      return copy.notSet;
    }
    return names.join(', ');
  }

  void _setAllDay(bool value) {
    setState(() {
      _allDay = value;
      if (value) {
        if (_start != null) {
          _start = startOfDay(_start!);
        }
        if (_end != null) {
          _end = startOfDay(_end!);
        }
        return;
      }
      if (_start != null && _start!.hour == 0 && _start!.minute == 0) {
        _start = DateTime(_start!.year, _start!.month, _start!.day, 9);
      }
      if (_end != null && _end!.hour == 0 && _end!.minute == 0) {
        final hour = ((_start?.hour ?? 9) + 1).clamp(0, 23);
        _end = DateTime(_end!.year, _end!.month, _end!.day, hour);
      }
    });
  }

  Future<void> _pickDate({required bool isEnd}) async {
    final now = DateTime.now();
    final current = isEnd ? (_end ?? _start) : _start;
    final picked = await showDateDrum(
      context,
      initial: current ?? now,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isEnd) {
        _end = _stamp(picked, _end ?? _start, fallbackHour: (_start?.hour ?? 8) + 1);
        _start ??= _stamp(picked, null, fallbackHour: 9);
      } else {
        _start = _stamp(picked, _start, fallbackHour: 9);
      }
      _clampEnd();
    });
  }

  Future<void> _pickTime({required bool isEnd}) async {
    final current = isEnd ? (_end ?? _start) : _start;
    final now = DateTime.now();
    final seed = current ?? DateTime(now.year, now.month, now.day, isEnd ? 10 : 9);
    final picked = await showWheelTime(
      context,
      initial: TimeOfDay(hour: seed.hour, minute: seed.minute),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      final day = current ?? DateTime.now();
      final stamped = DateTime(
        day.year,
        day.month,
        day.day,
        picked.hour,
        picked.minute,
      );
      if (isEnd) {
        _end = stamped;
        _start ??= DateTime(day.year, day.month, day.day, 9);
      } else {
        _start = stamped;
      }
      _allDay = false;
      _clampEnd();
    });
  }

  DateTime _stamp(DateTime day, DateTime? previous, {required int fallbackHour}) {
    if (_allDay) {
      return DateTime(day.year, day.month, day.day);
    }
    final hour = previous?.hour ?? fallbackHour.clamp(0, 23);
    final minute = previous?.minute ?? 0;
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  void _clampEnd() {
    final start = _start;
    final end = _end;
    if (start != null && end != null && end.isBefore(start)) {
      _end = start;
    }
  }

  Future<void> _pickRepeat() async {
    final copy = Copy.of(context);
    final picked = await _pickOption<String>(
      title: copy.repeat,
      values: const [
        recurrenceNone,
        recurrenceDaily,
        recurrenceWeekly,
        recurrenceMonthly,
        recurrenceWeekdays,
      ],
      label: copy.recurrence,
      selected: _recurrence,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _recurrence = picked;
      if (picked != recurrenceNone && _start == null) {
        _start = startOfDay(DateTime.now());
        _allDay = true;
      }
    });
  }

  Future<void> _pickReminder() async {
    final copy = Copy.of(context);
    final picked = await _pickOption<String>(
      title: copy.reminderLabel,
      values: const [
        reminderNone,
        reminderOnTime,
        reminder5m,
        reminder15m,
        reminder1h,
        reminder1d,
      ],
      label: copy.reminder,
      selected: _reminder,
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _reminder = picked;
      if (picked != reminderNone && _start == null) {
        _start = startOfDay(DateTime.now());
        _allDay = true;
      }
    });
  }

  Future<void> _pickPriority(Copy copy) async {
    final picked = await _pickOption<int>(
      title: copy.priorityLabel,
      values: const [0, 1, 2, 3],
      label: copy.priority,
      selected: _priority,
    );
    if (picked == null) {
      return;
    }
    setState(() => _priority = picked);
  }

  Future<void> _pickList(TaskRepository repo, Copy copy) async {
    final lists = _visibleLists(repo);
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  copy.lists,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final list in lists)
                ListTile(
                  leading: _ColorDot(color: list.color),
                  title: Text(copy.listTitle(list)),
                  trailing: list.id == _listId
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, list.id),
                ),
            ],
          ),
        );
      },
    );
    if (picked == null) {
      return;
    }
    setState(() => _listId = picked);
  }

  Future<void> _pickTags(TaskRepository repo, Copy copy) async {
    final name = TextEditingController();
    final picked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final tags = repo.tags.where((tag) => !tag.deleted).toList();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Text(
                      copy.tags,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            label: Text(tag.name),
                            avatar: CircleAvatar(
                              backgroundColor: Color(tag.color),
                              radius: 6,
                            ),
                            selected: _tagIds.contains(tag.id),
                            onSelected: (_) {
                              setState(() {
                                if (!_tagIds.add(tag.id)) {
                                  _tagIds.remove(tag.id);
                                }
                              });
                              setSheet(() {});
                            },
                          ),
                        for (final pending in _newTagNames)
                          InputChip(
                            label: Text(pending),
                            onDeleted: () {
                              setState(() => _newTagNames.remove(pending));
                              setSheet(() {});
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: name,
                            decoration: InputDecoration(hintText: copy.tagName),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _queueTag(name, setSheet),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: copy.addTag,
                          onPressed: () => _queueTag(name, setSheet),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(copy.save),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    name.dispose();
    if (picked == null && mounted) {
      setState(() {});
    }
  }

  void _queueTag(TextEditingController name, void Function(VoidCallback) setSheet) {
    final raw = name.text.trim();
    if (raw.isEmpty) {
      return;
    }
    setState(() => _newTagNames.add(raw));
    name.clear();
    setSheet(() {});
  }

  Future<T?> _pickOption<T>({
    required String title,
    required List<T> values,
    required String Function(T value) label,
    required T selected,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final value in values)
                ListTile(
                  title: Text(label(value)),
                  trailing: value == selected
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, value),
                ),
            ],
          ),
        );
      },
    );
  }

  ({DateTime? start, DateTime? end, bool allDay}) _normalized() {
    var start = _start;
    var end = _end;
    var allDay = _allDay;
    if (start == null &&
        (_recurrence != recurrenceNone || _reminder != reminderNone)) {
      start = startOfDay(DateTime.now());
      allDay = true;
    }
    if (start == null) {
      return (start: null, end: null, allDay: allDay);
    }
    if (allDay) {
      start = startOfDay(start);
      end = end == null ? null : startOfDay(end);
    } else {
      start = DateTime(
        start.year,
        start.month,
        start.day,
        start.hour,
        start.minute,
      );
      if (end != null) {
        end = DateTime(end.year, end.month, end.day, end.hour, end.minute);
      }
    }
    if (end != null && end.isBefore(start)) {
      end = start;
    }
    return (start: start, end: end, allDay: allDay);
  }

  Future<void> _save() async {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(copy.titleRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      final when = _normalized();
      final ids = <String>[..._tagIds];
      for (final name in _newTagNames) {
        ids.add(await repo.createTag(name));
      }
      if (!mounted) {
        return;
      }
      if (widget.taskId == null) {
        await repo.createTask(
          title: title,
          listId: _listId,
          notes: _notes.text,
          due: when.start,
          hasTime: when.start != null && !when.allDay,
          endsAt: when.end,
          priority: _priority,
          recurrence: _recurrence,
          reminder: _reminder,
          tagIds: ids,
        );
      } else {
        await repo.saveTask(
          id: widget.taskId!,
          title: title,
          listId: _listId,
          notes: _notes.text,
          due: when.start,
          hasTime: when.start != null && !when.allDay,
          endsAt: when.end,
          priority: _priority,
          recurrence: _recurrence,
          reminder: _reminder,
          tagIds: ids,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

List<ListModel> _visibleLists(TaskRepository repo) {
  final lists = repo.lists.where((list) => !list.deleted && !list.archived).toList();
  lists.sort((a, b) {
    if (a.isInbox != b.isInbox) {
      return a.isInbox ? -1 : 1;
    }
    return a.sortOrder.compareTo(b.sortOrder);
  });
  return lists;
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.copy,
    required this.scheme,
    required this.allDay,
    required this.start,
    required this.end,
    required this.onAllDay,
    required this.onStartDate,
    required this.onEndDate,
    required this.onStartTime,
    required this.onEndTime,
    required this.onClearEnd,
    this.showClear = true,
    this.interactiveKeys = true,
  });

  final Copy copy;
  final ColorScheme scheme;
  final bool allDay;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<bool> onAllDay;
  final VoidCallback onStartDate;
  final VoidCallback onEndDate;
  final VoidCallback onStartTime;
  final VoidCallback onEndTime;
  final VoidCallback onClearEnd;
  final bool showClear;
  final bool interactiveKeys;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          InkWell(
            key: interactiveKeys ? const Key('composer-all-day') : null,
            onTap: () => onAllDay(!allDay),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
              child: Row(
                children: [
                  Icon(Icons.wb_sunny_outlined, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      copy.allDay,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IgnorePointer(
                    child: Switch(value: allDay, onChanged: (_) {}),
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          _WhenRow(
            label: copy.start,
            value: start,
            allDay: allDay,
            copy: copy,
            dateKey: interactiveKeys
                ? const Key('composer-start-date')
                : const Key('detail-start-date'),
            timeKey: interactiveKeys
                ? const Key('composer-start-time')
                : const Key('detail-start-time'),
            onDate: onStartDate,
            onTime: onStartTime,
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          _WhenRow(
            label: copy.ends,
            value: end,
            allDay: allDay,
            copy: copy,
            dateKey: interactiveKeys
                ? const Key('composer-end-date')
                : const Key('detail-end-date'),
            timeKey: interactiveKeys
                ? const Key('composer-end-time')
                : const Key('detail-end-time'),
            onDate: onEndDate,
            onTime: onEndTime,
            onClear: !showClear || end == null ? null : onClearEnd,
            clearTooltip: copy.clearEnd,
          ),
        ],
      ),
    );
  }
}

class _WhenRow extends StatelessWidget {
  const _WhenRow({
    required this.label,
    required this.value,
    required this.allDay,
    required this.copy,
    required this.dateKey,
    required this.timeKey,
    required this.onDate,
    required this.onTime,
    this.onClear,
    this.clearTooltip,
  });

  final String label;
  final DateTime? value;
  final bool allDay;
  final Copy copy;
  final Key dateKey;
  final Key timeKey;
  final VoidCallback onDate;
  final VoidCallback onTime;
  final VoidCallback? onClear;
  final String? clearTooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final date = value == null
        ? copy.notSet
        : copy.due(value!, hasTime: false, now: DateTime.now());
    final time = value == null
        ? copy.pickTime
        : '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (onClear != null)
                IconButton(
                  tooltip: clearTooltip,
                  onPressed: onClear,
                  icon: const Icon(Icons.close),
                ),
            ],
          ),
          _WhenChoice(
            choiceKey: dateKey,
            label: date,
            muted: value == null,
            scheme: scheme,
            onTap: onDate,
          ),
          if (!allDay) ...[
            const SizedBox(height: 6),
            _WhenChoice(
              choiceKey: timeKey,
              label: time,
              muted: value == null,
              scheme: scheme,
              onTap: onTime,
            ),
          ],
        ],
      ),
    );
  }
}

class _WhenChoice extends StatelessWidget {
  const _WhenChoice({
    required this.choiceKey,
    required this.label,
    required this.muted,
    required this.scheme,
    required this.onTap,
  });

  final Key choiceKey;
  final String label;
  final bool muted;
  final ColorScheme scheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: choiceKey,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: muted ? scheme.onSurfaceVariant : scheme.onSurface,
                  ),
                ),
              ),
              Icon(Icons.expand_more, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) Divider(height: 1, color: scheme.outlineVariant),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? scheme.onSurfaceVariant, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color});

  final int color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Color(color),
        shape: BoxShape.circle,
      ),
    );
  }
}

class TaskFactView extends StatelessWidget {
  const TaskFactView({
    required this.task,
    required this.onEdit,
    super.key,
  });

  final TaskModel task;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final list = repo.listById(task.listId);
    final tags = repo.tagsFor(task.id);
    final allDay = task.dueAt == null || !task.dueHasTime;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              task.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ),
        ScheduleCard(
          copy: copy,
          scheme: scheme,
          allDay: allDay,
          start: task.dueAt,
          end: task.endsAt,
          onAllDay: (_) => onEdit(),
          onStartDate: onEdit,
          onEndDate: onEdit,
          onStartTime: onEdit,
          onEndTime: onEdit,
          onClearEnd: onEdit,
          showClear: false,
          interactiveKeys: false,
        ),
        const SizedBox(height: 12),
        _FactCard(
          children: [
            _FactRow(
              icon: Icons.repeat,
              label: copy.repeat,
              value: copy.recurrence(task.recurrence),
              onTap: onEdit,
            ),
            _FactRow(
              icon: Icons.notifications_none,
              label: copy.reminderLabel,
              value: copy.reminder(task.reminder),
              onTap: onEdit,
            ),
            _FactRow(
              icon: Icons.circle,
              iconColor: Color(list?.color ?? listColors.first),
              label: copy.lists,
              value: list == null ? copy.inbox : copy.listTitle(list),
              onTap: onEdit,
            ),
            _FactRow(
              icon: Icons.flag_outlined,
              label: copy.priorityLabel,
              value: copy.priority(task.priority),
              onTap: onEdit,
            ),
            _FactRow(
              icon: Icons.label_outline,
              label: copy.tags,
              value: tags.isEmpty
                  ? copy.notSet
                  : tags.map((tag) => tag.name).join(', '),
              onTap: onEdit,
            ),
          ],
        ),
        const SizedBox(height: 16),
        InkWell(
          onTap: onEdit,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.memo,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.notes.trim().isEmpty ? copy.notSet : task.notes,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
