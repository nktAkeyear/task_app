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
  bool _editingLayout = false;
  List<HomeBlock>? _pendingLayout;

  Future<void> _saveLayout(List<HomeBlock> next) async {
    if (_pendingLayout != null) return;
    final repo = RepoScope.of(context);
    setState(() => _pendingLayout = next);
    try {
      await repo.setHomeLayout(next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Copy.of(context).homeLayoutSaveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _pendingLayout = null);
    }
  }

  void _moveBlock(List<HomeBlock> blocks, int from, int to) {
    if (to < 0 || to >= blocks.length) return;
    final next = [...blocks];
    next.insert(to, next.removeAt(from));
    _saveLayout(next);
  }

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
    final blocks = _pendingLayout ?? parseHomeLayout(repo.homeLayout);
    final today = startOfDay(DateTime.now());
    final shown = blocks.where((block) => block.visible).toList();
    final displayed = _editingLayout ? blocks : shown;
    final savingLayout = _pendingLayout != null;
    final weekOn = shown.any((block) => block.id == 'week');
    final scheduleDay = weekOn ? _day : today;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        key: const Key('create-task'),
        tooltip: copy.createTask,
        onPressed: () => showAddSheet(context, day: scheduleDay),
        child: const Icon(Icons.add),
      ),
      body: ReorderableListView(
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        onReorderItem: (from, to) {
          if (_editingLayout && !savingLayout) _moveBlock(blocks, from, to);
        },
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    copy.today,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton.icon(
                  key: const Key('home-layout'),
                  onPressed: savingLayout
                      ? null
                      : () => setState(() => _editingLayout = !_editingLayout),
                  icon: Icon(
                    _editingLayout
                        ? Icons.check
                        : Icons.dashboard_customize_outlined,
                  ),
                  label: Text(
                    _editingLayout ? copy.doneLabel : copy.homeLayout,
                  ),
                ),
                IconButton(
                  key: const Key('home-layout-settings'),
                  tooltip: copy.homeLayoutSettings,
                  onPressed: savingLayout
                      ? null
                      : () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (context) => const HomeLayoutPage(),
                            ),
                          );
                        },
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            if (_editingLayout)
              Text(copy.homeLayoutLead)
            else if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  copy.allBlocksHidden,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
        children: [
          for (var index = 0; index < displayed.length; index++)
            Padding(
              key: ValueKey('home-block-${displayed[index].id}'),
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_editingLayout)
                    Row(
                      children: [
                        Switch(
                          key: ValueKey(
                            'home-inline-visible-${displayed[index].id}',
                          ),
                          value: displayed[index].visible,
                          onChanged: savingLayout
                              ? null
                              : (visible) {
                                  final next = [...blocks];
                                  next[index] = HomeBlock(
                                    displayed[index].id,
                                    visible,
                                  );
                                  _saveLayout(next);
                                },
                        ),
                        Expanded(
                          child: Text(copy.homeSection(displayed[index].id)),
                        ),
                        IconButton(
                          key: ValueKey(
                            'home-inline-up-${displayed[index].id}',
                          ),
                          tooltip: copy.moveBlockUp,
                          onPressed: savingLayout || index == 0
                              ? null
                              : () => _moveBlock(blocks, index, index - 1),
                          icon: const Icon(Icons.arrow_upward),
                        ),
                        IconButton(
                          key: ValueKey(
                            'home-inline-down-${displayed[index].id}',
                          ),
                          tooltip: copy.moveBlockDown,
                          onPressed: savingLayout || index == blocks.length - 1
                              ? null
                              : () => _moveBlock(blocks, index, index + 1),
                          icon: const Icon(Icons.arrow_downward),
                        ),
                        ReorderableDragStartListener(
                          key: ValueKey(
                            'home-inline-drag-${displayed[index].id}',
                          ),
                          enabled: !savingLayout,
                          index: index,
                          child: Tooltip(
                            message: copy.dragToReorder,
                            child: Semantics(
                              label: copy.dragToReorder,
                              child: const SizedBox(
                                width: 48,
                                height: 48,
                                child: Icon(Icons.drag_indicator),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  // This key also preserves state when the edit toolbar is inserted.
                  if (displayed[index].visible)
                    KeyedSubtree(
                      key: ValueKey('home-content-${displayed[index].id}'),
                      child: switch (displayed[index].id) {
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
                          tasks: repo.tasks
                              .where((task) => isOverdue(task, today))
                              .toList(),
                          onOpen: widget.onOpen,
                        ),
                        'habits' => const _TodayHabits(),
                        'pomodoro' => const _HomePomodoro(),
                        'diary' => _HomeDiary(day: weekOn ? _day : null),
                        'matrix' => _HomeMatrix(onOpen: widget.onOpen),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                ],
              ),
            ),
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
    final monday = today.subtract(
      Duration(days: today.weekday - DateTime.monday),
    );
    return Row(
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
    );
  }

  Widget _day(
    BuildContext context,
    DateTime day,
    Copy copy,
    ColorScheme scheme,
  ) {
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
    final empty = sameDay(day, today)
        ? copy.empty(TaskBoard.today)
        : copy.scheduleEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sameDay(day, today)
              ? copy.today
              : copy.due(day, hasTime: false, now: today),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Text(empty, style: TextStyle(color: scheme.onSurfaceVariant))
        else ...[
          if (timed.isNotEmpty) ...[
            Text(
              copy.timedItems,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            for (final task in timed)
              _TaskLine(task: task, onOpen: onOpen, showTime: true),
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
          Text(
            copy.overdueEmpty,
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
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
          Text(
            copy.habitsEmpty,
            style: TextStyle(color: scheme.onSurfaceVariant),
          )
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
                        Text(
                          habit.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
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
        Text(
          copy.pomodoro,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
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

class _HomeDiaryState extends State<_HomeDiary> with WidgetsBindingObserver {
  late DateTime _own;
  final _body = TextEditingController();
  Timer? _save;
  LocalTools? _tools;
  String? _loadedDay;
  bool _dirty = false;
  bool _saveFailed = false;
  final _pending = <String, String>{};
  final _pendingRevision = <String, int>{};
  final _failedDays = <String>{};
  int _revision = 0;
  Future<void> _saveTail = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _own = DateTime(now.year, now.month, now.day);
  }

  DateTime get _day => widget.day ?? _own;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tools = RepoScope.of(context).tools;
    if (_tools != tools) {
      _flush();
      _tools = tools;
      _loadedDay = null;
    }
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
    final key = dayKey(_day);
    if (_loadedDay == key && (_dirty || _pending.containsKey(key))) return;
    final stored = _pending[key] ?? _tools?.diary[key] ?? '';
    if (_body.text != stored) _body.text = stored;
    _loadedDay = key;
    _saveFailed = _failedDays.contains(key);
    _dirty = _saveFailed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _flush();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _save?.cancel();
    _flush();
    _body.dispose();
    super.dispose();
  }

  void _flush() {
    _save?.cancel();
    final tools = _tools;
    final key = _loadedDay;
    if (!_dirty || tools == null || key == null) return;
    final body = _body.text;
    _dirty = false;
    _pending[key] = body;
    final revision = ++_revision;
    _pendingRevision[key] = revision;
    // Capture the loaded day and text before navigation or a block move.
    _saveTail = _saveTail.then((_) async {
      try {
        await tools.saveDiary(key, body);
        if (_pendingRevision[key] == revision) {
          _pending.remove(key);
          _pendingRevision.remove(key);
          _failedDays.remove(key);
        }
        if (mounted && _loadedDay == key) {
          setState(() => _saveFailed = _failedDays.contains(key));
        }
      } catch (_) {
        if (_pendingRevision[key] != revision) return;
        _failedDays.add(key);
        if (mounted && _loadedDay == key && _body.text == body) {
          setState(() {
            _dirty = true;
            _saveFailed = true;
          });
        }
      }
    });
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
        Text(
          copy.diary,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        const SizedBox(height: 8),
        if (widget.day == null)
          Row(
            children: [
              IconButton(
                tooltip: copy.prevDay,
                onPressed: () {
                  _flush();
                  setState(
                    () => _own = DateTime(_own.year, _own.month, _own.day - 1),
                  );
                  _load();
                },
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(copy.diaryDate(_day), textAlign: TextAlign.center),
              ),
              IconButton(
                tooltip: copy.nextDay,
                onPressed: () {
                  _flush();
                  setState(
                    () => _own = DateTime(_own.year, _own.month, _own.day + 1),
                  );
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
            child: Text(
              copy.diaryEmpty,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('home-diary-body'),
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
            setState(() {
              _dirty = true;
              _saveFailed = false;
            });
            _save?.cancel();
            _save = Timer(const Duration(milliseconds: 300), _flush);
          },
        ),
        if (showSaved ||
            _dirty ||
            _pending.containsKey(_loadedDay) ||
            _saveFailed)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _saveFailed
                ? TextButton.icon(
                    onPressed: _flush,
                    icon: const Icon(Icons.refresh),
                    label: Text('${copy.diarySaveFailed} ${copy.retry}'),
                  )
                : Text(
                    _dirty || _pending.containsKey(_loadedDay)
                        ? copy.diarySaving
                        : copy.savedLocally,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
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
    final open = repo.tasks
        .where((task) => !task.deleted && !task.isCompleted)
        .toList();
    Color tint(int quadrant) {
      return switch (quadrant) {
        0 => scheme.errorContainer,
        1 => scheme.primaryContainer,
        2 => scheme.tertiaryContainer,
        _ => scheme.surfaceContainerHigh,
      };
    }

    Widget cell(int quadrant) {
      final tasks = open
          .where((task) => repo.tools.placements[task.id] == quadrant)
          .take(3)
          .toList();
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: tint(quadrant).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              copy.quadrant(quadrant),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            if (tasks.isEmpty)
              Text(
                copy.quadrantEmpty,
                style: TextStyle(color: scheme.onSurfaceVariant),
              )
            else
              for (final task in tasks)
                InkWell(
                  onTap: () => onOpen(task.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.matrix,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
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
  const _TaskLine({
    required this.task,
    required this.onOpen,
    this.showTime = false,
  });

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
      leading: showTime
          ? Text(time, style: const TextStyle(fontWeight: FontWeight.w800))
          : null,
      title: Text(
        task.title,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
      onTap: () => onOpen(task.id),
    );
  }
}
