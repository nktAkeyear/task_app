import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../domain/home_layout.dart';
import '../l10n/copy.dart';

class HomeLayoutPage extends StatelessWidget {
  const HomeLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = RepoScope.of(context);
    final copy = Copy.of(context);
    final blocks = parseHomeLayout(repo.homeLayout);
    return Scaffold(
      appBar: AppBar(title: Text(copy.homeLayout)),
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
                  copy.homeLayoutLead,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                  itemCount: blocks.length,
                  proxyDecorator: (child, index, animation) {
                    return Material(elevation: 6, child: child);
                  },
                  onReorderItem: (oldIndex, newIndex) {
                    final next = [...blocks];
                    final moved = next.removeAt(oldIndex);
                    next.insert(newIndex, moved);
                    repo.setHomeLayout(next);
                  },
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    return _LayoutRow(
                      key: ValueKey(block.id),
                      block: block,
                      index: index,
                      onVisible: (value) {
                        final next = [...blocks];
                        next[index] = HomeBlock(block.id, value);
                        repo.setHomeLayout(next);
                      },
                      onMove: (delta) {
                        final target = index + delta;
                        if (target < 0 || target >= blocks.length) {
                          return;
                        }
                        final next = [...blocks];
                        final moved = next.removeAt(index);
                        next.insert(target, moved);
                        repo.setHomeLayout(next);
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
        title: Text(copy.resetHomeTitle),
        content: Text(copy.resetHomeBody),
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
      await RepoScope.of(context).setHomeLayout(parseHomeLayout(defaultHomeLayout));
    }
  }
}

class _MoveRow extends Intent {
  const _MoveRow(this.delta);
  final int delta;
}

class _LayoutRow extends StatelessWidget {
  const _LayoutRow({
    required this.block,
    required this.index,
    required this.onVisible,
    required this.onMove,
    super.key,
  });

  final HomeBlock block;
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
                value: block.visible,
                onChanged: onVisible,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(copy.homeSection(block.id)),
                  Text(
                    copy.homeBlockDescription(block.id),
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
