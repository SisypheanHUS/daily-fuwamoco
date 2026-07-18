import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/greeting/ui/greeting_screen.dart';
import 'features/home/ui/home_screen.dart';
import 'features/settings/ui/settings_screen.dart';

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
      GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Daily FUWAMOCO',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}
