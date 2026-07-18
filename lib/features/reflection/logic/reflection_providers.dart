import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/local_date.dart';
import '../data/daily_entry.dart';
import '../data/daily_entry_repository.dart';

final dailyEntryRepositoryProvider = Provider<DailyEntryRepository>(
  (ref) => DailyEntryRepository(ref.watch(sharedPreferencesProvider)),
);

/// Today's entry only — every screen that cares (Home's ritual cards,
/// Morning Check-in, Evening Reflection) only ever reads/writes "today", so
/// there's no need for a full-list controller like habits has.
class TodayEntryController extends Notifier<DailyEntry> {
  @override
  DailyEntry build() {
    final repo = ref.watch(dailyEntryRepositoryProvider);
    return repo.entryFor(localDateKey(DateTime.now()));
  }

  Future<void> saveMorning({required Mood mood, required String note}) async {
    final repo = ref.read(dailyEntryRepositoryProvider);
    await repo.saveMorning(state.dateKey, mood: mood, note: note);
    state = repo.entryFor(state.dateKey);
  }

  Future<void> saveEvening({required Mood mood, required String goodThing}) async {
    final repo = ref.read(dailyEntryRepositoryProvider);
    await repo.saveEvening(state.dateKey, mood: mood, goodThing: goodThing);
    state = repo.entryFor(state.dateKey);
  }
}

final todayEntryProvider =
    NotifierProvider<TodayEntryController, DailyEntry>(TodayEntryController.new);
