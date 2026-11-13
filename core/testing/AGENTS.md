# :core:testing — AGENTS.md

Shared test helpers. Used only as `testImplementation` (the feature convention plugin adds it).

## Scope

| File | Purpose |
|---|---|
| `Snapshots.kt` | `appPaparazzi()` rule + `Paparazzi.snap(dark) { ... }`: deterministic screenshots (theme, night mode, locale) |

## Rules

- Never an `implementation`/`api` dependency of production code (checked by `scripts/check-modular-boundaries.sh`).
- Add fakes of `:core:model` contracts here when two or more modules need the same fake.

## Verification

```bash
./gradlew :core:testing:assembleDebug
```
