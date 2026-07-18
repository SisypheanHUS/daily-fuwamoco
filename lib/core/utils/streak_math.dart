import 'local_date.dart';

/// Current streak computed from a full set of completed date-keys, walking
/// backward from today. Today doesn't have to be present yet — a streak
/// stays alive until a day is actually missed, not the moment the clock
/// rolls over. Distinct from [StreakService]'s incremental "given
/// yesterday's state, extend or reset" logic (that one tracks the app-level
/// open streak and is already tested); this is the general-purpose version
/// any per-habit or per-date-set streak needs, including Calendar's activity
/// aggregation.
int currentStreak(Set<String> completedDateKeys, String todayKey) {
  if (completedDateKeys.isEmpty) return 0;
  var cursor = completedDateKeys.contains(todayKey)
      ? todayKey
      : previousDateKey(todayKey);
  if (!completedDateKeys.contains(cursor)) return 0;
  var count = 0;
  while (completedDateKeys.contains(cursor)) {
    count++;
    cursor = previousDateKey(cursor);
  }
  return count;
}
