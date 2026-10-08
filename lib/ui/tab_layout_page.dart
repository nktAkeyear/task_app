import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../domain/tab_layout.dart';
import '../l10n/copy.dart';

class TabLayoutPage extends StatelessWidget {
  const TabLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final items = parseTabLayout(repo.tabLayout);
    return Scaffold(
      appBar: AppBar(title: Text(copy.tabLayout)),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  copy.tabLayoutLead,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  itemCount: items.length,
                  proxyDecorator: (child, index, animation) {
                    return Material(elevation: 6, child: child);
                  },
                  onReorderItem: (oldIndex, newIndex) {
                    final next = [...items];
                    final moved = next.removeAt(oldIndex);
                    next.insert(newIndex, moved);
                    repo.setTabLayout(next);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _LayoutRow(
                      key: ValueKey(item.id),
                      item: item,
                      index: index,
                      onVisible: (value) {
                        final next = [...items];
                        next[index] = TabItem(item.id, value);
                        repo.setTabLayout(next);
                      },
                      onMove: (delta) {
                        final target = index + delta;
                        if (target < 0 || target >= items.length) {
                          return;
                        }
                        final next = [...items];
                        final moved = next.removeAt(index);
                        next.insert(target, moved);
                        repo.setTabLayout(next);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => _reset(context),
                  child: Text(copy.reset),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _reset(BuildContext context) async {
    final copy = Copy.of(context);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(copy.resetTabTitle),
        content: Text(copy.resetTabBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(copy.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(copy.reset),
          ),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      await RepoScope.of(context).setTabLayout(parseTabLayout(defaultTabLayout));
    }
  }
}

class _MoveRow extends Intent {
  const _MoveRow(this.delta);
  final int delta;
}

class _LayoutRow extends StatelessWidget {
  const _LayoutRow({
    required this.item,
    required this.index,
    required this.onVisible,
    required this.onMove,
    super.key,
  });

  final TabItem item;
  final int index;
  final ValueChanged<bool> onVisible;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Switch(
                value: item.visible,
                onChanged: onVisible,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.tabLabel(item.id)),
                  Text(
                    copy.tabDescription(item.id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.arrowUp, alt: true): _MoveRow(-1),
                  SingleActivator(LogicalKeyboardKey.arrowDown, alt: true): _MoveRow(1),
                },
                child: Actions(
                  actions: {
                    _MoveRow: CallbackAction<_MoveRow>(
                      onInvoke: (intent) {
                        onMove(intent.delta);
                        return null;
                      },
                    ),
                  },
                  child: Focus(
                    child: Semantics(
                      label: copy.dragToReorder,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.drag_indicator),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
