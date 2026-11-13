---
name: new-feature
description: Add a new feature module (:feature:<name>) to this Android project the standard way - scaffold script, boundaries, navigation wiring, screenshots, docs. Use when a task needs a new screen group or vertical slice that does not belong to an existing feature module.
---

# Add a feature module

Follow `docs/playbooks/add-feature-module.md`. In short:

1. `./scripts/new-feature.sh <name>` (lowercase, e.g. `shopping`). Never copy another module.
2. Fill the TODO in `feature/<name>/AGENTS.md`; add a row to the module map in root `AGENTS.md`.
3. Wire it in `app/.../AppNavigation.kt` (import `<name>Screen`, call it in the `NavHost`,
   connect its callbacks). Top-level destination → bottom bar + `maestro/smoke.yaml`.
4. Data from another feature → contract in `:core:model`, never a feature→feature dependency.
5. `./gradlew :feature:<name>:recordPaparazziDebug`, then look at the PNGs.
6. `./scripts/verify.sh :feature:<name>`.
