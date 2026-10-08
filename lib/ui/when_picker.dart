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

const spanYearStart = 2016;
const spanYearEnd = 2036;

class SpanPick {
  const SpanPick({required this.start, required this.end, required this.saveEnd});

  final DateTime start;
  final DateTime end;
  final bool saveEnd;
}

Future<SpanPick?> showSpanPicker(
  BuildContext context, {
  required DateTime start,
  required DateTime end,
  required bool editingEnd,
}) {
  return showModalBottomSheet<SpanPick>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return _SpanPicker(start: start, end: end, editingEnd: editingEnd);
    },
  );
}

class _SpanPicker extends StatefulWidget {
  const _SpanPicker({
    required this.start,
    required this.end,
    required this.editingEnd,
  });

  final DateTime start;
  final DateTime end;
  final bool editingEnd;

  @override
  State<_SpanPicker> createState() => _SpanPickerState();
}

class _SpanPickerState extends State<_SpanPicker> {
  late DateTime _start;
  late DateTime _end;
  late bool _editingEnd;
  var _endDirty = false;

  @override
  void initState() {
    super.initState();
    _start = widget.start;
    _end = widget.end;
    _editingEnd = widget.editingEnd;
  }

  DateTime get _active => _editingEnd ? _end : _start;

  void _onDrum(DateTime value) {
    final current = _active;
    if (current.year == value.year &&
        current.month == value.month &&
        current.day == value.day &&
        current.hour == value.hour &&
        current.minute == value.minute) {
      return;
    }
    setState(() {
      if (_editingEnd) {
        _end = value;
        _endDirty = true;
      } else {
        _start = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: _header(copy, scheme, end: false)),
                const SizedBox(width: 8),
                Expanded(child: _header(copy, scheme, end: true)),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: _SixDrums(value: _active, onChanged: _onDrum),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(copy.cancel),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      SpanPick(
                        start: _start,
                        end: _end,
                        saveEnd: _editingEnd || _endDirty,
                      ),
                    ),
                    child: Text(copy.doneLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(Copy copy, ColorScheme scheme, {required bool end}) {
    final active = _editingEnd == end;
    final value = end ? _end : _start;
    final color = active ? scheme.onPrimary : scheme.onSurface;
    return Material(
      color: active ? scheme.primary : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _editingEnd = end),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              Text(
                copy.drumDate(value),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                copy.halfClock(value),
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SixDrums extends StatefulWidget {
  const _SixDrums({required this.value, required this.onChanged});

  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  State<_SixDrums> createState() => _SixDrumsState();
}

class _SixDrumsState extends State<_SixDrums> {
  late final FixedExtentScrollController _years;
  late final FixedExtentScrollController _months;
  late final FixedExtentScrollController _days;
  late final FixedExtentScrollController _halves;
  late final FixedExtentScrollController _hours;
  late final FixedExtentScrollController _minutes;
  var _fromWheel = false;

  @override
  void initState() {
    super.initState();
    final value = widget.value;
    _years = FixedExtentScrollController(initialItem: _yearIndex(value));
    _months = FixedExtentScrollController(initialItem: value.month - 1);
    _days = FixedExtentScrollController(initialItem: value.day - 1);
    _halves = FixedExtentScrollController(initialItem: value.hour >= 12 ? 1 : 0);
    _hours = FixedExtentScrollController(initialItem: _hourIndex(value.hour));
    _minutes = FixedExtentScrollController(initialItem: value.minute);
  }

  @override
  void didUpdateWidget(_SixDrums oldWidget) {
    super.didUpdateWidget(oldWidget);
    final own = _fromWheel;
    _fromWheel = false;
    if (own || _same(oldWidget.value, widget.value)) {
      return;
    }
    _jump(_years, _yearIndex(widget.value));
    _jump(_months, widget.value.month - 1);
    _jump(_days, widget.value.day - 1);
    _jump(_halves, widget.value.hour >= 12 ? 1 : 0);
    _jump(_hours, _hourIndex(widget.value.hour));
    _jump(_minutes, widget.value.minute);
  }

  @override
  void dispose() {
    _years.dispose();
    _months.dispose();
    _days.dispose();
    _halves.dispose();
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  int _yearIndex(DateTime value) => (value.year - spanYearStart).clamp(0, spanYearEnd - spanYearStart);

  int _hourIndex(int hour24) {
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return hour12 - 1;
  }

  int _to24(int hour12, {required bool afternoon}) {
    if (hour12 == 12) {
      return afternoon ? 12 : 0;
    }
    return afternoon ? hour12 + 12 : hour12;
  }

  bool _same(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  void _jump(FixedExtentScrollController controller, int index) {
    if (!controller.hasClients || controller.selectedItem == index) {
      return;
    }
    controller.jumpToItem(index);
  }

  void _emit(DateTime next) {
    if (_same(widget.value, next)) {
      return;
    }
    _fromWheel = true;
    widget.onChanged(next);
  }

  DateTime _with({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
  }) {
    final value = widget.value;
    final nextYear = year ?? value.year;
    final nextMonth = month ?? value.month;
    final last = DateTime(nextYear, nextMonth + 1, 0).day;
    final nextDay = (day ?? value.day).clamp(1, last);
    return DateTime(
      nextYear,
      nextMonth,
      nextDay,
      hour ?? value.hour,
      minute ?? value.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(fontSize: 16, color: scheme.onSurface);
    final value = widget.value;
    final afternoon = value.hour >= 12;
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(context).brightness,
        textTheme: CupertinoTextThemeData(pickerTextStyle: style),
      ),
      child: Row(
        children: [
          Expanded(
            child: _wheel(
              controller: _years,
              onChanged: (index) => _emit(_with(year: spanYearStart + index)),
              children: [
                for (var year = spanYearStart; year <= spanYearEnd; year++)
                  Center(child: Text('$year', style: style)),
              ],
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _months,
              onChanged: (index) {
                final next = _with(month: index + 1);
                _emit(next);
                _jump(_days, next.day - 1);
              },
              children: [
                for (var month = 1; month <= 12; month++)
                  Center(child: Text(copy.monthShort(month), style: style)),
              ],
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _days,
              onChanged: (index) => _emit(_with(day: index + 1)),
              children: [
                for (var day = 1; day <= 31; day++)
                  Center(child: Text('$day', style: style)),
              ],
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _halves,
              onChanged: (index) {
                final hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
                _emit(_with(hour: _to24(hour12, afternoon: index == 1)));
              },
              children: [
                Center(child: Text(copy.amLabel, style: style)),
                Center(child: Text(copy.pmLabel, style: style)),
              ],
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _hours,
              onChanged: (index) => _emit(
                _with(hour: _to24(index + 1, afternoon: afternoon)),
              ),
              children: [
                for (var hour = 1; hour <= 12; hour++)
                  Center(child: Text('$hour', style: style)),
              ],
            ),
          ),
          Expanded(
            child: _wheel(
              controller: _minutes,
              onChanged: (index) => _emit(_with(minute: index)),
              children: [
                for (var minute = 0; minute < 60; minute++)
                  Center(child: Text(minute.toString().padLeft(2, '0'), style: style)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wheel({
    required FixedExtentScrollController controller,
    required ValueChanged<int> onChanged,
    required List<Widget> children,
  }) {
    return CupertinoPicker(
      scrollController: controller,
      itemExtent: 32,
      onSelectedItemChanged: onChanged,
      children: children,
    );
  }
}
