import 'package:flutter/material.dart';

const inboxId = 'inbox';

const listColors = <int>[
  0xFF1F4B4A,
  0xFFC46B2D,
  0xFF2F5D9F,
  0xFF8A3E6B,
  0xFF3E6B4F,
  0xFF7A3E3E,
  0xFF3D4C7A,
  0xFF6B5A2E,
  0xFF2E5E62,
  0xFF5C4A8A,
];

enum TaskBoard {
  inbox,
  today,
  upcoming,
  calendar,
  completed,
  search,
  settings,
  list,
}

class ListModel {
  const ListModel({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.isInbox,
    required this.archived,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final int color;
  final int sortOrder;
  final bool isInbox;
  final bool archived;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.listId,
    required this.title,
    required this.notes,
    required this.dueAt,
    required this.dueHasTime,
    required this.priority,
    required this.recurrence,
    required this.reminder,
    required this.reminderAt,
    required this.reminderFired,
    required this.sortOrder,
    required this.completedAt,
    required this.deleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String listId;
  final String title;
  final String notes;
  final DateTime? dueAt;
  final bool dueHasTime;
  final int priority;
  final String recurrence;
  final String reminder;
  final DateTime? reminderAt;
  final bool reminderFired;
  final int sortOrder;
  final DateTime? completedAt;
  final bool deleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCompleted => completedAt != null;
}

class TagModel {
  const TagModel({
    required this.id,
    required this.name,
    required this.color,
    required this.deleted,
  });

  final String id;
  final String name;
  final int color;
  final bool deleted;
}

class ChecklistModel {
  const ChecklistModel({
    required this.id,
    required this.taskId,
    required this.title,
    required this.done,
    required this.sortOrder,
    required this.deleted,
  });

  final String id;
  final String taskId;
  final String title;
  final bool done;
  final int sortOrder;
  final bool deleted;
}

class TaskTagModel {
  const TaskTagModel({
    required this.id,
    required this.taskId,
    required this.tagId,
    required this.deleted,
  });

  final String id;
  final String taskId;
  final String tagId;
  final bool deleted;
}

String boardLabel(TaskBoard board, {String? listName}) {
  return switch (board) {
    TaskBoard.inbox => '受信箱',
    TaskBoard.today => '今日',
    TaskBoard.upcoming => '近日',
    TaskBoard.calendar => 'カレンダー',
    TaskBoard.completed => '完了',
    TaskBoard.search => '検索',
    TaskBoard.settings => '設定',
    TaskBoard.list => listName ?? 'リスト',
  };
}

String priorityLabel(int priority) {
  return switch (priority) {
    1 => '低',
    2 => '中',
    3 => '高',
    _ => 'なし',
  };
}

Color priorityColor(int priority) {
  return switch (priority) {
    3 => const Color(0xFFB42318),
    2 => const Color(0xFFB54708),
    1 => const Color(0xFF175CD3),
    _ => const Color(0x00000000),
  };
}

String recurrenceLabel(String recurrence) {
  return switch (recurrence) {
    'daily' => '毎日',
    'weekly' => '毎週',
    'monthly' => '毎月',
    'weekdays' => '平日',
    _ => 'なし',
  };
}

String reminderLabel(String reminder) {
  return switch (reminder) {
    'ontime' => '時刻どおり',
    '5m' => '5分前',
    '15m' => '15分前',
    '1h' => '1時間前',
    '1d' => '1日前',
    _ => 'なし',
  };
}

String formatDue(DateTime due, {required bool hasTime, required DateTime now}) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(due.year, due.month, due.day);
  final diff = day.difference(today).inDays;
  const weeks = ['月', '火', '水', '木', '金', '土', '日'];
  final weekday = weeks[due.weekday - 1];
  final date = switch (diff) {
    0 => '今日',
    1 => '明日',
    -1 => '昨日',
    _ when due.year == now.year => '${due.month}月${due.day}日($weekday)',
    _ => '${due.year}年${due.month}月${due.day}日',
  };
  if (!hasTime) {
    return date;
  }
  final hh = due.hour.toString().padLeft(2, '0');
  final mm = due.minute.toString().padLeft(2, '0');
  return '$date $hh:$mm';
}

bool isOverdue(DateTime due, DateTime now, {required bool completed}) {
  if (completed) {
    return false;
  }
  final start = DateTime(now.year, now.month, now.day);
  return due.isBefore(start);
}

String? validateSyncUrl(String raw, {String language = 'ja'}) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(trimmed);
  if (uri == null ||
      (uri.scheme != 'http' && uri.scheme != 'https') ||
      uri.host.isEmpty) {
    return switch (language) {
      'en' => 'Enter an http or https URL.',
      'ko' => 'http 또는 https URL을 입력하세요.',
      _ => 'http または https の URL を入力してください。',
    };
  }
  return null;
}

Uri syncEndpoint(String base) {
  final uri = Uri.parse(base.trim());
  final basePath = uri.path;
  if (basePath.endsWith('/v1/sync')) {
    return uri;
  }
  final String path;
  if (basePath.isEmpty || basePath == '/') {
    path = '/v1/sync';
  } else if (basePath.endsWith('/')) {
    path = '${basePath}v1/sync';
  } else {
    path = '$basePath/v1/sync';
  }
  return uri.replace(path: path);
}
