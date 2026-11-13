# :core:model — AGENTS.md

Pure domain layer shared by every module: data classes and cross-feature contracts.

## Scope

| File | Purpose |
|---|---|
| `Polling.kt` | `pollEvery(...)`: the only allowed periodic-refresh loop (no hand-written infinite loops) |
| `TimeSource.kt` | Injected clock; features never call `now()` directly (deterministic tests) |

## Rules

- No Compose, no Android UI, no network, no database. Depends on nothing but coroutines.
- Models are immutable (`val`, data classes). No logic beyond small pure helpers.
- **Cross-feature contracts live here** (e.g. `interface XyzProvider`): the owning feature
  implements it, `:app` (or the owning feature's Hilt module) binds it, other features consume it.
- Keep every contract documented with a KDoc line naming the implementing module.

## Verification

```bash
./gradlew :core:model:testDebugUnitTest
```
