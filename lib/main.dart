import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/utils/local_date.dart';
import 'features/greeting/logic/greeting_gate.dart';
import 'features/settings/logic/settings_controller.dart';
import 'features/streak/logic/streak_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final todayKey = localDateKey(DateTime.now());
  StreakService(prefs).recordAppOpen(todayKey);

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
