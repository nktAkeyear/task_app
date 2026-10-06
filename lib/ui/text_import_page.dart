import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/filters.dart';
import '../domain/models.dart';
import '../domain/text_tasks.dart';
import '../l10n/copy.dart';

class TextImportPage extends StatefulWidget {
  const TextImportPage({
    this.listId,
    super.key,
  });

  final String? listId;

  @override
  State<TextImportPage> createState() => _TextImportPageState();
}

class _TextImportPageState extends State<TextImportPage> {
  final _source = TextEditingController();
  final List<TextEditingController> _titles = [];
  List<TextTaskDraft> _drafts = const [];
  var _saving = false;

  @override
  void dispose() {
    _source.dispose();
    for (final title in _titles) {
      title.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(copy.fromText)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              children: [
                TextField(
                  key: const Key('text-import-input'),
                  controller: _source,
                  minLines: 4,
                  maxLines: 8,
                  decoration: InputDecoration(
                    labelText: copy.textImportHint,
                    alignLabelWithHint: true,
                  ),
                  onChanged: (_) => _preview(),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.attach_file),
                    label: Text(copy.pickTextFile),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  copy.importPreview,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (_drafts.isEmpty)
                  Text(copy.textImportEmpty)
                else
                  for (var index = 0; index < _drafts.length; index++)
                    _previewRow(index, copy),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                key: const Key('text-import-save'),
                onPressed: _saving || _drafts.isEmpty ? null : _save,
                child: Text(copy.confirmAdd),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(int index, Copy copy) {
    final draft = _drafts[index];
    final when = draft.due == null
        ? copy.notSet
        : copy.due(draft.due!, hasTime: draft.hasTime, now: DateTime.now());
    final priority = draft.priority == 0 ? '' : ' · ${copy.priority(draft.priority)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _titles[index],
              decoration: InputDecoration(helperText: '$when$priority'),
            ),
          ),
          IconButton(
            tooltip: copy.delete,
            onPressed: () => setState(() {
              _titles[index].dispose();
              _titles.removeAt(index);
              _drafts = [..._drafts]..removeAt(index);
            }),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  void _preview() {
    final next = splitTextTasks(_source.text, now: DateTime.now());
    for (final title in _titles) {
      title.dispose();
    }
    _titles
      ..clear()
      ..addAll(next.map((draft) => TextEditingController(text: draft.title)));
    setState(() => _drafts = next);
  }

  Future<void> _pickFile() async {
    final copy = Copy.of(context);
    try {
      final picked = await FilePicker.pickFile(dialogTitle: copy.pickTextFile);
      if (picked == null || !mounted) {
        return;
      }
      final text = utf8.decode(await picked.readAsBytes());
      _source.text = text;
      _preview();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(copy.textImportFailed)));
      }
    }
  }

  Future<void> _save() async {
    final repo = RepoScope.of(context);
    setState(() => _saving = true);
    try {
      final listId = widget.listId ?? inboxId;
      for (var index = 0; index < _drafts.length; index++) {
        final draft = _drafts[index];
        final title = _titles[index].text.trim();
        if (title.isEmpty) {
          continue;
        }
        final due = draft.due;
        await repo.createTask(
          title: title,
          listId: listId,
          due: due == null ? null : (draft.hasTime ? due : startOfDay(due)),
          hasTime: draft.hasTime,
          priority: draft.priority,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
