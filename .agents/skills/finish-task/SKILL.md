---
name: finish-task
description: Complete a task in this Android project according to the Definition of Done - run all checks, review screenshots, update module AGENTS.md, ADRs, task file and STATUS.md, commit with the task id. Use when implementation of a T-xxx task is finished or the user asks to wrap up, verify or commit a task.
---

# Finish a task (Definition of Done)

1. `./scripts/verify.sh` — must be green. Fix causes; never weaken a check, raise a threshold or
   re-record snapshots just to pass.
2. Snapshots: if any changed, record on purpose (`./gradlew :<module>:recordPaparazziDebug`) and
   **look at** every new/changed PNG under `src/test/snapshots/images/`.
3. Device: if user-facing and an emulator is available, `./gradlew :app:installDebug` and
   `./scripts/maestro-smoke.sh` (plus the task's own flow). Note the result in the task file.
4. Docs: every touched module's `AGENTS.md` (< 80 lines); root module map; ADR (`./scripts/new-adr.sh`)
   for any new decision; `./scripts/debt-radar.sh` shows no ↑ (or the reason is in the task).
5. Commit: `feat(<module>): <title> (T-xxx)` (or fix/refactor/docs). Then put the hash into the
   task file (`**Status:** done (<hash>)`) and `docs/STATUS.md`, and commit that.
6. Check `./scripts/check-agent-change-scope.sh` for the change; if it fails, split the change.
7. Tell the user: what changed, how it was verified, what is next in STATUS.md.
