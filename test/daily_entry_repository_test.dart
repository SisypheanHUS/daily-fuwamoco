import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:daily_ruffian/features/reflection/data/daily_entry.dart';
import 'package:daily_ruffian/features/reflection/data/daily_entry_repository.dart';

void main() {
  late DailyEntryRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = DailyEntryRepository(await SharedPreferences.getInstance());
  });

  test('a date with no entry yet is neither morning- nor evening-done', () {
    final entry = repo.entryFor('2026-07-18');
    expect(entry.morningDone, isFalse);
    expect(entry.eveningDone, isFalse);
  });

  test('saveMorning round-trips mood and note, and marks morningDone', () async {
    await repo.saveMorning('2026-07-18', mood: Mood.happy, note: 'Coffee');

    final entry = repo.entryFor('2026-07-18');
    expect(entry.morningDone, isTrue);
    expect(entry.morningMood, Mood.happy);
    expect(entry.morningNote, 'Coffee');
    expect(entry.eveningDone, isFalse);
  });

  test('saveEvening on the same date preserves the morning fields', () async {
    await repo.saveMorning('2026-07-18', mood: Mood.happy, note: 'Coffee');
    await repo.saveEvening('2026-07-18', mood: Mood.calm, goodThing: 'A walk');

    final entry = repo.entryFor('2026-07-18');
    expect(entry.morningDone, isTrue);
    expect(entry.morningMood, Mood.happy);
    expect(entry.morningNote, 'Coffee');
    expect(entry.eveningDone, isTrue);
    expect(entry.eveningMood, Mood.calm);
    expect(entry.eveningGoodThing, 'A walk');
  });

  test('entries for different dates do not clash', () async {
    await repo.saveMorning('2026-07-17', mood: Mood.tender, note: 'Yesterday');
    await repo.saveMorning('2026-07-18', mood: Mood.warm, note: 'Today');

    expect(repo.entryFor('2026-07-17').morningNote, 'Yesterday');
    expect(repo.entryFor('2026-07-18').morningNote, 'Today');
  });

  test('saving morning twice on the same date overwrites, not duplicates', () async {
    await repo.saveMorning('2026-07-18', mood: Mood.happy, note: 'First');
    await repo.saveMorning('2026-07-18', mood: Mood.calm, note: 'Second');

    expect(repo.loadAll().where((e) => e.dateKey == '2026-07-18'), hasLength(1));
    expect(repo.entryFor('2026-07-18').morningNote, 'Second');
  });
}
