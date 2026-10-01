import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/local_tools.dart';
import '../domain/models.dart';
import 'widgets.dart';

class ToolsMenu extends StatelessWidget {
  const ToolsMenu({required this.onOpen, super.key});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Text(
            'ツール',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        _tile(
          context,
          'pomodoro',
          Icons.timer_outlined,
          'ポモドーロ',
          '25分の集中と5分の休憩',
        ),
        _tile(
          context,
          'matrix',
          Icons.grid_view_outlined,
          'マトリックス',
          '重要と緊急でタスクを分ける',
        ),
        _tile(context, 'habits', Icons.repeat, '習慣', '今日のチェックと連続日数'),
        _tile(context, 'diary', Icons.menu_book_outlined, '日記', '1日につき1件'),
        _tile(context, 'search', Icons.search, '検索', 'タスク名とメモ'),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    String id,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Card(
      child: ListTile(
        key: Key('tool-$id'),
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => onOpen(id),
      ),
    );
  }
}

class ToolPage extends StatelessWidget {
  const ToolPage({required this.id, this.onOpenTask, super.key});

  final String id;
  final ValueChanged<String>? onOpenTask;

  @override
  Widget build(BuildContext context) {
    return switch (id) {
      'pomodoro' => const PomodoroPage(),
      'matrix' => MatrixPage(onOpenTask: onOpenTask),
      'habits' => const HabitsPage(),
      'diary' => const DiaryPage(),
      _ => const SizedBox.shrink(),
    };
  }
}

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  Timer? _timer;
  var _caughtUp = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      RepoScope.of(context).tools.tickPomo();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_caughtUp) {
      return;
    }
    _caughtUp = true;
    RepoScope.of(context).tools.tickPomo();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final tools = repo.tools;
    final left = Duration(milliseconds: tools.displayRemainingMs);
    final minutes = left.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = left.inSeconds.remainder(60).toString().padLeft(2, '0');
    final openTasks = repo.tasks
        .where((task) => !task.deleted && !task.isCompleted)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          tools.pomoFocus ? '集中' : '休憩',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          '$minutes:$seconds',
          style: Theme.of(context).textTheme.displayMedium
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text('終えた集中 ${tools.finishedSessions} 回'),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          key: ValueKey(tools.pomoTaskId),
          initialValue: openTasks.any((task) => task.id == tools.pomoTaskId)
              ? tools.pomoTaskId
              : null,
          decoration: const InputDecoration(labelText: 'タスク'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('タスクを付けない'),
            ),
            for (final task in openTasks)
              DropdownMenuItem(value: task.id, child: Text(task.title)),
          ],
          onChanged: tools.setPomoTask,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              onPressed: tools.pomoRunning ? tools.pausePomo : tools.startPomo,
              child: Text(tools.pomoRunning ? '一時停止' : '開始'),
            ),
            OutlinedButton(
              onPressed: tools.resetPomo,
              child: const Text('リセット'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '集中は25分、休憩は5分です。',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class MatrixPage extends StatelessWidget {
  const MatrixPage({this.onOpenTask, super.key});

  final ValueChanged<String>? onOpenTask;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final tools = repo.tools;
    final open = repo.tasks
        .where((task) => !task.deleted && !task.isCompleted)
        .toList();
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: FilledButton.tonal(
              onPressed: () => _place(context, open),
              child: const Text('タスクを置く'),
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(12),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (var quadrant = 0; quadrant < 4; quadrant++)
                _Quadrant(
                  label: quadrantLabels[quadrant],
                  tasks: open
                      .where((task) => tools.placements[task.id] == quadrant)
                      .toList(),
                  onOpen: onOpenTask,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _place(BuildContext context, List<TaskModel> tasks) async {
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('置ける未完了のタスクがありません。')));
      return;
    }
    final repo = RepoScope.of(context);
    var taskId = tasks.first.id;
    var quadrant = repo.tools.placements[taskId] ?? 0;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('タスクを置く'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: taskId,
                items: [
                  for (final task in tasks)
                    DropdownMenuItem(value: task.id, child: Text(task.title)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setLocal(() => taskId = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: quadrant,
                items: [
                  for (var index = 0; index < 4; index++)
                    DropdownMenuItem(
                      value: index,
                      child: Text(quadrantLabels[index]),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setLocal(() => quadrant = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('置く'),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      await repo.tools.placeTask(taskId, quadrant);
    }
  }
}

class _Quadrant extends StatelessWidget {
  const _Quadrant({
    required this.label,
    required this.tasks,
    required this.onOpen,
  });

  final String label;
  final List<TaskModel> tasks;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Expanded(
              child: tasks.isEmpty
                  ? const Text('この区分のタスクはありません。')
                  : ListView(
                      children: [
                        for (final task in tasks)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: onOpen == null
                                ? null
                                : () => onOpen!(task.id),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tools = RepoScope.of(context).tools;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: '新しい習慣'),
                  onSubmitted: _add,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _add(_name.text),
                child: const Text('追加'),
              ),
            ],
          ),
        ),
        Expanded(
          child: tools.habits.isEmpty
              ? const EmptyHint(message: '習慣はまだありません。', icon: Icons.repeat)
              : ListView(
                  children: [
                    for (final habit in tools.habits)
                      CheckboxListTile(
                        value: habit.checkedToday,
                        onChanged: (_) => tools.toggleHabitToday(habit.id),
                        title: Text(habit.name),
                        subtitle: Text('連続 ${habit.streak} 日'),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _add(String name) async {
    final tools = RepoScope.of(context).tools;
    await tools.addHabit(name);
    if (!mounted) {
      return;
    }
    _name.clear();
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  late DateTime _day;
  final TextEditingController _body = TextEditingController();
  Timer? _save;
  LocalTools? _tools;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tools = RepoScope.of(context).tools;
    if (_seeded) {
      return;
    }
    _seeded = true;
    _body.text = _tools!.diary[dayKey(_day)] ?? '';
  }

  @override
  void dispose() {
    _save?.cancel();
    _flush();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stored = RepoScope.of(context).tools.diary[dayKey(_day)] ?? '';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: TextButton(
                  key: const Key('diary-date'),
                  onPressed: _pickDay,
                  child: Text(
                    '${_day.year}年${_day.month}月${_day.day}日',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        if (stored.isEmpty && _body.text.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('この日の日記はまだありません。'),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _body,
              expands: true,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: '今日のことを書く',
                alignLabelWithHint: true,
              ),
              onChanged: (_) {
                _save?.cancel();
                _save = Timer(const Duration(milliseconds: 300), _flush);
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }

  void _shift(int days) {
    final previous = dayKey(_day);
    final text = _body.text;
    setState(() {
      _day = _day.add(Duration(days: days));
      _body.text = _tools?.diary[dayKey(_day)] ?? '';
    });
    _tools?.saveDiary(previous, text);
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(_day.year - 5),
      lastDate: DateTime(_day.year + 2),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    final previous = dayKey(_day);
    final text = _body.text;
    setState(() {
      _day = DateTime(picked.year, picked.month, picked.day);
      _body.text = _tools?.diary[dayKey(_day)] ?? '';
    });
    await _tools?.saveDiary(previous, text);
  }

  void _flush() {
    _tools?.saveDiary(dayKey(_day), _body.text);
  }
}
