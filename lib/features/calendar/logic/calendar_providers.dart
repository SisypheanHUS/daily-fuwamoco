import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../habits/logic/habit_providers.dart';

/// Every date-key with at least one habit completion, across all habits.
/// Small local dataset — cheap to recompute on every habits change rather
/// than maintaining a separate index.
final activeDatesProvider = Provider<Set<String>>((ref) {
  final habits = ref.watch(habitsProvider);
  return habits.expand((h) => h.completedDateKeys).toSet();
});
