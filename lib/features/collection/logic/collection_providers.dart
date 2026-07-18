import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/streak/logic/streak_service.dart';
import '../data/collection_item.dart';
import '../data/collection_repository.dart';

final collectionCatalogProvider = FutureProvider<List<CollectionItem>>(
  (ref) => const CollectionRepository().loadAll(),
);

/// Milestones unlock live from the current streak — no separate persistence,
/// so raising the streak in dev tools or via normal use both "just work".
/// Seasonal/everyday items have no unlock rule yet (Phase 6 scope) and stay
/// locked regardless of streak.
bool isCollectionItemUnlocked(CollectionItem item, int streak) {
  if (item.threshold == null) return false;
  return streak >= item.threshold!;
}

final unlockedCollectionCountProvider = Provider<AsyncValue<int>>((ref) {
  final catalog = ref.watch(collectionCatalogProvider);
  final streak = ref.watch(streakProvider);
  return catalog.whenData(
    (items) => items.where((i) => isCollectionItemUnlocked(i, streak)).length,
  );
});
