# :feature:home — AGENTS.md

**Example feature** shipped with the template. It shows the expected shape of every feature;
during bootstrap it is repurposed as the app's first real screen or deleted
(`docs/BOOTSTRAP.md`, phase 5).

## Scope & Files

| File | Purpose |
|---|---|
| `HomeNavigation.kt` | Public contract: `HomeRoute` + `NavGraphBuilder.homeScreen()` |
| `HomeScreen.kt` | `HomeScreen` (stateful, gets the ViewModel) → `HomeContent` (stateless, screenshot-tested) |
| `HomeViewModel.kt` | `HomeUiState`, `HomeViewModel` (`StateFlow`, `TimeSource` injected) |
| `HomeViewModelTest.kt` | Unit test with a fixed time |
| `HomeScreenshotTest.kt` | Paparazzi: morning (light), evening (dark) |

## Pattern every feature follows

- Route + `NavGraphBuilder.<feature>Screen(...)` is the only public API; callbacks for leaving the feature.
- Screen = stateful wrapper + stateless `...Content(state, callbacks)`.
- ViewModel exposes one `StateFlow<...UiState>`; inputs come from `:core:model` contracts.
- Strings in `res/values/strings.xml`, colors from `MaterialTheme.colorScheme`.

## Dependencies & Boundaries

- Via `convention.android.feature`: `:core:model`, `:core:ui`, `:core:testing` (tests).
- **NEVER** depends on another feature module.

## Verification

```bash
./gradlew :feature:home:testDebugUnitTest :feature:home:verifyPaparazziDebug
./gradlew :feature:home:recordPaparazziDebug   # only on intentional UI changes
```
