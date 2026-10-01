class QuickAddParse {
  const QuickAddParse({
    required this.title,
    this.due,
    this.hasTime = false,
  });

  final String title;
  final DateTime? due;
  final bool hasTime;

  bool get isEmpty => title.isEmpty && due == null;
}

const _weekdays = <String, int>{
  '月': DateTime.monday,
  '火': DateTime.tuesday,
  '水': DateTime.wednesday,
  '木': DateTime.thursday,
  '金': DateTime.friday,
  '土': DateTime.saturday,
  '日': DateTime.sunday,
};

/// Pulls a due date out of a quick-add string.
///
/// Recognizes 今日, 明日, 明後日, 来週, 曜日, 今週, 来週の曜日, 月日, and times
/// such as 10時, 9時30分, 午後1時, and 18:30. Date words are read as their own
/// token, or as a leading 「今日の」 style prefix.
QuickAddParse parseQuickAdd(String input, {DateTime? now}) {
  final clock = now ?? DateTime.now();
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return const QuickAddParse(title: '');
  }

  var working = trimmed;
  final time = _takeTime(working);
  if (time != null) {
    working = time.rest;
  }

  final date = _takeDate(working, clock);
  if (date != null) {
    working = date.rest;
  }

  final title = working.replaceAll(RegExp(r'\s+'), ' ').trim();
  final safeTitle = title.isEmpty ? '無題' : title;
  final day = date?.day;

  if (time != null && day == null) {
    var due = DateTime(clock.year, clock.month, clock.day, time.hour, time.minute);
    if (!due.isAfter(clock)) {
      due = DateTime(clock.year, clock.month, clock.day + 1, time.hour, time.minute);
    }
    return QuickAddParse(title: safeTitle, due: due, hasTime: true);
  }

  if (day != null && time != null) {
    return QuickAddParse(
      title: safeTitle,
      due: DateTime(day.year, day.month, day.day, time.hour, time.minute),
      hasTime: true,
    );
  }

  if (day != null) {
    return QuickAddParse(
      title: safeTitle,
      due: DateTime(day.year, day.month, day.day),
      hasTime: false,
    );
  }

  return QuickAddParse(title: safeTitle);
}

class _TimeHit {
  const _TimeHit(this.hour, this.minute, this.rest);
  final int hour;
  final int minute;
  final String rest;
}

class _DateHit {
  const _DateHit(this.day, this.rest);
  final DateTime day;
  final String rest;
}

_TimeHit? _takeTime(String input) {
  final patterns = <RegExp>[
    RegExp(r'(午前|午後)\s*(\d{1,2})\s*時(?:\s*(\d{1,2})\s*分)?'),
    RegExp(r'(\d{1,2})\s*時(?:\s*(\d{1,2})\s*分)?'),
    RegExp(r'(?<!\d)(\d{1,2}):(\d{2})(?!\d)'),
  ];
  for (final pattern in patterns) {
    final match = pattern.firstMatch(input);
    if (match == null) {
      continue;
    }
    int hour;
    int minute;
    if (match.groupCount >= 3 && (match.group(1) == '午前' || match.group(1) == '午後')) {
      hour = int.parse(match.group(2)!);
      minute = match.group(3) == null ? 0 : int.parse(match.group(3)!);
      final meridiem = match.group(1);
      if (meridiem == '午後' && hour < 12) {
        hour += 12;
      }
      if (meridiem == '午前' && hour == 12) {
        hour = 0;
      }
    } else if (pattern.pattern.contains('時')) {
      hour = int.parse(match.group(1)!);
      minute = match.group(2) == null ? 0 : int.parse(match.group(2)!);
    } else {
      hour = int.parse(match.group(1)!);
      minute = int.parse(match.group(2)!);
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      continue;
    }
    final rest = input.replaceRange(match.start, match.end, ' ');
    return _TimeHit(hour, minute, rest);
  }
  return null;
}

_DateHit? _takeDate(String input, DateTime now) {
  final specs = <_DateSpec>[
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])(\d{4})\s*年\s*(\d{1,2})\s*月\s*(\d{1,2})\s*日(?![\p{L}\p{N}])', unicode: true),
      (match, clock) {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        return _validDate(year, month, day);
      },
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])(\d{1,2})\s*月\s*(\d{1,2})\s*日(?![\p{L}\p{N}])', unicode: true),
      (match, clock) {
        final month = int.parse(match.group(1)!);
        final day = int.parse(match.group(2)!);
        if (month < 1 || month > 12) {
          return null;
        }
        var year = clock.year;
        var resolved = _validDate(year, month, day);
        if (resolved == null) {
          return null;
        }
        final today = DateTime(clock.year, clock.month, clock.day);
        if (resolved.isBefore(today)) {
          year += 1;
          resolved = _validDate(year, month, day);
        }
        return resolved;
      },
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])来週の?\s*([月火水木金土日])曜(?:日)?(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => _weekdayInWeek(clock, _weekdays[match.group(1)!]!, weekOffset: 1),
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])今週の?\s*([月火水木金土日])曜(?:日)?(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => _weekdayInWeek(clock, _weekdays[match.group(1)!]!, weekOffset: 0),
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])([月火水木金土日])曜(?:日)?(?![\p{L}\p{N}])', unicode: true),
      (match, clock) {
        final target = _weekdays[match.group(1)!]!;
        var delta = target - clock.weekday;
        if (delta < 0) {
          delta += 7;
        }
        return DateTime(clock.year, clock.month, clock.day + delta);
      },
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])明後日(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => DateTime(clock.year, clock.month, clock.day + 2),
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])明日(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => DateTime(clock.year, clock.month, clock.day + 1),
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])今日(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => DateTime(clock.year, clock.month, clock.day),
    ),
    _DateSpec(
      RegExp(r'(?<![\p{L}\p{N}])来週(?![\p{L}\p{N}])', unicode: true),
      (match, clock) => DateTime(clock.year, clock.month, clock.day + 7),
    ),
    _DateSpec(
      RegExp(r'^(今日|明日|明後日)の'),
      (match, clock) {
        return switch (match.group(1)) {
          '今日' => DateTime(clock.year, clock.month, clock.day),
          '明日' => DateTime(clock.year, clock.month, clock.day + 1),
          _ => DateTime(clock.year, clock.month, clock.day + 2),
        };
      },
    ),
    _DateSpec(
      RegExp(r'^来週の(?![月火水木金土日])'),
      (match, clock) => DateTime(clock.year, clock.month, clock.day + 7),
    ),
  ];

  for (final spec in specs) {
    final match = spec.pattern.firstMatch(input);
    if (match == null) {
      continue;
    }
    final day = spec.parse(match, now);
    if (day == null) {
      continue;
    }
    return _DateHit(day, input.replaceRange(match.start, match.end, ' '));
  }
  return null;
}

class _DateSpec {
  const _DateSpec(this.pattern, this.parse);
  final RegExp pattern;
  final DateTime? Function(RegExpMatch match, DateTime now) parse;
}

DateTime? _validDate(int year, int month, int day) {
  if (month < 1 || month > 12 || day < 1) {
    return null;
  }
  final last = DateTime(year, month + 1, 0).day;
  if (day > last) {
    return null;
  }
  return DateTime(year, month, day);
}

DateTime _weekdayInWeek(DateTime now, int weekday, {required int weekOffset}) {
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - DateTime.monday));
  final targetMonday = DateTime(monday.year, monday.month, monday.day + (7 * weekOffset));
  return DateTime(targetMonday.year, targetMonday.month, targetMonday.day + (weekday - DateTime.monday));
}
