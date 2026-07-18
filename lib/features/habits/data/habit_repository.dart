import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/storage/json_list_store.dart';
import 'habit.dart';

class HabitRepository {
  HabitRepository(this._prefs);

  static const _key = 'habits';

  final SharedPreferences _prefs;

  List<Habit> loadAll() =>
      readJsonList(_prefs, _key).map(Habit.fromJson).toList();

  Future<void> _saveAll(List<Habit> habits) =>
      writeJsonList(_prefs, _key, habits.map((h) => h.toJson()).toList());

  Future<void> add(Habit habit) => _saveAll([...loadAll(), habit]);

  Future<void> toggleToday(String habitId, String todayKey) async {
    final all = loadAll();
    final index = all.indexWhere((h) => h.id == habitId);
    if (index == -1) return;
    final updated = Set<String>.from(all[index].completedDateKeys);
    if (!updated.remove(todayKey)) updated.add(todayKey);
    all[index] = all[index].copyWith(completedDateKeys: updated);
    await _saveAll(all);
  }

  Future<void> delete(String habitId) =>
      _saveAll(loadAll()..removeWhere((h) => h.id == habitId));
}
