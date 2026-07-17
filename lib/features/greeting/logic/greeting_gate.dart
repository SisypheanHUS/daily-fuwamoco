import 'package:shared_preferences/shared_preferences.dart';

/// Decides whether the morning sequence runs, using two-phase flags (PRD §5, §8).
///
/// - `greeting_started` is persisted the moment the sequence begins, so a user
///   who kills the app mid-animation is treated as already greeted (option (b)
///   from PRD §8.2 — no loops).
/// - Comparison is `todayKey > startedKey`, not `!=`, so setting the device
///   clock back never re-triggers (PRD §8.1).
class GreetingGate {
  GreetingGate(this._prefs);

  static const kStarted = 'greeting_started';
  static const kCompleted = 'greeting_completed';

  final SharedPreferences _prefs;

  bool shouldGreetToday(String todayKey, {required bool enabled}) {
    if (!enabled) return false;
    final started = _prefs.getString(kStarted);
    return shouldGreet(todayKey: todayKey, startedKey: started);
  }

  /// Pure decision — kept separate so it's trivially testable.
  static bool shouldGreet({required String todayKey, String? startedKey}) {
    if (startedKey == null) return true;
    return todayKey.compareTo(startedKey) > 0;
  }

  Future<void> markStarted(String todayKey) =>
      _prefs.setString(kStarted, todayKey);

  Future<void> markCompleted(String todayKey) =>
      _prefs.setString(kCompleted, todayKey);
}
