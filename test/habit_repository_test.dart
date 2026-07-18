import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/features/habits/data/habit.dart';
import 'package:daily_ruffian/features/habits/data/habit_repository.dart';

void main() {
  late HabitRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = HabitRepository(await SharedPreferences.getInstance());
  });

  test('starts empty', () {
    expect(repo.loadAll(), isEmpty);
  });

  test('add persists a habit and round-trips its fields', () async {
    await repo.add(const Habit(
      id: '1',
      title: 'Stretch',
      timeOfDay: HabitTimeOfDay.morning,
      colorKey: 'yellow',
    ));

    final all = repo.loadAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Stretch');
    expect(all.first.timeOfDay, HabitTimeOfDay.morning);
    expect(all.first.colorKey, 'yellow');
    expect(all.first.completedDateKeys, isEmpty);
  });

  test('toggleToday adds then removes the date key', () async {
    await repo.add(const Habit(
      id: '1',
      title: 'Stretch',
      timeOfDay: HabitTimeOfDay.morning,
      colorKey: 'yellow',
    ));

    await repo.toggleToday('1', '2026-07-17');
    expect(repo.loadAll().first.completedDateKeys, {'2026-07-17'});

    await repo.toggleToday('1', '2026-07-17');
    expect(repo.loadAll().first.completedDateKeys, isEmpty);
  });

  test('toggleToday on an unknown id is a no-op, not a crash', () async {
    await repo.toggleToday('missing', '2026-07-17');
    expect(repo.loadAll(), isEmpty);
  });

  test('delete removes only the targeted habit', () async {
    await repo.add(const Habit(id: '1', title: 'A', timeOfDay: HabitTimeOfDay.morning, colorKey: 'yellow'));
    await repo.add(const Habit(id: '2', title: 'B', timeOfDay: HabitTimeOfDay.evening, colorKey: 'blue'));

    await repo.delete('1');

    final all = repo.loadAll();
    expect(all, hasLength(1));
    expect(all.first.id, '2');
  });
}
