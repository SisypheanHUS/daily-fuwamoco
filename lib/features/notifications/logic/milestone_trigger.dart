/// Streak lengths worth celebrating — mirrors the Collection screen's
/// "Milestones" group thresholds (phase 6), so a charm unlocking and a
/// notification firing are always the same event.
const milestoneThresholds = [7, 30, 100];

/// Pure: which threshold (if any) did the streak just cross since the last
/// time this was checked? Highest threshold wins if somehow more than one
/// was skipped at once (e.g. streak data edited externally).
int? milestoneCrossed({required int lastNotifiedStreak, required int currentStreak}) {
  for (final threshold in milestoneThresholds.reversed) {
    if (currentStreak >= threshold && lastNotifiedStreak < threshold) {
      return threshold;
    }
  }
  return null;
}
