import 'package:flutter_test/flutter_test.dart';
import 'package:tas/domain/recurrence.dart';

void main() {
  test('daily, weekly, and monthly next instances', () {
    expect(nextOccurrence(DateTime(2026, 10, 1, 9, 30), recurrenceDaily), DateTime(2026, 10, 2, 9, 30));
    expect(nextOccurrence(DateTime(2026, 10, 1), recurrenceWeekly), DateTime(2026, 10, 8));
    expect(nextOccurrence(DateTime(2026, 1, 31, 15, 30), recurrenceMonthly), DateTime(2026, 2, 28, 15, 30));
    expect(nextOccurrence(DateTime(2024, 1, 31), recurrenceMonthly), DateTime(2024, 2, 29));
    expect(nextOccurrence(DateTime(2026, 3, 31), recurrenceMonthly), DateTime(2026, 4, 30));
  });

  test('weekday recurrence skips Saturday and Sunday', () {
    expect(nextOccurrence(DateTime(2026, 10, 2, 9), recurrenceWeekdays), DateTime(2026, 10, 5, 9));
    expect(nextOccurrence(DateTime(2026, 10, 3), recurrenceWeekdays), DateTime(2026, 10, 5));
    expect(nextOccurrence(DateTime(2026, 10, 4), recurrenceWeekdays), DateTime(2026, 10, 5));
    expect(nextOccurrence(DateTime(2026, 10, 5), recurrenceWeekdays), DateTime(2026, 10, 6));
  });

  test('nextOccurrenceAfter skips instances that are not after now', () {
    final next = nextOccurrenceAfter(
      from: DateTime(2026, 9, 1, 9),
      recurrence: recurrenceDaily,
      notBefore: DateTime(2026, 10, 1, 10),
    );
    expect(next, DateTime(2026, 10, 2, 9));
  });

  test('date-only reminders use 09:00', () {
    final due = DateTime(2026, 10, 3);
    expect(
      reminderInstant(due: due, dueHasTime: false, preset: reminderOnTime),
      DateTime(2026, 10, 3, 9),
    );
    expect(
      reminderInstant(due: DateTime(2026, 10, 3, 18), dueHasTime: true, preset: reminder1h),
      DateTime(2026, 10, 3, 17),
    );
    expect(reminderInstant(due: due, dueHasTime: false, preset: reminderNone), isNull);
  });
}
