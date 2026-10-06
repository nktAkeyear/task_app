import 'package:flutter_test/flutter_test.dart';
import 'package:tas/domain/text_tasks.dart';

void main() {
  test('lines become tasks and a paragraph splits on sentences', () {
    final lines = splitTextTasks(
      '資料を送る 今日 高\nいつか読む',
      now: DateTime(2026, 10, 1, 9),
    );
    expect(lines, hasLength(2));
    expect(lines[0].title, '資料を送る');
    expect(lines[0].due, DateTime(2026, 10, 1));
    expect(lines[0].hasTime, isFalse);
    expect(lines[0].priority, 3);
    expect(lines[1].title, 'いつか読む');
    expect(lines[1].due, isNull);

    final sentences = splitTextTasks(
      '明日 牛乳を買う。来週 レポートを出す。',
      now: DateTime(2026, 10, 1, 9),
    );
    expect(sentences, hasLength(2));
    expect(sentences[0].title, '牛乳を買う');
    expect(sentences[0].due, DateTime(2026, 10, 2));
    expect(sentences[1].title, 'レポートを出す');
    expect(sentences[1].due, isNotNull);
  });
}
