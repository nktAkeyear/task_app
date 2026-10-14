class TabItem {
  const TabItem(this.id, this.visible);

  final String id;
  final bool visible;
}

// Keep the original indices stable for the persisted homeTab preference.
const tabIds = [
  'lists',
  'today',
  'calendar',
  'tools',
  'settings',
  'habits',
  'diary',
  'pomodoro',
  'matrix',
  'search',
];
const independentToolTabs = ['habits', 'diary', 'pomodoro', 'matrix', 'search'];
const defaultTabLayout =
    'today,lists,habits,diary,pomodoro,calendar,matrix,search,settings';

int tabIndex(String id) {
  final index = tabIds.indexOf(id);
  return index < 0 ? 1 : index;
}

List<TabItem> parseTabLayout(String? raw) {
  final parts = (raw == null || raw.trim().isEmpty ? defaultTabLayout : raw)
      .split(',');
  final result = <TabItem>[];
  final seen = <String>{};
  // Explicit individual preferences win over the legacy group, regardless of order.
  final explicit = parts
      .map((part) => part.trim().replaceFirst(RegExp(r'^-'), ''))
      .toSet();
  for (final part in parts) {
    final token = part.trim();
    final hidden = token.startsWith('-');
    final id = hidden ? token.substring(1) : token;
    if (id == 'tools') {
      for (final tool in independentToolTabs) {
        if (!explicit.contains(tool) && seen.add(tool)) {
          result.add(TabItem(tool, !hidden));
        }
      }
    } else if (tabIds.contains(id) && seen.add(id)) {
      result.add(TabItem(id, !hidden));
    }
  }
  for (final id in defaultTabLayout.split(',')) {
    if (seen.add(id)) result.add(TabItem(id, true));
  }
  return result;
}

String encodeTabLayout(List<TabItem> items) {
  return items.map((item) => item.visible ? item.id : '-${item.id}').join(',');
}
