# :app — AGENTS.md

Thin shell: Application, the single Activity, root navigation and the Hilt composition root.

## Scope & Files

| File | Purpose |
|---|---|
| `MainApplication.kt` | `@HiltAndroidApp` |
| `MainActivity.kt` | Edge-to-edge, `AppTheme`, `AppNavHost` |
| `AppNavigation.kt` | `AppNavHost`: adds each feature's `NavGraphBuilder.<feature>Screen()`, wires callbacks between features |
| `AppModule.kt` | Binds cross-module contracts from `:core:model` (e.g. `TimeSource`) |

## Rules

- The only module that depends on `:feature:*` modules.
- **NEVER** put feature UI, feature state or data access here. If it grows past wiring, it belongs in a feature or core module.
- Navigation root and `AppModule` are critical paths (`scripts/critical-paths.txt`): keep changes there small.

## Verification

```bash
./gradlew :app:assembleDebug
./scripts/maestro-smoke.sh   # device/emulator: maestro/smoke.yaml
```
