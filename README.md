# Daily FUWAMOCO

[🇬🇧 English](#english) · [🇻🇳 Tiếng Việt](#tieng-viet)

## Screenshots

| | | |
|---|---|---|
| ![Greeting](docs/screenshots/greeting.png) Morning greeting | ![Home](docs/screenshots/home.png) Home | ![Morning check-in](docs/screenshots/morning-checkin.png) Morning check-in |
| ![Evening reflection](docs/screenshots/evening-reflection.png) Evening reflection | ![Rituals](docs/screenshots/rituals.png) Rituals (habits) | ![Calendar](docs/screenshots/calendar.png) Calendar |
| ![Notifications](docs/screenshots/notifications.png) Notifications | ![Collection](docs/screenshots/collection.png) Collection | ![Settings](docs/screenshots/settings.png) Settings |

---

<a name="english"></a>

## English

Daily FUWAMOCO is a cozy companion app inspired by FUWAMOCO and, especially,
Mococo's heartfelt pep talks that somehow always arrive at the right time.

I built this app for myself—a small place to start the day with a warm
greeting, hear a few encouraging words, keep a gentle streak, and share tiny
everyday rituals with two mascots that never ask me to be more productive,
only to keep going.

This isn't a habit tracker, a productivity tool, or a social platform. It's
a personal portfolio project exploring how comfort, kindness, and emotional
design can make software feel like a quiet companion rather than another
thing demanding your attention.

Built with Flutter, Riverpod, and go_router.

### Features

- **Morning greeting** — once per calendar day, a short animated sequence
  (fade-in → text → voice clip → wallpaper → quote → streak/next stream),
  tap-to-skip, fails soft to visual-only if audio is unavailable.
- **Streak** — counts consecutive daily app opens.
- **Rituals (habit tracker)** — small recurring habits grouped by time of
  day, each with its own streak.
- **Calendar** — month view with an activity dot per day; tap a day to see
  what was done.
- **Morning check-in / Evening reflection** — a quick daily mood + note,
  independently completable.
- **Notifications** — in-app inbox, fires when your streak crosses a
  7/30/100-day milestone (no OS push — see [scope](docs/PRD-daily-fuwamoco-v2.md)).
- **Collection** — a small charm catalog; the Milestones group unlocks
  live from your streak.
- **Settings** — reduce motion, display name, greeting controls, and a
  "Reset my data" flow that returns the app to first-open state.

Everything is local-only (`shared_preferences`) — no accounts, no backend,
works fully offline.

### Stack

- Flutter, Riverpod (`flutter_riverpod`), go_router
  (`StatefulShellRoute.indexedStack` for the bottom nav)
- Storage: `shared_preferences` — flat keys for settings, plus a small
  JSON-list helper (`lib/core/storage/json_list_store.dart`) for the
  mutable structured data (habits, notifications, daily entries)
- Audio: `just_audio`, manifest-driven local clips
- All content (quotes, wallpapers, schedule, prompts, the collection
  catalog) is bundled JSON — never hardcoded strings

### Run it

```powershell
flutter run -d chrome              # real browser window
flutter run -d web-server          # headless, serves on localhost
flutter test                       # logic + widget tests
```

No Android/iOS SDK setup was done for this project — it was built and
verified entirely against the web target.

### Docs

- [`docs/PRD-morning-companion.md`](docs/PRD-morning-companion.md) — the
  original v1 spec (the morning greeting feature).
- [`docs/PRD-daily-fuwamoco-v2.md`](docs/PRD-daily-fuwamoco-v2.md) — the
  v2 redesign's scope, architecture decisions, and what was deliberately
  left out (real push notifications, a personality picker, reminder times).
- [`CLAUDE.md`](CLAUDE.md) — working rules this project was built under.

### Status

Feature-complete for the scope above. Not under active development —
built as a design/engineering exercise, not a shipping product.

---

<a name="tieng-viet"></a>

## Tiếng Việt

Daily FUWAMOCO là một app companion ấm áp lấy cảm hứng từ FUWAMOCO — đặc
biệt là những lời động viên chân thành của Mococo, kiểu gì cũng luôn đến
đúng lúc mình cần nhất.

Mình làm app này cho chính mình — một góc nhỏ để bắt đầu ngày mới bằng một
lời chào ấm áp, nghe vài câu động viên, giữ một streak nhẹ nhàng, và chia
sẻ những nghi thức nhỏ mỗi ngày cùng hai mascot chẳng bao giờ đòi hỏi mình
phải năng suất hơn, chỉ cần mình tiếp tục cố gắng thôi.

Đây không phải app theo dõi thói quen, không phải công cụ năng suất, cũng
không phải mạng xã hội. Đây là một project cá nhân (portfolio) để mình thử
xem sự ấm áp, tử tế và thiết kế cảm xúc có thể khiến phần mềm trở thành
một người bạn đồng hành âm thầm — thay vì thêm một thứ nữa đòi hỏi sự chú
ý của mình — đến mức nào.

Xây dựng bằng Flutter, Riverpod, và go_router.

### Tính năng

- **Lời chào buổi sáng** — mỗi ngày (theo lịch) chạy một lần, một chuỗi
  hoạt ảnh ngắn (mờ dần vào → chữ → clip giọng nói → hình nền → câu trích
  dẫn → streak/lịch stream tiếp theo), chạm để bỏ qua, nếu không phát được
  audio thì tự động chuyển sang chỉ hiển thị hình ảnh.
- **Streak** — đếm số ngày liên tiếp mở app.
- **Rituals (theo dõi thói quen)** — các thói quen nhỏ lặp lại, nhóm theo
  buổi trong ngày, mỗi thói quen có streak riêng.
- **Calendar** — xem theo tháng, có chấm hoạt động mỗi ngày; chạm vào một
  ngày để xem đã làm gì.
- **Morning check-in / Evening reflection** — ghi nhanh tâm trạng + ghi
  chú mỗi ngày, hai phần hoàn thành độc lập nhau.
- **Notifications** — hộp thư trong app, bắn thông báo khi streak vượt
  mốc 7/30/100 ngày (không dùng push của hệ điều hành — xem
  [phạm vi](docs/PRD-daily-fuwamoco-v2.md)).
- **Collection** — bộ sưu tập charm nhỏ; nhóm Milestones mở khoá trực
  tiếp theo streak hiện tại.
- **Settings** — giảm hiệu ứng chuyển động, đặt tên hiển thị, điều khiển
  lời chào, và luồng "Reset my data" đưa app về trạng thái như mới cài.

Toàn bộ dữ liệu chỉ lưu local (`shared_preferences`) — không tài khoản,
không backend, chạy offline hoàn toàn.

### Công nghệ

- Flutter, Riverpod (`flutter_riverpod`), go_router
  (`StatefulShellRoute.indexedStack` cho thanh điều hướng dưới)
- Lưu trữ: `shared_preferences` — key phẳng cho settings, cộng thêm một
  helper JSON-list nhỏ (`lib/core/storage/json_list_store.dart`) cho dữ
  liệu có cấu trúc, có thể thay đổi (habits, notifications, daily entries)
- Audio: `just_audio`, các clip local điều khiển qua manifest
- Toàn bộ nội dung (quote, wallpaper, lịch stream, prompt, danh mục
  collection) đều là JSON đóng gói sẵn — không hardcode chuỗi trong code

### Chạy thử

```powershell
flutter run -d chrome              # cửa sổ trình duyệt thật
flutter run -d web-server          # chạy ngầm, serve ở localhost
flutter test                       # test logic + widget
```

Project này không cài Android/iOS SDK — được build và kiểm thử hoàn toàn
trên nền web.

### Tài liệu

- [`docs/PRD-morning-companion.md`](docs/PRD-morning-companion.md) — spec
  gốc của v1 (tính năng lời chào buổi sáng).
- [`docs/PRD-daily-fuwamoco-v2.md`](docs/PRD-daily-fuwamoco-v2.md) —
  phạm vi bản redesign v2, các quyết định kiến trúc, và những gì chủ đích
  không làm (push notification thật, bộ chọn tính cách, giờ nhắc nhở).
- [`CLAUDE.md`](CLAUDE.md) — các quy tắc làm việc mà project này tuân theo.

### Trạng thái

Đã hoàn thành đầy đủ tính năng trong phạm vi trên. Không còn phát triển
tiếp — đây là một bài tập thiết kế/kỹ thuật cá nhân, không phải sản phẩm
thương mại.
