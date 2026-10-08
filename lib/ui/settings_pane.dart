import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../l10n/copy.dart';
import '../update/app_update.dart';
import 'home_layout_page.dart';

class SettingsPane extends StatefulWidget {
  const SettingsPane({super.key});

  @override
  State<SettingsPane> createState() => _SettingsPaneState();
}

class _SettingsPaneState extends State<SettingsPane> {
  final TextEditingController _url = TextEditingController();
  final TextEditingController _name = TextEditingController();
  String? _urlError;
  var _seeded = false;
  String? _version;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) {
      return;
    }
    final repo = RepoScope.of(context);
    _url.text = repo.syncBaseUrl;
    _name.text = repo.deviceName;
    _seeded = true;
    PackageInfo.fromPlatform()
        .then((info) {
          if (mounted) {
            setState(() => _version = info.version);
          }
        })
        .catchError((Object _) {});
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
    final copy = Copy.of(context);
    final accentIndex = accentSeeds.indexOf(repo.accent);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        Text(
          copy.settings,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          copy.settingsLead,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _Head(copy.appearance),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(copy.system),
              icon: const Icon(Icons.brightness_auto),
            ),
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(copy.light),
              icon: const Icon(Icons.light_mode_outlined),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(copy.dark),
              icon: const Icon(Icons.dark_mode_outlined),
            ),
          ],
          selected: {repo.themeMode},
          onSelectionChanged: (value) => repo.setTheme(value.first),
        ),
        const SizedBox(height: 16),
        _Head(copy.accent),
        Wrap(
          spacing: 8,
          children: [
            for (var index = 0; index < accentSeeds.length; index++)
              IconButton(
                tooltip: copy.accentName(index),
                onPressed: () => repo.setAccent(accentSeeds[index]),
                icon: CircleAvatar(
                  backgroundColor: Color(accentSeeds[index]),
                  child: accentIndex == index
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _Head(copy.language),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'ja', label: Text('日本語')),
            ButtonSegment(value: 'en', label: Text('English')),
            ButtonSegment(value: 'ko', label: Text('한국어')),
          ],
          selected: {repo.language},
          onSelectionChanged: (value) => repo.setLanguage(value.first),
        ),
        const SizedBox(height: 16),
        _Head(copy.homeTab),
        Wrap(
          spacing: 8,
          children: [
            for (final entry in [0, 1, 2, 3])
              ChoiceChip(
                label: Text(switch (entry) {
                  0 => copy.lists,
                  1 => copy.today,
                  2 => copy.calendar,
                  _ => copy.tools,
                }),
                selected: repo.homeTab == entry,
                onSelected: (_) => repo.setHomeTab(entry),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(copy.homeLayout),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const HomeLayoutPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        _Head(copy.pomodoro),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Minutes(
              label: copy.focusMinutes,
              value: repo.pomoFocusMin,
              onChanged: (value) => repo.setPomoDurations(
                focus: value,
                shortBreak: repo.pomoShortMin,
                longBreak: repo.pomoLongMin,
              ),
            ),
            _Minutes(
              label: copy.shortMinutes,
              value: repo.pomoShortMin,
              onChanged: (value) => repo.setPomoDurations(
                focus: repo.pomoFocusMin,
                shortBreak: value,
                longBreak: repo.pomoLongMin,
              ),
            ),
            _Minutes(
              label: copy.longMinutes,
              value: repo.pomoLongMin,
              onChanged: (value) => repo.setPomoDurations(
                focus: repo.pomoFocusMin,
                shortBreak: repo.pomoShortMin,
                longBreak: value,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Head(copy.thisDevice),
        TextField(
          controller: _name,
          decoration: InputDecoration(labelText: copy.deviceName),
          onSubmitted: repo.setDeviceName,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => repo.setDeviceName(_name.text),
            child: Text(copy.saveDevice),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          copy.deviceId(repo.deviceId),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),
        _Head(copy.sync),
        TextField(
          controller: _url,
          decoration: InputDecoration(
            labelText: copy.syncUrl,
            hintText: 'http://127.0.0.1:8787',
            errorText: _urlError,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => _saveUrl(repo),
              child: Text(copy.saveUrl),
            ),
            OutlinedButton(
              onPressed: () async {
                _url.clear();
                setState(() => _urlError = null);
                await repo.setSyncUrl('');
              },
              child: Text(copy.clearUrl),
            ),
            OutlinedButton(
              onPressed: repo.flushSync,
              child: Text(copy.syncNow),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(repo.syncMessage),
        Text(
          copy.pending(repo.outboxCount),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        _Head(copy.backup),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: () => _exportFile(repo),
              child: Text(copy.exportFile),
            ),
            OutlinedButton(
              onPressed: () => _copy(repo),
              child: Text(copy.copyJson),
            ),
            OutlinedButton(
              onPressed: () => _importFile(repo),
              child: Text(copy.importFile),
            ),
            OutlinedButton(
              onPressed: () => _paste(repo),
              child: Text(copy.pasteJson),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Head(copy.keyboard),
        Text(copy.shortcuts),
        const SizedBox(height: 28),
        Text(
          copy.versionLabel(_version),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () => checkForUpdate(context, fromSettings: true),
            child: Text(copy.checkUpdate),
          ),
        ),
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
    final copy = Copy.of(context);
    try {
      final json = await repo.exportJson();
      final saved = await FilePicker.saveFile(
        fileName: 'tas-backup.json',
        bytes: Uint8List.fromList(utf8.encode(json)),
        dialogTitle: copy.exportDialog,
      );
      if (!mounted) {
        return;
      }
      if (saved != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(Copy.of(context).exported)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Copy.of(context).exportFailed)));
      }
    }
  }

  Future<void> _copy(TaskRepository repo) async {
    final json = await repo.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(Copy.of(context).copied)));
    }
  }

  Future<void> _importFile(TaskRepository repo) async {
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: Copy.of(context).importDialog,
      );
      if (picked == null) {
        return;
      }
      final raw = utf8.decode(await picked.readAsBytes());
      await repo.importJson(raw);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(Copy.of(context).imported)));
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Copy.of(context).importFailed)));
      }
    }
  }

  Future<void> _paste(TaskRepository repo) async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Copy.of(context).pasteTitle),
        content: TextField(
          controller: controller,
          minLines: 6,
          maxLines: 12,
          decoration: InputDecoration(hintText: Copy.of(context).pasteHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(Copy.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(Copy.of(context).importAction),
          ),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty) {
      return;
    }
    try {
      await repo.importJson(text);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(Copy.of(context).imported)));
      }
    } on FormatException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(Copy.of(context).importFailed)));
      }
    }
  }
}

class _Minutes extends StatelessWidget {
  const _Minutes({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: '$value',
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onFieldSubmitted: (raw) {
          final parsed = int.tryParse(raw);
          if (parsed != null) {
            onChanged(parsed);
          }
        },
      ),
    );
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
