import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/core/utils/local_date.dart';
import 'package:daily_ruffian/features/notifications/data/notification_repository.dart';
import 'package:daily_ruffian/main.dart';

void main() {
  // Widget tests pump AppRoot with an already-computed initialLocation —
  // bootstrapApp only ever runs inside real main() or a reset, so it needs
  // to be driven directly here to cover the streak/milestone/notification
  // wiring at all.

  test('crossing a milestone on boot fires exactly one notification and '
      'records the threshold', () async {
    final todayKey = localDateKey(DateTime.now());
    SharedPreferences.setMockInitialValues({
      'streak_count': 6,
      'streak_last_open_date': previousDateKey(todayKey),
    });
    final prefs = await SharedPreferences.getInstance();

    await bootstrapApp(prefs);

    expect(prefs.getInt('streak_count'), 7);

    final notifRepo = NotificationRepository(prefs);
    expect(notifRepo.lastNotifiedStreak(), 7);
    final items = notifRepo.loadAll();
    expect(items, hasLength(1));
    expect(items.single.message, contains('7-day streak'));
    expect(items.single.read, isFalse);
  });

  test('sitting above an already-notified threshold does not re-fire',
      () async {
    final todayKey = localDateKey(DateTime.now());
    SharedPreferences.setMockInitialValues({
      'streak_count': 10,
      'streak_last_open_date': previousDateKey(todayKey),
      'notifications_last_seen_streak': 7,
    });
    final prefs = await SharedPreferences.getInstance();

    await bootstrapApp(prefs);

    expect(prefs.getInt('streak_count'), 11);
    expect(NotificationRepository(prefs).loadAll(), isEmpty);
  });
}
