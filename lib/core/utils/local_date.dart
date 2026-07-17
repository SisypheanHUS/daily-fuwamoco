/// Calendar-day helpers. Days are always compared as ISO `yyyy-MM-dd` strings
/// in the device's local time — string order equals date order, and a `>`
/// comparison means "clock moved to a later day" (setting the clock back never
/// re-triggers anything, per PRD §8.1).
library;

String localDateKey(DateTime now) {
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '${now.year}-$m-$d';
}

String previousDateKey(String dateKey) {
  final date = DateTime.parse(dateKey).subtract(const Duration(days: 1));
  return localDateKey(date);
}

/// Stable across runs and platforms (unlike String.hashCode), so
/// "content of the day" picks stay deterministic. PRD §6.5.
int stableHash(String input) {
  var hash = 0;
  for (final unit in input.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}
