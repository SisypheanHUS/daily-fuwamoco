import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/calendar/ui/calendar_screen.dart';
import 'features/greeting/ui/greeting_screen.dart';
import 'features/habits/ui/habit_tracker_screen.dart';
import 'features/home/ui/home_screen.dart';
import 'features/notifications/ui/notifications_screen.dart';
import 'features/reflection/ui/evening_reflection_screen.dart';
import 'features/reflection/ui/morning_checkin_screen.dart';
import 'features/settings/ui/settings_screen.dart';
import 'shared/widgets/app_shell.dart';

class DailyRuffianApp extends StatefulWidget {
  const DailyRuffianApp({super.key, required this.initialLocation});

  final String initialLocation;

  @override
  State<DailyRuffianApp> createState() => _DailyRuffianAppState();
}

class _DailyRuffianAppState extends State<DailyRuffianApp> {
  // Created once — building a new GoRouter on every rebuild would remount the
  // current screen and reset navigation + animation state.
  late final GoRouter _router = GoRouter(
    initialLocation: widget.initialLocation,
    routes: [
      GoRoute(path: '/greeting', builder: (_, _) => const GreetingScreen()),
      GoRoute(
        path: '/checkin/morning',
        builder: (_, _) => const MorningCheckinScreen(),
      ),
      GoRoute(
        path: '/checkin/evening',
        builder: (_, _) => const EveningReflectionScreen(),
      ),
      GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (_, _) => const HomeScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/habits', builder: (_, _) => const HabitTrackerScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/calendar', builder: (_, _) => const CalendarScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen())],
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daily FUWAMOCO',
      theme: AppTheme.light,
      // The brief is explicitly light/cream-only ("avoid dark UI") — without
      // pinning this, MaterialApp defaults to ThemeMode.system and silently
      // falls back to the old near-black palette on any device set to dark
      // mode, which is exactly what this redesign moved away from.
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
