import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app.dart';
import '../domain/home_layout.dart';
import '../l10n/copy.dart';

class HomeLayoutPage extends StatefulWidget {
  const HomeLayoutPage({super.key});

  @override
  State<HomeLayoutPage> createState() => _HomeLayoutPageState();
}

class _HomeLayoutPageState extends State<HomeLayoutPage> {
  List<HomeBlock> _blocks = const [];
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_saving) {
      _blocks = parseHomeLayout(RepoScope.of(context).homeLayout);
    }
  }

  Future<void> _saveLayout(List<HomeBlock> next) async {
    if (_saving) return;
    final repo = RepoScope.of(context);
    setState(() {
      _blocks = next;
      _saving = true;
    });
    try {
      await repo.setHomeLayout(next);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(Copy.of(context).homeLayoutSaveFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _blocks = parseHomeLayout(repo.homeLayout);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final copy = Copy.of(context);
    final blocks = _blocks;
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
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
                    if (_saving) return;
                    final next = [...blocks];
                    final moved = next.removeAt(oldIndex);
                    next.insert(newIndex, moved);
                    _saveLayout(next);
                  },
                  itemBuilder: (context, index) {
                    final block = blocks[index];
                    return _LayoutRow(
                      key: ValueKey(block.id),
                      block: block,
                      index: index,
                      enabled: !_saving,
                      canMoveUp: index > 0,
                      canMoveDown: index < blocks.length - 1,
                      onVisible: (value) {
                        final next = [...blocks];
                        next[index] = HomeBlock(block.id, value);
                        _saveLayout(next);
                      },
                      onMove: (delta) {
                        final target = index + delta;
                        if (target < 0 || target >= blocks.length) {
                          return;
                        }
                        final next = [...blocks];
                        final moved = next.removeAt(index);
                        next.insert(target, moved);
                        _saveLayout(next);
                      },
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _saving ? null : () => _reset(context),
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
      await _saveLayout(parseHomeLayout(defaultHomeLayout));
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
    required this.enabled,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onVisible,
    required this.onMove,
    super.key,
  });

  final HomeBlock block;
  final int index;
  final bool enabled;
  final bool canMoveUp;
  final bool canMoveDown;
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
              child: Semantics(
                label: copy.homeSection(block.id),
                child: Switch(
                  key: ValueKey('home-visible-${block.id}'),
                  value: block.visible,
                  onChanged: enabled ? onVisible : null,
                ),
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
            IconButton(
              key: ValueKey('home-up-${block.id}'),
              tooltip: copy.moveBlockUp,
              onPressed: enabled && canMoveUp ? () => onMove(-1) : null,
              icon: const Icon(Icons.arrow_upward),
            ),
            IconButton(
              key: ValueKey('home-down-${block.id}'),
              tooltip: copy.moveBlockDown,
              onPressed: enabled && canMoveDown ? () => onMove(1) : null,
              icon: const Icon(Icons.arrow_downward),
            ),
            ReorderableDragStartListener(
              key: ValueKey('home-drag-${block.id}'),
              enabled: enabled,
              index: index,
              child: Shortcuts(
                shortcuts: const {
                  SingleActivator(LogicalKeyboardKey.arrowUp, alt: true):
                      _MoveRow(-1),
                  SingleActivator(LogicalKeyboardKey.arrowDown, alt: true):
                      _MoveRow(1),
                },
                child: Actions(
                  actions: {
                    _MoveRow: CallbackAction<_MoveRow>(
                      onInvoke: (intent) {
                        if (enabled) onMove(intent.delta);
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
