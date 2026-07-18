# Daily Ruffian

A FUWAMOCO-fan cozy companion app ("Daily FUWAMOCO"), branded around a warm
little twin-mascot pair. Opening the app should feel like checking in with a
companion, not launching a utility or a gamified habit tracker.

## Stack

- Flutter, Riverpod, go_router (`StatefulShellRoute.indexedStack` for the
  4-tab bottom nav: Home / Rituals / Calendar / Settings)
- Storage: shared_preferences — flat keys for flags/settings, plus
  `lib/core/storage/json_list_store.dart` (JSON-encoded lists) for mutable
  structured data: habits, notifications, daily check-in entries
- Audio: just_audio, local assets driven by `assets/audio/greetings/<pack>/manifest.json`
- Manifest-driven content throughout: bundled JSON assets loaded via
  `rootBundle`, never hardcoded strings (quotes, wallpapers, schedule,
  reflection prompts, collection catalog)

## Design

- Warm cream/clay/pastel palette (`AppTheme`), Plus Jakarta Sans, 20–32px
  rounded corners, soft shadows. Light-only by design — `app.dart` pins
  `themeMode: ThemeMode.light`; avoid dark UI.
- Follow `E:\Dev\skills\design.md` and `E:\Dev\skills\flutter.md`.

## Features (v2)

Home, Habit Tracker ("Rituals"), Calendar, Morning Check-in / Evening
Reflection, Notifications (in-app inbox only — no OS push, see
`docs/PRD-daily-fuwamoco-v2.md`), Collection (charm catalog, Milestones
group unlocks live from streak), Settings (Preferences/About sections,
"Reset my data" clears local state — no accounts, no sync). Full v2 scope
and deferred items: `docs/PRD-daily-fuwamoco-v2.md`.

## Core feature: Morning Companion

Full spec in `docs/PRD-morning-companion.md`. The short version:

- First open of the calendar day (local time) runs the greeting sequence:
  fade-in → "Good Morning, Ruffian." → voice clip → wallpaper → quote → streak + next stream.
- Later opens the same day go straight to home. Compare ISO date strings with `>`
  (not `!=`) so setting the clock back never re-triggers.
- Two-phase flags: `greeting_started` is persisted the moment the sequence begins;
  if the app is killed mid-animation, next open counts as done (no loop).
- Content is manifest-driven — never hardcode asset filenames in code.
- `GreetingContentProvider` interface stays the extension point for
  seasonal/birthday/weekend/voice-pack providers later. v1 ships only
  `DefaultGreetingProvider` (tags = generic, uniform random).
- Settings priority: Mute all > Enable morning greeting > Random greeting.
- Fail-safe: missing/broken audio must never crash or block the visual sequence.

## v1 decisions (open questions from PRD, resolved)

1. Streak counts **app opens** (first open of the day).
2. Next stream comes from local `assets/schedule/schedule.json`; "TBA" when empty.
3. v1 is local-only, no accounts, no sync. "Greeted today" is per-device.
4. Audio is bundled (mp3); grow the pool by dropping files + manifest entries
   (no code changes).
5. Wallpaper picked deterministically per day from a local manifest; v1 entries are
   gradients, image support already in the schema.

## Out of scope (v1)

Seasonal/birthday/weekend/holiday/weather greetings, extra voice packs,
favorite-greeting picker, cloud sync, AI quotes. The architecture anchors for all
of these exist (tags, GreetingContext, pack_id) — do not build them early.

## Project-specific rules

- The "Test greeting" button must never touch the greeted-today flags.
- Greeting sequence total length ≤ 6–8s and must be tap-to-skip.
- Everything must work fully offline.
