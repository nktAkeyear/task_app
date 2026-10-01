import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../data/task_repository.dart';
import '../domain/models.dart';
import '../reminders/os_notifications.dart';
import 'calendar_pane.dart';
import 'detail_pane.dart';
import 'list_pane.dart';
import 'settings_pane.dart';
import 'task_pane.dart';
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
  int _tab = 0;
  bool _drilled = false;
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
      if (!task.deleted && !task.isCompleted && task.reminderAt != null && !task.reminderFired) {
        await OsNotifications.instance.schedule(task);
      }
    }
    await _poll();
    if (!mounted) {
      return;
    }
    _reminderTimer = Timer.periodic(const Duration(seconds: 20), (_) => _poll());
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
      _board = board;
      _listId = null;
      _drilled = true;
      _tab = switch (board) {
        TaskBoard.today => 1,
        TaskBoard.calendar => 2,
        TaskBoard.search => 3,
        _ => 0,
      };
    });
  }

  void _selectList(String id) {
    setState(() {
      _board = TaskBoard.list;
      _listId = id;
      _drilled = true;
      _tab = 0;
    });
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
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => DetailPane(taskId: id)));
  }

  List<TaskModel> _visible(TaskRepository repo) {
    return repo.tasksFor(
      board: _board,
      listId: _listId,
      day: _board == TaskBoard.calendar ? _day : null,
      query: _query,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= _desktopWidth;
        return Shortcuts(
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.keyN, control: true): NewTaskIntent(),
            SingleActivator(LogicalKeyboardKey.keyF, control: true): SearchIntent(),
            SingleActivator(LogicalKeyboardKey.enter, control: true): CompleteIntent(),
            SingleActivator(LogicalKeyboardKey.keyJ): MoveIntent(1),
            SingleActivator(LogicalKeyboardKey.keyK): MoveIntent(-1),
            SingleActivator(LogicalKeyboardKey.arrowDown, control: true): MoveIntent(1),
            SingleActivator(LogicalKeyboardKey.arrowUp, control: true): MoveIntent(-1),
            SingleActivator(LogicalKeyboardKey.digit1, control: true): BoardIntent(TaskBoard.inbox),
            SingleActivator(LogicalKeyboardKey.digit2, control: true): BoardIntent(TaskBoard.today),
            SingleActivator(LogicalKeyboardKey.digit3, control: true): BoardIntent(TaskBoard.upcoming),
            SingleActivator(LogicalKeyboardKey.digit4, control: true): BoardIntent(TaskBoard.calendar),
            SingleActivator(LogicalKeyboardKey.digit5, control: true): BoardIntent(TaskBoard.completed),
          },
          child: Actions(
            actions: {
              NewTaskIntent: CallbackAction<NewTaskIntent>(onInvoke: (_) {
                _focusNew(desktop);
                return null;
              }),
              SearchIntent: CallbackAction<SearchIntent>(onInvoke: (_) {
                _focusSearch(desktop);
                return null;
              }),
              CompleteIntent: CallbackAction<CompleteIntent>(onInvoke: (_) {
                _complete();
                return null;
              }),
              MoveIntent: CallbackAction<MoveIntent>(onInvoke: (intent) {
                _move(intent.delta, repo);
                return null;
              }),
              BoardIntent: CallbackAction<BoardIntent>(onInvoke: (intent) {
                _selectSmart(intent.board);
                return null;
              }),
            },
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              body: Column(
                children: [
                  if (_notices.isNotEmpty) _banner(context, desktop),
                  Expanded(child: desktop ? _desktop(repo) : _mobile(repo)),
                ],
              ),
              bottomNavigationBar: desktop ? null : _bottomNav(),
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
            Expanded(child: Text('リマインダー: ${notice.title}', maxLines: 1, overflow: TextOverflow.ellipsis)),
            TextButton(
              onPressed: () {
                setState(() => _notices.removeAt(0));
                _openTask(notice.id, desktop: desktop);
              },
              child: const Text('開く'),
            ),
            TextButton(onPressed: () => setState(() => _notices.removeAt(0)), child: const Text('閉じる')),
          ],
        ),
      ),
    );
  }

  Widget _desktop(TaskRepository repo) {
    final center = _board == TaskBoard.settings
        ? const SettingsPane()
        : _board == TaskBoard.calendar
        ? CalendarPane(
            month: _month,
            day: _day,
            selectedId: _selectedId,
            query: _query,
            searchController: _searchController,
            onMonth: (value) => setState(() => _month = DateTime(value.year, value.month)),
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
                ? const EmptyHint(message: 'タスクを選ぶと、メモや期限を編集できます。', icon: Icons.edit_outlined)
                : DetailPane(key: ValueKey(_selectedId), taskId: _selectedId!, embedded: true),
          ),
        ],
      ],
    );
  }

  Widget _mobile(TaskRepository repo) {
    if (_tab == 0 && !_drilled) {
      return ListPane(
        board: _board,
        listId: _listId,
        navKeys: false,
        onSmart: _selectSmart,
        onList: _selectList,
        onSettings: () => _openSettings(false),
      );
    }
    if (_tab == 2 || _board == TaskBoard.calendar && _tab != 1 && _tab != 3) {
      return CalendarPane(
        month: _month,
        day: _day,
        selectedId: _selectedId,
        query: _query,
        searchController: _searchController,
        onMonth: (value) => setState(() => _month = DateTime(value.year, value.month)),
        onDay: (value) => setState(() {
          _day = value;
          _month = DateTime(value.year, value.month);
        }),
        onOpen: (id) => _openTask(id, desktop: false),
        onSelect: (id) => setState(() => _selectedId = id),
        quickAddFocus: _quickAdd,
        searchFocus: _search,
        onQuery: (value) => setState(() => _query = value),
      );
    }
    final board = _tab == 1
        ? TaskBoard.today
        : _tab == 3
        ? TaskBoard.search
        : _board;
    return Column(
      children: [
        if (_tab == 0 && _drilled)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _drilled = false),
              icon: const Icon(Icons.arrow_back),
              label: const Text('リストへ戻る'),
            ),
          ),
        Expanded(
          child: TaskPane(
            board: board,
            listId: _listId,
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
          ),
        ),
      ],
    );
  }

  Widget _bottomNav() {
    return NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) {
        setState(() {
          _tab = index;
          _board = switch (index) {
            1 => TaskBoard.today,
            2 => TaskBoard.calendar,
            3 => TaskBoard.search,
            _ => _drilled ? _board : TaskBoard.inbox,
          };
        });
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.list_alt_outlined), label: 'リスト'),
        NavigationDestination(icon: Icon(Icons.today_outlined, key: Key('nav-today')), label: '今日'),
        NavigationDestination(icon: Icon(Icons.calendar_month_outlined, key: Key('nav-calendar')), label: 'カレンダー'),
        NavigationDestination(icon: Icon(Icons.search, key: Key('nav-search')), label: '検索'),
      ],
    );
  }

  void _focusNew(bool desktop) {
    if (_board == TaskBoard.settings || (!desktop && _tab == 0 && !_drilled)) {
      setState(() {
        _board = TaskBoard.inbox;
        _tab = 0;
        _drilled = true;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _quickAdd.requestFocus());
  }

  void _focusSearch(bool desktop) {
    final menu = !desktop && _tab == 0 && !_drilled;
    if (_board == TaskBoard.settings || menu) {
      setState(() {
        _board = TaskBoard.search;
        _tab = 3;
        _drilled = false;
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
