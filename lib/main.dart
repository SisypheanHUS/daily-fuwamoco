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
  final initialLocation = await _bootstrap(prefs);
  runApp(AppRoot(prefs: prefs, initialLocation: initialLocation));
}

/// The once-per-open boot sequence: records the app open, fires a milestone
/// notification if a streak threshold was just crossed, then decides where
/// to land. Extracted so [AppRoot]'s "Reset my data" flow can re-run exactly
/// this after clearing prefs, producing real fresh-install state instead of
/// a hand-maintained list of providers to invalidate.
Future<String> _bootstrap(SharedPreferences prefs) async {
  final todayKey = localDateKey(DateTime.now());
  StreakService(prefs).recordAppOpen(todayKey);

  await _maybeFireMilestoneNotification(prefs);

  final gate = GreetingGate(prefs);
  final greetingEnabled =
      prefs.getBool(SettingsController.kGreetingEnabled) ?? true;
  final shouldGreet = gate.shouldGreetToday(todayKey, enabled: greetingEnabled);
  return shouldGreet ? '/greeting' : '/home';
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

/// Owns the [ProviderScope]'s identity so a full data reset can remount it
/// with a fresh key — every provider underneath gets torn down and rebuilt
/// against the now-cleared prefs, the same guarantee a real relaunch gives.
class AppRoot extends StatefulWidget {
  const AppRoot({super.key, required this.prefs, required this.initialLocation});

  final SharedPreferences prefs;
  final String initialLocation;

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  Key _scopeKey = UniqueKey();
  late String _initialLocation = widget.initialLocation;

  Future<void> _resetAndRestart() async {
    await widget.prefs.clear();
    final location = await _bootstrap(widget.prefs);
    setState(() {
      _initialLocation = location;
      _scopeKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: _scopeKey,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(widget.prefs),
        appResetProvider.overrideWithValue(_resetAndRestart),
      ],
      child: DailyRuffianApp(initialLocation: _initialLocation),
    );
  }
}
