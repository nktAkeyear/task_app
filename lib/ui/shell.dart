import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/models.dart';
import '../reminders/os_notifications.dart';
import 'calendar_pane.dart';
import 'create_task_page.dart';
import 'detail_pane.dart';
import 'list_pane.dart';
import 'settings_pane.dart';
import 'task_pane.dart';
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
  final List<_Place> _stack = [const _Place.listRoot()];
  late DateTime _month;
  late DateTime _day;
  final _quickAdd = FocusNode();
  final _search = FocusNode();
  final _searchController = TextEditingController();
  final _notices = <TaskModel>[];
  Timer? _reminderTimer;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _day = DateTime(now.year, now.month, now.day);
    WidgetsBinding.instance.addPostFrameCallback((_) => _arm());
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
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    _syncTimer?.cancel();
    _quickAdd.dispose();
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

  void _go(_Place place) {
    setState(() {
      final top = _stack.last;
      if (top == place) {
        return;
      }
      _stack.add(place);
    });
  }

  void _popInApp() {
    if (_stack.length <= 1) {
      return;
    }
    setState(() => _stack.removeLast());
  }

  void _openCreate(bool desktop) {
    final place = _stack.last;
    final listId = desktop
        ? (_board == TaskBoard.list ? _listId : null)
        : (place.board == TaskBoard.list ? place.listId : null);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CreateTaskPage(listId: listId),
      ),
    );
  }

  void _openSettings(bool desktop) {
    if (desktop) {
      setState(() => _board = TaskBoard.settings);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('設定')),
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
    final place = _stack.last;
    final mobile =
        _stack.length > 1 ||
        place.drilled ||
        place.tool != null ||
        place.tab != 0;
    final board = !mobile
        ? _board
        : place.tool == 'search'
        ? TaskBoard.search
        : place.board;
    final listId = mobile ? place.listId : _listId;
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
                canPop: desktop || _stack.length <= 1,
                onPopInvokedWithResult: (didPop, _) {
                  if (!didPop) {
                    _popInApp();
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
                'リマインダー: ${notice.title}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _notices.removeAt(0));
                _openTask(notice.id, desktop: desktop);
              },
              child: const Text('開く'),
            ),
            TextButton(
              onPressed: () => setState(() => _notices.removeAt(0)),
              child: const Text('閉じる'),
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
                  label: const Text('戻る'),
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
            onSelect: (id) => setState(() => _selectedId = id),
            quickAddFocus: _quickAdd,
            searchFocus: _search,
            onQuery: (value) => setState(() => _query = value),
          )
        : TaskPane(
            board: _board,
            listId: _listId,
            selectedId: _selectedId,
            query: _query,
            day: _day,
            showSearch: true,
            searchController: _searchController,
            onOpen: (id) => _openTask(id, desktop: true),
            onSelect: (id) => setState(() => _selectedId = id),
            onQuery: (value) => setState(() => _query = value),
            searchFocus: _search,
            quickAddFocus: _quickAdd,
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
                ? const EmptyHint(
                    message: 'タスクを選ぶと、メモや期限を編集できます。',
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
    final place = _stack.last;
    final back = _stack.length > 1
        ? Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('back-in-app'),
              onPressed: _popInApp,
              icon: const Icon(Icons.arrow_back),
              label: Text(_stack[_stack.length - 2].tab == 0 ? 'リストへ戻る' : '戻る'),
            ),
          )
        : null;
    if (place.tool == 'menu') {
      return Column(
        children: [
          ?back,
          Expanded(
            child: ToolsMenu(
              onOpen: (id) => _go(
                id == 'search' ? const _Place.tool('search') : _Place.tool(id),
              ),
            ),
          ),
        ],
      );
    }
    if (place.tool != null && place.tool != 'search') {
      return Column(
        children: [
          ?back,
          Expanded(
            child: ToolPage(
              id: place.tool!,
              onOpenTask: (id) => _openTask(id, desktop: false),
            ),
          ),
        ],
      );
    }
    if (place.tab == 0 && !place.drilled) {
      return Column(
        children: [
          ?back,
          Expanded(
            child: ListPane(
              board: place.board,
              listId: place.listId,
              navKeys: false,
              onSmart: (board) => _go(_Place.smart(board)),
              onList: (id) => _go(_Place.userList(id)),
              onSettings: () => _openSettings(false),
              onCreateTask: () => _openCreate(false),
            ),
          ),
        ],
      );
    }
    if (place.board == TaskBoard.calendar) {
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
              onSelect: (id) => setState(() => _selectedId = id),
              quickAddFocus: _quickAdd,
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
            board: place.tool == 'search' ? TaskBoard.search : place.board,
            listId: place.listId,
            selectedId: _selectedId,
            query: _query,
            day: _day,
            showSearch: true,
            searchController: _searchController,
            onOpen: (id) => _openTask(id, desktop: false),
            onSelect: (id) => setState(() => _selectedId = id),
            onQuery: (value) => setState(() => _query = value),
            searchFocus: _search,
            quickAddFocus: _quickAdd,
            onCreate: () => _openCreate(false),
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return NavigationBar(
      selectedIndex: _stack.last.tab,
      onDestinationSelected: (index) {
        _go(switch (index) {
          1 => const _Place.today(),
          2 => const _Place.calendar(),
          3 => const _Place.tools(),
          _ => const _Place.listRoot(),
        });
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          label: 'リスト',
        ),
        NavigationDestination(
          icon: Icon(Icons.today_outlined, key: Key('nav-today')),
          label: '今日',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined, key: Key('nav-calendar')),
          label: 'カレンダー',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined, key: Key('nav-tools')),
          label: 'ツール',
        ),
      ],
    );
  }

  void _focusNew(bool desktop) {
    if (!desktop &&
        (_stack.last.tool != null ||
            (_stack.last.tab == 0 && !_stack.last.drilled))) {
      _go(
        const _Place(
          tab: 0,
          board: TaskBoard.inbox,
          listId: null,
          drilled: true,
          tool: null,
        ),
      );
    } else if (desktop &&
        (_board == TaskBoard.settings || _desktopTool != null)) {
      setState(() {
        _desktopTool = null;
        _board = TaskBoard.inbox;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _quickAdd.requestFocus(),
    );
  }

  void _focusSearch(bool desktop) {
    if (!desktop) {
      _go(const _Place.tool('search'));
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

class _Place {
  const _Place({
    required this.tab,
    required this.board,
    required this.listId,
    required this.drilled,
    required this.tool,
  });

  const _Place.listRoot()
    : tab = 0,
      board = TaskBoard.inbox,
      listId = null,
      drilled = false,
      tool = null;

  const _Place.today()
    : tab = 1,
      board = TaskBoard.today,
      listId = null,
      drilled = true,
      tool = null;

  const _Place.calendar()
    : tab = 2,
      board = TaskBoard.calendar,
      listId = null,
      drilled = true,
      tool = null;

  const _Place.tools()
    : tab = 3,
      board = TaskBoard.inbox,
      listId = null,
      drilled = false,
      tool = 'menu';

  const _Place.userList(this.listId)
    : tab = 0,
      board = TaskBoard.list,
      drilled = true,
      tool = null;

  const _Place.tool(this.tool)
    : tab = 3,
      board = TaskBoard.inbox,
      listId = null,
      drilled = false;

  factory _Place.smart(TaskBoard board) {
    return switch (board) {
      TaskBoard.today => const _Place.today(),
      TaskBoard.calendar => const _Place.calendar(),
      TaskBoard.search => const _Place.tool('search'),
      _ => _Place(
        tab: 0,
        board: board,
        listId: null,
        drilled: true,
        tool: null,
      ),
    };
  }

  final int tab;
  final TaskBoard board;
  final String? listId;
  final bool drilled;
  final String? tool;

  @override
  bool operator ==(Object other) {
    return other is _Place &&
        other.tab == tab &&
        other.board == board &&
        other.listId == listId &&
        other.drilled == drilled &&
        other.tool == tool;
  }

  @override
  int get hashCode => Object.hash(tab, board, listId, drilled, tool);
}
