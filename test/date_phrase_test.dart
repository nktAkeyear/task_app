import 'package:flutter_test/flutter_test.dart';
import 'package:tas/domain/date_phrase.dart';

void main() {
  final thursday = DateTime(2026, 10, 1, 15);
  test('1 Oct 2026 is Thursday', () {
    expect(thursday.weekday, DateTime.thursday);
  });

  test('今日, 明日, and 来週', () {
    final today = parseQuickAdd('牛乳を買う 今日', now: thursday);
    expect(today.title, '牛乳を買う');
    expect(today.due, DateTime(2026, 10, 1));
    expect(today.hasTime, isFalse);

    final tomorrow = parseQuickAdd('会議 明日 10時', now: thursday);
    expect(tomorrow.title, '会議');
    expect(tomorrow.due, DateTime(2026, 10, 2, 10));
    expect(tomorrow.hasTime, isTrue);

    final nextWeek = parseQuickAdd('報告書 来週', now: thursday);
    expect(nextWeek.title, '報告書');
    expect(nextWeek.due, DateTime(2026, 10, 8));
    expect(nextWeek.hasTime, isFalse);
  });

  test('weekdays and 来週の月曜', () {
    final friday = parseQuickAdd('定例 金曜', now: thursday);
    expect(friday.title, '定例');
    expect(friday.due, DateTime(2026, 10, 2));

    final monday = parseQuickAdd('定例 来週の月曜', now: thursday);
    expect(monday.due, DateTime(2026, 10, 5));

    final sameDay = parseQuickAdd('振返 木曜日', now: thursday);
    expect(sameDay.due, DateTime(2026, 10, 1));

    final thisMonday = parseQuickAdd('議事 今週の月曜', now: thursday);
    expect(thisMonday.due, DateTime(2026, 9, 28));
  });

  test('month day rolls into next year when it has passed', () {
    expect(parseQuickAdd('歯科 3月5日', now: thursday).due, DateTime(2027, 3, 5));
    expect(parseQuickAdd('歯科 10月20日', now: thursday).due, DateTime(2026, 10, 20));
    expect(parseQuickAdd('記念 2024年2月29日', now: thursday).due, DateTime(2024, 2, 29));
  });

  test('times, including 午後 and a clock that already passed', () {
    final morning = DateTime(2026, 10, 1, 8);
    expect(parseQuickAdd('朝会 9時30分', now: morning).due, DateTime(2026, 10, 1, 9, 30));
    expect(parseQuickAdd('朝会 9時30分', now: thursday).due, DateTime(2026, 10, 2, 9, 30));
    expect(parseQuickAdd('昼 午後1時', now: morning).due, DateTime(2026, 10, 1, 13));
    expect(parseQuickAdd('夜 18:30', now: morning).due, DateTime(2026, 10, 1, 18, 30));
    expect(parseQuickAdd('深夜 午前12時', now: morning).due, DateTime(2026, 10, 2, 0));
  });

  test('leading の prefix and plain titles', () {
    final prefixed = parseQuickAdd('今日の買い物', now: thursday);
    expect(prefixed.title, '買い物');
    expect(prefixed.due, DateTime(2026, 10, 1));

    final plain = parseQuickAdd('振り返り', now: thursday);
    expect(plain.title, '振り返り');
    expect(plain.due, isNull);

    expect(parseQuickAdd('今日', now: thursday).title, '無題');
    expect(parseQuickAdd('   ', now: thursday).title, isEmpty);
    expect(parseQuickAdd('明後日に会う', now: thursday).due, isNull);
  });
}
