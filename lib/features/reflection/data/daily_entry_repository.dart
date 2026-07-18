import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/json_list_store.dart';
import 'daily_entry.dart';

class DailyEntryRepository {
  DailyEntryRepository(this._prefs);

  static const _key = 'daily_entries';

  final SharedPreferences _prefs;

  List<DailyEntry> loadAll() =>
      readJsonList(_prefs, _key).map(DailyEntry.fromJson).toList();

  Future<void> _saveAll(List<DailyEntry> entries) =>
      writeJsonList(_prefs, _key, entries.map((e) => e.toJson()).toList());

  DailyEntry entryFor(String dateKey) => loadAll().firstWhere(
    (e) => e.dateKey == dateKey,
    orElse: () => DailyEntry(dateKey: dateKey),
  );

  Future<void> _upsert(
    String dateKey,
    DailyEntry Function(DailyEntry) update,
  ) async {
    final all = loadAll();
    final index = all.indexWhere((e) => e.dateKey == dateKey);
    final base = index == -1 ? DailyEntry(dateKey: dateKey) : all[index];
    final updated = update(base);
    if (index == -1) {
      all.add(updated);
    } else {
      all[index] = updated;
    }
    await _saveAll(all);
  }

  Future<void> saveMorning(
    String dateKey, {
    required Mood mood,
    required String note,
  }) => _upsert(
    dateKey,
    (e) => e.copyWith(
      morningMood: mood,
      morningNote: note,
      morningCompletedAt: DateTime.now().toIso8601String(),
    ),
  );

  Future<void> saveEvening(
    String dateKey, {
    required Mood mood,
    required String goodThing,
  }) => _upsert(
    dateKey,
    (e) => e.copyWith(
      eveningMood: mood,
      eveningGoodThing: goodThing,
      eveningCompletedAt: DateTime.now().toIso8601String(),
    ),
  );
}
