# 0001 — Multi-module architecture for small agent contexts

**Status:** accepted (template default)  
**Date:** template  

## Context

An app built mostly by AI agents is changed in many short sessions, each with a limited context
window. In a single-module app every task drags in navigation, DI, data and unrelated screens:
agents read too much, guess more, and take "convenient" shortcuts between features that are hard
to undo. Running all screenshot tests for every change is slow.

## Decision

```
                 :app  (MainActivity, AppNavHost, Hilt composition root)
                   │
     ┌─────────────┼─────────────┐
:feature:a    :feature:b    :feature:c      (vertical slices; never depend on each other)
     └─────────────┼─────────────┘
                :core:ui  (AppTheme, tokens, shared components)
                   │
               :core:model  (domain models, cross-feature contracts)

  optional, added when requirements need them: :core:database, :core:network, :core:data
  test-only: :core:testing (screenshot helpers, shared fakes)
```

- **`:feature:<name>`**: UI (stateful screen → stateless content), ViewModel, repository, its own
  unit and Paparazzi tests. Public API = a route + `NavGraphBuilder.<name>Screen(callbacks)`.
- **Features never depend on each other.** Data from another feature → interface in
  `:core:model`, implemented by the owning feature, bound by Hilt. Navigation between features →
  callbacks wired in `:app`.
- **`:app`** is wiring only: no feature UI, state or data access.
- **Convention plugins** (`build-logic/`): `convention.android.feature` gives a feature module
  Compose, Hilt, Paparazzi, navigation and the core modules; a feature build file is ~5 lines.
  Namespaces are derived from the module path and `project.basePackage`.
- **Per-module `AGENTS.md`** (< 80 lines): scope, files, public contract, boundaries, commands.
  Agents read the module's file instead of the module.

## Consequences

- A task usually touches one feature module plus maybe `:core:model`; tests for one module run in
  seconds (`./scripts/verify.sh :feature:<name>`).
- More Gradle modules, more wiring in `:app`, contracts need a home and a KDoc.
- Enforced by `scripts/check-modular-boundaries.sh` (CI): feature isolation in build files and
  imports, core layering, test-only `:core:testing`, AGENTS.md present and short, no color
  literals in features.
