import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/models.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({this.listId, super.key});

  final String? listId;

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  late String _listId;
  DateTime? _due;
  var _hasTime = false;
  var _priority = 0;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _listId = widget.listId ?? inboxId;
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
    final lists = repo.lists.where((list) => !list.deleted && !list.archived).toList();
    if (!lists.any((list) => list.id == _listId)) {
      _listId = inboxId;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('タスクを作成')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          TextField(
            key: const Key('create-title'),
            controller: _title,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'タスク名'),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('create-notes'),
            controller: _notes,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'メモ'),
          ),
          const SizedBox(height: 16),
          const Text('リスト', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _listId,
            items: [
              for (final list in lists) DropdownMenuItem(value: list.id, child: Text(list.name)),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _listId = value);
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('期限', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _pickDate,
                child: Text(_due == null ? '日付を選ぶ' : '${_due!.month}/${_due!.day}'),
              ),
              OutlinedButton(
                onPressed: _due == null ? null : _pickTime,
                child: Text(_hasTime && _due != null ? '${_due!.hour}:${_due!.minute.toString().padLeft(2, '0')}' : '時刻を選ぶ'),
              ),
              if (_due != null)
                TextButton(
                  onPressed: () => setState(() {
                    _due = null;
                    _hasTime = false;
                  }),
                  child: const Text('期限を消す'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('優先度', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('なし')),
              ButtonSegment(value: 1, label: Text('低')),
              ButtonSegment(value: 2, label: Text('中')),
              ButtonSegment(value: 3, label: Text('高')),
            ],
            selected: {_priority},
            onSelectionChanged: (value) => setState(() => _priority = value.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('create-save'),
            onPressed: _saving ? null : _save,
            child: const Text('作成する'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _due = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _hasTime ? (_due?.hour ?? 9) : 0,
        _hasTime ? (_due?.minute ?? 0) : 0,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_due ?? DateTime.now()),
    );
    if (picked == null || _due == null) {
      return;
    }
    setState(() {
      _hasTime = true;
      _due = DateTime(_due!.year, _due!.month, _due!.day, picked.hour, picked.minute);
    });
  }

  Future<void> _save() async {
    final repo = RepoScope.of(context);
    setState(() => _saving = true);
    try {
      await repo.createTask(
        title: _title.text,
        listId: _listId,
        notes: _notes.text,
        due: _due,
        hasTime: _hasTime,
        priority: _priority,
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
