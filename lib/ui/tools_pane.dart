import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/local_tools.dart';
import '../domain/models.dart';
import '../l10n/copy.dart';
import '../reminders/os_notifications.dart';
import 'widgets.dart';

class ToolsMenu extends StatelessWidget {
  const ToolsMenu({required this.onOpen, super.key});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Text(
            copy.tools,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        _tile(
          context,
          'pomodoro',
          Icons.timer_outlined,
          copy.pomodoro,
          copy.pomodoroBlurb,
        ),
        _tile(
          context,
          'matrix',
          Icons.grid_view_outlined,
          copy.matrix,
          copy.matrixBlurb,
        ),
        _tile(context, 'habits', Icons.repeat, copy.habits, copy.habitsBlurb),
        _tile(
          context,
          'diary',
          Icons.menu_book_outlined,
          copy.diary,
          copy.diaryBlurb,
        ),
        _tile(context, 'search', Icons.search, copy.search, copy.searchBlurb),
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
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceContainerLow,
      child: ListTile(
        key: Key('tool-$id'),
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
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

class PomoChip extends StatelessWidget {
  const PomoChip({required this.onOpen, super.key});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final tools = RepoScope.of(context).tools;
    final copy = Copy.of(context);
    final label = switch (tools.phase) {
      'short' => copy.shortBreak,
      'long' => copy.longBreak,
      _ => copy.focusPhase,
    };
    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        key: const Key('pomo-chip'),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text(
                clockLabel(tools.displayRemainingMs),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final tools = repo.tools;
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final phase = switch (tools.phase) {
      'short' => copy.shortBreak,
      'long' => copy.longBreak,
      _ => copy.focusPhase,
    };
    final openTasks = repo.tasks
        .where((task) => !task.deleted && !task.isCompleted)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Card(
          elevation: 0,
          color: scheme.primaryContainer.withValues(alpha: 0.45),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                Text(phase, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  clockLabel(tools.displayRemainingMs),
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 8),
                Text(copy.sessions(tools.finishedSessions)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String?>(
          key: ValueKey(tools.pomoTaskId),
          initialValue: openTasks.any((task) => task.id == tools.pomoTaskId)
              ? tools.pomoTaskId
              : null,
          decoration: InputDecoration(labelText: copy.task),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(copy.noTask)),
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
            FilledButton.icon(
              onPressed: tools.pomoRunning ? tools.pausePomo : tools.startPomo,
              icon: Icon(tools.pomoRunning ? Icons.pause : Icons.play_arrow),
              label: Text(tools.pomoRunning ? copy.pause : copy.start),
            ),
            OutlinedButton.icon(
              onPressed: tools.resetPomo,
              icon: const Icon(Icons.replay),
              label: Text(copy.reset),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(copy.pomoHint, style: TextStyle(color: scheme.onSurfaceVariant)),
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
    final copy = Copy.of(context);
    final open = repo.tasks
        .where((task) => !task.deleted && !task.isCompleted)
        .toList();
    final unplaced = open
        .where((task) => !tools.placements.containsKey(task.id))
        .toList();
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 0.9,
            children: [
              for (var quadrant = 0; quadrant < 4; quadrant++)
                _Quadrant(
                  quadrant: quadrant,
                  label: copy.quadrant(quadrant),
                  tasks: open
                      .where((task) => tools.placements[task.id] == quadrant)
                      .toList(),
                  onOpen: onOpenTask,
                ),
            ],
          ),
        ),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: SizedBox(
            height: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
                  child: Row(
                    children: [
                      Text(
                        copy.unplaced,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _place(context, open),
                        child: Text(copy.placeTask),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: unplaced.isEmpty
                      ? const SizedBox.shrink()
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            for (final task in unplaced)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _TaskChip(
                                  task: task,
                                  onOpen: onOpenTask,
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _place(BuildContext context, List<TaskModel> tasks) async {
    final copy = Copy.of(context);
    if (tasks.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(copy.noOpenTasks)));
      return;
    }
    final repo = RepoScope.of(context);
    var taskId = tasks.first.id;
    var quadrant = repo.tools.placements[taskId] ?? 0;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text(copy.placeTask),
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
                      child: Text(copy.quadrant(index)),
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
              child: Text(copy.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(copy.place),
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
    required this.quadrant,
    required this.label,
    required this.tasks,
    required this.onOpen,
  });

  final int quadrant;
  final String label;
  final List<TaskModel> tasks;
  final ValueChanged<String>? onOpen;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tint = switch (quadrant) {
      0 => scheme.errorContainer,
      1 => scheme.primaryContainer,
      2 => scheme.tertiaryContainer,
      _ => scheme.surfaceContainerHigh,
    };
    return DragTarget<String>(
      onAcceptWithDetails: (details) =>
          RepoScope.of(context).tools.placeTask(details.data, quadrant),
      builder: (context, candidate, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: candidate.isEmpty ? tint.withValues(alpha: 0.55) : tint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidate.isEmpty ? scheme.outlineVariant : scheme.primary,
              width: candidate.isEmpty ? 1 : 2,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Expanded(
                child: tasks.isEmpty
                    ? Text(copy.quadrantEmpty)
                    : ListView(
                        children: [
                          for (final task in tasks)
                            _TaskChip(
                              task: task,
                              onOpen: onOpen,
                              quadrant: quadrant,
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.task, required this.onOpen, this.quadrant});

  final TaskModel task;
  final ValueChanged<String>? onOpen;
  final int? quadrant;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    return Draggable<String>(
      data: task.id,
      feedback: Material(child: Chip(label: Text(task.title))),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: Chip(label: Text(task.title)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        onTap: onOpen == null ? null : () => onOpen!(task.id),
        trailing: PopupMenuButton<int>(
          tooltip: copy.move,
          onSelected: (value) async {
            final tools = RepoScope.of(context).tools;
            if (value < 0) {
              await tools.clearPlacement(task.id);
            } else {
              await tools.placeTask(task.id, value);
            }
          },
          itemBuilder: (context) => [
            for (var index = 0; index < 4; index++)
              if (index != quadrant)
                PopupMenuItem(value: index, child: Text(copy.quadrant(index))),
            if (quadrant != null)
              PopupMenuItem(value: -1, child: Text(copy.removePlacement)),
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
    final copy = Copy.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _name,
                  decoration: InputDecoration(hintText: copy.newHabit),
                  onSubmitted: _add,
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => _add(_name.text),
                child: Text(copy.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: tools.habits.isEmpty && tools.archivedHabits.isEmpty
              ? EmptyHint(message: copy.habitsEmpty, icon: Icons.repeat)
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    for (final habit in tools.habits)
                      _HabitCard(habit: habit, onChanged: _sync),
                    if (tools.archivedHabits.isNotEmpty)
                      ExpansionTile(
                        title: Text(copy.archivedHabits),
                        children: [
                          for (final habit in tools.archivedHabits)
                            _HabitCard(habit: habit, onChanged: _sync),
                        ],
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
    await _sync();
  }

  Future<void> _sync() async {
    final tools = RepoScope.of(context).tools;
    await OsNotifications.instance.syncHabits([
      ...tools.habits,
      ...tools.archivedHabits,
    ]);
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.habit, required this.onChanged});

  final HabitView habit;
  final Future<void> Function() onChanged;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tools = RepoScope.of(context).tools;
    final reminder = habit.reminderMinute == null
        ? copy.noReminder
        : '${(habit.reminderMinute! ~/ 60).toString().padLeft(2, '0')}:${(habit.reminderMinute! % 60).toString().padLeft(2, '0')}';
    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HabitCheck(
              checked: habit.checkedToday,
              color: Color(habit.color),
              checkKey: Key('habit-check-${habit.id}'),
              onTap: () async {
                await tools.toggleHabitToday(habit.id);
                await onChanged();
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(copy.streak(habit.streak)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final done in habit.week)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done
                                  ? Color(habit.color)
                                  : scheme.outlineVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reminder,
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _action(context, value),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'rename', child: Text(copy.rename)),
                PopupMenuItem(value: 'color', child: Text(copy.changeColor)),
                PopupMenuItem(
                  value: 'remind',
                  child: Text(copy.reminderOptional),
                ),
                PopupMenuItem(
                  value: 'archive',
                  child: Text(
                    habit.archived ? copy.unarchiveList : copy.archive,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _action(BuildContext context, String value) async {
    final tools = RepoScope.of(context).tools;
    final copy = Copy.of(context);
    switch (value) {
      case 'rename':
        final name = await _ask(context, copy.rename, habit.name);
        if (name != null) {
          await tools.renameHabit(habit.id, name);
        }
      case 'color':
        final color = await showDialog<int>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(copy.color),
            content: Wrap(
              spacing: 8,
              children: [
                for (final swatch in listColors)
                  IconButton(
                    onPressed: () => Navigator.pop(context, swatch),
                    icon: CircleAvatar(backgroundColor: Color(swatch)),
                  ),
              ],
            ),
          ),
        );
        if (color != null) {
          await tools.setHabitColor(habit.id, color);
        }
      case 'remind':
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(
            hour: (habit.reminderMinute ?? 8 * 60) ~/ 60,
            minute: (habit.reminderMinute ?? 0) % 60,
          ),
        );
        if (!context.mounted) {
          return;
        }
        if (picked == null) {
          await tools.setHabitReminder(habit.id, null);
        } else {
          await tools.setHabitReminder(
            habit.id,
            picked.hour * 60 + picked.minute,
          );
        }
      case 'archive':
        await tools.setHabitArchived(habit.id, !habit.archived);
    }
    await onChanged();
  }

  Future<String?> _ask(
    BuildContext context,
    String title,
    String initial,
  ) async {
    final copy = Copy.of(context);
    final controller = TextEditingController(text: initial);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: copy.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(copy.save),
          ),
        ],
      ),
    );
    return value == null || value.isEmpty ? null : value;
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
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final stored = RepoScope.of(context).tools.diary[dayKey(_day)] ?? '';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: copy.back,
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: TextButton(
                  key: const Key('diary-date'),
                  onPressed: _pickDay,
                  child: Text(
                    copy.diaryDate(_day),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              stored.isEmpty && _body.text.isEmpty
                  ? copy.diaryEmpty
                  : copy.savedLocally,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _body,
                expands: true,
                maxLines: null,
                style: const TextStyle(fontSize: 18, height: 1.5),
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: copy.diaryHint,
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.all(16),
                ),
                onChanged: (_) {
                  _save?.cancel();
                  _save = Timer(const Duration(milliseconds: 300), _flush);
                  setState(() {});
                },
              ),
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
    if (picked == null || !mounted) {
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
