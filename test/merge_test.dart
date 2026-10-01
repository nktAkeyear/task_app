import 'package:flutter_test/flutter_test.dart';
import 'package:tas/domain/hlc.dart';
import 'package:tas/sync/protocol.dart';

Hlc hlc(int physical, String device, [int logical = 0]) => Hlc(physical, logical, device);

FieldValue field(Object? value, Hlc clock) => FieldValue(value, clock);

SyncEntity task(String id, Map<String, FieldValue> fields, {Hlc? deleted, Hlc? restored}) {
  return SyncEntity(
    type: entityTask,
    id: id,
    fields: fields,
    deletedHlc: deleted,
    restoredHlc: restored,
  );
}

void main() {
  test('non-overlapping fields merge', () {
    final merged = mergeEntities(
      task('1', {'title': field('買う', hlc(10, 'aaa'))}),
      task('1', {'notes': field('牛乳', hlc(11, 'zzz'))}),
    );
    expect(merged.fields['title']!.value, '買う');
    expect(merged.fields['notes']!.value, '牛乳');
    expect(merged.isDeleted, isFalse);
  });

  test('higher field clock wins, then higher device id', () {
    final newer = mergeEntities(
      task('1', {'title': field('A', hlc(10, 'zzz'))}),
      task('1', {'title': field('B', hlc(11, 'aaa'))}),
    );
    expect(newer.fields['title']!.value, 'B');

    final tie = mergeEntities(
      task('1', {'title': field('A', hlc(10, 'aaa'))}),
      task('1', {'title': field('B', hlc(10, 'zzz'))}),
    );
    expect(tie.fields['title']!.value, 'B');
  });

  test('a delete and a field edit both remain', () {
    final newerField = mergeEntities(
      task('1', {'title': field('残す', hlc(11, 'zzz'))}),
      task('1', const {}, deleted: hlc(10, 'aaa')),
    );
    expect(newerField.isDeleted, isTrue);
    expect(newerField.deletedHlc, hlc(10, 'aaa'));
    expect(newerField.fields['title']!.value, '残す');

    final newerDelete = mergeEntities(
      task('1', {'title': field('残す', hlc(10, 'zzz'))}),
      task('1', const {}, deleted: hlc(11, 'aaa')),
    );
    expect(newerDelete.isDeleted, isTrue);
    expect(newerDelete.fields['title']!.value, '残す');
    expect(newerDelete.deletedHlc!.deviceId, 'aaa');
  });

  test('a newer field edit does not clear the tombstone', () {
    final merged = mergeEntities(
      task('1', {'title': field('古い', hlc(10, 'aaa')), 'notes': field('メモ', hlc(9, 'aaa'))}, deleted: hlc(12, 'aaa')),
      task('1', {'title': field('更新', hlc(13, 'mmm'))}),
    );
    expect(merged.isDeleted, isTrue);
    expect(merged.deletedHlc, hlc(12, 'aaa'));
    expect(merged.fields['title']!.value, '更新');
    expect(merged.fields['notes']!.value, 'メモ');
  });

  test('an explicit newer restore clears the tombstone and keeps fields', () {
    final merged = mergeEntities(
      task('1', {'title': field('更新', hlc(13, 'mmm'))}, deleted: hlc(12, 'aaa')),
      task('1', {'notes': field('メモ', hlc(11, 'bbb'))}, restored: hlc(14, 'aaa')),
    );
    expect(merged.isDeleted, isFalse);
    expect(merged.deletedHlc, isNull);
    expect(merged.restoredHlc, hlc(14, 'aaa'));
    expect(merged.fields['title']!.value, '更新');
    expect(merged.fields['notes']!.value, 'メモ');

    final notNewer = mergeEntities(
      task('1', {'title': field('A', hlc(1, 'aaa'))}, deleted: hlc(10, 'zzz')),
      task('1', const {}, restored: hlc(10, 'aaa')),
    );
    expect(notNewer.isDeleted, isTrue);
    expect(notNewer.deletedHlc, hlc(10, 'zzz'));
    expect(notNewer.fields['title']!.value, 'A');
  });

  test('equal delete clocks keep the higher device id and stay deleted', () {
    final merged = mergeEntities(
      task('1', const {}, deleted: hlc(8, 'aaa')),
      task('1', const {}, deleted: hlc(8, 'zzz')),
    );
    expect(merged.isDeleted, isTrue);
    expect(merged.deletedHlc!.deviceId, 'zzz');
  });

  test('merge is order independent for a delete and a newer field', () {
    final left = task('1', {'title': field('A', hlc(5, 'aaa'))}, deleted: hlc(4, 'bbb'));
    final right = task('1', {'notes': field('B', hlc(3, 'ccc'))});
    final forward = mergeEntities(left, right);
    final backward = mergeEntities(right, left);
    expect(forward.isDeleted, backward.isDeleted);
    expect(forward.fields['title']!.value, backward.fields['title']!.value);
    expect(forward.fields['notes']!.value, 'B');
    expect(forward.isDeleted, isTrue);
    expect(forward.deletedHlc, hlc(4, 'bbb'));
  });
}
