# Daily Ruffian

A FUWAMOCO-fan morning companion app. Opening the app in the morning should feel
like being greeted by a warm little companion, not launching a utility.

## Stack

- Flutter, Riverpod, go_router
- Storage: shared_preferences (flags + settings only)
- Audio: just_audio, local assets driven by `assets/audio/greetings/<pack>/manifest.json`

## Design

- Minimal, monochrome, cute. One accent color.
- Follow `E:\Dev\skills\design.md` and `E:\Dev\skills\flutter.md`.

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
