import 'package:flutter_test/flutter_test.dart';
import 'package:tas/domain/hlc.dart';
import 'package:tas/sync/protocol.dart';

Hlc hlc(int physical, String device, [int logical = 0]) => Hlc(physical, logical, device);

FieldValue field(Object? value, Hlc clock) => FieldValue(value, clock);

SyncEntity task(String id, Map<String, FieldValue> fields, {Hlc? deleted}) {
  return SyncEntity(type: entityTask, id: id, fields: fields, deletedHlc: deleted);
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

  test('delete wins when its wall clock is greater or equal, even against a higher device id', () {
    final newerDelete = mergeEntities(
      task('1', {'title': field('残す', hlc(10, 'zzz'))}),
      task('1', const {}, deleted: hlc(11, 'aaa')),
    );
    expect(newerDelete.isDeleted, isTrue);

    final tie = mergeEntities(
      task('1', {'title': field('残す', hlc(10, 'zzz'))}),
      task('1', const {}, deleted: hlc(10, 'aaa')),
    );
    expect(tie.isDeleted, isTrue);
    expect(tie.deletedHlc!.deviceId, 'aaa');
  });

  test('a strictly newer update resurrects a tombstone', () {
    final merged = mergeEntities(
      task('1', {'title': field('古い', hlc(10, 'aaa'))}, deleted: hlc(12, 'aaa')),
      task('1', {'title': field('復活', hlc(13, 'mmm'))}),
    );
    expect(merged.isDeleted, isFalse);
    expect(merged.fields['title']!.value, '復活');
    expect(merged.fields['notes'], isNull);
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
    expect(forward.isDeleted, isFalse);
  });
}
