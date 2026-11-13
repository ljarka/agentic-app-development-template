# AI-Agent Mobile Development Playbook

Practical rules and engineering habits for building an Android app mostly with AI coding agents,
and where each one is implemented in this template.

The rules come from a real project (a multi-module family photo app built with agents over many
months), cross-checked against Android and CI best-practice references (sources at the end).
This template is that project's development environment with the product taken out.

---

## What characterizes an AI-agent-heavy mobile project

It is not defined by "AI-generated code". It is defined by **how the repository constrains and
verifies change**:

1. **Context is intentionally segmented.** The codebase is modular, and agents are told not to
   read everything at once. This reduces context overload and mistake propagation.
2. **Architecture rules are executable, not advisory.** Dependency boundaries are enforced by a
   script that runs in CI.
3. **Every module has local operating instructions.** Short `AGENTS.md` files define scope,
   dependencies, entry points and module-level verification commands.
4. **Visual regressions are first-class.** Screenshot tests run as part of normal verification,
   with diffs uploaded on failure.
5. **Planning and decisions are durable.** ADRs and a task queue with statuses make intent, order
   and completion criteria explicit for humans and agents.
6. **Scaffolding is standardized.** New features are created by scripts that encode the expected
   architecture from day one.
7. **Security assumptions are documented and bounded**, for the app at runtime *and* for the
   agents working on it.

## Rule → where it lives in this template

| # | Rule | Implemented by |
|---|---|---|
| 1 | Architecture boundaries as a testable contract | `scripts/check-modular-boundaries.sh`, CI |
| 2 | Repository structure for small context windows | modules + `AGENTS.md` "read only what you need" |
| 3 | Interface contracts between features | `:core:model`, Hilt bindings, `AppNavHost` callbacks |
| 4 | Short, local, executable module docs | `<module>/AGENTS.md` (< 80 lines, checked) |
| 5 | Standardized feature creation | `scripts/new-feature.sh`, `build-logic/` convention plugins |
| 6 | Deterministic visual testing by default | Paparazzi in every feature, `:core:testing` |
| 7 | CI mirrors local checks | `scripts/verify.sh` = `.github/workflows/ci.yml` |
| 8 | Decisions and task state in the repo | `docs/decisions/`, `docs/tasks/`, `docs/STATUS.md` |
| 9 | Strict Definition of Done | `AGENTS.md`, PR template |
| 10 | Explicit runtime security assumptions | `docs/ARCHITECTURE.md` trust boundaries |
| 11 | Shared primitives for repeated control flow | `pollEvery`, `TimeSource` in `:core:model` |
| 12 | Debt radar for AI-common failure modes | `scripts/debt-radar.sh` + baseline |
| 13 | Deterministic test runtime | `snap()` helper, injected time ([ADR 0003](../decisions/0003-deterministic-screenshot-tests.md)) |
| 14 | Agent KPI loop | `scripts/collect-agent-kpi.py`, CI artifact |
| 15 | AI-specific threat model | `docs/ARCHITECTURE.md#ai-threat-model`, secret scan |
| 16 | Machine-readable change-scope guardrails | `scripts/check-agent-change-scope.sh`, `critical-paths.txt`, CODEOWNERS |
| 17 | Backend–mobile contract checks | `docs/BOOTSTRAP.md` "Backend" (when the app has one) |

---

## 1) Treat architecture boundaries as a testable contract

**Rule:** If a boundary can be broken, it eventually will be, by humans or agents. Put
boundaries into automated checks.

**Why for AI agents:** Agents optimize for local completion; without hard boundaries they
introduce convenient but harmful couplings.

**How:**
- A boundary script that fails on forbidden dependencies (build files *and* imports).
- Run it before and after changes, and in CI on every PR.
- Keep checks simple and transparent; regex/static checks are an acceptable baseline.

**Here:** `scripts/check-modular-boundaries.sh` discovers modules from `settings.gradle.kts` and
checks feature isolation, core layering, test-only `:core:testing`, AGENTS.md size and color
literals in features.

## 2) Optimize repository structure for small context windows

**Rule:** A thin app shell, isolated feature modules and shared core contracts.

**Why for AI agents:** Smaller scope per task reduces hallucination risk and improves navigation
and edits.

**How:**
- Keep `:app` orchestration thin; feature logic lives in feature modules.
- Cross-feature interfaces in a stable core module.
- Make "read only what you need" an explicit contributor rule.

**Here:** [ADR 0001](../decisions/0001-modular-architecture.md); root `AGENTS.md` "Do not load
the whole project".

## 3) Use interface contracts for cross-feature communication

**Rule:** Never call sibling feature internals directly; communicate via contracts in a neutral
core layer.

**Why for AI agents:** Agents follow direct call paths; contracts prevent shortcut dependencies
that are hard to unwind later.

**How:** provider interfaces in `:core:model`; implementations bound in the composition root (or
the owning feature's Hilt module); navigation between features through callbacks wired in `:app`.

**Here:** `TimeSource` (contract) → bound in `app/.../AppModule.kt`; `HomeRoute` +
`NavGraphBuilder.homeScreen()` → used only by `AppNavHost`.

## 4) Make module docs short, local and executable

**Rule:** Each module exposes a concise operations card: scope, dependencies, entry points,
exact test commands.

**Why for AI agents:** Agents perform best with explicit, local constraints and concrete
commands, not broad prose.

**How:** `<module>/AGENTS.md` with a line budget; module-specific commands; existence and size
validated automatically; updating it is part of the Definition of Done.

## 5) Standardize feature creation via scripts

**Rule:** Never start a module from blank copy-paste.

**Why for AI agents:** Scaffolding drift compounds quickly when many agent edits happen in
parallel or over time.

**How:** one scaffolding script; a playbook explaining the architecture and validation path;
default dependencies in convention plugins so module build files stay tiny.

**Here:** `scripts/new-feature.sh`, [add-feature-module.md](add-feature-module.md),
`build-logic/src/main/kotlin/convention.android.feature.gradle.kts`.

## 6) Use deterministic visual testing as a default

**Rule:** UI snapshots are reproducible and checked in, with an explicit record/verify workflow.

**Why for AI agents:** Agents can unintentionally alter UI details; deterministic snapshots catch
subtle regressions quickly.

**How:** screenshot tests in each feature module; deterministic fixtures; clear `record` and
`verify` commands; diffs uploaded on CI failure.

**Here:** Paparazzi applied by the feature convention plugin; `verifyPaparazziDebug` in CI;
`**/build/paparazzi/failures/` uploaded.

## 7) Mirror local checks in CI and keep the matrix honest

**Rule:** CI runs the same critical checks engineers and agents run locally, plus a runtime
matrix where parity matters (e.g. backend language versions).

**Why for AI agents:** Changes can pass locally and fail under other runtime assumptions.

**Here:** `scripts/verify.sh` runs the same steps as `.github/workflows/ci.yml`; a commented
backend matrix job is ready for apps with a server.

## 8) Keep decisions and task state in-version, granular and current

**Rule:** Undocumented intent equals future rework.

**Why for AI agents:** Agents need current context about "why this exists" and "what is next" to
avoid contradictory changes.

**How:** ADRs for significant decisions; a task queue with statuses and dependencies; a
definition of "ready" (= implementable without further product decisions).

**Here:** `docs/decisions/`, `docs/tasks/`, `docs/STATUS.md`, `scripts/new-adr.sh`,
`scripts/new-task.sh`.

## 9) Encode a strict Definition of Done

**Rule:** "Code changed" is not done. "Verified + documented + traceable" is done.

**Why for AI agents:** Agents finish implementation quickly but skip integration duties unless
explicitly required.

**How:** green checks, module docs updated, ADR/task/status updated, commit hash recorded.

## 10) Make security assumptions explicit and environment-aware

**Rule:** Define trust boundaries, transport rules and auth modes in docs.

**Why for AI agents:** Security gaps come from implicit assumptions, e.g. local-only defaults
reused for internet exposure.

**How:** local network vs internet rules; required auth for external exposure; HTTP/HTTPS
constraints; token handling.

**Here:** `docs/ARCHITECTURE.md` "Trust boundaries", filled during bootstrap.

## 11) Reduce repeated control-flow patterns with shared primitives

**Rule:** When the same async control flow appears in several modules (poll loops, retries,
timers), extract one tested helper.

**Why for AI agents:** Ad-hoc loops drift over time and produce subtly different behavior.

**Here:** `pollEvery(...)` and `TimeSource` in `:core:model` with tests; the debt radar flags new
`while (true)` loops.

## 12) Keep a debt radar focused on AI-common failure modes

**Rule:** Continuously scan for patterns AI tools overproduce: broad exception catches,
unbounded loops, blocking calls, oversized multi-responsibility files.

**Why for AI agents:** These pass initial tests but degrade reliability and maintainability.

**Here:** `scripts/debt-radar.sh` counts them against `scripts/debt-baseline.txt`; CI fails when
debt grows (`STRICT=1`).

## 13) Enforce a deterministic runtime for visual checks

**Rule:** Snapshot tests run under fixed conditions: theme mode, locale, time-relative text,
stable fixtures.

**Why for AI agents:** Without it, flaky diffs get misread as regressions, or real regressions
hide in the noise, and blind re-recording becomes a habit.

**Here:** `snap(dark)` forces night mode, English locale and static colors; ViewModels get time
from `TimeSource`; snapshots render stateless content with fixed data.

## 14) Add an agent KPI loop

**Rule:** Measure agent output quality as an engineering signal, not anecdote.

**Why for AI agents:** Without measurement, teams optimize throughput (more patches) instead of
outcome (fewer regressions, less rework).

**Track:** first-pass green rate; rework ratio (follow-up fix commits per change); snapshot flake
rate; time-to-merge by change size.

**Here:** `scripts/collect-agent-kpi.py` writes `agent-kpi.json` on every CI run (artifact);
aggregate them over time (DORA metrics are a good frame).

## 15) Add an AI-specific threat model

**Rule:** Treat repository content and generated suggestions as potentially untrusted
instructions.

**Why for AI agents:** The risk is also in *agent operation*: prompt injection in
comments/files/web pages, unsafe command execution, accidental secret exposure.

**Here:** `docs/ARCHITECTURE.md#ai-threat-model`; root `AGENTS.md` "Agent safety";
`scripts/check-no-secrets-in-diff.sh` in CI; `.gitignore` for keystores and `.env`.

## 16) Add machine-readable change-scope guardrails

**Rule:** The acceptable blast radius of agent edits is enforced automatically.

**Why for AI agents:** Agents perform broad edits quickly; large implicit scope is a major source
of architectural drift.

**How:** path-level policy; fail CI above file/module thresholds unless explicitly approved;
reviewer gates on high-risk paths.

**Here:** `scripts/check-agent-change-scope.sh` (60 files / 6 modules / 3 with critical paths),
`scripts/critical-paths.txt`, `.github/CODEOWNERS`.

## 17) Protect backend–mobile contracts with schema checks

**Rule:** API compatibility is tested explicitly, not inferred from UI behavior.

**Why for AI agents:** Agents silently change DTO assumptions; failures show up late, in specific
flows only.

**How:** versioned API schema snapshots (OpenAPI/JSON schema); compatibility checks in CI;
consumer-oriented contract tests for the riskiest endpoints (auth, sync, writes).

**Here:** required by `docs/BOOTSTRAP.md` "Backend" as soon as the app has one.

---

## Recommended operating model (checklist)

1. **Constrain:** module boundaries + contracts + local module instructions.
2. **Generate:** scaffold from scripts, not blank files.
3. **Verify locally:** module tests + snapshots + boundary checks (`./scripts/verify.sh :module`).
4. **Verify globally:** CI runs architecture/test/lint/build and uploads artifacts.
5. **Document intent:** ADRs for choices, STATUS.md for execution order.
6. **Harden continuously:** debt radar for exceptions, polling, blocking and coupling.
7. **Stabilize test runtime:** locale/time/night mode fixed in snapshots.
8. **Measure outcomes:** first-pass green, rework, flake rate, time-to-merge.
9. **Constrain blast radius:** scope guard + critical paths.
10. **Secure the agent workflow:** threat model, secret scan by default.

---

## Sources

- **[E1]** Android Developers — Guide to app modularization: https://developer.android.com/topic/modularization
- **[E2]** Android Developers — Guide to app architecture (separation of concerns, SSOT, UDF): https://developer.android.com/topic/architecture
- **[E3]** Paparazzi (record/verify snapshots, failure diffs): https://github.com/cashapp/paparazzi
- **[E4]** GitHub Docs — Building and testing Java with Gradle: https://docs.github.com/en/actions/tutorials/build-and-test-code/java-with-gradle
- **[E5]** Cognitect — Documenting Architecture Decisions: https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions
- **[E6]** DORA — The Four Keys metrics: https://dora.dev/guides/dora-metrics-four-keys/
- **[E7]** OWASP GenAI Security Project — LLM/GenAI Top 10: https://genai.owasp.org/
- **[E8]** GitHub Docs — About code owners: https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners
- **[E9]** Pact — Contract testing: https://docs.pact.io/
- **[E10]** Google Play Console Help — Staged rollouts: https://support.google.com/googleplay/android-developer/answer/6346149
