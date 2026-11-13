# :core:ui — AGENTS.md

Design system: theme, tokens and reusable Compose components. No feature logic.

## Scope

| File | Purpose |
|---|---|
| `theme/Color.kt` | Brand palette: the only file with color literals |
| `theme/Theme.kt` | `AppTheme(darkTheme, dynamicColor = false)`: wraps every screen and screenshot |
| `theme/Type.kt`, `theme/Dimens.kt` | Type scale, spacing tokens (`Dimens.SpaceM`, ...) |
| `component/StateViews.kt` | `LoadingState`, `MessageState` (empty / error with action) |

## Rules

- Features read colors from `MaterialTheme.colorScheme`, never `Color(0x...)`.
- A component used by two or more features moves here (with a screenshot in the first user's test).
- Depends on `:core:model` only. Never on `:core:network`, `:core:database` or any feature.

## Verification

```bash
./gradlew :core:ui:assembleDebug
```
