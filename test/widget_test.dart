import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/app.dart';
import 'package:daily_ruffian/core/providers.dart';

void main() {
  testWidgets('home screen renders streak, quote and next stream sections',
      (tester) async {
    SharedPreferences.setMockInitialValues({'streak_count': 3});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const DailyRuffianApp(initialLocation: '/home'),
      ),
    );
    await tester.pump();

    expect(find.text('Daily FUWAMOCO'), findsOneWidget);
    expect(find.text('3 day streak'), findsOneWidget);
    expect(find.text('QUOTE OF THE DAY'), findsOneWidget);
    expect(find.text('NEXT STREAM'), findsOneWidget);
  });

  testWidgets('greeting screen shows the morning text and can be skipped',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const DailyRuffianApp(initialLocation: '/greeting'),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Good Morning,\nRuffian.'), findsOneWidget);
    // starting the sequence must persist the started flag immediately
    expect(prefs.getString('greeting_started'), isNotNull);

    await tester.tap(find.text('Good Morning,\nRuffian.'));
    // pumpAndSettle would hang forever: the home screen's mascot breathes
    // in an infinite repeat(reverse: true) loop by design, so it never
    // "settles". Pump a bounded duration for the route transition instead.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Daily FUWAMOCO'), findsOneWidget); // home
    expect(prefs.getString('greeting_completed'), isNotNull);
  });
}
