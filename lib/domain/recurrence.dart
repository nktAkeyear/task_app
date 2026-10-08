const recurrenceNone = 'none';
const recurrenceDaily = 'daily';
const recurrenceWeekly = 'weekly';
const recurrenceMonthly = 'monthly';
const recurrenceWeekdays = 'weekdays';

const reminderNone = 'none';
const reminderOnTime = 'ontime';
const reminder5m = '5m';
const reminder15m = '15m';
const reminder1h = '1h';
const reminder1d = '1d';

/// The next single occurrence after [from]. Does not skip ahead.
DateTime nextOccurrence(DateTime from, String recurrence) {
  return switch (recurrence) {
    recurrenceDaily => DateTime(from.year, from.month, from.day + 1, from.hour, from.minute, from.second),
    recurrenceWeekly => DateTime(from.year, from.month, from.day + 7, from.hour, from.minute, from.second),
    recurrenceMonthly => addMonths(from, 1),
    recurrenceWeekdays => _nextWeekday(from),
    _ => from,
  };
}

/// Steps [nextOccurrence] until the result is strictly after [notBefore].
DateTime nextOccurrenceAfter({
  required DateTime from,
  required String recurrence,
  required DateTime notBefore,
}) {
  var next = nextOccurrence(from, recurrence);
  var guard = 0;
  while (!next.isAfter(notBefore) && guard < 500) {
    next = nextOccurrence(next, recurrence);
    guard++;
  }
  return next;
}

DateTime addMonths(DateTime from, int months) {
  final total = from.year * 12 + (from.month - 1) + months;
  final year = total ~/ 12;
  final month = total % 12 + 1;
  final last = DateTime(year, month + 1, 0).day;
  final day = from.day > last ? last : from.day;
  return DateTime(year, month, day, from.hour, from.minute, from.second);
}

DateTime _nextWeekday(DateTime from) {
  var next = DateTime(from.year, from.month, from.day + 1, from.hour, from.minute, from.second);
  while (next.weekday == DateTime.saturday || next.weekday == DateTime.sunday) {
    next = DateTime(next.year, next.month, next.day + 1, next.hour, next.minute, next.second);
  }
  return next;
}

/// Date-only tasks remind at 09:00 local on the due day.
DateTime? reminderInstant({
  required DateTime? due,
  required bool dueHasTime,
  required String preset,
}) {
  if (due == null || preset == reminderNone) {
    return null;
  }
  final base = dueHasTime ? due : DateTime(due.year, due.month, due.day, 9);
  if (preset.startsWith('m:')) {
    final minutes = int.tryParse(preset.substring(2));
    if (minutes == null) {
      return null;
    }
    return base.subtract(Duration(minutes: minutes));
  }
  return switch (preset) {
    reminderOnTime => base,
    reminder5m => base.subtract(const Duration(minutes: 5)),
    reminder15m => base.subtract(const Duration(minutes: 15)),
    reminder1h => base.subtract(const Duration(hours: 1)),
    reminder1d => base.subtract(const Duration(days: 1)),
    _ => null,
  };
}
