# PRD — Daily FUWAMOCO v2 (visual + IA redesign)

Companion doc to [`PRD-morning-companion.md`](PRD-morning-companion.md), which
stays accurate for the Morning Companion / greeting feature specifically and
was left untouched by this work. This doc exists so v2's scope decisions —
especially what was deliberately deferred — are discoverable later instead of
buried in a now-closed plan file.

## What this was

A full visual redesign (warm cream/clay/pastel palette, Plus Jakarta Sans,
twin-mascot pair, 20–32px rounded corners) plus six new feature areas, built
from a 10-screen mockup set designed in a Claude Design project. Landed as
seven sequential phases, each with its own `flutter analyze` + `flutter test`
+ browser verification pass and its own commit:

1. Reskin (theme, mascot, `ThemeMode.light` pinning) applied to the existing
   Greeting/Home/Settings screens.
2. Habit Tracker ("Rituals" tab).
3. Calendar tab.
4. Morning Check-in / Evening Reflection (wired into Home's existing ritual
   cards, replacing their static placeholder state).
5. Notifications (in-app inbox, bell icon on Home).
6. Collection (charm catalog, reached from a Home card).
7. Settings restructure (grouped sections, Reset my data).

## Information architecture

Bottom nav: **Home / Rituals / Calendar / Settings** (4 tabs — the mockups
were inconsistent about a 5th "Collection" tab; resolved to keep the bar at
4). Collection and Notifications are each reached one tap from Home (a card,
and the app-bar bell) rather than being tabs themselves.

## Deferred (decided with the user, not silently dropped)

- **Real OS push notifications / scheduled reminders.** No
  `flutter_local_notifications`, no native permission flow. v1 notifications
  are an in-app inbox only, populated when the streak crosses a 7/30/100-day
  milestone (`lib/features/notifications/logic/milestone_trigger.dart`).
- **"Twins' personality" picker and "Morning/Evening reminder time" settings**
  — both fell out once real push notifications were deferred, since neither
  would have any observable effect without it.
- **Collection unlock logic beyond Milestones.** Only the Milestones group
  unlocks live (from `streakProvider`, no new persistence). Seasonal and
  Everyday groups exist in the bundled manifest but render locked-only in v1
  — same "anchor the catalog now, wire unlocks later" pattern already used
  elsewhere in this codebase.

## Notable architecture decisions

- **New storage primitive:** `lib/core/storage/json_list_store.dart`. Every
  feature before v2 stored either flat primitives or read-only bundled asset
  JSON — habits, notifications, and daily check-in entries are the first
  mutable, user-generated, structured data this app has needed, so this one
  helper (`readJsonList`/`writeJsonList` over `dart:convert`, fail-soft to
  `[]`) is what every new repository is built on.
- **Reset my data** clears `SharedPreferences` and remounts the whole
  `ProviderScope` with a fresh `Key` (see `AppRoot` in `lib/main.dart`)
  instead of hand-invalidating every provider that reads prefs — a future
  feature's provider can't be missed and left stale after a reset, because
  nothing about the reset is enumerated by hand.
- **Font and palette** were taken directly from the approved mockups' shared
  CSS (`shared.css` tokens → `AppTheme` constants) and Plus Jakarta Sans is
  bundled offline from the `google/fonts` GitHub repo, matching the same
  offline-first approach already used for Quicksand in v1.
- Package name, directories, and native bundle IDs were **not** renamed —
  only user-facing strings changed to "Daily FUWAMOCO". Renaming the Dart
  package (`daily_ruffian`) is a separate, riskier operation with Android/iOS
  implications that wasn't in scope here.
