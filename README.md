# Daily Ruffian

A FUWAMOCO-fan morning companion app. Open it once a day and get greeted —
voice, wallpaper, quote, streak, next stream.

- Spec: `docs/PRD-morning-companion.md`
- Working rules: `CLAUDE.md` (project) + `E:\Dev\CLAUDE.md` (global)

## Run

```powershell
& E:\Dev\SDK\flutter\bin\flutter.bat run -d web-server --web-port 8123   # quick web preview
& E:\Dev\SDK\flutter\bin\flutter.bat test                                # logic + widget tests
```

## Content is manifest-driven

Add greetings/quotes/wallpapers/schedule by editing JSON under `assets/` —
no code changes:

- `assets/audio/greetings/default/manifest.json` — voice clips (current .wav files
  are placeholder tones; drop in real licensed recordings + entries)
- `assets/quotes/quotes.json`
- `assets/wallpapers/manifest.json` (gradients now, `image` field ready)
- `assets/schedule/schedule.json` — upcoming streams (ISO datetimes)
