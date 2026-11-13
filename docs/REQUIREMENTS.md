# Requirements

> **Fill this file in, then ask your agent: "Bootstrap the app from docs/REQUIREMENTS.md".**
> Write in any language, in plain words. Bullet points are fine; complete sentences are not needed.
> Leave a section as `TBD` when you don't know yet: the agent will ask instead of guessing.
> A filled-in example: [examples/REQUIREMENTS.example.md](examples/REQUIREMENTS.example.md).
>
> After bootstrap this file stays the product source of truth: change it first when the product
> changes, then ask the agent to plan the tasks that follow from the change.

## 1. Product

- **Name:** TBD
- **Package / application id:** TBD (e.g. `com.yourname.appname`; cannot change after the first release)
- **One sentence:** what the app is and for whom.
- **Problem it solves:** why someone installs it.
- **Success looks like:** how you will know it works (e.g. "the family uses one shopping list instead of chat messages").

## 2. Users

| Who | What they want | How often |
|---|---|---|
| TBD | TBD | TBD |

## 3. Features

One block per feature, in priority order. The agent turns each into a feature module and tasks.
Mark each with **MVP** (first release) or **Later**.

### F1 — <name> (MVP)

- **User story:** As a <user> I want to <action> so that <benefit>.
- **Screens:** list / detail / form / ...
- **Rules & edge cases:** empty state, limits, what happens offline, errors.
- **Acceptance criteria:**
  - [ ] ...
  - [ ] ...

### F2 — <name> (MVP / Later)

- ...

## 4. Navigation

- **Top level:** bottom tabs / single screen / drawer: which destinations?
- **Start screen:** what a first-time user sees; what a returning user sees.
- **Sign-in:** none / local only / account (which provider?).

## 5. Data

- **Main entities:** e.g. `ShoppingList(name, items)`, `Item(text, done)`.
- **Where data lives:** only on the device / own backend / third-party API (which?) / sync between devices?
- **Offline:** must work offline? Which parts?
- **Sharing between users:** yes/no; who sees what.
- **Data to never collect or send anywhere:** ...

## 6. Integrations & backend

- **Backend:** none / existing API (link to docs) / new backend to build (language preference?).
- **Third-party services/SDKs:** maps, payments, analytics, AI, push notifications, ... (each needs your OK).
- **Device features & permissions:** camera, location, notifications, photos, background work, ...

## 7. Design

- **Look & feel:** words (calm, playful, dense, ...) and apps you like.
- **Brand colors:** primary `#......`, secondary `#......` (or "pick for me").
- **Typography / icon:** preferences, or "default Material 3".
- **Mockups / sketches:** put images in `docs/wireframes/` and list them here.
- **Dark mode:** yes (default) / no.
- **Form factors:** phone only / phone + tablet / foldables / TV / ...

## 8. Non-functional

- **Min Android version:** default Android 8.0 (API 26).
- **Languages:** default English; others?
- **Accessibility:** default: TalkBack labels, 48dp touch targets, dynamic text size.
- **Performance / size / battery:** anything special?
- **Privacy & security:** sensitive data? Backups allowed? Screenshots allowed?

## 9. Release

- **Distribution:** Google Play / GitHub releases (APK) / internal only.
- **First release scope:** which features (default: everything marked MVP).
- **Deadline / milestones:** optional.

## 10. Out of scope

- Things the app deliberately does NOT do (prevents the agent from "helpfully" adding them).

## 11. Open questions

- Questions you already know are undecided. The agent adds its own here during bootstrap and
  moves answers into the sections above.
