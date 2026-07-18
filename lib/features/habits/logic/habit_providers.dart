import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/id_generator.dart';
import '../../../core/utils/local_date.dart';
import '../data/habit.dart';
import '../data/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(ref.watch(sharedPreferencesProvider)),
);

class HabitsController extends Notifier<List<Habit>> {
  @override
  List<Habit> build() => ref.watch(habitRepositoryProvider).loadAll();

  Future<void> add({
    required String title,
    required HabitTimeOfDay timeOfDay,
    required String colorKey,
  }) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.add(
      Habit(
        id: generateLocalId(),
        title: title,
        timeOfDay: timeOfDay,
        colorKey: colorKey,
      ),
    );
    state = repo.loadAll();
  }

  Future<void> toggleToday(String habitId) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.toggleToday(habitId, localDateKey(DateTime.now()));
    state = repo.loadAll();
  }

  Future<void> delete(String habitId) async {
    final repo = ref.read(habitRepositoryProvider);
    await repo.delete(habitId);
    state = repo.loadAll();
  }
}

final habitsProvider = NotifierProvider<HabitsController, List<Habit>>(
  HabitsController.new,
);
