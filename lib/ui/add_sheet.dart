import 'package:flutter/material.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/filters.dart';
import '../domain/models.dart';
import '../l10n/copy.dart';
import 'task_composer.dart';
import 'text_import_page.dart';
import 'when_picker.dart';

Future<void> showAddSheet(
  BuildContext context, {
  String? listId,
  DateTime? day,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) {
      final inset = MediaQuery.viewInsetsOf(context).bottom;
      final height = MediaQuery.sizeOf(context).height * 0.88;
      return Padding(
        padding: EdgeInsets.only(bottom: inset),
        child: SizedBox(
          height: height,
          child: AddSheet(listId: listId, day: day),
        ),
      );
    },
  );
}

class AddSheet extends StatefulWidget {
  const AddSheet({this.listId, this.day, super.key});

  final String? listId;
  final DateTime? day;

  @override
  State<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<AddSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  late String _listId;
  var _allDay = true;
  var _priority = 0;
  DateTime? _start;
  DateTime? _end;
  final _tagIds = <String>{};
  final _newTagNames = <String>[];
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _listId = widget.listId ?? inboxId;
    if (widget.day != null) {
      final day = widget.day!;
      _start = DateTime(day.year, day.month, day.day);
      _allDay = true;
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
          child: Text(
            copy.createTask,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            children: [
              TextField(
                key: const Key('create-title'),
                controller: _title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: copy.titleHint,
                  border: InputBorder.none,
                ),
              ),
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
              const SizedBox(height: 8),
              _Row(
                icon: Icons.circle,
                iconColor: Color(_listColor(repo)),
                label: copy.lists,
                value: _listLabel(repo, copy),
                onTap: () => _pickList(repo, copy),
              ),
              _Row(
                icon: Icons.flag_outlined,
                label: copy.priorityLabel,
                value: copy.priority(_priority),
                onTap: () => _pickPriority(copy),
              ),
              _Row(
                icon: Icons.label_outline,
                label: copy.tags,
                value: _tagLabel(repo, copy),
                onTap: () => _pickTags(repo, copy),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const Key('create-notes'),
                controller: _notes,
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: copy.memo,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('text-import'),
                  onPressed: _openText,
                  icon: const Icon(Icons.notes_outlined),
                  label: Text(copy.fromText),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const Key('open-details'),
                  onPressed: _openDetails,
                  icon: const Icon(Icons.open_in_full),
                  label: Text(copy.moreDetails),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              key: const Key('create-save'),
              onPressed: _saving ? null : _save,
              child: Text(copy.save),
            ),
          ),
        ),
      ],
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
    final picked = await showMonthCalendar(context, initial: current ?? now);
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
      _clamp();
    });
  }

  Future<void> _pickTime({required bool isEnd}) async {
    final now = DateTime.now();
    final current = isEnd ? (_end ?? _start) : _start;
    final seed = current ?? DateTime(now.year, now.month, now.day, isEnd ? 10 : 9);
    final picked = await showWheelTime(
      context,
      initial: TimeOfDay(hour: seed.hour, minute: seed.minute),
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      final day = current ?? now;
      final stamped = DateTime(day.year, day.month, day.day, picked.hour, picked.minute);
      if (isEnd) {
        _end = stamped;
        _start ??= DateTime(day.year, day.month, day.day, 9);
      } else {
        _start = stamped;
      }
      _allDay = false;
      _clamp();
    });
  }

  DateTime _stamp(DateTime day, DateTime? previous, {required int fallbackHour}) {
    if (_allDay) {
      return DateTime(day.year, day.month, day.day);
    }
    return DateTime(
      day.year,
      day.month,
      day.day,
      previous?.hour ?? fallbackHour.clamp(0, 23),
      previous?.minute ?? 0,
    );
  }

  void _clamp() {
    if (_start != null && _end != null && _end!.isBefore(_start!)) {
      _end = _start;
    }
  }

  ({DateTime? start, DateTime? end, bool allDay}) _span() {
    var start = _start;
    var end = _end;
    final allDay = _allDay;
    if (start == null) {
      return (start: null, end: null, allDay: allDay);
    }
    if (allDay) {
      start = startOfDay(start);
      end = end == null ? null : startOfDay(end);
    }
    if (end != null && end.isBefore(start)) {
      end = start;
    }
    return (start: start, end: end, allDay: allDay);
  }

  Future<void> _pickList(TaskRepository repo, Copy copy) async {
    final lists = repo.lists.where((list) => !list.deleted && !list.archived).toList()
      ..sort((a, b) {
        if (a.isInbox != b.isInbox) {
          return a.isInbox ? -1 : 1;
        }
        return a.sortOrder.compareTo(b.sortOrder);
      });
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final list in lists)
                ListTile(
                  leading: CircleAvatar(backgroundColor: Color(list.color), radius: 8),
                  title: Text(copy.listTitle(list)),
                  trailing: list.id == _listId ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, list.id),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _listId = picked);
    }
  }

  Future<void> _pickPriority(Copy copy) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final level in const [0, 1, 2, 3])
                ListTile(
                  title: Text(copy.priority(level)),
                  trailing: level == _priority ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, level),
                ),
            ],
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _priority = picked);
    }
  }

  Future<void> _pickTags(TaskRepository repo, Copy copy) async {
    final name = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            final tags = repo.tags.where((tag) => !tag.deleted);
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: SafeArea(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  children: [
                    Text(copy.tags, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in tags)
                          FilterChip(
                            label: Text(tag.name),
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
                    TextField(
                      controller: name,
                      decoration: InputDecoration(hintText: copy.tagName),
                      onSubmitted: (value) {
                        final raw = value.trim();
                        if (raw.isEmpty) {
                          return;
                        }
                        setState(() => _newTagNames.add(raw));
                        name.clear();
                        setSheet(() {});
                      },
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
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openText() async {
    final navigator = Navigator.of(context);
    final listId = _listId;
    navigator.pop();
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => TextImportPage(listId: listId),
      ),
    );
  }

  void _openDetails() {
    final navigator = Navigator.of(context);
    final span = _span();
    final title = _title.text;
    final notes = _notes.text;
    final listId = _listId;
    final priority = _priority;
    final tags = _tagIds.toList();
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => TaskComposerPage(
          listId: listId,
          initialTitle: title,
          initialNotes: notes,
          initialStart: span.start,
          initialEnd: span.end,
          initialHasTime: span.start != null && !span.allDay,
          initialPriority: priority,
          initialTagIds: tags,
        ),
      ),
    );
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
      final span = _span();
      final ids = <String>[..._tagIds];
      for (final name in _newTagNames) {
        ids.add(await repo.createTag(name));
      }
      if (!mounted) {
        return;
      }
      await repo.createTask(
        title: title,
        listId: _listId,
        notes: _notes.text,
        due: span.start,
        hasTime: span.start != null && !span.allDay,
        endsAt: span.end,
        priority: _priority,
        tagIds: ids,
      );
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

class _Row extends StatelessWidget {
  const _Row({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? scheme.onSurfaceVariant, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
