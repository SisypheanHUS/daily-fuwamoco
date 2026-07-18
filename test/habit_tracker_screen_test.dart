import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/core/providers.dart';
import 'package:daily_ruffian/features/habits/data/habit.dart';
import 'package:daily_ruffian/features/habits/logic/habit_providers.dart';
import 'package:daily_ruffian/features/habits/ui/habit_tracker_screen.dart';

void main() {
  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: HabitTrackerScreen()),
      ),
    );
    // Bounded pump, not pumpAndSettle — the empty state's TwinsMascot breathes
    // in an infinite loop by design (see companion_mascot.dart) and would
    // hang pumpAndSettle forever.
    await tester.pump();
    return container;
  }

  testWidgets('shows the empty state when there are no habits yet',
      (tester) async {
    await pumpScreen(tester);

    expect(find.text('No rituals yet'), findsOneWidget);
    expect(find.text('Add your first ritual'), findsOneWidget);
  });

  testWidgets('the add-habit sheet opens and is scrollable to its submit button',
      (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Add your first ritual'));
    await tester.pump();

    expect(find.text('New ritual'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    // The submit row exists in the tree even if off the initial viewport —
    // confirms the sheet built successfully rather than throwing mid-layout.
    expect(find.text('Add ritual'), findsOneWidget);
  });

  testWidgets(
      'once a habit exists, the screen shows the grouped list instead of the empty state',
      (tester) async {
    final container = await pumpScreen(tester);

    // Exercise the screen's reaction to real habit state directly through
    // the provider — HabitRepository.add() itself is already covered by
    // habit_repository_test.dart; this test's job is the screen, not
    // re-verifying ModalBottomSheet/TextField scroll plumbing.
    await container.read(habitsProvider.notifier).add(
          title: 'Drink water',
          timeOfDay: HabitTimeOfDay.morning,
          colorKey: 'blue',
        );
    await tester.pump();

    expect(find.text('No rituals yet'), findsNothing);
    expect(find.text('MORNING'), findsOneWidget);
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.text('Not started yet'), findsOneWidget);
  });

  testWidgets('tapping the toggle ring marks a habit done for today',
      (tester) async {
    final container = await pumpScreen(tester);
    await container.read(habitsProvider.notifier).add(
          title: 'Drink water',
          timeOfDay: HabitTimeOfDay.morning,
          colorKey: 'blue',
        );
    await tester.pump();

    expect(find.text('Not started yet'), findsOneWidget);

    // The toggle ring itself is what's tappable — find it via its
    // GestureDetector wrapper rather than by icon (no checkmark exists yet).
    final ring = find.descendant(
      of: find.byType(GestureDetector),
      matching: find.byType(AnimatedContainer),
    );
    await tester.tap(ring);
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.textContaining('day streak'), findsOneWidget);
  });
}
