import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/local_tools.dart';
import '../domain/models.dart';
import '../l10n/copy.dart';
import '../reminders/os_notifications.dart';
import 'widgets.dart';

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
          isExpanded: true,
          initialValue: openTasks.any((task) => task.id == tools.pomoTaskId)
              ? tools.pomoTaskId
              : null,
          decoration: InputDecoration(labelText: copy.task),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(copy.noTask)),
            for (final task in openTasks)
              DropdownMenuItem(
                value: task.id,
                child: Text(task.title, overflow: TextOverflow.ellipsis),
              ),
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
            height: 120,
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
                        onPressed: () => showPlaceTaskDialog(context),
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
                                child: SizedBox(
                                  width: 240,
                                  child: _TaskChip(
                                    task: task,
                                    onOpen: onOpenTask,
                                  ),
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
}

Future<void> showPlaceTaskDialog(BuildContext context) async {
  final repo = RepoScope.of(context);
  final tasks = repo.tasks
      .where((task) => !task.deleted && !task.isCompleted)
      .toList();
  final copy = Copy.of(context);
  if (tasks.isEmpty) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(copy.noOpenTasks)));
    return;
  }
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
              key: const Key('matrix-task'),
              isExpanded: true,
              initialValue: taskId,
              items: [
                for (final task in tasks)
                  DropdownMenuItem(
                    value: task.id,
                    child: Text(task.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setLocal(() {
                    taskId = value;
                    quadrant = repo.tools.placements[taskId] ?? 0;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              key: ValueKey('matrix-quadrant-$taskId'),
              isExpanded: true,
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

Future<void> logHabitFromUi(
  BuildContext context,
  HabitView habit, {
  required bool tap,
  Future<void> Function()? onChanged,
}) async {
  final tools = RepoScope.of(context).tools;
  if (tap && habit.goal > 1) {
    if (!habit.checkedToday) {
      return;
    }
    await tools.setHabitAmount(habit.id, 0);
    await onChanged?.call();
    return;
  }
  await tools.logHabit(habit.id, toggle: tap);
  await onChanged?.call();
}

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  Future<void> _showAdd() async {
    final copy = Copy.of(context);
    final name = TextEditingController();
    var goal = 1;
    var saving = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, update) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              0,
              24,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    copy.newHabit,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: name,
                    autofocus: true,
                    maxLength: 100,
                    decoration: InputDecoration(
                      labelText: copy.name,
                      hintText: copy.pick(
                        '例：水を飲む、読書する',
                        'e.g. Drink water, read',
                        '예: 물 마시기, 독서',
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => update(() {}),
                  ),
                  Row(
                    children: [
                      Expanded(child: Text(copy.dailyGoal(goal))),
                      IconButton.outlined(
                        key: const Key('habit-goal-less'),
                        tooltip: copy.decreaseGoal,
                        onPressed: saving || goal <= 1
                            ? null
                            : () => update(() => goal--),
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      IconButton.outlined(
                        key: const Key('habit-goal-more'),
                        tooltip: copy.increaseGoal,
                        onPressed: saving || goal >= 99
                            ? null
                            : () => update(() => goal++),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('save-habit'),
                    onPressed: saving || name.text.trim().isEmpty
                        ? null
                        : () async {
                            update(() => saving = true);
                            try {
                              await RepoScope.of(context).tools
                                  .addHabit(name.text.trim(), goal: goal);
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              await _sync();
                            } finally {
                              if (sheetContext.mounted) {
                                update(() => saving = false);
                              }
                            }
                          },
                    icon: const Icon(Icons.add),
                    label: Text(copy.add),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    // The bottom sheet's exit animation still owns its text field briefly.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tools = RepoScope.of(context).tools;
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final complete = tools.habits.where((habit) => habit.checkedToday).length;
    final total = tools.habits.length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                copy.habits,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            FilledButton.icon(
              key: const Key('add-habit'),
              onPressed: _showAdd,
              icon: const Icon(Icons.add),
              label: Text(copy.add),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                copy.pick('今日の達成', 'Today’s progress', '오늘의 달성'),
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(
                '$complete / $total',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: total == 0 ? 0 : complete / total,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                semanticsLabel: copy.habits,
                semanticsValue:
                    '${total == 0 ? 0 : (complete * 100 / total).round()}',
              ),
              const SizedBox(height: 12),
              Text(
                copy.pick(
                  '＋で記録、−で取り消し。少しずつ続けましょう。',
                  'Tap + to log, − to undo. One step at a time.',
                  '+로 기록하고 −로 취소하세요. 조금씩 계속해요.',
                ),
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (tools.habits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: EmptyHint(message: copy.habitsEmpty, icon: Icons.repeat),
          ),
        for (final habit in tools.habits)
          _HabitCard(key: ValueKey(habit.id), habit: habit, onChanged: _sync),
        if (tools.archivedHabits.isNotEmpty)
          ExpansionTile(
            title: Text(copy.archivedHabits),
            children: [
              for (final habit in tools.archivedHabits)
                _HabitCard(
                  key: ValueKey(habit.id),
                  habit: habit,
                  onChanged: _sync,
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _sync() async {
    if (!mounted) return;
    final tools = RepoScope.of(context).tools;
    await OsNotifications.instance.syncHabits([
      ...tools.habits,
      ...tools.archivedHabits,
    ]);
  }
}

class _HabitCard extends StatefulWidget {
  const _HabitCard({required this.habit, required this.onChanged, super.key});
  final HabitView habit;
  final Future<void> Function() onChanged;
  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard> {
  HabitView get habit => widget.habit;
  Future<void> Function() get onChanged => widget.onChanged;
  bool _saving = false;

  Future<void> _change(int delta) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await RepoScope.of(context).tools.setHabitAmount(
        habit.id,
        (habit.progress + delta).clamp(0, habit.goal),
      );
      if (mounted) await onChanged();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final today = RepoScope.of(context).tools.now();
    final weekdays = copy
        .pick('月 火 水 木 金 土 日', 'M T W T F S S', '월 화 수 목 금 토 일')
        .split(' ');
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  habit.checkedToday ? Icons.check_circle : Icons.repeat,
                  color: Color(habit.color),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    habit.name,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: copy.pick('習慣の設定', 'Habit settings', '습관 설정'),
                  onSelected: (value) => _action(context, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'rename', child: Text(copy.rename)),
                    PopupMenuItem(
                      value: 'color',
                      child: Text(copy.changeColor),
                    ),
                    PopupMenuItem(
                      value: 'remind',
                      child: Text(copy.reminderOptional),
                    ),
                    if (habit.reminderMinute != null)
                      PopupMenuItem(
                        value: 'clear-reminder',
                        child: Text(copy.noReminder),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    copy.streak(habit.streak),
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
                if (habit.reminderMinute != null) ...[
                  Icon(
                    Icons.notifications_outlined,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(habit.reminderMinute! ~/ 60).toString().padLeft(2, '0')}:${(habit.reminderMinute! % 60).toString().padLeft(2, '0')}',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.outlined(
                  key: Key('habit-minus-${habit.id}'),
                  tooltip: copy.pick('1回取り消す', 'Undo one', '1회 취소'),
                  onPressed: _saving || habit.archived || habit.progress <= 0
                      ? null
                      : () => _change(-1),
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        copy.habitProgress(habit.progress, habit.goal),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        habit.checkedToday
                            ? copy.completed
                            : copy.dailyGoal(habit.goal),
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  key: Key('habit-check-${habit.id}'),
                  tooltip: copy.pick('1回記録する', 'Log one', '1회 기록'),
                  onPressed: _saving || habit.archived || habit.checkedToday
                      ? null
                      : () => _change(1),
                  icon: Icon(habit.checkedToday ? Icons.check : Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (var i = 0; i < habit.week.length; i++)
                  Expanded(
                    child: Semantics(
                      label:
                          '${dayKey(DateTime(today.year, today.month, today.day - 6 + i))} ${habit.week[i] ? copy.completed : copy.pick('未達成', 'Incomplete', '미완료')}',
                      child: Column(
                        children: [
                          Text(
                            weekdays[DateTime(
                                  today.year,
                                  today.month,
                                  today.day - 6 + i,
                                ).weekday -
                                1],
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            habit.week[i]
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 20,
                            color: habit.week[i]
                                ? Color(habit.color)
                                : scheme.outlineVariant,
                          ),
                        ],
                      ),
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
          return;
        }
        await tools.setHabitReminder(
          habit.id,
          picked.hour * 60 + picked.minute,
        );
      case 'clear-reminder':
        await tools.setHabitReminder(habit.id, null);
      case 'archive':
        await tools.setHabitArchived(habit.id, !habit.archived);
    }
    if (context.mounted) {
      await onChanged();
    }
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

class _DiaryPageState extends State<DiaryPage> with WidgetsBindingObserver {
  late DateTime _day;
  final TextEditingController _body = TextEditingController();
  Timer? _save;
  LocalTools? _tools;
  var _seeded = false;
  final Map<String, String> _drafts = {};
  final Map<String, int> _draftRevisions = {};
  final Map<String, int> _pending = {};
  int _revision = 0;
  final Set<String> _failed = {};
  Future<void> _saveTail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tools = RepoScope.of(context).tools;
    if (_seeded && _drafts.containsKey(dayKey(_day))) {
      return;
    }
    _seeded = true;
    final stored = _tools!.diary[dayKey(_day)] ?? '';
    if (_body.text != stored) {
      _body.text = stored;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _flush();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _save?.cancel();
    _flush();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final key = dayKey(_day);
    final failed = _failed.contains(key);
    final saving = _drafts.containsKey(key);
    final today = dayKey(DateTime.now()) == key;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 320;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!compact)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        copy.diary,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      key: const Key('diary-history'),
                      onPressed: _showEntries,
                      icon: const Icon(Icons.history_rounded),
                      label: Text(copy.pick('過去の日記', 'Past entries', '지난 일기')),
                    ),
                  ],
                ),
              Row(
                children: [
                  IconButton(
                    tooltip: copy.pick('前の日', 'Previous day', '이전 날'),
                    onPressed: () => _shift(-1),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      key: const Key('diary-date'),
                      onPressed: _pickDay,
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(
                        copy.diaryDate(_day),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: copy.pick('次の日', 'Next day', '다음 날'),
                    onPressed: () => _shift(1),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  if (!today)
                    TextButton(
                      key: const Key('diary-today'),
                      onPressed: () {
                        final now = DateTime.now();
                        _changeDay(DateTime(now.year, now.month, now.day));
                      },
                      child: Text(copy.today),
                    ),
                ],
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    border: Border.all(color: scheme.outlineVariant),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: TextField(
                    key: const Key('diary-body'),
                    controller: _body,
                    expands: true,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(fontSize: 18, height: 1.7),
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      hintText: copy.pick(
                        '今日はどんな一日でしたか？\n出来事や気持ちを、自由に書いてみましょう。',
                        'How was your day?\nWrite down a moment, a feeling, or a thought.',
                        '오늘은 어떤 하루였나요?\n있었던 일이나 마음을 자유롭게 적어 보세요.',
                      ),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                    onChanged: (text) {
                      _drafts[dayKey(_day)] = text;
                      _draftRevisions[dayKey(_day)] = ++_revision;
                      _failed.remove(dayKey(_day));
                      _save?.cancel();
                      _save = Timer(const Duration(milliseconds: 300), _flush);
                      setState(() {});
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    failed
                        ? Icons.error_outline
                        : saving
                        ? Icons.more_horiz
                        : Icons.check_circle_outline,
                    size: 16,
                    color: failed ? scheme.error : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Semantics(
                      liveRegion: failed,
                      child: Text(
                        failed
                            ? copy.diarySaveFailed
                            : saving
                            ? copy.diarySaving
                            : copy.pick('保存済み', 'Saved', '저장됨'),
                        style: TextStyle(
                          fontSize: 12,
                          color: failed
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  if (failed)
                    TextButton(onPressed: _flush, child: Text(copy.retry))
                  else
                    Text(
                      copy.pick(
                        '${_body.text.characters.length}文字',
                        '${_body.text.characters.length} characters',
                        '${_body.text.characters.length}자',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEntries() async {
    FocusScope.of(context).unfocus();
    final copy = Copy.of(context);
    final entries =
        {...?_tools?.diary, ..._drafts}.entries
            .where(
              (entry) =>
                  entry.value.trim().isNotEmpty &&
                  DateTime.tryParse(entry.key) != null,
            )
            .toList()
          ..sort((a, b) => b.key.compareTo(a.key));
    final selected = await showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        copy.pick('過去の日記', 'Past entries', '지난 일기'),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: copy.close,
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            copy.pick(
                              '日記を書くと、ここから読み返せます。',
                              'Your entries will appear here as you write.',
                              '일기를 쓰면 여기에서 다시 읽을 수 있어요.',
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, index) =>
                            const Divider(height: 1, indent: 20, endIndent: 20),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          final date = DateTime.parse(entry.key);
                          return ListTile(
                            key: Key('diary-entry-${entry.key}'),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            selected: entry.key == dayKey(_day),
                            title: Text(copy.diaryDate(date)),
                            subtitle: Text(
                              entry.value.trim().replaceAll(
                                RegExp(r'\s+'),
                                ' ',
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () => Navigator.pop(context, date),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) _changeDay(selected);
  }

  void _shift(int days) {
    _changeDay(DateTime(_day.year, _day.month, _day.day + days));
  }

  void _changeDay(DateTime day) {
    _flush();
    setState(() {
      _day = day;
      _body.text = _drafts[dayKey(_day)] ?? _tools?.diary[dayKey(_day)] ?? '';
    });
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
    _changeDay(DateTime(picked.year, picked.month, picked.day));
  }

  void _flush() {
    _save?.cancel();
    final tools = _tools;
    if (tools == null) {
      return;
    }
    for (final entry in _drafts.entries.toList()) {
      final revision = _draftRevisions[entry.key]!;
      if (_pending[entry.key] == revision) {
        continue;
      }
      _pending[entry.key] = revision;
      _saveTail = _saveTail.then((_) async {
        try {
          await tools.saveDiary(entry.key, entry.value);
          if (_draftRevisions[entry.key] == revision) {
            _drafts.remove(entry.key);
            _draftRevisions.remove(entry.key);
            _failed.remove(entry.key);
          }
        } catch (_) {
          if (_draftRevisions[entry.key] == revision) {
            _failed.add(entry.key);
          }
        } finally {
          if (_pending[entry.key] == revision) {
            _pending.remove(entry.key);
          }
          if (mounted) {
            setState(() {});
          }
        }
      });
    }
  }
}
