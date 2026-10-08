import 'dart:async';

import 'package:flutter/material.dart';

import '../app.dart';
import '../data/local_tools.dart';
import '../domain/filters.dart';
import '../domain/home_layout.dart';
import '../domain/models.dart' hide isOverdue;
import '../l10n/copy.dart';
import 'add_sheet.dart';
import 'home_layout_page.dart';
import 'tools_pane.dart';
import 'widgets.dart';

class TodayHome extends StatefulWidget {
  const TodayHome({required this.onOpen, super.key});

  final ValueChanged<String> onOpen;

  @override
  State<TodayHome> createState() => _TodayHomeState();
}

class _TodayHomeState extends State<TodayHome> {
  late DateTime _day;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _day = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final blocks = parseHomeLayout(repo.homeLayout);
    final today = startOfDay(DateTime.now());
    final shown = blocks.where((block) => block.visible).toList();
    final weekOn = shown.any((block) => block.id == 'week');
    final scheduleDay = weekOn ? _day : today;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('create-task'),
        tooltip: copy.createTask,
        onPressed: () => showAddSheet(context, day: scheduleDay),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  copy.today,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                key: const Key('home-layout'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (context) => const HomeLayoutPage()),
                  );
                },
                child: Text(copy.homeLayout),
              ),
            ],
          ),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                copy.allBlocksHidden,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          for (final block in shown) ...[
            const SizedBox(height: 20),
            switch (block.id) {
              'week' => _WeekStrip(
                selected: _day,
                today: today,
                tasks: repo.tasks,
                onSelect: (day) => setState(() => _day = day),
              ),
              'schedule' => _Schedule(
                day: scheduleDay,
                today: today,
                tasks: daySchedule(repo.tasks, scheduleDay),
                onOpen: widget.onOpen,
              ),
              'overdue' => _Overdue(
                tasks: repo.tasks.where((task) => isOverdue(task, today)).toList(),
                onOpen: widget.onOpen,
              ),
              'habits' => const _TodayHabits(),
              'pomodoro' => const _HomePomodoro(),
              'diary' => _HomeDiary(day: weekOn ? _day : null),
              _ => _HomeMatrix(onOpen: widget.onOpen),
            },
          ],
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selected,
    required this.today,
    required this.tasks,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime today;
  final List<TaskModel> tasks;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    return Row(
      children: [
        for (var offset = 0; offset < 7; offset++)
          Expanded(
            child: _day(context, monday.add(Duration(days: offset)), copy, scheme),
          ),
      ],
    );
  }

  Widget _day(BuildContext context, DateTime day, Copy copy, ColorScheme scheme) {
    final isToday = sameDay(day, today);
    final isSelected = sameDay(day, selected);
    final marked = tasks.any(
      (task) => !task.deleted && !task.isCompleted && coversDay(task, day),
    );
    final key = '${day.year}-${day.month}-${day.day}';
    return InkWell(
      key: Key('week-$key'),
      onTap: () => onSelect(startOfDay(day)),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Text(
              copy.weekdays[day.weekday - 1],
              style: TextStyle(
                fontSize: 12,
                color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? scheme.primary : Colors.transparent,
                border: isToday && !isSelected
                    ? Border.all(color: scheme.primary, width: 2)
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: isSelected ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              key: marked ? Key('week-mark-$key') : null,
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: marked ? scheme.primary : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({
    required this.day,
    required this.today,
    required this.tasks,
    required this.onOpen,
  });

  final DateTime day;
  final DateTime today;
  final List<TaskModel> tasks;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final timed = tasks.where((task) => task.dueHasTime).toList();
    final allday = tasks.where((task) => !task.dueHasTime).toList();
    final empty = sameDay(day, today) ? copy.empty(TaskBoard.today) : copy.scheduleEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sameDay(day, today) ? copy.today : copy.due(day, hasTime: false, now: today),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Text(empty, style: TextStyle(color: scheme.onSurfaceVariant))
        else ...[
          if (timed.isNotEmpty) ...[
            Text(copy.timedItems, style: TextStyle(color: scheme.onSurfaceVariant)),
            for (final task in timed) _TaskLine(task: task, onOpen: onOpen, showTime: true),
          ],
          if (allday.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(copy.allDay, style: TextStyle(color: scheme.onSurfaceVariant)),
            for (final task in allday) _TaskLine(task: task, onOpen: onOpen),
          ],
        ],
      ],
    );
  }
}

class _Overdue extends StatelessWidget {
  const _Overdue({required this.tasks, required this.onOpen});

  final List<TaskModel> tasks;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final ordered = [...tasks]..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.homeSection('overdue'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (ordered.isEmpty)
          Text(copy.overdueEmpty, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          for (final task in ordered) _TaskLine(task: task, onOpen: onOpen),
      ],
    );
  }
}

class _TodayHabits extends StatelessWidget {
  const _TodayHabits();

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final habits = RepoScope.of(context).tools.habits;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.homeSection('habits'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (habits.isEmpty)
          Text(copy.habitsEmpty, style: TextStyle(color: scheme.onSurfaceVariant))
        else
          for (final habit in habits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  HabitCheck(
                    checked: habit.checkedToday,
                    color: Color(habit.color),
                    progress: habit.progress,
                    goal: habit.goal,
                    checkKey: Key('today-habit-${habit.id}'),
                    onTap: () => logHabitFromUi(context, habit, tap: true),
                    onSlide: () => logHabitFromUi(context, habit, tap: false),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(habit.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        if (habit.goal > 1)
                          Text(
                            copy.habitProgress(habit.progress, habit.goal),
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        Text(
                          copy.streak(habit.streak),
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _HomePomodoro extends StatelessWidget {
  const _HomePomodoro();

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final tools = RepoScope.of(context).tools;
    final scheme = Theme.of(context).colorScheme;
    final phase = switch (tools.phase) {
      'short' => copy.shortBreak,
      'long' => copy.longBreak,
      _ => copy.focusPhase,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(copy.pomodoro, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        Text(phase),
        Text(
          clockLabel(tools.displayRemainingMs),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(copy.sessions(tools.finishedSessions)),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: tools.pomoRunning ? tools.pausePomo : tools.startPomo,
          child: Text(tools.pomoRunning ? copy.pause : copy.start),
        ),
        const SizedBox(height: 8),
        Text(copy.pomoHint, style: TextStyle(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

class _HomeDiary extends StatefulWidget {
  const _HomeDiary({required this.day});

  /// Null when the week strip is hidden. The diary then keeps its own day.
  final DateTime? day;

  @override
  State<_HomeDiary> createState() => _HomeDiaryState();
}

class _HomeDiaryState extends State<_HomeDiary> {
  late DateTime _own;
  final _body = TextEditingController();
  Timer? _save;
  LocalTools? _tools;
  var _ready = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _own = DateTime(now.year, now.month, now.day);
  }

  DateTime get _day => widget.day ?? _own;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tools = RepoScope.of(context).tools;
    _load();
  }

  @override
  void didUpdateWidget(_HomeDiary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.day != widget.day) {
      _flush();
      _load();
    }
  }

  void _load() {
    final stored = _tools?.diary[dayKey(_day)] ?? '';
    if (_body.text != stored) {
      _body.text = stored;
    }
    _ready = true;
  }

  @override
  void dispose() {
    _save?.cancel();
    _flush();
    _body.dispose();
    super.dispose();
  }

  void _flush() {
    final tools = _tools;
    if (!_ready || tools == null) {
      return;
    }
    tools.saveDiary(dayKey(_day), _body.text);
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final stored = RepoScope.of(context).tools.diary[dayKey(_day)] ?? '';
    final showSaved = _body.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(copy.diary, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        if (widget.day == null)
          Row(
            children: [
              IconButton(
                tooltip: copy.prevDay,
                onPressed: () {
                  _flush();
                  setState(() => _own = _own.subtract(const Duration(days: 1)));
                  _load();
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(child: Text(copy.diaryDate(_day), textAlign: TextAlign.center)),
              IconButton(
                tooltip: copy.nextDay,
                onPressed: () {
                  _flush();
                  setState(() => _own = _own.add(const Duration(days: 1)));
                  _load();
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          )
        else
          Text(copy.diaryDate(_day)),
        if (!showSaved && stored.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(copy.diaryEmpty, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _body,
          minLines: 5,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: copy.diaryHint,
            filled: true,
            fillColor: scheme.surfaceContainer,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) {
            setState(() {});
            _save?.cancel();
            _save = Timer(const Duration(milliseconds: 300), _flush);
          },
        ),
        if (showSaved)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(copy.savedLocally, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
      ],
    );
  }
}

class _HomeMatrix extends StatelessWidget {
  const _HomeMatrix({required this.onOpen});

  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final repo = RepoScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final open = repo.tasks.where((task) => !task.deleted && !task.isCompleted).toList();
    Color tint(int quadrant) {
      return switch (quadrant) {
        0 => scheme.errorContainer,
        1 => scheme.primaryContainer,
        2 => scheme.tertiaryContainer,
        _ => scheme.surfaceContainerHigh,
      };
    }

    Widget cell(int quadrant) {
      final tasks = open.where((task) => repo.tools.placements[task.id] == quadrant).take(3).toList();
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tint(quadrant).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(copy.quadrant(quadrant), style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            if (tasks.isEmpty)
              Text(copy.quadrantEmpty, style: TextStyle(color: scheme.onSurfaceVariant))
            else
              for (final task in tasks)
                InkWell(
                  onTap: () => onOpen(task.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(copy.matrix, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cell(0)),
            const SizedBox(width: 8),
            Expanded(child: cell(1)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cell(2)),
            const SizedBox(width: 8),
            Expanded(child: cell(3)),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => showPlaceTaskDialog(context),
            child: Text(copy.placeTask),
          ),
        ),
      ],
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.task, required this.onOpen, this.showTime = false});

  final TaskModel task;
  final ValueChanged<String> onOpen;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final now = DateTime.now();
    final subtitle = taskSubtitle(
      context: context,
      task: task,
      list: repo.listById(task.listId),
      tags: repo.tagsFor(task.id),
      checklistDone: 0,
      checklistTotal: 0,
      now: now,
      showList: true,
    );
    final time = task.dueAt == null
        ? ''
        : '${task.dueAt!.hour.toString().padLeft(2, '0')}:${task.dueAt!.minute.toString().padLeft(2, '0')}';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: showTime ? Text(time, style: const TextStyle(fontWeight: FontWeight.w800)) : null,
      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () => onOpen(task.id),
    );
  }
}
