import 'models.dart';

DateTime startOfDay(DateTime value) => DateTime(value.year, value.month, value.day);

bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

/// True when [day] falls on the start, or between the start and end inclusive.
bool isOverdue(TaskModel task, DateTime now) {
  if (task.deleted || task.isCompleted || task.dueAt == null) {
    return false;
  }
  final end = startOfDay(task.endsAt ?? task.dueAt!);
  return end.isBefore(startOfDay(now));
}

List<TaskModel> daySchedule(List<TaskModel> tasks, DateTime day) {
  final items = tasks
      .where((task) => !task.deleted && !task.isCompleted && coversDay(task, day))
      .toList();
  items.sort((a, b) {
    if (a.dueHasTime != b.dueHasTime) {
      return a.dueHasTime ? -1 : 1;
    }
    if (a.dueHasTime && b.dueHasTime) {
      return a.dueAt!.compareTo(b.dueAt!);
    }
    return a.sortOrder.compareTo(b.sortOrder);
  });
  return items;
}

bool coversDay(TaskModel task, DateTime day) {
  final start = task.dueAt;
  if (start == null) {
    return false;
  }
  final target = startOfDay(day);
  final from = startOfDay(start);
  final rawEnd = startOfDay(task.endsAt ?? start);
  final to = rawEnd.isBefore(from) ? from : rawEnd;
  return !target.isBefore(from) && !target.isAfter(to);
}

List<TaskModel> filterTasks({
  required List<TaskModel> tasks,
  required TaskBoard board,
  String? listId,
  DateTime? day,
  String query = '',
  required DateTime now,
}) {
  final visible = tasks.where((task) => !task.deleted);
  final searched = query.trim().isEmpty
      ? visible
      : visible.where((task) => _matches(task, query));

  final Iterable<TaskModel> selected = switch (board) {
    TaskBoard.search => searched,
    TaskBoard.inbox => searched.where((task) => task.listId == inboxId && !task.isCompleted),
    TaskBoard.today => searched.where((task) => !task.isCompleted && _isTodayOrOverdue(task, now)),
    TaskBoard.upcoming => searched.where((task) => !task.isCompleted && _isUpcoming(task, now)),
    TaskBoard.completed => searched.where((task) => task.isCompleted),
    TaskBoard.calendar => searched.where((task) => day != null && coversDay(task, day)),
    TaskBoard.list => searched.where((task) => task.listId == listId && !task.isCompleted),
    TaskBoard.settings => const <TaskModel>[],
  };

  final list = selected.toList();
  list.sort((a, b) => _compare(a, b, board));
  return list;
}

bool _matches(TaskModel task, String query) {
  final needle = query.trim().toLowerCase();
  return task.title.toLowerCase().contains(needle) || task.notes.toLowerCase().contains(needle);
}

bool _isTodayOrOverdue(TaskModel task, DateTime now) {
  final due = task.dueAt;
  if (due == null) {
    return false;
  }
  final end = startOfDay(now).add(const Duration(days: 1));
  return due.isBefore(end);
}

bool _isUpcoming(TaskModel task, DateTime now) {
  final due = task.dueAt;
  if (due == null) {
    return false;
  }
  final start = startOfDay(now);
  final end = start.add(const Duration(days: 7));
  return !due.isBefore(start) && due.isBefore(end);
}

int _compare(TaskModel a, TaskModel b, TaskBoard board) {
  switch (board) {
    case TaskBoard.today:
    case TaskBoard.upcoming:
    case TaskBoard.calendar:
      final due = _compareNullable(a.dueAt, b.dueAt);
      if (due != 0) {
        return due;
      }
      final priority = b.priority.compareTo(a.priority);
      if (priority != 0) {
        return priority;
      }
      return a.sortOrder.compareTo(b.sortOrder);
    case TaskBoard.completed:
      return _compareNullable(b.completedAt, a.completedAt);
    case TaskBoard.search:
      return b.updatedAt.compareTo(a.updatedAt);
    case TaskBoard.inbox:
    case TaskBoard.list:
    case TaskBoard.settings:
      final sort = a.sortOrder.compareTo(b.sortOrder);
      if (sort != 0) {
        return sort;
      }
      return a.createdAt.compareTo(b.createdAt);
  }
}

int _compareNullable(DateTime? a, DateTime? b) {
  if (a == null && b == null) {
    return 0;
  }
  if (a == null) {
    return 1;
  }
  if (b == null) {
    return -1;
  }
  return a.compareTo(b);
}

String emptyCopy(TaskBoard board, {String query = ''}) {
  if (query.trim().isNotEmpty) {
    return '一致するタスクはありません。';
  }
  if (board == TaskBoard.search) {
    return 'タスク名やメモから探せます。';
  }
  return switch (board) {
    TaskBoard.inbox => '受信箱は空です。下の欄からタスクを追加できます。',
    TaskBoard.today => '今日のタスクはありません。',
    TaskBoard.upcoming => '今後7日のタスクはありません。',
    TaskBoard.completed => '完了したタスクはまだありません。',
    TaskBoard.calendar => 'この日のタスクはありません。',
    TaskBoard.list => 'このリストは空です。下の欄から追加できます。',
    TaskBoard.search => '一致するタスクはありません。',
    TaskBoard.settings => '',
  };
}
