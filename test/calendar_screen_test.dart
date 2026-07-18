import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/core/providers.dart';
import 'package:daily_ruffian/core/utils/local_date.dart';
import 'package:daily_ruffian/features/calendar/ui/calendar_screen.dart';
import 'package:daily_ruffian/features/habits/data/habit.dart';
import 'package:daily_ruffian/features/habits/logic/habit_providers.dart';

void main() {
  // The month grid alone fills a typical test surface — the detail card
  // below it is off-screen and (like any Sliver-backed ListView, `.builder`
  // or not) simply isn't mounted until scrolled into view. Real phones are
  // tall enough this rarely matters; the test still has to scroll for it.

  testWidgets('shows "no rituals" for today when nothing is completed yet',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.text('No rituals completed this day.'), findsOneWidget);
  });

  testWidgets(
      "a habit completed today shows up in today's detail list",
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final todayKey = localDateKey(DateTime.now());
    await container.read(habitRepositoryProvider).add(Habit(
          id: '1',
          title: 'Drink water',
          timeOfDay: HabitTimeOfDay.morning,
          colorKey: 'blue',
          completedDateKeys: {todayKey},
        ));
    container.invalidate(habitsProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pump();

    expect(find.text('No rituals completed this day.'), findsNothing);
    expect(find.text('Drink water'), findsOneWidget);
  });
}
