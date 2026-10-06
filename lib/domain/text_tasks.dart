import 'date_phrase.dart';

class TextTaskDraft {
  const TextTaskDraft({
    required this.title,
    this.due,
    this.hasTime = false,
    this.priority = 0,
  });

  final String title;
  final DateTime? due;
  final bool hasTime;
  final int priority;
}

/// Splits pasted text into task drafts.
///
/// A line break means one task per non-empty line. A single paragraph with no
/// line breaks splits on sentence boundaries. Japanese date phrases, times,
/// and priority words are pulled out of each piece.
List<TextTaskDraft> splitTextTasks(String raw, {DateTime? now}) {
  final pieces = _pieces(raw);
  return [
    for (final piece in pieces) _draft(piece, now: now),
  ];
}

List<String> _pieces(String raw) {
  final text = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').trim();
  if (text.isEmpty) {
    return const [];
  }
  if (text.contains('\n')) {
    return [
      for (final line in text.split('\n'))
        if (line.trim().isNotEmpty) line.trim(),
    ];
  }
  final sentences = text
      .split(RegExp(r'(?<=[。！？!?])\s*'))
      .map((part) => part.trim().replaceFirst(RegExp(r'[。！？!?]+$'), '').trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (sentences.length <= 1) {
    return [text];
  }
  return sentences;
}

TextTaskDraft _draft(String piece, {DateTime? now}) {
  final priority = _takePriority(piece);
  final parsed = parseQuickAdd(priority.rest, now: now);
  final title = parsed.title.trim().isEmpty ? piece.trim() : parsed.title;
  return TextTaskDraft(
    title: title,
    due: parsed.due,
    hasTime: parsed.hasTime,
    priority: priority.level,
  );
}

class _PriorityHit {
  const _PriorityHit(this.level, this.rest);
  final int level;
  final String rest;
}

_PriorityHit _takePriority(String input) {
  final rules = <(RegExp, int)>[
    (RegExp(r'優先度\s*[:：]?\s*高'), 3),
    (RegExp(r'優先度\s*[:：]?\s*中'), 2),
    (RegExp(r'優先度\s*[:：]?\s*低'), 1),
    (RegExp(r'優先高'), 3),
    (RegExp(r'優先中'), 2),
    (RegExp(r'優先低'), 1),
    (RegExp(r'(^|[\s、,])高(?=$|[\s、,])'), 3),
    (RegExp(r'(^|[\s、,])中(?=$|[\s、,])'), 2),
    (RegExp(r'(^|[\s、,])低(?=$|[\s、,])'), 1),
    (RegExp(r'\bhigh\b', caseSensitive: false), 3),
    (RegExp(r'\bmedium\b', caseSensitive: false), 2),
    (RegExp(r'\blow\b', caseSensitive: false), 1),
    (RegExp('높음'), 3),
    (RegExp('중간'), 2),
    (RegExp('낮음'), 1),
  ];
  for (final rule in rules) {
    final match = rule.$1.firstMatch(input);
    if (match == null) {
      continue;
    }
    final rest = input.replaceRange(match.start, match.end, ' ');
    return _PriorityHit(rule.$2, rest.replaceAll(RegExp(r'\s+'), ' ').trim());
  }
  return _PriorityHit(0, input);
}
