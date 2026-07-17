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
