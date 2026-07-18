import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/features/habits/data/habit.dart';
import 'package:daily_ruffian/features/notifications/data/notification_item.dart';
import 'package:daily_ruffian/main.dart';

void main() {
  testWidgets(
      'Reset my data clears prefs and remounts to fresh-install state',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'streak_count': 12,
      'streak_last_open_date': '2026-07-16',
      'settings_display_name': 'Ruffian',
      'greeting_completed': '2026-07-17',
      'habits': jsonEncode([
        const Habit(
          id: '1',
          title: 'Drink water',
          timeOfDay: HabitTimeOfDay.morning,
          colorKey: 'blue',
        ).toJson(),
      ]),
      'notifications': jsonEncode([
        const NotificationItem(
          id: '1',
          avatarColorKey: 'pink',
          message: 'Test notification',
          timestamp: '2026-07-17T08:00:00.000',
        ).toJson(),
      ]),
      'notifications_last_seen_streak': 7,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(AppRoot(prefs: prefs, initialLocation: '/home'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('12 day streak'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.dragUntilVisible(
      find.text('Reset my data'),
      find.byType(ListView),
      const Offset(0, -100),
    );
    await tester.pump();
    await tester.tap(find.text('Reset my data'));
    await tester.pump();
    expect(find.text('Reset my data?'), findsOneWidget);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    // Reset remounts the whole ProviderScope, which recomputes the greeting
    // gate against now-cleared flags — this lands back on the greeting, not
    // home, same as an actual first install would.
    await tester.pump(const Duration(milliseconds: 500));

    // Reset re-runs the same boot sequence a real relaunch would, so it
    // immediately records this as day 1 of a new streak rather than 0.
    expect(prefs.getInt('streak_count'), 1);
    expect(prefs.getString('settings_display_name'), isNull);
    expect(prefs.getString('habits'), isNull);
    expect(prefs.getString('notifications'), isNull);
    expect(prefs.getInt('notifications_last_seen_streak'), isNull);
    expect(find.text('Good Morning,\nRuffian.'), findsOneWidget);
  });
}
