import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/features/greeting/logic/greeting_gate.dart';

void main() {
  group('GreetingGate.shouldGreet', () {
    test('greets on first ever launch', () {
      expect(
        GreetingGate.shouldGreet(todayKey: '2026-07-17', startedKey: null),
        isTrue,
      );
    });

    test('does not greet twice on the same day', () {
      expect(
        GreetingGate.shouldGreet(
            todayKey: '2026-07-17', startedKey: '2026-07-17'),
        isFalse,
      );
    });

    test('greets again on the next day', () {
      expect(
        GreetingGate.shouldGreet(
            todayKey: '2026-07-18', startedKey: '2026-07-17'),
        isTrue,
      );
    });

    test('setting the clock back never re-triggers', () {
      expect(
        GreetingGate.shouldGreet(
            todayKey: '2026-07-16', startedKey: '2026-07-17'),
        isFalse,
      );
    });

    test('crossing a month/year boundary still compares correctly', () {
      expect(
        GreetingGate.shouldGreet(
            todayKey: '2027-01-01', startedKey: '2026-12-31'),
        isTrue,
      );
    });
  });
}
