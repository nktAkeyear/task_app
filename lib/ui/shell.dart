import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/models.dart';
import '../l10n/copy.dart';
import '../reminders/os_notifications.dart';
import '../update/app_update.dart';
import 'add_sheet.dart';
import 'calendar_pane.dart';
import 'detail_pane.dart';
import 'list_pane.dart';
import 'settings_pane.dart';
import 'task_pane.dart';
import 'today_home.dart';
import 'tools_pane.dart';
import 'widgets.dart';

class NewTaskIntent extends Intent {
  const NewTaskIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class CompleteIntent extends Intent {
  const CompleteIntent();
}

class MoveIntent extends Intent {
  const MoveIntent(this.delta);
  final int delta;
}

class BoardIntent extends Intent {
  const BoardIntent(this.board);
  final TaskBoard board;
}

class TasShell extends StatefulWidget {
  const TasShell({super.key});

  @override
  State<TasShell> createState() => _TasShellState();
}

class _TasShellState extends State<TasShell> {
  static const _desktopWidth = 1080.0;

  TaskBoard _board = TaskBoard.inbox;
  String? _listId;
  String? _selectedId;
  String _query = '';
  String? _desktopTool;
  int _tab = 1;
  _Drill? _drill;
  var _tabReady = false;
  var _boardReady = false;
  late DateTime _month;
  late DateTime _day;
  final _search = FocusNode();
  final _searchController = TextEditingController();
  final _notices = <TaskModel>[];
  Timer? _reminderTimer;
  Timer? _syncTimer;
  Timer? _pomoTimer;
  var _askedUpdate = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _day = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _arm());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = RepoScope.of(context);
    if (!_tabReady) {
      _tab = repo.homeTab.clamp(0, 3);
      _tabReady = true;
    }
    if (!_boardReady) {
      _boardReady = true;
      _board = switch (repo.homeTab.clamp(0, 3)) {
        0 => TaskBoard.inbox,
        2 => TaskBoard.calendar,
        1 => TaskBoard.today,
        _ => TaskBoard.inbox,
      };
    }
    if (repo.tools.pomoRunning) {
      _pomoTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) {
          return;
        }
        RepoScope.of(context).tools.tickPomo();
      });
    } else {
      _pomoTimer?.cancel();
      _pomoTimer = null;
    }
  }

  Future<void> _arm() async {
    if (!mounted) {
      return;
    }
    await OsNotifications.instance.init();
    if (!mounted) {
      return;
    }
    final repo = RepoScope.of(context);
    for (final task in repo.tasks) {
      if (!task.deleted &&
          !task.isCompleted &&
          task.reminderAt != null &&
          !task.reminderFired) {
        await OsNotifications.instance.schedule(task);
      }
    }
    await _poll();
    if (!mounted) {
      return;
    }
    _reminderTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _poll(),
    );
    _syncTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      if (mounted) {
        RepoScope.of(context).flushSync();
      }
    });
    await OsNotifications.instance.syncHabits([
      ...repo.tools.habits,
      ...repo.tools.archivedHabits,
    ]);
    final testing = WidgetsBinding.instance.runtimeType.toString().contains(
      'Test',
    );
    if (!testing && mounted && !_askedUpdate) {
      _askedUpdate = true;
      await checkForUpdate(context, fromSettings: false);
    }
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _syncTimer?.cancel();
    _pomoTimer?.cancel();
    _search.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _poll() async {
    if (!mounted) {
      return;
    }
    final repo = RepoScope.of(context);
    final due = repo.pendingReminders();
    if (due.isEmpty) {
      return;
    }
    await repo.markRemindersFired(due.map((task) => task.id));
    if (!mounted) {
      return;
    }
    setState(() {
      _notices.insertAll(0, due);
      if (_notices.length > 4) {
        _notices.removeRange(4, _notices.length);
      }
    });
    for (final task in due) {
      await OsNotifications.instance.showTask(task);
    }
  }

  void _selectSmart(TaskBoard board) {
    setState(() {
      _desktopTool = null;
      _board = board;
      _listId = null;
    });
  }

  void _selectList(String id) {
    setState(() {
      _desktopTool = null;
      _board = TaskBoard.list;
      _listId = id;
    });
  }

  void _selectTab(int index) {
    setState(() {
      _tab = index;
      _drill = null;
    });
  }

  void _popBack() {
    if (_drill != null) {
      setState(() => _drill = null);
      return;
    }
    final home = RepoScope.of(context).homeTab.clamp(0, 3);
    if (_tab != home) {
      setState(() {
        _tab = home;
        _drill = null;
      });
    }
  }

  void _openTool(String id, {required bool desktop}) {
    if (desktop) {
      if (id == 'search') {
        setState(() {
          _desktopTool = null;
          _board = TaskBoard.search;
          _listId = null;
        });
        return;
      }
      setState(() => _desktopTool = id);
      return;
    }
    setState(() => _drill = _Drill.tool(id));
  }

  void _openCreate(bool desktop) {
    final board = desktop
        ? _board
        : (_drill?.board ??
              switch (_tab) {
                1 => TaskBoard.today,
                2 => TaskBoard.calendar,
                _ => TaskBoard.inbox,
              });
    final listId = desktop
        ? (board == TaskBoard.list ? _listId : null)
        : (_drill?.board == TaskBoard.list ? _drill?.listId : null);
    final day = board == TaskBoard.calendar
        ? _day
        : board == TaskBoard.today
        ? DateTime.now()
        : null;
    showAddSheet(context, listId: listId, day: day);
  }

  void _openSettings(bool desktop) {
    if (desktop) {
      setState(() => _board = TaskBoard.settings);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(Copy.of(context).settings)),
          body: const SettingsPane(),
        ),
      ),
    );
  }

  void _openTask(String id, {required bool desktop}) {
    setState(() => _selectedId = id);
    if (desktop) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => DetailPane(taskId: id)),
    );
  }

  List<TaskModel> _visible(TaskRepository repo) {
    final desktop = MediaQuery.sizeOf(context).width >= _desktopWidth;
    final TaskBoard board;
    final String? listId;
    if (desktop) {
      board = _board;
      listId = _listId;
    } else if (_drill?.tool == 'search') {
      board = TaskBoard.search;
      listId = null;
    } else if (_drill?.board != null) {
      board = _drill!.board!;
      listId = _drill!.listId;
    } else {
      board = switch (_tab) {
        1 => TaskBoard.today,
        2 => TaskBoard.calendar,
        _ => TaskBoard.inbox,
      };
      listId = null;
    }
    return repo.tasksFor(
      board: board,
      listId: listId,
      day: board == TaskBoard.calendar ? _day : null,
      query: _query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= _desktopWidth;
        final inset = MediaQuery.paddingOf(context);
        return ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            removeLeft: true,
            removeRight: true,
            child: Padding(
              padding: inset,
              child: PopScope(
                canPop:
                    desktop ||
                    (_drill == null && _tab == repo.homeTab.clamp(0, 3)),
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    _popBack();
                  }
                },
                child: Shortcuts(
                  shortcuts: const {
                    SingleActivator(LogicalKeyboardKey.keyN, control: true):
                        NewTaskIntent(),
                    SingleActivator(LogicalKeyboardKey.keyF, control: true):
                        SearchIntent(),
                    SingleActivator(LogicalKeyboardKey.enter, control: true):
                        CompleteIntent(),
                    SingleActivator(LogicalKeyboardKey.keyJ): MoveIntent(1),
                    SingleActivator(LogicalKeyboardKey.keyK): MoveIntent(-1),
                    SingleActivator(
                      LogicalKeyboardKey.arrowDown,
                      control: true,
                    ): MoveIntent(
                      1,
                    ),
                    SingleActivator(LogicalKeyboardKey.arrowUp, control: true):
                        MoveIntent(-1),
                    SingleActivator(LogicalKeyboardKey.digit1, control: true):
                        BoardIntent(TaskBoard.inbox),
                    SingleActivator(LogicalKeyboardKey.digit2, control: true):
                        BoardIntent(TaskBoard.today),
                    SingleActivator(LogicalKeyboardKey.digit3, control: true):
                        BoardIntent(TaskBoard.upcoming),
                    SingleActivator(LogicalKeyboardKey.digit4, control: true):
                        BoardIntent(TaskBoard.calendar),
                    SingleActivator(LogicalKeyboardKey.digit5, control: true):
                        BoardIntent(TaskBoard.completed),
                  },
                  child: Actions(
                    actions: {
                      NewTaskIntent: CallbackAction<NewTaskIntent>(
                        onInvoke: (_) {
                          _focusNew(desktop);
                          return null;
                        },
                      ),
                      SearchIntent: CallbackAction<SearchIntent>(
                        onInvoke: (_) {
                          _focusSearch(desktop);
                          return null;
                        },
                      ),
                      CompleteIntent: CallbackAction<CompleteIntent>(
                        onInvoke: (_) {
                          _complete();
                          return null;
                        },
                      ),
                      MoveIntent: CallbackAction<MoveIntent>(
                        onInvoke: (intent) {
                          _move(intent.delta, repo);
                          return null;
                        },
                      ),
                      BoardIntent: CallbackAction<BoardIntent>(
                        onInvoke: (intent) {
                          _selectSmart(intent.board);
                          return null;
                        },
                      ),
                    },
                    child: Scaffold(
                      resizeToAvoidBottomInset: true,
                      body: Column(
                        children: [
                          if (_notices.isNotEmpty) _banner(context, desktop),
                          if (repo.tools.pomoRunning &&
                              _desktopTool != 'pomodoro' &&
                              _drill?.tool != 'pomodoro')
                            PomoChip(
                              onOpen: () =>
                                  _openTool('pomodoro', desktop: desktop),
                            ),
                          Expanded(
                            child: desktop ? _desktop(repo) : _mobile(repo),
                          ),
                        ],
                      ),
                      bottomNavigationBar: desktop ? null : _bottomNav(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _banner(BuildContext context, bool desktop) {
    final notice = _notices.first;
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.notifications_active_outlined),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                Copy.of(context).reminderBanner(notice.title),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _notices.removeAt(0));
                _openTask(notice.id, desktop: desktop);
              },
              child: Text(Copy.of(context).open),
            ),
            TextButton(
              onPressed: () => setState(() => _notices.removeAt(0)),
              child: Text(Copy.of(context).close),
            ),
          ],
        ),
      ),
    );
  }

  Widget _desktop(TaskRepository repo) {
    final Widget center = _desktopTool != null
        ? Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _desktopTool = null),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(Copy.of(context).back),
                ),
              ),
              Expanded(
                child: ToolPage(
                  id: _desktopTool!,
                  onOpenTask: (id) => _openTask(id, desktop: true),
                ),
              ),
            ],
          )
        : _board == TaskBoard.settings
        ? const SettingsPane()
        : _board == TaskBoard.calendar
        ? CalendarPane(
            month: _month,
            day: _day,
            selectedId: _selectedId,
            query: _query,
            searchController: _searchController,
            onMonth: (value) =>
                setState(() => _month = DateTime(value.year, value.month)),
            onDay: (value) => setState(() {
              _day = value;
              _month = DateTime(value.year, value.month);
            }),
            onOpen: (id) => _openTask(id, desktop: true),
            searchFocus: _search,
            onQuery: (value) => setState(() => _query = value),
          )
        : _board == TaskBoard.today
        ? TodayHome(onOpen: (id) => _openTask(id, desktop: true))
        : TaskPane(
            board: _board,
            listId: _listId,
            selectedId: _selectedId,
            query: _query,
            day: _day,
            showSearch: true,
            searchController: _searchController,
            onOpen: (id) => _openTask(id, desktop: true),
            onQuery: (value) => setState(() => _query = value),
            searchFocus: _search,
            onCreate: () => _openCreate(true),
          );
    return Row(
      children: [
        SizedBox(
          key: const Key('pane-lists'),
          width: 300,
          child: ListPane(
            board: _board,
            listId: _listId,
            onSmart: _selectSmart,
            onList: _selectList,
            onSettings: () => _openSettings(true),
            onCreateTask: () => _openCreate(true),
            onTool: (id) {
              if (id == 'search') {
                setState(() {
                  _desktopTool = null;
                  _board = TaskBoard.search;
                  _listId = null;
                });
                return;
              }
              setState(() => _desktopTool = id);
            },
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(key: const Key('pane-tasks'), child: center),
        if (_board != TaskBoard.settings) ...[
          const VerticalDivider(width: 1),
          SizedBox(
            key: const Key('pane-detail'),
            width: 420,
            child: _selectedId == null
                ? EmptyHint(
                    message: Copy.of(context).detailEmpty,
                    icon: Icons.edit_outlined,
                  )
                : DetailPane(
                    key: ValueKey(_selectedId),
                    taskId: _selectedId!,
                    embedded: true,
                  ),
          ),
        ],
      ],
    );
  }

  Widget _mobile(TaskRepository repo) {
    final copy = Copy.of(context);
    final back = _drill == null
        ? null
        : Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('back-in-app'),
              onPressed: _popBack,
              icon: const Icon(Icons.arrow_back),
              label: Text(
                _tab == 0 && _drill!.tool == null
                    ? copy.backToLists
                    : copy.back,
              ),
            ),
          );
    if (_drill?.tool != null && _drill!.tool != 'search') {
      return Column(
        children: [
          ?back,
          Expanded(
            child: ToolPage(
              id: _drill!.tool!,
              onOpenTask: (id) => _openTask(id, desktop: false),
            ),
          ),
        ],
      );
    }
    if (_tab == 0 && _drill == null) {
      return ListPane(
        board: TaskBoard.inbox,
        listId: null,
        navKeys: false,
        onSmart: (board) => setState(() => _drill = _Drill.board(board)),
        onList: (id) => setState(() => _drill = _Drill.list(id)),
        onSettings: () => _openSettings(false),
        onCreateTask: () => _openCreate(false),
      );
    }
    if (_tab == 1 && _drill == null) {
      return TodayHome(onOpen: (id) => _openTask(id, desktop: false));
    }
    if (_tab == 3 && _drill == null) {
      return ToolsMenu(
        onOpen: (id) => setState(() => _drill = _Drill.tool(id)),
      );
    }
    final board = _drill?.tool == 'search'
        ? TaskBoard.search
        : _drill?.board ??
              switch (_tab) {
                1 => TaskBoard.today,
                2 => TaskBoard.calendar,
                _ => TaskBoard.inbox,
              };
    if (board == TaskBoard.calendar) {
      return Column(
        children: [
          ?back,
          Expanded(
            child: CalendarPane(
              month: _month,
              day: _day,
              selectedId: _selectedId,
              query: _query,
              searchController: _searchController,
              onMonth: (value) =>
                  setState(() => _month = DateTime(value.year, value.month)),
              onDay: (value) => setState(() {
                _day = value;
                _month = DateTime(value.year, value.month);
              }),
            onOpen: (id) => _openTask(id, desktop: false),
            searchFocus: _search,
              onQuery: (value) => setState(() => _query = value),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        ?back,
        Expanded(
          child: TaskPane(
            board: board,
            listId: _drill?.listId,
            selectedId: _selectedId,
            query: _query,
            day: _day,
            showSearch: true,
            searchController: _searchController,
            onOpen: (id) => _openTask(id, desktop: false),
            onQuery: (value) => setState(() => _query = value),
            searchFocus: _search,
            onCreate: () => _openCreate(false),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    final copy = Copy.of(context);
    return NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: _selectTab,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.list_alt_outlined),
          label: copy.lists,
        ),
        NavigationDestination(
          icon: const Icon(Icons.today_outlined, key: Key('nav-today')),
          label: copy.today,
        ),
        NavigationDestination(
          icon: const Icon(
            Icons.calendar_month_outlined,
            key: Key('nav-calendar'),
          ),
          label: copy.calendar,
        ),
        NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined, key: Key('nav-tools')),
          label: copy.tools,
        ),
      ],
    );
  }

  void _focusNew(bool desktop) {
    _openCreate(desktop);
  }

  void _focusSearch(bool desktop) {
    if (!desktop) {
      setState(() => _drill = const _Drill.tool('search'));
    } else if (_board == TaskBoard.settings || _desktopTool != null) {
      setState(() {
        _desktopTool = null;
        _board = TaskBoard.search;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _search.requestFocus());
  }

  Future<void> _complete() async {
    final id = _selectedId;
    if (id == null || !mounted) {
      return;
    }
    final repo = RepoScope.of(context);
    final message = await repo.toggleComplete(id);
    if (mounted) {
      showUndoSnack(context, message, repo.undo);
    }
  }

  void _move(int delta, TaskRepository repo) {
    final tasks = _visible(repo);
    if (tasks.isEmpty) {
      return;
    }
    final index = tasks.indexWhere((task) => task.id == _selectedId);
    final next = (index < 0 ? 0 : index + delta).clamp(0, tasks.length - 1);
    setState(() => _selectedId = tasks[next].id);
  }
}

class _Drill {
  const _Drill.board(this.board)
    : listId = null,
      tool = null;
  const _Drill.list(this.listId) : board = TaskBoard.list, tool = null;
  const _Drill.tool(this.tool) : board = null, listId = null;

  final TaskBoard? board;
  final String? listId;
  final String? tool;
}
