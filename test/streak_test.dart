import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/features/streak/logic/streak_service.dart';

void main() {
  group('StreakService.nextStreak', () {
    test('first open ever starts at 1', () {
      expect(
        StreakService.nextStreak(
            todayKey: '2026-07-17', lastOpenKey: null, current: 0),
        1,
      );
    });

    test('same day keeps the streak', () {
      expect(
        StreakService.nextStreak(
            todayKey: '2026-07-17', lastOpenKey: '2026-07-17', current: 5),
        5,
      );
    });

    test('consecutive day extends the streak', () {
      expect(
        StreakService.nextStreak(
            todayKey: '2026-07-18', lastOpenKey: '2026-07-17', current: 5),
        6,
      );
    });

    test('missed day resets to 1', () {
      expect(
        StreakService.nextStreak(
            todayKey: '2026-07-20', lastOpenKey: '2026-07-17', current: 5),
        1,
      );
    });

    test('extends across month boundary', () {
      expect(
        StreakService.nextStreak(
            todayKey: '2026-08-01', lastOpenKey: '2026-07-31', current: 2),
        3,
      );
    });
  });
}
