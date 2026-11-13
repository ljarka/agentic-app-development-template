# Playbook: add a feature module

Use for every new user-facing capability. Never create a module by copying another one.

## 1. Scaffold

```bash
./scripts/new-feature.sh <name>        # e.g. shopping → :feature:shopping
```

Creates `feature/<name>/` with build file, `AGENTS.md`, `<Name>Navigation.kt` (route +
`NavGraphBuilder.<name>Screen()`), `<Name>Screen.kt` (stateful + stateless), `<Name>ViewModel.kt`
(`UiState` + `StateFlow`), a unit test, a screenshot test, `strings.xml`; registers the module in
`settings.gradle.kts` and `app/build.gradle.kts`.

## 2. Respect the boundaries

1. **No feature → feature dependency**, not in Gradle and not in imports.
2. Need another feature's data? Look for a contract in `:core:model`. None? Add an interface
   there (with KDoc naming the implementing module), implement it in the owning feature, bind it
   with Hilt (`@Binds` in the owning feature, or `:app/AppModule.kt` for app-wide things).
3. Need to open another feature's screen? Take a callback (`onOpenX: (id) -> Unit`) in your
   `NavGraphBuilder` extension; `:app` connects it to the other feature's route.
4. Models shared by two modules → `:core:model`. A component used by two features → `:core:ui`.
   Network → `:core:network`, persistence → `:core:database` (create them per BOOTSTRAP.md if missing).

## 3. UI and screenshots

1. Keep `...Content(state, callbacks)` stateless; all strings in `res/values/strings.xml`;
   colors from `MaterialTheme.colorScheme`, spacing from `Dimens`.
2. One snapshot per distinct state (loading, empty, content, error), plus dark for the main one:
   `paparazzi.snap(dark = true) { ... }`.
3. Record and look at the images:
   ```bash
   ./gradlew :feature:<name>:recordPaparazziDebug
   ```

## 4. Hook into `:app`

1. `app/.../AppNavigation.kt`: `import <base>.feature.<name>.<name>Screen` and call it inside
   the `NavHost`; connect its callbacks.
2. Top-level destination? Add it to the app's bottom bar/rail and to `maestro/smoke.yaml`.

## 5. Document and verify

1. Fill the module `AGENTS.md` (scope, files, public contract, boundaries) and add a row to the
   module map in the root `AGENTS.md`.
2. ```bash
   ./scripts/verify.sh :feature:<name>    # fast
   ./scripts/verify.sh                    # before commit
   ```
