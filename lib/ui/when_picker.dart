import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../domain/filters.dart';
import '../l10n/copy.dart';

Future<DateTime?> showMonthCalendar(
  BuildContext context, {
  required DateTime initial,
}) {
  final copy = Copy.of(context);
  var visible = DateTime(initial.year, initial.month);
  DateTime selected = startOfDay(initial);
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          final scheme = Theme.of(context).colorScheme;
          final first = DateTime(visible.year, visible.month);
          final leading = first.weekday - DateTime.monday;
          final gridStart = DateTime(first.year, first.month, 1 - leading);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: copy.prevMonth,
                        onPressed: () => setSheet(() {
                          visible = DateTime(visible.year, visible.month - 1);
                        }),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          copy.monthYear(visible),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: copy.nextMonth,
                        onPressed: () => setSheet(() {
                          visible = DateTime(visible.year, visible.month + 1);
                        }),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      for (final label in copy.weekdays)
                        Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (var week = 0; week < 6; week++)
                    Row(
                      children: [
                        for (var weekday = 0; weekday < 7; weekday++)
                          Expanded(
                            child: _dayButton(
                              context,
                              gridStart.add(Duration(days: week * 7 + weekday)),
                              visible,
                              selected,
                              scheme,
                              (day) => Navigator.pop(context, day),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _dayButton(
  BuildContext context,
  DateTime day,
  DateTime visible,
  DateTime selected,
  ColorScheme scheme,
  ValueChanged<DateTime> onPick,
) {
  final inMonth = day.month == visible.month;
  final isSelected = sameDay(day, selected);
  return Padding(
    padding: const EdgeInsets.all(2),
    child: Material(
      color: isSelected ? scheme.primary : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => onPick(startOfDay(day)),
        child: SizedBox(
          height: 40,
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected
                    ? scheme.onPrimary
                    : inMonth
                    ? scheme.onSurface
                    : scheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<TimeOfDay?> showWheelTime(
  BuildContext context, {
  required TimeOfDay initial,
}) {
  var hour = initial.hour.clamp(0, 23);
  var minute = initial.minute.clamp(0, 59);
  final copy = Copy.of(context);
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      final style = TextStyle(fontSize: 22, color: scheme.onSurface);
      return CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: CupertinoTextThemeData(pickerTextStyle: style),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: hour,
                          ),
                          itemExtent: 44,
                          onSelectedItemChanged: (index) => hour = index,
                          children: [
                            for (var value = 0; value < 24; value++)
                              Center(
                                child: Text(
                                  value.toString().padLeft(2, '0'),
                                  style: style,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(':', style: style),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: minute,
                          ),
                          itemExtent: 44,
                          onSelectedItemChanged: (index) => minute = index,
                          children: [
                            for (var value = 0; value < 60; value++)
                              Center(
                                child: Text(
                                  value.toString().padLeft(2, '0'),
                                  style: style,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        TimeOfDay(hour: hour, minute: minute),
                      ),
                      child: Text(copy.doneLabel),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
