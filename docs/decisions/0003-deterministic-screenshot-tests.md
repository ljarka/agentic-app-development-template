# 0003 — Paparazzi screenshot tests under a fixed runtime

**Status:** accepted (template default)  
**Date:** template  

## Context

Agents change UI often and can alter details nobody asked for (spacing, colors, a missing state).
Unit tests don't see that. Screenshot tests do, but only if they are reproducible: a snapshot
that depends on the current time, locale, system dark mode or dynamic color produces flaky
diffs, and flaky diffs teach everyone (agents included) to re-record without looking.

## Decision

- Every feature module has Paparazzi tests (`<Feature>ScreenshotTest.kt`) for each distinct state
  of each screen (loading, empty, content, error), light and dark. Goldens are committed in
  `src/test/snapshots`.
- Tests use only `appPaparazzi()` and `snap(dark) { ... }` from `:core:testing`: fixed device
  (Pixel 6), fixed tolerance (0.1 %), explicit night mode, English locale, `AppTheme` with
  `dynamicColor = false`.
- Snapshots render the **stateless** `...Content(state)` composable with fixed data. Time-dependent
  text is computed from injected values (`TimeSource` in ViewModels, formatters as parameters).
- `verifyPaparazziDebug` runs in CI and `./scripts/verify.sh`; CI uploads diffs on failure.
- `recordPaparazziDebug` only for intentional UI changes, and the agent **looks at** the new PNGs
  before committing them.

## Consequences

- UI regressions are visible in the PR as image diffs.
- Each new state costs one test function; goldens add binary files to the repo.
- Paparazzi is a JVM renderer: device-specific behavior is covered by Maestro flows instead.
