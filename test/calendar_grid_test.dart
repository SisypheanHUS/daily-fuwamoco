import 'package:flutter_test/flutter_test.dart';

import 'package:daily_ruffian/features/calendar/logic/calendar_grid.dart';

void main() {
  group('calendarGridDays', () {
    test('always returns a whole number of weeks', () {
      final days = calendarGridDays(DateTime(2026, 7));
      expect(days.length % 7, 0);
    });

    test('every day of the requested month is included exactly once', () {
      final days = calendarGridDays(DateTime(2026, 7));
      final julyDays = days.where((d) => d.month == 7 && d.year == 2026);
      expect(julyDays.length, 31); // July has 31 days
      expect(julyDays.map((d) => d.day).toSet(), {for (var i = 1; i <= 31; i++) i});
    });

    test('the grid starts on a Sunday', () {
      final days = calendarGridDays(DateTime(2026, 7));
      expect(days.first.weekday % 7, 0); // Dart: Sunday == 7, %7 == 0
    });

    test('the grid ends on a Saturday', () {
      final days = calendarGridDays(DateTime(2026, 7));
      expect(days.last.weekday, DateTime.saturday);
    });

    test('a month that already starts on Sunday needs no leading days', () {
      // November 2026 starts on a Sunday.
      final days = calendarGridDays(DateTime(2026, 11));
      expect(days.first, DateTime(2026, 11, 1));
    });

    test('handles a December -> January year rollover', () {
      final days = calendarGridDays(DateTime(2026, 12));
      final decDays = days.where((d) => d.month == 12 && d.year == 2026);
      expect(decDays.length, 31);
      // trailing days, if any, roll into January 2027
      final trailing = days.where((d) => d.year == 2027);
      for (final d in trailing) {
        expect(d.month, 1);
      }
    });
  });
}
