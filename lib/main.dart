import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers.dart';
import 'core/utils/id_generator.dart';
import 'core/utils/local_date.dart';
import 'features/greeting/logic/greeting_gate.dart';
import 'features/notifications/data/notification_item.dart';
import 'features/notifications/data/notification_repository.dart';
import 'features/notifications/logic/milestone_trigger.dart';
import 'features/settings/logic/settings_controller.dart';
import 'features/streak/logic/streak_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final todayKey = localDateKey(DateTime.now());
  StreakService(prefs).recordAppOpen(todayKey);

  await _maybeFireMilestoneNotification(prefs);

  final gate = GreetingGate(prefs);
  final greetingEnabled =
      prefs.getBool(SettingsController.kGreetingEnabled) ?? true;
  final shouldGreet = gate.shouldGreetToday(todayKey, enabled: greetingEnabled);

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: DailyRuffianApp(initialLocation: shouldGreet ? '/greeting' : '/home'),
    ),
  );
}

/// The single v1 trigger for Notifications (and, indirectly, Collection's
/// milestone charms) — a streak crossing 7/30/100 days. Runs once per app
/// open, right after the streak itself updates, so it always sees the
/// freshest value.
Future<void> _maybeFireMilestoneNotification(SharedPreferences prefs) async {
  final notifRepo = NotificationRepository(prefs);
  final currentStreak = StreakService(prefs).current;
  final crossed = milestoneCrossed(
    lastNotifiedStreak: notifRepo.lastNotifiedStreak(),
    currentStreak: currentStreak,
  );
  if (crossed == null) return;

  await notifRepo.add(NotificationItem(
    id: generateLocalId(),
    avatarColorKey: 'pink',
    message:
        "You just reached a $crossed-day streak — a little charm is waiting in your Collection",
    timestamp: DateTime.now().toIso8601String(),
  ));
  await notifRepo.setLastNotifiedStreak(currentStreak);
}
