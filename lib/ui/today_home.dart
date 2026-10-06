import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/filters.dart';
import '../domain/home_layout.dart';
import '../domain/models.dart' hide isOverdue;
import '../l10n/copy.dart';
import 'add_sheet.dart';
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('create-task'),
        tooltip: copy.createTask,
        onPressed: () => showAddSheet(
          context,
          day: _day,
        ),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Text(
            copy.today,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          for (final block in blocks)
            if (block.visible)
              switch (block.id) {
                'week' => _WeekStrip(
                  selected: _day,
                  today: today,
                  tasks: repo.tasks,
                  onSelect: (day) => setState(() => _day = day),
                ),
                'schedule' => _Schedule(
                  day: _day,
                  today: today,
                  tasks: daySchedule(repo.tasks, _day),
                  onOpen: widget.onOpen,
                ),
                'overdue' => _Overdue(
                  tasks: repo.tasks.where((task) => isOverdue(task, today)).toList(),
                  onOpen: widget.onOpen,
                ),
                _ => const _TodayHabits(),
              },
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          for (var offset = 0; offset < 7; offset++)
            Expanded(
              child: _day(
                context,
                monday.add(Duration(days: offset)),
                copy,
                scheme,
              ),
            ),
        ],
      ),
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
    final timed = tasks.where((task) => task.dueHasTime).toList();
    final allday = tasks.where((task) => !task.dueHasTime).toList();
    final empty = sameDay(day, today)
        ? copy.empty(TaskBoard.today)
        : copy.scheduleEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sameDay(day, today) ? copy.today : copy.due(day, hasTime: false, now: today),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(empty),
            )
          else ...[
            if (timed.isNotEmpty) ...[
              Text(copy.timedItems),
              for (final task in timed) _TaskLine(task: task, onOpen: onOpen),
            ],
            if (allday.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(copy.allDay),
              for (final task in allday) _TaskLine(task: task, onOpen: onOpen),
            ],
          ],
        ],
      ),
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
    final ordered = [...tasks]..sort((a, b) => a.dueAt!.compareTo(b.dueAt!));
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.homeSection('overdue'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (ordered.isEmpty)
            Text(copy.overdueEmpty)
          else
            for (final task in ordered) _TaskLine(task: task, onOpen: onOpen),
        ],
      ),
    );
  }
}

class _TodayHabits extends StatelessWidget {
  const _TodayHabits();

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final habits = RepoScope.of(context).tools.habits;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy.homeSection('habits'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          const SizedBox(height: 8),
          if (habits.isEmpty)
            Text(copy.habitsEmpty)
          else
            for (final habit in habits)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    HabitCheck(
                      checked: habit.checkedToday,
                      color: Color(habit.color),
                      checkKey: Key('today-habit-${habit.id}'),
                      onTap: () => RepoScope.of(context).tools.toggleHabitToday(habit.id),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(copy.streak(habit.streak)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _TaskLine extends StatelessWidget {
  const _TaskLine({required this.task, required this.onOpen});

  final TaskModel task;
  final ValueChanged<String> onOpen;

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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () => onOpen(task.id),
    );
  }
}
