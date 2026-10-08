class TabItem {
  const TabItem(this.id, this.visible);

  final String id;
  final bool visible;
}

const tabIds = ['lists', 'today', 'calendar', 'tools', 'settings'];

const defaultTabLayout = 'lists,today,calendar,tools,settings';

int tabIndex(String id) {
  final index = tabIds.indexOf(id);
  return index < 0 ? 1 : index;
}

List<TabItem> parseTabLayout(String? raw) {
  final known = tabIds.toSet();
  final result = <TabItem>[];
  final seen = <String>{};
  for (final part in (raw ?? '').split(',')) {
    final token = part.trim();
    if (token.isEmpty) {
      continue;
    }
    final hidden = token.startsWith('-');
    final id = hidden ? token.substring(1) : token;
    if (!known.contains(id) || !seen.add(id)) {
      continue;
    }
    result.add(TabItem(id, !hidden));
  }
  for (final id in tabIds) {
    if (seen.add(id)) {
      result.add(TabItem(id, true));
    }
  }
  return result;
}

String encodeTabLayout(List<TabItem> items) {
  return items.map((item) => item.visible ? item.id : '-${item.id}').join(',');
}
