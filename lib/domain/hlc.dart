/// Hybrid logical clock.
///
/// Ordering for ordinary field writes is (physical, logical, deviceId).
/// Delete-versus-update conflicts compare physical and logical only; device id
/// is the tie-break after that, and only when both sides are the same kind.
class Hlc implements Comparable<Hlc> {
  const Hlc(this.physical, this.logical, this.deviceId);

  final int physical;
  final int logical;
  final String deviceId;

  /// Physical time, then logical counter. Device id is ignored.
  int compareWall(Hlc other) {
    final byPhysical = physical.compareTo(other.physical);
    if (byPhysical != 0) {
      return byPhysical;
    }
    return logical.compareTo(other.logical);
  }

  @override
  int compareTo(Hlc other) {
    final wall = compareWall(other);
    if (wall != 0) {
      return wall;
    }
    return deviceId.compareTo(other.deviceId);
  }

  bool operator >(Hlc other) => compareTo(other) > 0;

  String encode() => '$physical:$logical:$deviceId';

  static Hlc parse(String raw) {
    final first = raw.indexOf(':');
    final second = first < 0 ? -1 : raw.indexOf(':', first + 1);
    if (first <= 0 || second <= first) {
      throw FormatException('Invalid HLC: $raw');
    }
    return Hlc(
      int.parse(raw.substring(0, first)),
      int.parse(raw.substring(first + 1, second)),
      raw.substring(second + 1),
    );
  }

  Map<String, Object?> toJson() => {
    'p': physical,
    'l': logical,
    'd': deviceId,
  };

  factory Hlc.fromJson(Map<String, Object?> json) {
    return Hlc(
      (json['p'] as num).toInt(),
      (json['l'] as num).toInt(),
      json['d']! as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Hlc &&
      other.physical == physical &&
      other.logical == logical &&
      other.deviceId == deviceId;

  @override
  int get hashCode => Object.hash(physical, logical, deviceId);

  @override
  String toString() => encode();
}

/// Monotonic HLC generator for one device.
class HlcClock {
  HlcClock(this.deviceId, {Hlc? last, DateTime Function()? now}) : _now = now ?? DateTime.now {
    _last = last;
  }

  final String deviceId;
  final DateTime Function() _now;
  Hlc? _last;

  Hlc? get last => _last;

  Hlc tick() {
    final physical = _now().millisecondsSinceEpoch;
    final prev = _last;
    final next = prev == null || physical > prev.physical
        ? Hlc(physical, 0, deviceId)
        : Hlc(prev.physical, prev.logical + 1, deviceId);
    _last = next;
    return next;
  }

  /// Advance the local clock so later local writes happen after [remote].
  void observe(Hlc remote) {
    final now = _now().millisecondsSinceEpoch;
    final localP = _last?.physical ?? 0;
    final localC = _last?.logical ?? -1;
    final nextP = _max3(localP, remote.physical, now);
    final int nextC;
    if (nextP == localP && nextP == remote.physical) {
      final higher = localC > remote.logical ? localC : remote.logical;
      nextC = higher + 1;
    } else if (nextP == localP) {
      nextC = localC + 1;
    } else if (nextP == remote.physical) {
      nextC = remote.logical + 1;
    } else {
      nextC = 0;
    }
    _last = Hlc(nextP, nextC, deviceId);
  }
}

int _max3(int a, int b, int c) {
  final ab = a > b ? a : b;
  return ab > c ? ab : c;
}
