# Requirements (example)

> A filled-in example showing the level of detail that lets an agent bootstrap without guessing.
> It is short on purpose: a small app needs a short file.

## 1. Product

- **Name:** Plant Pal
- **Package / application id:** `com.example.plantpal`
- **One sentence:** Reminds me when each of my house plants needs water.
- **Problem it solves:** I forget which plant I watered when; some get too much, some none.
- **Success looks like:** No dead plants for three months; I only open the app when it reminds me.

## 2. Users

| Who | What they want | How often |
|---|---|---|
| Me (one person, one phone) | See which plants need water today, mark them watered | daily, < 30 s |

## 3. Features

### F1 — Plant list (MVP)

- **User story:** As a plant owner I want to see all my plants sorted by "water next" so that I
  know what to do today.
- **Screens:** list (start screen), add/edit plant form.
- **Rules & edge cases:** plant = name, optional photo from the camera/gallery, watering interval
  in days (1–60), last watered date. Overdue plants on top in the error color. Empty state:
  "No plants yet" + "Add plant". Deleting asks for confirmation.
- **Acceptance criteria:**
  - [ ] Adding a plant with interval 3 shows "Water in 3 days".
  - [ ] Tapping the drop icon marks it watered today; the list re-sorts.
  - [ ] A plant 2 days overdue shows "2 days overdue" at the top.

### F2 — Reminders (MVP)

- **User story:** As a plant owner I want one notification in the morning listing the plants to
  water so that I don't need to open the app to check.
- **Rules & edge cases:** one notification per day at 08:00 (time configurable in F3), only if
  at least one plant is due. Tapping it opens the list. Android 13+: ask for the notification
  permission the first time a plant is added, not at app start.
- **Acceptance criteria:**
  - [ ] With two plants due, the notification text is "Water: Monstera, Fern".
  - [ ] No notification on a day with nothing due.

### F3 — Settings (Later)

- Reminder time, dark mode override.

## 4. Navigation

- **Top level:** single screen (plant list) with a settings icon (Later); form as a full screen.
- **Start screen:** plant list (empty state on first start).
- **Sign-in:** none.

## 5. Data

- **Main entities:** `Plant(id, name, photoUri?, intervalDays, lastWateredDate)`.
- **Where data lives:** only on the device (Room). No backend, no sync.
- **Offline:** everything works offline.
- **Sharing between users:** no.
- **Data to never collect or send anywhere:** anything. No analytics, no crash reporting SDK.

## 6. Integrations & backend

- **Backend:** none.
- **Third-party services/SDKs:** none; Coil for showing photos is OK.
- **Device features & permissions:** notifications, camera/gallery via the system photo picker
  (no storage permission), WorkManager for the daily reminder.

## 7. Design

- **Look & feel:** calm, lots of white space, green.
- **Brand colors:** primary `#2E7D32`, secondary "pick for me".
- **Typography / icon:** default Material 3; icon: a leaf with a water drop.
- **Mockups / sketches:** `docs/wireframes/plant-list-sketch.jpg` (photo of a paper sketch).
- **Dark mode:** yes.
- **Form factors:** phone only.

## 8. Non-functional

- **Min Android version:** API 26.
- **Languages:** English and Polish.
- **Accessibility:** defaults.
- **Privacy & security:** no backups needed.

## 9. Release

- **Distribution:** GitHub releases (APK).
- **First release scope:** F1 + F2.

## 10. Out of scope

- Plant identification from photos, fertilizing schedules, multiple users, widgets.

## 11. Open questions

- Should "watered" be undoable (accidental tap)? Assumption: yes, a snackbar with "Undo".
