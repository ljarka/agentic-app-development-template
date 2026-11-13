# Bootstrap: from requirements to a working app

Procedure for an AI agent turning this template into a concrete app described in
[REQUIREMENTS.md](REQUIREMENTS.md). Work phase by phase; every phase ends **green and committed**
(`./scripts/verify.sh`), so the owner can stop, review or roll back at any boundary.
Track progress in [tasks/T-001-bootstrap.md](tasks/T-001-bootstrap.md) (tick the boxes as you go).

**Golden rules for the whole bootstrap**

- Requirements are the contract. Do not add features, SDKs, permissions or screens that are not
  in REQUIREMENTS.md. If something is missing, **ask**; don't invent.
- Every decision that is not obvious from the requirements becomes an ADR (`./scripts/new-adr.sh`).
- Keep the template's guardrails: never weaken a check to make it pass. If a rule truly does not
  fit this app, change it through an ADR and update the script in the same commit.
- Small commits, one phase (or one task) per commit, message `bootstrap(phase N): ...`.

---

## Phase 0 — Baseline is green

```bash
./scripts/install-git-hooks.sh
./scripts/verify.sh
```

If it is not green on a fresh clone, stop and report (environment problem, not a code task).

## Phase 1 — Understand and close the gaps

1. Read REQUIREMENTS.md fully, and `docs/wireframes/` if it has images.
2. Write down every gap that would force you to guess: missing acceptance criteria, unclear data
   ownership, backend unknowns, sign-in, permissions, MVP boundary. Put them in section 11
   "Open questions" of REQUIREMENTS.md.
3. **Ask the owner** the blocking questions in one batch (multiple choice with your recommended
   option first works best). Record each answer in the right section of REQUIREMENTS.md and remove
   it from "Open questions". Non-blocking questions may stay open with your stated assumption.
4. Commit: `bootstrap(phase 1): clarified requirements`.

## Phase 2 — Identity

```bash
./scripts/init-project.sh "<App Name>" <base.package>
./scripts/verify.sh
```

- Fill the **App:** line at the top of AGENTS.md with the one-sentence description.
- Replace "Template App" mentions in README.md with the app's own README intro (keep the
  "Working with agents" and "Commands" sections).
- Commit: `bootstrap(phase 2): init project as <App Name>`.

## Phase 3 — Architecture

Decide and document, before writing feature code:

1. **Module plan.** One `:feature:<name>` per vertical slice the user sees (usually one per
   top-level destination or per REQUIREMENTS feature). Core modules only when needed:
   | Need in requirements | Module | Typical libs (already in the catalog) |
   |---|---|---|
   | Local persistence | `:core:database` | Room (`room-*`), DataStore |
   | Network / backend | `:core:network` | Retrofit, OkHttp, kotlinx.serialization |
   | Repositories combining both, offline-first | `:core:data` | — |
   | Background sync / reminders | inside the owning feature, or `:core:work` if shared | WorkManager + `hilt-work` |
   Data a second feature needs → a contract interface in `:core:model`.
2. **ADRs** (one per decision, `./scripts/new-adr.sh "..."`): data & persistence, backend & auth,
   navigation structure, any third-party service, anything the owner chose in Phase 1.
3. **docs/ARCHITECTURE.md:** module graph, data flow, trust boundaries (what talks to what, over
   which transport, with which credentials), the AI threat model section adjusted to this app.
4. **Design tokens:** brand colors → `core/ui/.../theme/Color.kt`, type → `Type.kt`, launcher icon
   colors (`app/src/main/res`). Snapshots of `:feature:home` will change: re-record and look.
5. **Critical paths:** add the new security/persistence/navigation-sensitive paths to
   `scripts/critical-paths.txt` (and `.github/CODEOWNERS` if the owner uses GitHub reviews).
6. Commit: `bootstrap(phase 3): architecture, ADRs, design tokens`.

## Phase 4 — Plan the work

1. Break every MVP feature into tasks with `./scripts/new-task.sh "<title>"`. Each task:
   - fits the scope guard (≤ 60 files, ≤ 6 code modules); split otherwise;
   - names its modules, its screens/states, acceptance criteria copied from REQUIREMENTS.md,
     the screenshots to add and the Maestro flow (if user-facing);
   - is `ready` only if an agent could implement it **without asking anything**.
2. Order: core modules (data/network) → each feature (data → ViewModel → UI → navigation) →
   cross-feature wiring → polish (empty/error states, accessibility, dark mode) → release prep.
3. Write [STATUS.md](STATUS.md): phases (MVP first), each row linking its task and status.
   "Later" features get `draft` tasks or a single row each.
4. Commit: `bootstrap(phase 4): task queue`.

## Phase 5 — Scaffold

1. Core modules from Phase 3: create `core/<name>/` with `build.gradle.kts`
   (`id("convention.android.library")` + its libs), `AGENTS.md`, `include(...)` in
   `settings.gradle.kts`. Add each to the AGENTS.md module map.
2. Feature modules: `./scripts/new-feature.sh <name>` for each, wire each into
   `app/.../AppNavigation.kt` (top-level destinations: add a bottom bar shell in `:app` if
   REQUIREMENTS says so).
3. `:feature:home`: repurpose it as the real start screen (rename via a new feature + delete) or
   delete it (`settings.gradle.kts`, `app/build.gradle.kts`, `AppNavigation.kt`, its snapshots).
4. Record snapshots, update `maestro/smoke.yaml` so it visits every top-level destination.
5. `./scripts/verify.sh`, commit: `bootstrap(phase 5): module skeleton`.

## Phase 6 — Build the MVP, task by task

For each `ready` task in STATUS.md order:

1. Mark it `in-progress` (task file + STATUS.md).
2. Read only the module `AGENTS.md` files the task names.
3. Implement with tests first where logic exists (ViewModel, repository, mappers):
   - ViewModel: one `StateFlow<UiState>`; unit tests for state transitions.
   - UI: stateless `...Content(state, callbacks)`; Paparazzi snapshot per distinct state, light + dark.
   - Data: fakes of contracts in tests; never real network in unit tests.
4. Fast loop: `./scripts/verify.sh :feature:<name>`; finish with full `./scripts/verify.sh`.
5. Device check when an emulator is available: `./gradlew :app:installDebug && ./scripts/maestro-smoke.sh`.
6. Definition of Done (AGENTS.md), then commit `feat(<module>): <task title> (T-xxx)`; put the
   commit hash in the task file and mark it `done`.

Stop and ask the owner when a task turns out to need a product decision: write the question in
the task file, mark it `draft`, and continue with the next independent task.

## Phase 7 — Hand over

1. Delete the `BOOTSTRAP:START … BOOTSTRAP:END` block from AGENTS.md.
2. README.md: what the app does, how to build/run, how to release.
3. `UPDATE_BASELINE=1 ./scripts/debt-radar.sh` only if remaining debt is listed in STATUS.md.
4. T-001 `done`; STATUS.md shows what is next ("Later" features, debt, release).
5. Report to the owner: what works, what was assumed (link ADRs), what is open.

---

## Backend (only if REQUIREMENTS.md needs one built)

- Lives in `server/` with its own `AGENTS.md`, tests and Dockerfile; CI job is ready (commented)
  in `.github/workflows/ci.yml`.
- The API contract is versioned (`server/openapi.yaml` or JSON schemas) and the app's DTOs are
  tested against it (playbook rule 17).
- Document exposure: local network vs internet, auth, HTTPS (docs/ARCHITECTURE.md, an ADR).
- Test server separate from any real data; credentials only in `~/.config/<project>/test.env`.
