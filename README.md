# Agentic App Development Template (Android)

A GitHub template for building Android apps **with AI coding agents** (Claude Code, Codex, Gemini
CLI, Cursor, …). You describe the app in one file; the agent turns the template into that app,
and keeps developing it inside guardrails designed for how agents work and fail.

It is not an empty project. It ships a working, tested Android skeleton, plus the environment
around it: instructions agents read, scripts that enforce the architecture, deterministic
screenshot tests, CI, and a step-by-step bootstrap procedure. It was extracted from a real
multi-module app developed mostly by agents (see
[the playbook](docs/playbooks/ai-agent-mobile-development.md)).

```
 you                         agent                                    repository
 ───                         ─────                                    ──────────
 docs/REQUIREMENTS.md ─────► docs/BOOTSTRAP.md (phases 0–7) ────────► your app
   "what"                     asks questions, renames project,          modules, ADRs, tasks,
                              plans modules/ADRs/tasks, scaffolds,      tests, screenshots, CI
                              builds MVP task by task                   all green
```

## Quick start

1. **Create your repo** from this template ("Use this template" on GitHub) and clone it.
2. **Check the environment** (JDK 21, Android SDK):
   ```bash
   ./scripts/install-git-hooks.sh
   ./scripts/verify.sh
   ```
3. **Describe your app** in [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md): product, users,
   features with acceptance criteria, navigation, data, integrations, design. Plain bullet points
   in any language are fine; write `TBD` where you don't know. Mockups go in `docs/wireframes/`.
   See the [filled-in example](docs/examples/REQUIREMENTS.example.md).
4. **Ask your agent:**
   > Bootstrap the app from docs/REQUIREMENTS.md.

   The agent reads [`AGENTS.md`](AGENTS.md) (Claude Code via [`CLAUDE.md`](CLAUDE.md)), follows
   [`docs/BOOTSTRAP.md`](docs/BOOTSTRAP.md), asks you the open questions in one batch, and then
   works phase by phase. Every phase ends green and committed, so you can review or stop at any
   point.
5. **Keep developing** the same way: change REQUIREMENTS.md (or just ask), the agent plans tasks
   in [`docs/STATUS.md`](docs/STATUS.md) and implements them one at a time with the Definition of
   Done.

No requirements yet? Ask the agent to interview you and write REQUIREMENTS.md with you first.

## What the bootstrap does

| Phase | Agent does | You do |
|---|---|---|
| 0 Baseline | Runs all checks on the untouched template | — |
| 1 Clarify | Lists gaps in the requirements, asks you | Answer (multiple choice, recommendation first) |
| 2 Identity | `init-project.sh "<Name>" <package>`: package, app id, names | — |
| 3 Architecture | Module plan, ADRs, trust boundaries, brand colors | Review ADRs |
| 4 Plan | Task briefs `T-002…` (each "ready" = implementable without questions), STATUS.md | Reorder / cut scope |
| 5 Scaffold | Core + feature modules, navigation, smoke flow | — |
| 6 Build | MVP task by task: tests, screenshots, device check, one commit each | Review commits/PRs |
| 7 Hand over | README, removes bootstrap notice, reports assumptions | — |

## What's inside

### The app skeleton

Kotlin · Jetpack Compose · Material 3 · Hilt · Navigation (type-safe routes) · coroutines/Flow ·
Gradle convention plugins · version catalog (with pre-vetted optional libs: Retrofit, OkHttp,
Room, DataStore, WorkManager, Coil).

```
:app            thin shell: MainActivity, AppNavHost, Hilt composition root
:feature:home   example feature (route, stateful/stateless screen, ViewModel, unit + screenshot tests)
:core:ui        AppTheme, design tokens, LoadingState / MessageState
:core:model     domain models, cross-feature contracts, pollEvery, TimeSource
:core:testing   appPaparazzi() + snap(dark): deterministic screenshot helpers (tests only)
build-logic/    convention.android.{application,library,feature}: a feature build file is ~5 lines
```

### The agent environment

| Piece | Where | Why |
|---|---|---|
| Agent index | [`AGENTS.md`](AGENTS.md), `CLAUDE.md` | Rules, where knowledge lives, Definition of Done, < 150 lines |
| Module cards | `<module>/AGENTS.md` | Scope, files, contract, commands; < 80 lines so agents read the card, not the module |
| Requirements | [`docs/REQUIREMENTS.md`](docs/REQUIREMENTS.md) | The product source of truth you edit |
| Bootstrap procedure | [`docs/BOOTSTRAP.md`](docs/BOOTSTRAP.md) | Requirements → app, phase by phase |
| Roadmap & tasks | [`docs/STATUS.md`](docs/STATUS.md), [`docs/tasks/`](docs/tasks/README.md) | What next, in which order, with acceptance criteria |
| Decisions | [`docs/decisions/`](docs/decisions/README.md) | ADRs: why it's built this way (5 included) |
| Architecture | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Module graph, data flow, trust boundaries, **AI threat model** |
| Playbooks | [`docs/playbooks/`](docs/playbooks/) | Add a feature, device testing, the rules behind it all |
| Skills | `.agents/skills/` (`.claude/skills` → symlink) | `bootstrap-app`, `new-feature`, `finish-task` + Google's Android skills (adaptive, edge-to-edge, Compose performance) |
| Device flows | `maestro/` | Maestro smoke test on an emulator |

### Guardrails (run locally by `./scripts/verify.sh` and in CI)

| Script | Stops |
|---|---|
| `check-modular-boundaries.sh` | feature→feature deps/imports, wrong core layering, missing/long AGENTS.md, color literals in features |
| `check-agent-change-scope.sh` | > 60 files, > 6 modules, or wide changes touching critical paths (`scripts/critical-paths.txt`) |
| `check-no-secrets-in-diff.sh` | tokens/keys in added lines, keystores or `.env` committed |
| `debt-radar.sh` | growth of catch-all, `while (true)`, `runBlocking`, `GlobalScope`, `!!`, TODOs, files > 500 lines |
| ktlint (+ pre-commit hook) | style drift ([ADR 0002](docs/decisions/0002-ktlint.md)) |
| Paparazzi `verifyPaparazziDebug` | unintended UI changes ([ADR 0003](docs/decisions/0003-deterministic-screenshot-tests.md)) |
| `collect-agent-kpi.py` | nothing: records first-pass-green, change size and test results per CI run |

Scaffolding: `new-feature.sh`, `new-task.sh`, `new-adr.sh`, `init-project.sh`.

## The playbook behind it

[`docs/playbooks/ai-agent-mobile-development.md`](docs/playbooks/ai-agent-mobile-development.md)
describes 17 rules for building mobile apps with AI agents, learned on a real project and
checked against Android, CI and security references. The core idea: an agent-heavy project is
defined not by AI-generated code but by **how the repository constrains and verifies change**.

1. **Boundaries are executable** — a script, not a wiki page, says features can't depend on each other.
2. **Small contexts** — thin app shell, isolated feature modules, contracts in a core module; agents read one module's card, not the project.
3. **Contracts between features** — interfaces in `:core:model`, wired in `:app`.
4. **Short local docs** — every module has a < 80-line `AGENTS.md` with exact commands.
5. **Scaffold, don't copy** — scripts and convention plugins create modules in the right shape.
6. **Screenshots by default** — every screen state, light and dark, checked in CI.
7. **CI = local** — the same `verify.sh` everywhere.
8. **Intent in the repo** — ADRs, task briefs, a status board; "ready" means no open product questions.
9. **Strict Definition of Done** — verified, documented, traceable.
10. **Explicit security assumptions** — trust boundaries written down.
11. **Shared primitives** — one tested `pollEvery` instead of ad-hoc loops.
12. **Debt radar** — count what agents overproduce.
13. **Deterministic tests** — fixed time, locale, theme in snapshots.
14. **KPIs** — first-pass green rate, rework, flakiness, time-to-merge.
15. **AI threat model** — repo/web text is data, not instructions; secret scanning by default.
16. **Blast-radius limits** — change-scope guard and critical paths.
17. **Contract tests** — when there is a backend, its API schema is versioned and checked.

Each rule in the playbook says why it matters for agents, how to implement it, and where it lives
in this template.

## Commands

```bash
./scripts/verify.sh                               # everything CI runs
./scripts/verify.sh :feature:home                 # fast loop for one module
./scripts/new-feature.sh <name>                   # new :feature:<name>
./gradlew :feature:<name>:recordPaparazziDebug    # re-record screenshots (intentional UI change)
./gradlew ktlintFormat                            # fix code style
./gradlew :app:installDebug && ./scripts/maestro-smoke.sh   # device smoke test (Maestro)
```

## Requirements

- JDK 21 and the Android SDK (compileSdk 37). Android Studio works but isn't required.
- Optional: [Maestro](https://maestro.dev) and an emulator for device flows.
- An AI coding agent that reads `AGENTS.md` (or `CLAUDE.md`).

## Releases

Push a tag `v1.2.3` → `.github/workflows/release.yml` builds a signed APK and creates a GitHub
release. Add the repository secrets `APP_KEYSTORE_BASE64` (`base64 -i release.jks`),
`APP_KEYSTORE_PASSWORD`, `APP_KEY_ALIAS`, `APP_KEY_PASSWORD`. Keep the keystore out of the repo.

## Adapting the template

- SDK levels: `build-logic/src/main/kotlin/AppSdk.kt`. Versions: `gradle/libs.versions.toml`.
- Guardrail thresholds: env variables at the top of each script; change them with an amendment to
  [ADR 0004](docs/decisions/0004-agent-guardrails.md).
- Critical paths: `scripts/critical-paths.txt` and `.github/CODEOWNERS` (uncomment, set your handle).
- Choose a license for your project (none is included).
