import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/features/notifications/logic/milestone_trigger.dart';

void main() {
  group('milestoneCrossed', () {
    test('no notification below the first threshold', () {
      expect(milestoneCrossed(lastNotifiedStreak: 0, currentStreak: 6), isNull);
    });

    test('fires exactly on crossing 7', () {
      expect(milestoneCrossed(lastNotifiedStreak: 0, currentStreak: 7), 7);
    });

    test('does not re-fire while sitting above an already-notified threshold', () {
      expect(milestoneCrossed(lastNotifiedStreak: 7, currentStreak: 10), isNull);
    });

    test('fires again on crossing the next threshold', () {
      expect(milestoneCrossed(lastNotifiedStreak: 7, currentStreak: 30), 30);
    });

    test('skipping straight past a threshold still fires the highest crossed', () {
      // e.g. streak data restored/edited externally, jumping from 5 to 35
      expect(milestoneCrossed(lastNotifiedStreak: 5, currentStreak: 35), 30);
    });

    test('reaching the final threshold fires once and never again', () {
      expect(milestoneCrossed(lastNotifiedStreak: 30, currentStreak: 100), 100);
      expect(milestoneCrossed(lastNotifiedStreak: 100, currentStreak: 150), isNull);
    });
  });
}
