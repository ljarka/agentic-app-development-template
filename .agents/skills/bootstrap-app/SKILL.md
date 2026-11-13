---
name: bootstrap-app
description: Turn this Android app template into the concrete app described in docs/REQUIREMENTS.md (clarify requirements, rename the project, plan architecture and tasks, scaffold modules, build the MVP). Use when the user asks to bootstrap, create, generate or start the app from requirements, or when AGENTS.md still shows the BOOTSTRAP block.
---

# Bootstrap the app

1. Check `docs/REQUIREMENTS.md`. If it is still the empty template (sections say `TBD`), ask the
   user to fill it in or to describe the app now; offer to write REQUIREMENTS.md with them from
   their description (show it to them for confirmation before continuing).
2. Follow `docs/BOOTSTRAP.md` phase by phase. It is the procedure; do not skip phases.
3. Track progress in `docs/tasks/T-001-bootstrap.md` (tick the checklist, write assumptions).
4. End every phase with `./scripts/verify.sh` green and one commit
   (`bootstrap(phase N): ...`). Large phases may need `ALLOW_LARGE_AGENT_DIFF=1` in CI; say so.
5. Phase 1 questions go to the user in one batch, recommended option first. Never invent product
   decisions; record each answer in REQUIREMENTS.md.
6. In phase 6 use the `new-feature` and `finish-task` skills for each task.
