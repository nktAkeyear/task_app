import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/filters.dart';
import '../domain/models.dart';
import 'task_pane.dart';

class CalendarPane extends StatelessWidget {
  const CalendarPane({
    required this.month,
    required this.day,
    required this.selectedId,
    required this.onMonth,
    required this.onDay,
    required this.onOpen,
    required this.onSelect,
    required this.quickAddFocus,
    required this.searchFocus,
    required this.query,
    required this.onQuery,
    required this.searchController,
    super.key,
  });

  final DateTime month;
  final DateTime day;
  final String? selectedId;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<DateTime> onDay;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onSelect;
  final FocusNode quickAddFocus;
  final FocusNode searchFocus;
  final String query;
  final ValueChanged<String> onQuery;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    final first = DateTime(month.year, month.month);
    final leading = first.weekday - DateTime.monday;
    final gridStart = DateTime(first.year, first.month, 1 - leading);
    final counts = <DateTime, int>{};
    for (final task in repo.tasks) {
      final due = task.dueAt;
      if (task.deleted || due == null) {
        continue;
      }
      final key = startOfDay(due);
      counts[key] = (counts[key] ?? 0) + 1;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: '前の月',
                onPressed: () => onMonth(DateTime(month.year, month.month - 1)),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${month.year}年${month.month}月',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              IconButton(
                tooltip: '次の月',
                onPressed: () => onMonth(DateTime(month.year, month.month + 1)),
                icon: const Icon(Icons.chevron_right),
              ),
              TextButton(onPressed: () => onDay(startOfDay(DateTime.now())), child: const Text('今日')),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              for (final label in const ['月', '火', '水', '木', '金', '土', '日'])
                Expanded(
                  child: Center(
                    child: Text(label, style: TextStyle(color: scheme.onSurfaceVariant, fontWeight: FontWeight.w700)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 42,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 48),
          itemBuilder: (context, index) {
            final date = DateTime(gridStart.year, gridStart.month, gridStart.day + index);
            final inMonth = date.month == month.month;
            final selected = sameDay(date, day);
            final today = sameDay(date, DateTime.now());
            final count = counts[startOfDay(date)] ?? 0;
            return Padding(
              padding: const EdgeInsets.all(2),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onDay(startOfDay(date)),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected ? scheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: today && !selected ? Border.all(color: scheme.primary) : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: selected
                              ? scheme.onPrimary
                              : inMonth
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      if (count > 0)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: selected ? scheme.onPrimary : scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: TaskPane(
            board: TaskBoard.calendar,
            listId: null,
            selectedId: selectedId,
            query: query,
            day: day,
            onOpen: onOpen,
            onSelect: onSelect,
            onQuery: onQuery,
            searchController: searchController,
            searchFocus: searchFocus,
            quickAddFocus: quickAddFocus,
            showSearch: true,
            showTitle: false,
          ),
        ),
      ],
    );
  }
}
