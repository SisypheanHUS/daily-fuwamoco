import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/json_list_store.dart';
import 'notification_item.dart';

class NotificationRepository {
  NotificationRepository(this._prefs);

  static const _key = 'notifications';
  static const _maxItems = 50;
  static const kLastNotifiedStreak = 'notifications_last_seen_streak';

  final SharedPreferences _prefs;

  /// Highest streak value a milestone notification has already fired for —
  /// lets `main()` fire at most once per threshold crossed, not once per app
  /// open while the streak sits above it.
  int lastNotifiedStreak() => _prefs.getInt(kLastNotifiedStreak) ?? 0;

  Future<void> setLastNotifiedStreak(int value) =>
      _prefs.setInt(kLastNotifiedStreak, value);

  List<NotificationItem> loadAll() {
    final items = readJsonList(
      _prefs,
      _key,
    ).map(NotificationItem.fromJson).toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // newest first
    return items;
  }

  Future<void> _saveAll(List<NotificationItem> items) =>
      writeJsonList(_prefs, _key, items.map((n) => n.toJson()).toList());

  Future<void> add(NotificationItem item) async {
    final all = [item, ...loadAll()];
    if (all.length > _maxItems) all.removeRange(_maxItems, all.length);
    await _saveAll(all);
  }

  Future<void> markAllRead() =>
      _saveAll(loadAll().map((n) => n.copyWith(read: true)).toList());

  Future<void> clearAll() => _saveAll(const []);
}
