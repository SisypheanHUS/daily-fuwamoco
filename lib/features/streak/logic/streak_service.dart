import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers.dart';
import '../../../core/utils/local_date.dart';

/// Streak = consecutive days the app was opened (v1 decision, PRD §11.1).
/// Runs once per launch, before the UI, so home and greeting read a settled value.
class StreakService {
  StreakService(this._prefs);

  static const kStreakCount = 'streak_count';
  static const kLastOpenDate = 'streak_last_open_date';

  final SharedPreferences _prefs;

  int get current => _prefs.getInt(kStreakCount) ?? 0;

  void recordAppOpen(String todayKey) {
    final last = _prefs.getString(kLastOpenDate);
    final next = nextStreak(
      todayKey: todayKey,
      lastOpenKey: last,
      current: current,
    );
    _prefs.setInt(kStreakCount, next);
    _prefs.setString(kLastOpenDate, todayKey);
  }

  /// Pure streak rule: same day keeps it, yesterday extends it,
  /// anything else (gap or clock weirdness) resets to 1.
  static int nextStreak({
    required String todayKey,
    String? lastOpenKey,
    required int current,
  }) {
    if (lastOpenKey == todayKey) return current == 0 ? 1 : current;
    if (lastOpenKey != null && previousDateKey(todayKey) == lastOpenKey) {
      return current + 1;
    }
    return 1;
  }
}

final streakProvider = Provider<int>(
  (ref) => StreakService(ref.watch(sharedPreferencesProvider)).current,
);
