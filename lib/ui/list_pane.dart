import 'package:flutter/material.dart';

import '../app.dart';
import '../domain/models.dart';
import 'widgets.dart';

class ListPane extends StatelessWidget {
  const ListPane({
    required this.board,
    required this.listId,
    required this.onSmart,
    required this.onList,
    required this.onSettings,
    this.onCreateTask,
    this.onTool,
    this.navKeys = true,
    super.key,
  });

  final TaskBoard board;
  final String? listId;
  final ValueChanged<TaskBoard> onSmart;
  final ValueChanged<String> onList;
  final VoidCallback onSettings;
  final VoidCallback? onCreateTask;
  final ValueChanged<String>? onTool;
  final bool navKeys;

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const TasMark(),
                const SizedBox(width: 10),
                Text(
                  'Tas',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (onCreateTask != null)
                  IconButton(
                    key: const Key('create-task'),
                    tooltip: 'タスクを作成',
                    onPressed: onCreateTask,
                    icon: const Icon(Icons.add),
                  ),
              ],
            ),
          ),
          _SmartTile(
            icon: Icons.inbox_outlined,
            label: '受信箱',
            selected: board == TaskBoard.inbox,
            count: repo.tasksFor(board: TaskBoard.inbox).length,
            onTap: () => onSmart(TaskBoard.inbox),
            itemKey: navKeys ? const Key('nav-inbox') : null,
          ),
          _SmartTile(
            icon: Icons.today_outlined,
            label: '今日',
            selected: board == TaskBoard.today,
            count: repo.tasksFor(board: TaskBoard.today).length,
            onTap: () => onSmart(TaskBoard.today),
            itemKey: navKeys ? const Key('nav-today') : null,
          ),
          _SmartTile(
            icon: Icons.date_range_outlined,
            label: '近日',
            selected: board == TaskBoard.upcoming,
            count: repo.tasksFor(board: TaskBoard.upcoming).length,
            onTap: () => onSmart(TaskBoard.upcoming),
            itemKey: navKeys ? const Key('nav-upcoming') : null,
          ),
          _SmartTile(
            icon: Icons.calendar_month_outlined,
            label: 'カレンダー',
            selected: board == TaskBoard.calendar,
            onTap: () => onSmart(TaskBoard.calendar),
            itemKey: navKeys ? const Key('nav-calendar') : null,
          ),
          _SmartTile(
            icon: Icons.check_circle_outline,
            label: '完了',
            selected: board == TaskBoard.completed,
            count: repo.tasksFor(board: TaskBoard.completed).length,
            onTap: () => onSmart(TaskBoard.completed),
            itemKey: navKeys ? const Key('nav-completed') : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
            child: Row(
              children: [
                Text(
                  'リスト',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'リストを追加',
                  onPressed: () => _createList(context),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          Expanded(
            child: repo.userLists.isEmpty
                ? const EmptyHint(
                    message: '自分のリストはまだありません。',
                    icon: Icons.list_alt_outlined,
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: repo.userLists.length,
                    onReorderItem: (oldIndex, newIndex) {
                      final ids = repo.userLists
                          .map((list) => list.id)
                          .toList();
                      final moved = ids.removeAt(oldIndex);
                      ids.insert(newIndex, moved);
                      repo.reorderLists(ids);
                    },
                    itemBuilder: (context, index) {
                      final list = repo.userLists[index];
                      final count = repo
                          .tasksFor(board: TaskBoard.list, listId: list.id)
                          .length;
                      return _ListRow(
                        key: ValueKey(list.id),
                        list: list,
                        count: count,
                        index: index,
                        selected: board == TaskBoard.list && listId == list.id,
                        onTap: () => onList(list.id),
                        onMenu: () => _listMenu(context, list),
                      );
                    },
                  ),
          ),
          if (repo.archivedLists.isNotEmpty)
            ExpansionTile(
              title: const Text('アーカイブ'),
              children: [
                for (final list in repo.archivedLists)
                  ListTile(
                    leading: _Dot(color: list.color),
                    title: Text(list.name),
                    onTap: () => onList(list.id),
                    trailing: IconButton(
                      tooltip: '元に戻す',
                      onPressed: () => repo.setListArchived(list.id, false),
                      icon: const Icon(Icons.unarchive_outlined),
                    ),
                  ),
              ],
            ),
          if (onTool != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                'ツール',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('ポモドーロ'),
              onTap: () => onTool!('pomodoro'),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view_outlined),
              title: const Text('マトリックス'),
              onTap: () => onTool!('matrix'),
            ),
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('習慣'),
              onTap: () => onTool!('habits'),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('日記'),
              onTap: () => onTool!('diary'),
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('検索'),
              onTap: () => onTool!('search'),
            ),
          ],
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('設定'),
            selected: board == TaskBoard.settings,
            onTap: onSettings,
          ),
        ],
      ),
    );
  }

  Future<void> _createList(BuildContext context) async {
    final repo = RepoScope.of(context);
    final name = await _askName(context, title: 'リストを作成', initial: '');
    if (name == null || !context.mounted) {
      return;
    }
    try {
      final id = await repo.createList(name);
      onList(id);
    } on FormatException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }

  Future<void> _listMenu(BuildContext context, ListModel list) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: const Text('名前を変更'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('色を変える'),
              onTap: () => Navigator.pop(context, 'color'),
            ),
            ListTile(
              leading: Icon(
                list.archived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              title: Text(list.archived ? 'アーカイブを解除' : 'アーカイブ'),
              onTap: () => Navigator.pop(context, 'archive'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('削除'),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );
    if (!context.mounted || action == null) {
      return;
    }
    final repo = RepoScope.of(context);
    switch (action) {
      case 'rename':
        final name = await _askName(
          context,
          title: '名前を変更',
          initial: list.name,
        );
        if (name != null) {
          await repo.renameList(list.id, name);
        }
      case 'color':
        final color = await _pickColor(context, list.color);
        if (color != null) {
          await repo.recolorList(list.id, color);
        }
      case 'archive':
        await repo.setListArchived(list.id, !list.archived);
      case 'delete':
        final ok = await confirmAction(
          context,
          title: 'リストを削除',
          message: '「${list.name}」を削除します。中のタスクは受信箱に移ります。',
          action: '削除',
        );
        if (ok) {
          final message = await repo.deleteList(list.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(message)));
          }
          if (listId == list.id) {
            onSmart(TaskBoard.inbox);
          }
        }
    }
  }
}

class _SmartTile extends StatelessWidget {
  const _SmartTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.itemKey,
    this.count,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Key? itemKey;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        key: itemKey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selected: selected,
        selectedTileColor: scheme.primaryContainer.withValues(alpha: 0.65),
        leading: Icon(icon),
        title: Text(label),
        trailing: count == null
            ? null
            : Text('$count', style: TextStyle(color: scheme.onSurfaceVariant)),
        onTap: onTap,
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({
    required super.key,
    required this.list,
    required this.count,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.onMenu,
  });

  final ListModel list;
  final int count;
  final int index;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.65)
          : Colors.transparent,
      child: ListTile(
        leading: _Dot(color: list.color),
        title: Text(list.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$count', style: TextStyle(color: scheme.onSurfaceVariant)),
            IconButton(
              tooltip: 'リストの操作',
              onPressed: onMenu,
              icon: const Icon(Icons.more_horiz),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.drag_handle),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final int color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
    );
  }
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String initial,
}) {
  final controller = TextEditingController(text: initial);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(labelText: '名前'),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text.trim()),
          child: const Text('保存'),
        ),
      ],
    ),
  );
}

Future<int?> _pickColor(BuildContext context, int current) {
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('色'),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final color in listColors)
            InkWell(
              onTap: () => Navigator.pop(context, color),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color == current ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
