class HomeBlock {
  const HomeBlock(this.id, this.visible);

  final String id;
  final bool visible;
}

const homeSectionIds = [
  'week',
  'schedule',
  'overdue',
  'habits',
  'pomodoro',
  'diary',
  'matrix',
];

const defaultHomeLayout =
    'week,schedule,overdue,habits,pomodoro,diary,matrix';

List<HomeBlock> parseHomeLayout(String? raw) {
  final known = homeSectionIds.toSet();
  final result = <HomeBlock>[];
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
    result.add(HomeBlock(id, !hidden));
  }
  for (final id in homeSectionIds) {
    if (seen.add(id)) {
      result.add(HomeBlock(id, true));
    }
  }
  return result;
}

String encodeHomeLayout(List<HomeBlock> blocks) {
  return blocks.map((block) => block.visible ? block.id : '-${block.id}').join(',');
}
