import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'page_transition_effect.dart';

/// Persistent bottom nav for the 4 primary destinations (Home / Rituals /
/// Calendar / Settings). Collection and Notifications are deliberately not
/// tabs here — they're reached from a Home card and the app-bar bell icon
/// respectively, keeping the bar itself to 4 items.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // goBranch swaps an IndexedStack — it never fires a Navigator
          // push, so PageTransitionObserver can't see it. Pulse manually.
          if (index != navigationShell.currentIndex) {
            pulsePageTransitionEffect();
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.spa_rounded),
            label: 'Rituals',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
