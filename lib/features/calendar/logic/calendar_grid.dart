/// Complete calendar weeks (multiples of 7) covering [month], including the
/// faded leading/trailing days from adjacent months — pulled out as a pure
/// function so the grid math is testable without pumping the widget.
List<DateTime> calendarGridDays(DateTime month) {
  final firstOfMonth = DateTime(month.year, month.month, 1);
  final firstWeekday = firstOfMonth.weekday % 7; // Dart Mon=1..Sun=7 -> Sun=0
  final gridStart = firstOfMonth.subtract(Duration(days: firstWeekday));

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final lastOfMonth = DateTime(month.year, month.month, daysInMonth);
  final lastWeekday = lastOfMonth.weekday % 7;
  final gridEnd = lastOfMonth.add(Duration(days: 6 - lastWeekday));

  return [
    for (var d = gridStart; !d.isAfter(gridEnd); d = d.add(const Duration(days: 1)))
      d,
  ];
}
