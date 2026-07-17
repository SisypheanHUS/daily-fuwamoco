# PRD — Morning Companion (Daily Ruffian)

## 1. Tổng quan

**Tên tính năng:** Morning Companion
**Vai trò:** Tính năng lõi (signature feature) của app Daily Ruffian.
**Mục tiêu trải nghiệm:** Khi mở app lần đầu trong ngày, người dùng cảm thấy như đang được FUWAMOCO chào buổi sáng — một companion nhỏ, ấm áp, chứ không phải mở một utility app.

**Đối tượng dùng tài liệu này:** mobile dev (Flutter/RN), backend (nếu có sync), designer, QA.

---

## 2. Mục tiêu & Success Metrics

| Mục tiêu | Metric |
|---|---|
| Tạo thói quen mở app mỗi sáng | % DAU mở app trước 12:00 trưa |
| Tăng cảm giác gắn bó (companion feel) | Retention D1/D7/D30 |
| Giữ streak hoạt động | % user có streak ≥ 3 ngày |
| Voice greeting không gây phiền | % user tắt greeting trong Settings (mong muốn thấp, <10%) |
| Không lỗi phát trùng greeting | 0 báo cáo "greeting phát lại nhiều lần/ngày" |

---

## 3. Phạm vi (Scope)

### Trong phạm vi (v1)
- Fade-in animation khi mở app buổi sáng đầu tiên trong ngày.
- Text greeting "Good Morning, Ruffian."
- Phát audio greeting ngẫu nhiên từ local asset pool.
- Hiển thị wallpaper trong ngày.
- Hiển thị quote trong ngày (animation riêng).
- Hiển thị streak hiện tại + "next stream" (lịch stream tiếp theo).
- Logic "chỉ chạy 1 lần/ngày theo lịch, theo local device time".
- Settings: bật/tắt greeting, volume, random on/off, test button, mute-all.
- Kiến trúc audio pool mở rộng được tới hàng trăm file mà không sửa code.

### Ngoài phạm vi (v1, để dành roadmap sau)
- Seasonal / birthday / weekend / holiday / weather-based greeting.
- Voice pack khác (nhiều nhân vật/giọng).
- User tự chọn greeting yêu thích.
- Đồng bộ cloud giữa nhiều thiết bị.
- Cá nhân hóa nội dung quote theo AI.

### Ràng buộc & giả định
- Không có nhân vật thật/âm thanh có bản quyền được nhúng cứng trong tài liệu này — audio là placeholder do team tự sản xuất/license.
- Offline-first: toàn bộ trải nghiệm sáng phải chạy được không cần mạng (trừ khi lịch stream cần fetch online).

---

## 4. User Story chính

> Là một Ruffian, khi tôi mở app lần đầu trong ngày, tôi muốn được chào buổi sáng bằng giọng nói + hình ảnh + quote, để cảm thấy như đang bắt đầu ngày mới cùng FUWAMOCO, không bị lặp lại phiền phức nếu tôi mở lại app trong ngày.

**Acceptance Criteria:**
1. Given user chưa mở app hôm nay, when mở app, then chạy full sequence (fade-in → text → voice → wallpaper → quote → streak/next stream).
2. Given user đã mở app hôm nay rồi, when mở lại, then app vào thẳng home state, không animation/voice.
3. Given `mute all` bật, when trigger greeting, then vẫn chạy animation nhưng không phát âm thanh.
4. Given "Enable morning greeting" tắt, when mở app, then bỏ qua toàn bộ sequence, vào thẳng home.
5. Given không có audio file nào khả dụng (lỗi/rỗng), then app vẫn chạy phần visual, fail-safe không crash.

---

## 5. Sequence chi tiết (State Machine)

```
[App Launch]
     │
     ▼
[Check: hasGreetedToday(localDate)?]
     │
   ┌─┴─────────────┐
  No               Yes
   │                │
   ▼                ▼
[Run Greeting     [Skip → Home Screen]
 Sequence]
   │
   ▼
1. Fade-in (splash/companion overlay)
2. Show text "Good Morning, Ruffian."
3. Trigger audio playback (nếu enabled & không mute)
4. Show wallpaper of the day
5. Reveal quote (animated: fade/slide)
6. Show streak counter + next stream info
   │
   ▼
[markGreetedToday(localDate)] → persist
   │
   ▼
[Home Screen]
```

**Điểm mấu chốt kỹ thuật:** bước "markGreetedToday" phải ghi persistent storage **trước hoặc ngay sau** khi sequence bắt đầu chạy (không đợi tới cuối animation), để tránh trường hợp user thoát app giữa chừng animation rồi mở lại → bị chạy lại. Khuyến nghị: ghi ngay khi bắt đầu, kèm cờ `greeting_in_progress` để xử lý app bị kill giữa chừng (xem mục 8.3).

---

## 6. Kiến trúc kỹ thuật

### 6.1 Stack đề xuất
- **Framework:** Flutter (khuyến nghị vì animation mượt, single codebase iOS/Android, audio plugin ổn định) — hoặc React Native nếu team đã có sẵn kinh nghiệm RN.
- **State management:** Riverpod (Flutter) / Zustand hoặc Redux Toolkit (RN).
- **Local storage:** SharedPreferences/Hive (Flutter) hoặc AsyncStorage/MMKV (RN) — dùng cho flags nhẹ (last greeted date, settings).
- **Audio:** `just_audio` (Flutter) hoặc `react-native-track-player` (RN) — hỗ trợ local asset playback, volume control.
- **Content config:** JSON manifest (xem 6.3) để tách nội dung khỏi code.

### 6.2 Cấu trúc thư mục asset

```
assets/
  audio/
    greetings/
      default/
        morning_01.mp3
        morning_02.mp3
        morning_03.mp3
        ...
        morning_178.mp3
      manifest.json
  wallpapers/
    2026-07-17.png (hoặc theme-based, xem 6.4)
  quotes/
    quotes.json
```

### 6.3 Audio Manifest (thiết kế mở rộng "hàng trăm file không sửa code")

`assets/audio/greetings/default/manifest.json`:
```json
{
  "pack_id": "default",
  "pack_name": "FUWAMOCO Default Greetings",
  "clips": [
    { "id": "morning_01", "file": "morning_01.mp3", "tags": ["generic"], "weight": 1 },
    { "id": "morning_02", "file": "morning_02.mp3", "tags": ["generic"], "weight": 1 },
    { "id": "morning_03", "file": "morning_03.mp3", "tags": ["generic"], "weight": 1 }
  ]
}
```

**Nguyên tắc thiết kế:**
- Code chỉ đọc `manifest.json`, **không hardcode tên file**. Thêm file mới = thêm entry vào manifest + copy file vào thư mục → không cần build lại logic.
- Trường `tags` (`generic`, `seasonal:tet`, `event:birthday`, `weekend`, `weather:rain`...) đã được thiết kế sẵn dù v1 chỉ dùng `generic` — đây chính là điểm neo cho roadmap mục 9.
- Trường `weight` cho phép sau này làm trọng số random (ví dụ clip hiếm hơn, hoặc clip mới được ưu tiên xuất hiện) mà không đổi schema.
- `pack_id` cho phép nhiều voice pack tồn tại song song (roadmap "Different voice packs").

### 6.4 Content Provider Pattern

Thiết kế 1 lớp trừu tượng `GreetingContentProvider` để tách "logic chọn nội dung" khỏi "nơi lưu nội dung":

```
interface GreetingContentProvider {
  getEligibleClips(context: GreetingContext): AudioClip[]
  pickOne(clips: AudioClip[]): AudioClip
}

GreetingContext {
  date: Date
  isWeekend: bool
  isHoliday: bool
  isBirthday: bool
  season: enum
  weather: enum | null
  userFavorites: string[] | null
}
```

- v1: implement 1 provider duy nhất `DefaultGreetingProvider` — chỉ filter theo `tags = generic`, chọn ngẫu nhiên đều (uniform random), bỏ qua toàn bộ context khác.
- Roadmap: thêm `SeasonalGreetingProvider`, `BirthdayGreetingProvider`... implement cùng interface, compose theo priority chain (nếu có birthday hôm nay → ưu tiên birthday clip; nếu không → seasonal; nếu không → weekend; nếu không → default). Không cần sửa UI/playback layer.

### 6.5 Wallpaper & Quote

- Tương tự audio: dùng manifest JSON (`quotes.json`, `wallpapers/manifest.json`) thay vì hardcode path.
- Cách chọn "quote của ngày" nên **deterministic theo ngày** (seed = ngày hiện tại, ví dụ `hash(date) % quotes.length`) để cùng 1 ngày mọi lần mở lại (trong logic nội bộ, dù không hiển thị lại) đều trả cùng 1 quote — tránh trường hợp lưu sai state mà quote đổi giữa chừng.
- Wallpaper: có thể fetch remote (để update không cần release app) hoặc bundle local + cache; đề xuất remote JSON config + CDN ảnh, fallback local nếu offline.

### 6.6 Streak & Next Stream data

- **Streak:** đếm số ngày liên tiếp user mở app (hoặc hoàn thành 1 hành động cụ thể trong app — cần định nghĩa rõ "streak" tính theo gì: mở app, hay tương tác, hay check-in). Lưu local + optional sync backend nếu có tài khoản.
- **Next stream:** cần data source — API lịch stream (YouTube API / internal schedule service). Cache lại, hiển thị "TBA" nếu không có dữ liệu, tránh crash khi API fail.

---

## 7. Settings Page — Spec chi tiết

| Control | Loại | Default | Behavior |
|---|---|---|---|
| Enable morning greeting | Toggle | ON | Tắt = bỏ qua toàn bộ sequence (kể cả visual), vào thẳng home |
| Greeting volume | Slider 0–100% | 80% | Áp dụng riêng cho audio greeting, độc lập với volume media khác của app |
| Random greeting | Toggle | ON | Tắt = luôn phát clip đầu tiên (hoặc clip đã pin) thay vì random |
| Test greeting | Button | — | Phát thử ngay 1 clip random, không set flag "đã greet hôm nay" |
| Mute all voice playback | Toggle | OFF | Global override: tắt hết audio trong app (không riêng greeting), ưu tiên cao nhất |

**Thứ tự ưu tiên xử lý:** `Mute all` > `Enable morning greeting` (audio) > `Random greeting`.

---

## 8. Edge Cases & Xử lý lỗi

1. **Đổi timezone / đổi giờ hệ thống:** dùng "calendar day theo local time tại thời điểm mở app" — cần xử lý trường hợp user chỉnh giờ về quá khứ (không nên trigger greeting lại) — khuyến nghị so sánh với `last_greeted_date` lưu dạng ISO date string, cộng thêm kiểm tra "date hiện tại > last_greeted_date" (không chỉ "khác").
2. **App bị kill giữa animation:** dùng cờ 2 pha — set `greeting_started = today` ngay khi bắt đầu, set `greeting_completed = today` khi xong. Nếu mở lại thấy `started` nhưng không `completed`, có thể chọn: (a) resume từ đầu 1 lần nữa, hoặc (b) coi như đã xong và vào home — nên chọn (b) để tránh loop, an toàn hơn cho UX.
3. **Audio file lỗi/thiếu:** validate manifest lúc build; runtime nếu file load fail → fallback im lặng (log lỗi, không crash, không chặn visual sequence).
4. **Không có mạng khi cần next stream/wallpaper remote:** fallback cache gần nhất hoặc placeholder rõ ràng ("Đang cập nhật lịch stream...").
5. **User có nhiều thiết bị:** nếu không có backend sync ở v1, "đã greet hôm nay" là theo từng thiết bị — cần nêu rõ trong tài liệu để tránh hiểu nhầm là bug.

---

## 9. Kiến trúc mở rộng tương lai (không code ở v1, nhưng chuẩn bị sẵn)

| Tính năng tương lai | Điểm neo đã có sẵn trong kiến trúc v1 |
|---|---|
| Seasonal greetings | `tags: seasonal:*` trong manifest + `GreetingContext.season` |
| Birthday greetings | `GreetingContext.isBirthday` + `BirthdayGreetingProvider` |
| Weekend greetings | `GreetingContext.isWeekend` |
| Holiday greetings | `GreetingContext.isHoliday` (cần data nguồn holiday calendar) |
| Weather-based greetings | `GreetingContext.weather` (cần tích hợp weather API) |
| Voice packs khác nhau | `pack_id` trong manifest, `GreetingContentProvider` theo pack |
| User favorite greetings | `userFavorites` trong context + UI chọn (thêm màn hình "Chọn giọng yêu thích") |

Nguyên tắc chung: **mọi provider mới chỉ cần implement interface `GreetingContentProvider` và đăng ký vào priority chain**, không đụng vào playback layer, state machine, hay Settings core.

---

## 10. Non-functional Requirements

- **Performance:** sequence tổng thời gian ≤ 6–8 giây (không để user chờ lâu mỗi sáng).
- **Offline-first:** toàn bộ core sequence (trừ next-stream/wallpaper remote) chạy được offline.
- **Accessibility:** có thể tắt hoàn toàn animation/voice cho user nhạy cảm với chuyển động/âm thanh (đã có qua Settings).
- **Storage:** audio pool hàng trăm file — cân nhắc compressed format (AAC/OPUS) để giữ app size hợp lý; hoặc tải on-demand pack thay vì bundle hết vào app từ đầu (giảm dung lượng cài đặt).
- **Testability:** "Test greeting" button không được ảnh hưởng đến state "đã greet hôm nay".

---

## 11. Câu hỏi mở — ĐÃ CHỐT cho v1 (2026-07-17)

1. **Streak tính theo gì?** → Mở app (lần đầu trong ngày, theo local time).
2. **Next-stream data từ đâu?** → v1: JSON local `assets/schedule/schedule.json`, hiển thị "TBA" khi trống. API để roadmap.
3. **Backend/sync?** → v1 local-only, không tài khoản. "Đã greet hôm nay" là per-device (đã nêu rõ ở 8.5).
4. **Audio bundle hay tải theo pack?** → v1 bundle trong app (pool còn nhỏ). Khi scale hàng trăm file sẽ chuyển on-demand pack.
5. **Wallpaper theo ngày hay theme?** → Deterministic theo ngày từ manifest local; v1 dùng gradient, schema đã hỗ trợ image.
