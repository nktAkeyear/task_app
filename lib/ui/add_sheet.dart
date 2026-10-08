import 'package:flutter/material.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/filters.dart';
import '../domain/models.dart';
import '../domain/recurrence.dart';
import '../l10n/copy.dart';
import 'text_import_page.dart';
import 'when_picker.dart';

Future<void> showAddSheet(
  BuildContext context, {
  String? listId,
  DateTime? day,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (context) => AddSheet(listId: listId, day: day),
    ),
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
  var _recurrence = recurrenceNone;
  var _reminder = reminderNone;
  DateTime? _start;
  DateTime? _end;
  var _endTouched = false;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _listId = widget.listId ?? inboxId;
    final day = widget.day;
    if (day != null) {
      _start = DateTime(day.year, day.month, day.day);
      _allDay = true;
    }
    _title.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  DateTime get _seedDay {
    final start = _start;
    if (start != null) {
      return startOfDay(start);
    }
    final day = widget.day;
    if (day != null) {
      return DateTime(day.year, day.month, day.day);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime get _endSeed => _end ?? _seedDay;

  DateTime _clockOn(DateTime day, {required int hour, int minute = 0}) {
    return DateTime(day.year, day.month, day.day, hour, minute);
  }

  DateTime get _pickerStart {
    final start = _start ?? _seedDay;
    if (_allDay || (start.hour == 0 && start.minute == 0)) {
      return _clockOn(start, hour: 9);
    }
    return start;
  }

  DateTime get _pickerEnd {
    final end = _endTouched ? _end : null;
    if (end != null && !(_allDay && end.hour == 0 && end.minute == 0)) {
      if (_allDay) {
        return _clockOn(end, hour: 10);
      }
      return end;
    }
    final start = _pickerStart;
    final hour = (start.hour + 1).clamp(0, 23);
    return _clockOn(end ?? start, hour: hour, minute: start.minute);
  }

  String _rowClock(DateTime value) {
    final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    return '$hour12:${value.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: copy.close,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
        title: Text(copy.createTask),
        actions: [
          TextButton(
            key: const Key('create-save'),
            onPressed: _saving ? null : _save,
            child: Text(copy.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
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
              suffixIcon: _title.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _title.clear,
                      icon: const Icon(Icons.close),
                    ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(_listColor(repo)),
              radius: 8,
            ),
            title: Text(_listLabel(repo, copy)),
            trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            onTap: () => _pickList(repo, copy),
          ),
          Material(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  key: const Key('composer-all-day'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  title: Text(copy.allDay),
                  value: _allDay,
                  onChanged: _setAllDay,
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _WhenLine(
                  icon: Icons.login,
                  dateKey: const Key('composer-start-date'),
                  timeKey: const Key('composer-start-time'),
                  date: copy.drumDate(_start ?? _seedDay),
                  time: _allDay ? null : _rowClock(_pickerStart),
                  onTap: () => _openPicker(end: false),
                ),
                Divider(height: 1, color: scheme.outlineVariant),
                _WhenLine(
                  icon: Icons.logout,
                  dateKey: const Key('composer-end-date'),
                  timeKey: const Key('composer-end-time'),
                  date: copy.drumDate(_endSeed),
                  time: _allDay ? null : _rowClock(_pickerEnd),
                  onTap: () => _openPicker(end: true),
                ),
              ],
            ),
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(copy.reminderLabel),
            trailing: Text(
              copy.reminder(_reminder),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            onTap: _pickReminder,
          ),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(copy.repeat),
            trailing: Text(
              copy.recurrence(_recurrence),
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            onTap: _pickRepeat,
          ),
          TextField(
            key: const Key('create-notes'),
            controller: _notes,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: copy.memo,
              alignLabelWithHint: true,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('text-import'),
              onPressed: _openText,
              icon: const Icon(Icons.notes_outlined),
              label: Text(copy.fromText),
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
    return 0xFF6750A4;
  }

  String _listLabel(TaskRepository repo, Copy copy) {
    for (final list in repo.lists) {
      if (list.id == _listId) {
        return copy.listTitle(list);
      }
    }
    return copy.inbox;
  }

  void _setAllDay(bool value) {
    setState(() {
      _allDay = value;
      final start = _start;
      if (start != null && value) {
        _start = startOfDay(start);
      } else if (start != null && start.hour == 0 && start.minute == 0) {
        _start = DateTime(start.year, start.month, start.day, 9);
      }
      final end = _end;
      if (end != null && value) {
        _end = startOfDay(end);
      }
    });
  }

  Future<void> _openPicker({required bool end}) async {
    final picked = await showSpanPicker(
      context,
      start: _pickerStart,
      end: _pickerEnd,
      editingEnd: end,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      final startTimeSame = picked.start.hour == _pickerStart.hour &&
          picked.start.minute == _pickerStart.minute;
      final endTimeSame = picked.end.hour == _pickerEnd.hour &&
          picked.end.minute == _pickerEnd.minute;
      final keepAllDay = _allDay && startTimeSame && endTimeSame;
      if (keepAllDay) {
        _start = startOfDay(picked.start);
        if (picked.saveEnd) {
          _endTouched = true;
          _end = startOfDay(picked.end);
        }
      } else {
        _allDay = false;
        _start = picked.start;
        if (picked.saveEnd) {
          _endTouched = true;
          _end = picked.end;
        }
      }
      _clamp();
    });
  }

  void _clamp() {
    final start = _start;
    final end = _end;
    if (start != null && end != null && end.isBefore(start)) {
      _end = start;
    }
  }

  ({DateTime? start, DateTime? end, bool allDay}) _span() {
    var start = _start;
    var end = _endTouched ? _end : null;
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

  Future<void> _pickRepeat() async {
    final copy = Copy.of(context);
    final picked = await _pickString(
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
    setState(() => _recurrence = picked);
  }

  Future<void> _pickReminder() async {
    final copy = Copy.of(context);
    const custom = '__custom__';
    final picked = await _pickString(
      title: copy.reminderLabel,
      values: const [
        reminderNone,
        reminderOnTime,
        reminder5m,
        reminder15m,
        reminder1h,
        reminder1d,
        custom,
      ],
      label: (value) => value == custom ? copy.customMinutes : copy.reminder(value),
      selected: _reminder.startsWith('m:') ? custom : _reminder,
    );
    if (picked == null || !mounted) {
      return;
    }
    if (picked == custom) {
      final minutes = await _askMinutes();
      if (minutes == null) {
        return;
      }
      setState(() => _reminder = 'm:$minutes');
      return;
    }
    setState(() => _reminder = picked);
  }

  Future<int?> _askMinutes() async {
    final copy = Copy.of(context);
    final field = TextEditingController();
    final minutes = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.customMinutes),
        content: TextField(
          controller: field,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: copy.customMinutes),
          onSubmitted: (raw) => Navigator.pop(context, int.tryParse(raw.trim())),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(field.text.trim())),
            child: Text(copy.doneLabel),
          ),
        ],
      ),
    );
    field.dispose();
    if (minutes == null || minutes < 0) {
      return null;
    }
    return minutes;
  }

  Future<String?> _pickString({
    required String title,
    required List<String> values,
    required String Function(String value) label,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              for (final value in values)
                ListTile(
                  title: Text(label(value)),
                  trailing: value == selected ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.pop(context, value),
                ),
            ],
          ),
        );
      },
    );
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

  Future<void> _save() async {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(copy.titleRequired)));
      return;
    }
    setState(() => _saving = true);
    try {
      final span = _span();
      await repo.createTask(
        title: title,
        listId: _listId,
        notes: _notes.text,
        due: span.start,
        hasTime: span.start != null && !span.allDay,
        endsAt: span.end,
        recurrence: _recurrence,
        reminder: _reminder,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _WhenLine extends StatelessWidget {
  const _WhenLine({
    required this.icon,
    required this.dateKey,
    required this.timeKey,
    required this.date,
    required this.time,
    required this.onTap,
  });

  final IconData icon;
  final Key dateKey;
  final Key timeKey;
  final String date;
  final String? time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: scheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(child: Text(date, key: dateKey)),
            if (time != null)
              Text(
                time!,
                key: timeKey,
                style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
              ),
          ],
        ),
      ),
    );
  }
}
