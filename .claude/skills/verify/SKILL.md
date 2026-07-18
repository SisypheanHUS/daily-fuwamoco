---
name: verify
description: How to build, run, and verify Daily Ruffian (Flutter) on this machine
---

# Verifying Daily Ruffian

## Toolchain

Flutter is NOT on PATH. Always call it by full path:

```powershell
& E:\Dev\SDK\flutter\bin\flutter.bat <command>
```

No Android SDK installed — use the web target for runtime verification,
`flutter test` for logic/widget checks.

## Build & launch

```powershell
Set-Location "E:\Dev\Apps\Fuwamoco App"
& E:\Dev\SDK\flutter\bin\flutter.bat run -d web-server --web-port 8123   # background it
```

Wait for `is being served at http://localhost:8123` in the output, then drive it
with the Chrome tools. First page load after a server (re)start recompiles in the
browser and can take 30s+; later reloads boot in ~4-7s.

## Flows worth driving

- Morning greeting: clear the daily flags in the browser console then reload —
  `['flutter.greeting_started','flutter.greeting_completed'].forEach(k=>localStorage.removeItem(k))`
  (shared_preferences on web = localStorage with `flutter.` prefix).
- Greeted-today skip: plain reload must land on `#/home` with no greeting.
- Settings: `#/settings` — Test Play must not change the flags; Mute-all must
  gray out Random/volume and make Play show the "Muted" snackbar.

## Gotchas

- The greeting auto-navigates ~6.5s after app boot; browser-tool round-trips are
  15-30s, so catching a mid-animation frame is a dice roll. Put the screenshot in
  the same browser_batch as the navigate + wait, and treat "gradient but no text
  yet" as probably-early-boot, not a regression — cross-check with
  `flutter test test\widget_test.dart` (it hit-tests the greeting text).
- Web autoplay policy blocks greeting audio on reload (no user gesture). The app
  falls back silently by design; use the Settings "Play" button to hear audio.
- Rapid multiple screenshots in one batch can freeze the debug renderer
  (CDP timeout). One screenshot per batch is safe.
- dwds "injected client" TypeErrors in the console are Flutter tooling noise,
  not app errors.
- `CompanionMascot` runs an infinite breathing `AnimationController.repeat(reverse: true)`.
  Any screen that shows it (greeting, home) will hang `tester.pumpAndSettle()`
  forever, since there's always a pending frame. Use bounded `tester.pump(duration)`
  calls in widget tests instead — see `test/widget_test.dart`.
- The app pins `themeMode: ThemeMode.light` (see `app.dart`) — the brief is
  light/cream-only, "avoid dark UI". If the browser/OS is in dark mode and this
  ever regresses (MaterialApp defaults to `ThemeMode.system`), the whole app
  silently falls back to a dark near-black palette that directly contradicts
  the design. Worth a visual spot-check after any `app.dart` change.
- Small tap targets (e.g. the 28px habit toggle ring) are easy to miss by a
  few px when eyeballing coordinates from a screenshot — a missed click looks
  identical to a broken handler (nothing visibly changes). Don't conclude
  "bug" from one miss: `zoom` into the target region first to get an accurate
  center, and confirm state changes via
  `localStorage.getItem('flutter.<key>')` (SharedPreferences on web), not
  just by eye.
- `showModalBottomSheet` content wrapped in `SingleChildScrollView` lays out
  fully — `find`/`tap` on an off-viewport child reports its real (unscrolled)
  position, which reads as "hit test failed, might be off-screen" the same
  way a genuine layout bug would. In widget tests, drive it into view first
  (`tester.dragUntilVisible(target, find.byType(SingleChildScrollView), ...)`)
  rather than assuming overflow. In practice this mostly matters for very
  short surfaces (real phones are usually tall enough that everything fits
  without scrolling).
- After any `app.dart`/routing change, do a full `flutter run` restart before
  verifying rather than relying on the already-running process — this repo's
  sessions have consistently restarted rather than hot-reloaded, so hot
  reload's behavior for router/shell changes specifically hasn't actually
  been tested here.
- Flutter web registers a service worker that aggressively caches the built
  bundle. A tab left open across a `flutter run` restart can keep rendering
  the *previous* build indefinitely (looked exactly like a missing route:
  "Coming soon" for a screen that was already implemented). If a restarted
  app doesn't reflect a source change, don't assume the code is wrong —
  open a **fresh tab** first (`tabs_create_mcp`), or unregister the service
  worker via `navigator.serviceWorker.getRegistrations().then(rs =>
  rs.map(r => r.unregister()))` and reload with a cache-busting query param.
- Injecting data into `localStorage` via `javascript_tool` on an
  **already-running** tab does not retroactively update Riverpod state —
  providers read prefs once at construction, not on every localStorage
  change. It looks identical to "the toggle/add didn't work" (nothing
  visibly changes) but isn't a reactivity bug — it's a test-methodology
  mismatch. Drive state changes through the actual UI (or a fresh page load
  that re-runs `main()`) instead of poking storage mid-session.
- `resize_window` on the Chrome tool does not actually change this
  environment's viewport (`window.innerWidth` stays ~1854 regardless of the
  requested size) — there's no way to get a true mobile-width screenshot
  here. `GridView`/`childAspectRatio` layouts (e.g. Collection) look
  visually stretched/distorted at that fixed desktop width because each
  column gets ~600px instead of a phone's ~120px; do the aspect-ratio math
  by hand (padding/columns/gaps against a real phone width like 390) rather
  than concluding "broken layout" from how it looks in a screenshot here.
  Plain full-width `Column`/`ListView` screens don't show this because they
  have no aspect-ratio constraint to distort.
- Flutter's debug-mode "DEBUG" corner ribbon (`debugShowCheckedModeBanner`,
  on by default) paints on top of everything, including `AppBar` actions
  placed near the right edge — it can fully hide (and eat clicks meant for)
  a right-aligned `IconButton`, with zero console errors, looking exactly
  like a genuine "widget never rendered" bug. If a right-edge action seems
  to render as literally nothing, don't assume the code is wrong before
  checking this — `app.dart` now sets `debugShowCheckedModeBanner: false`
  precisely because this cost a long debugging session (spawned a full
  server-restart / fresh-tab / accessibility-tree / colored-marker-widget
  investigation before the ribbon turned out to be the whole story).
- Manual mouse click-drag in Chrome does not reliably scroll a Flutter-web
  `ListView` the way a real touchscreen or a `flutter test`
  `WidgetTester.drag`/`dragUntilVisible` does — content below the fold can
  be genuinely unreachable by browser-automation drag/scroll alone. Treat
  automated widget-test scrolling as the source of truth for "does the
  off-screen content react correctly"; use manual browser verification for
  what's already on-screen, not as proof something below the fold is
  broken just because a drag didn't move it.
