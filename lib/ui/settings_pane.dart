import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/task_repository.dart';

class SettingsPane extends StatefulWidget {
  const SettingsPane({super.key});

  @override
  State<SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<SettingsPane> {
  late final TextEditingController _url;
  late final TextEditingController _name;
  String? _urlError;

  @override
  void initState() {
    super.initState();
    final repo = RepoScope.of(context);
    _url = TextEditingController(text: repo.syncBaseUrl);
    _name = TextEditingController(text: repo.deviceName);
  }

  @override
  void dispose() {
    _url.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text('設定', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Tas はこの端末に保存します。同期先は空のままで使えます。', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 20),
        const _Head('外観'),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.system, label: Text('システム'), icon: Icon(Icons.brightness_auto)),
            ButtonSegment(value: ThemeMode.light, label: Text('ライト'), icon: Icon(Icons.light_mode_outlined)),
            ButtonSegment(value: ThemeMode.dark, label: Text('ダーク'), icon: Icon(Icons.dark_mode_outlined)),
          ],
          selected: {repo.themeMode},
          onSelectionChanged: (value) => repo.setTheme(value.first),
        ),
        const SizedBox(height: 24),
        const _Head('この端末'),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: '端末名'),
          onSubmitted: repo.setDeviceName,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(onPressed: () => repo.setDeviceName(_name.text), child: const Text('端末名を保存')),
        ),
        const SizedBox(height: 8),
        Text('端末 ID: ${repo.deviceId}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
        const SizedBox(height: 24),
        const _Head('同期'),
        TextField(
          controller: _url,
          decoration: InputDecoration(
            labelText: '同期サーバーの URL',
            hintText: 'http://127.0.0.1:8787',
            errorText: _urlError,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: () => _saveUrl(repo), child: const Text('URL を保存')),
            OutlinedButton(
              onPressed: () async {
                _url.clear();
                setState(() => _urlError = null);
                await repo.setSyncUrl('');
              },
              child: const Text('URL を消す'),
            ),
            OutlinedButton(onPressed: repo.flushSync, child: const Text('今すぐ同期')),
          ],
        ),
        const SizedBox(height: 8),
        Text(repo.syncMessage),
        Text('未送信の変更: ${repo.outboxCount}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        const _Head('バックアップ'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(onPressed: () => _exportFile(repo), child: const Text('ファイルに書き出す')),
            OutlinedButton(onPressed: () => _copy(repo), child: const Text('JSON をコピー')),
            OutlinedButton(onPressed: () => _importFile(repo), child: const Text('ファイルから読み込む')),
            OutlinedButton(onPressed: () => _paste(repo), child: const Text('JSON を貼り付け')),
          ],
        ),
        const SizedBox(height: 24),
        const _Head('キーボード'),
        const Text('Ctrl+N  タスクを追加\nCtrl+F  検索\nCtrl+Enter  完了にする\nJ / K  前後のタスク\nCtrl+1 から Ctrl+5  受信箱、今日、近日、カレンダー、完了'),
      ],
    );
  }

  Future<void> _saveUrl(TaskRepository repo) async {
    final error = await repo.setSyncUrl(_url.text);
    if (mounted) {
      setState(() => _urlError = error);
    }
  }

  Future<void> _exportFile(TaskRepository repo) async {
    try {
      final json = await repo.exportJson();
      final saved = await FilePicker.saveFile(
        fileName: 'tas-backup.json',
        bytes: Uint8List.fromList(utf8.encode(json)),
        dialogTitle: 'バックアップを書き出す',
      );
      if (!mounted) {
        return;
      }
      if (saved != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('バックアップを書き出しました。')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('書き出せませんでした。JSON のコピーを使ってください。')));
      }
    }
  }

  Future<void> _copy(TaskRepository repo) async {
    final json = await repo.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('JSON をコピーしました。')));
    }
  }

  Future<void> _importFile(TaskRepository repo) async {
    try {
      final picked = await FilePicker.pickFile(dialogTitle: 'バックアップを読み込む');
      if (picked == null) {
        return;
      }
      final raw = utf8.decode(await picked.readAsBytes());
      await repo.importJson(raw);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('バックアップを読み込みました。')));
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('読み込めませんでした。ファイルの形式を確認してください。')));
      }
    }
  }

  Future<void> _paste(TaskRepository repo) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('JSON を読み込む'),
        content: TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          decoration: const InputDecoration(hintText: '書き出した JSON を貼り付け'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('キャンセル')),
          FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('読み込む')),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) {
      return;
    }
    try {
      await repo.importJson(text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('バックアップを読み込みました。')));
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('読み込めませんでした。ファイルの形式を確認してください。')));
      }
    }
  }
}

class _Head extends StatelessWidget {
  const _Head(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
