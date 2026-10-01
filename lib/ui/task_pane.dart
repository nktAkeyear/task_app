import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/date_phrase.dart';
import '../domain/models.dart';
import '../l10n/copy.dart';
import 'task_composer.dart';
import 'widgets.dart';

class TaskPane extends StatelessWidget {
  const TaskPane({
    required this.board,
    required this.listId,
    required this.selectedId,
    required this.query,
    required this.day,
    required this.onOpen,
    required this.onQuery,
    required this.searchController,
    required this.searchFocus,
    required this.quickAddFocus,
    required this.showSearch,
    this.onCreate,
    this.showTitle = true,
    super.key,
  });

  final TaskBoard board;
  final String? listId;
  final String? selectedId;
  final String query;
  final DateTime? day;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onQuery;
  final TextEditingController searchController;
  final FocusNode searchFocus;
  final FocusNode quickAddFocus;
  final bool showSearch;
  final VoidCallback? onCreate;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final listName = listId == null ? null : repo.listById(listId!)?.name;
    final copy = Copy.of(context);
    final title = showTitle ? copy.board(board, listName: listName) : '';
    final tasks = repo.tasksFor(
      board: board,
      listId: listId,
      day: day,
      query: query,
    );
    final manual = board == TaskBoard.inbox || board == TaskBoard.list;
    final width = MediaQuery.sizeOf(context).width;
    final swipe = width < 1080;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (onCreate != null)
                  IconButton(
                    key: const Key('create-task'),
                    tooltip: copy.createTask,
                    onPressed: onCreate,
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
          ),
        if (showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              key: const Key('search-field'),
              controller: searchController,
              focusNode: searchFocus,
              decoration: InputDecoration(
                hintText: copy.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: copy.clearSearch,
                        onPressed: () {
                          searchController.clear();
                          onQuery('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
              onChanged: onQuery,
            ),
          ),
        Expanded(
          child: tasks.isEmpty
              ? EmptyHint(
                  message: copy.empty(board, query: query),
                  icon: query.trim().isNotEmpty || board == TaskBoard.search
                      ? Icons.search_off
                      : Icons.task_alt,
                )
              : manual
              ? ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemCount: tasks.length,
                  onReorderItem: (oldIndex, newIndex) {
                    final ids = tasks.map((task) => task.id).toList();
                    final moved = ids.removeAt(oldIndex);
                    ids.insert(newIndex, moved);
                    repo.reorderTasks(ids);
                  },
                  itemBuilder: (context, index) {
                    return _Entry(
                      key: ValueKey(tasks[index].id),
                      task: tasks[index],
                      index: index,
                      selected: tasks[index].id == selectedId,
                      enableSwipe: swipe,
                      showHandle: true,
                      onOpen: () => onOpen(tasks[index].id),
                    );
                  },
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _Entry(
                      key: ValueKey(tasks[index].id),
                      task: tasks[index],
                      selected: tasks[index].id == selectedId,
                      enableSwipe: swipe,
                      showHandle: false,
                      onOpen: () => onOpen(tasks[index].id),
                    );
                  },
                ),
        ),
        if (board != TaskBoard.completed)
          QuickAddBar(
            focusNode: quickAddFocus,
            onSubmit: (raw) async {
              final parsed = parseQuickAdd(raw, now: DateTime.now());
              if (parsed.title.trim().isEmpty) {
                return;
              }
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => TaskComposerPage(
                    listId: board == TaskBoard.list ? listId : null,
                    initialTitle: parsed.title,
                    initialStart: parsed.due,
                    initialHasTime: parsed.hasTime,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required super.key,
    required this.task,
    required this.selected,
    required this.enableSwipe,
    required this.showHandle,
    required this.onOpen,
    this.index,
  });

  final TaskModel task;
  final bool selected;
  final bool enableSwipe;
  final bool showHandle;
  final VoidCallback onOpen;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final now = DateTime.now();
    final items = repo.checklistFor(task.id);
    final done = items.where((item) => item.done).length;
    final tile = TaskTile(
      task: task,
      selected: selected,
      onOpen: onOpen,
      onToggle: () async {
        final message = await repo.toggleComplete(task.id);
        if (context.mounted) {
          showUndoSnack(context, message, repo.undo);
        }
      },
      subtitle: taskSubtitle(
        context: context,
        task: task,
        list: repo.listById(task.listId),
        tags: repo.tagsFor(task.id),
        checklistDone: done,
        checklistTotal: items.length,
        now: now,
        showList: true,
      ),
    );
    final row = Row(
      children: [
        Expanded(child: tile),
        if (showHandle && index != null)
          ReorderableDragStartListener(
            index: index!,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.drag_handle),
            ),
          ),
      ],
    );
    if (!enableSwipe) {
      return row;
    }
    return Dismissible(
      key: ValueKey('swipe-${task.id}'),
      background: _SwipeBg(
        align: Alignment.centerLeft,
        color: const Color(0xFF1C4E4A),
        icon: Icons.check,
        label: Copy.of(context).swipeDone,
      ),
      secondaryBackground: _SwipeBg(
        align: Alignment.centerRight,
        color: const Color(0xFF9F1D1D),
        icon: Icons.delete_outline,
        label: Copy.of(context).delete,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final stays =
              task.recurrence != 'none' &&
              task.dueAt != null &&
              !task.isCompleted;
          final message = await repo.toggleComplete(task.id);
          if (context.mounted) {
            showUndoSnack(context, message, repo.undo);
          }
          return !stays;
        }
        final message = await repo.deleteTask(task.id);
        if (context.mounted) {
          showUndoSnack(context, message, repo.undo);
        }
        return true;
      },
      child: row,
    );
  }
}

class _SwipeBg extends StatelessWidget {
  const _SwipeBg({
    required this.align,
    required this.color,
    required this.icon,
    required this.label,
  });

  final Alignment align;
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
