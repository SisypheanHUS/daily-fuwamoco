import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/core/utils/streak_math.dart';

void main() {
  group('currentStreak', () {
    test('empty set has no streak', () {
      expect(currentStreak({}, '2026-07-17'), 0);
    });

    test('today done, consecutive days before it', () {
      final dates = {'2026-07-15', '2026-07-16', '2026-07-17'};
      expect(currentStreak(dates, '2026-07-17'), 3);
    });

    test('today not done yet, but yesterday was — streak stays alive', () {
      final dates = {'2026-07-15', '2026-07-16'};
      expect(currentStreak(dates, '2026-07-17'), 2);
    });

    test('a day was skipped in the middle — streak stops there', () {
      final dates = {'2026-07-10', '2026-07-16', '2026-07-17'};
      expect(currentStreak(dates, '2026-07-17'), 2);
    });

    test('neither today nor yesterday done — streak is broken', () {
      final dates = {'2026-07-10'};
      expect(currentStreak(dates, '2026-07-17'), 0);
    });

    test('streak extends correctly across a month boundary', () {
      final dates = {'2026-07-31', '2026-08-01'};
      expect(currentStreak(dates, '2026-08-01'), 2);
    });
  });
}
