import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../domain/filters.dart';
import '../l10n/copy.dart';

final drumRangeStart = DateTime(2024);
final drumRangeEnd = DateTime(2030, 12, 31);

int drumDayIndex(DateTime day) {
  return startOfDay(day).difference(drumRangeStart).inDays;
}

DateTime drumDateAt(int index) {
  return drumRangeStart.add(Duration(days: index));
}

int drumMonthIndex(DateTime day) {
  return (day.year - drumRangeStart.year) * 12 + day.month - 1;
}

DateTime drumMonthAt(int index) {
  final year = drumRangeStart.year + index ~/ 12;
  final month = index % 12 + 1;
  return DateTime(year, month);
}

int get drumDayCount => drumRangeEnd.difference(drumRangeStart).inDays;
int get drumMonthCount => (2030 - 2024 + 1) * 12;

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

Future<DateTime?> showDateDrum(
  BuildContext context, {
  required DateTime initial,
}) {
  var selected = startOfDay(initial);
  final copy = Copy.of(context);
  return showModalBottomSheet<DateTime>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setSheet) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    copy.monthYear(selected),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 180,
                    child: DateDrums(
                      value: selected,
                      onChanged: (value) => setSheet(() => selected = value),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: Text(copy.doneLabel),
                    ),
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

class DateDrums extends StatefulWidget {
  const DateDrums({required this.value, required this.onChanged, super.key});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<DateDrums> createState() => _DateDrumsState();
}

class _DateDrumsState extends State<DateDrums> {
  late final FixedExtentScrollController _days;
  late final FixedExtentScrollController _months;
  var _fromWheel = false;

  @override
  void initState() {
    super.initState();
    _days = FixedExtentScrollController(initialItem: _clampDay(drumDayIndex(widget.value)));
    _months = FixedExtentScrollController(initialItem: _clampMonth(drumMonthIndex(widget.value)));
  }

  @override
  void didUpdateWidget(DateDrums oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_fromWheel) {
      _fromWheel = false;
      _jump(_months, _clampMonth(drumMonthIndex(widget.value)));
      return;
    }
    if (!sameDay(oldWidget.value, widget.value)) {
      _jump(_days, _clampDay(drumDayIndex(widget.value)));
      _jump(_months, _clampMonth(drumMonthIndex(widget.value)));
    }
  }

  @override
  void dispose() {
    _days.dispose();
    _months.dispose();
    super.dispose();
  }

  int _clampDay(int index) => index.clamp(0, drumDayCount - 1);
  int _clampMonth(int index) => index.clamp(0, drumMonthCount - 1);

  void _jump(FixedExtentScrollController controller, int index) {
    if (!controller.hasClients || controller.selectedItem == index) {
      return;
    }
    controller.jumpToItem(index);
  }

  void _emit(DateTime day) {
    _fromWheel = true;
    widget.onChanged(
      DateTime(day.year, day.month, day.day, widget.value.hour, widget.value.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(fontSize: 18, color: scheme.onSurface);
    final nowYear = DateTime.now().year;
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        textTheme: CupertinoTextThemeData(pickerTextStyle: style),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoPicker(
              scrollController: _months,
              itemExtent: 36,
              onSelectedItemChanged: (index) {
                final month = drumMonthAt(index);
                final last = DateTime(month.year, month.month + 1, 0).day;
                final day = widget.value.day.clamp(1, last);
                _emit(DateTime(month.year, month.month, day));
                _jump(_days, _clampDay(drumDayIndex(DateTime(month.year, month.month, day))));
              },
              children: [
                for (var index = 0; index < drumMonthCount; index++)
                  Center(
                    child: Text(
                      _monthLabel(copy, drumMonthAt(index), nowYear),
                      style: style,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: _days,
              itemExtent: 36,
              onSelectedItemChanged: (index) {
                final day = drumDateAt(index);
                _emit(day);
                _jump(_months, _clampMonth(drumMonthIndex(day)));
              },
              children: [
                for (var index = 0; index < drumDayCount; index++)
                  Center(child: Text('${drumDateAt(index).day}', style: style)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthLabel(Copy copy, DateTime month, int nowYear) {
    final name = copy.monthName(month.month);
    if (month.year == nowYear) {
      return name;
    }
    return '$name ${month.year}';
  }
}

class TimeDrums extends StatefulWidget {
  const TimeDrums({required this.value, required this.onChanged, super.key});

  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;

  @override
  State<TimeDrums> createState() => _TimeDrumsState();
}

class _TimeDrumsState extends State<TimeDrums> {
  late final FixedExtentScrollController _hours;
  late final FixedExtentScrollController _minutes;
  var _editHour = false;
  var _editMinute = false;
  final _hourText = TextEditingController();
  final _minuteText = TextEditingController();

  @override
  void initState() {
    super.initState();
    _hours = FixedExtentScrollController(initialItem: widget.value.hour);
    _minutes = FixedExtentScrollController(initialItem: widget.value.minute);
  }

  @override
  void didUpdateWidget(TimeDrums oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.hour != widget.value.hour && _hours.hasClients) {
      _hours.jumpToItem(widget.value.hour);
    }
    if (oldWidget.value.minute != widget.value.minute && _minutes.hasClients) {
      _minutes.jumpToItem(widget.value.minute);
    }
  }

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    _hourText.dispose();
    _minuteText.dispose();
    super.dispose();
  }

  void _commitHour() {
    final parsed = int.tryParse(_hourText.text.trim());
    if (parsed != null) {
      widget.onChanged(TimeOfDay(hour: parsed.clamp(0, 23), minute: widget.value.minute));
    }
    setState(() => _editHour = false);
  }

  void _commitMinute() {
    final parsed = int.tryParse(_minuteText.text.trim());
    if (parsed != null) {
      widget.onChanged(TimeOfDay(hour: widget.value.hour, minute: parsed.clamp(0, 59)));
    }
    setState(() => _editMinute = false);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(fontSize: 20, color: scheme.onSurface);
    return SizedBox(
      height: 140,
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: Theme.of(context).brightness,
          textTheme: CupertinoTextThemeData(pickerTextStyle: style),
        ),
        child: Row(
          children: [
            Expanded(child: _column(hour: true, style: style)),
            Text(':', style: style),
            Expanded(child: _column(hour: false, style: style)),
          ],
        ),
      ),
    );
  }

  Widget _column({required bool hour, required TextStyle style}) {
    final editing = hour ? _editHour : _editMinute;
    if (editing) {
      final controller = hour ? _hourText : _minuteText;
      return TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        onSubmitted: (_) => hour ? _commitHour() : _commitMinute(),
        onTapOutside: (_) => hour ? _commitHour() : _commitMinute(),
      );
    }
    return GestureDetector(
      onDoubleTap: () {
        if (hour) {
          _hourText.text = widget.value.hour.toString();
          setState(() => _editHour = true);
        } else {
          _minuteText.text = widget.value.minute.toString();
          setState(() => _editMinute = true);
        }
      },
      child: CupertinoPicker(
        scrollController: hour ? _hours : _minutes,
        itemExtent: 36,
        onSelectedItemChanged: (index) {
          if (hour) {
            widget.onChanged(TimeOfDay(hour: index, minute: widget.value.minute));
          } else {
            widget.onChanged(TimeOfDay(hour: widget.value.hour, minute: index));
          }
        },
        children: [
          for (var value = 0; value < (hour ? 24 : 60); value++)
            Center(child: Text(value.toString().padLeft(2, '0'), style: style)),
        ],
      ),
    );
  }
}
