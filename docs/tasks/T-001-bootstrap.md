# T-001 — Bootstrap the app from REQUIREMENTS.md

**Status:** ready (as soon as docs/REQUIREMENTS.md is filled in)  
**Modules:** all  
**Depends on:** docs/REQUIREMENTS.md  
**Procedure:** [docs/BOOTSTRAP.md](../BOOTSTRAP.md)

## Summary

Turn the template into the app described in REQUIREMENTS.md: identity, architecture, task queue,
module skeleton, MVP. This task is the checklist; BOOTSTRAP.md is the how. It is the one task
allowed to exceed the scope guard, **but only phase by phase** (one commit per phase).

## Checklist

- [ ] Phase 0 — baseline green (`./scripts/verify.sh`)
- [ ] Phase 1 — gaps listed, owner asked, answers in REQUIREMENTS.md
- [ ] Phase 2 — `init-project.sh` run, AGENTS.md "App:" line, README intro
- [ ] Phase 3 — module plan, ADRs, ARCHITECTURE.md, design tokens, critical paths
- [ ] Phase 4 — tasks T-002… `ready`, STATUS.md phases
- [ ] Phase 5 — core + feature modules scaffolded and wired, `:feature:home` repurposed/removed, smoke flow
- [ ] Phase 6 — MVP tasks `done` (each with its own commit and DoD)
- [ ] Phase 7 — bootstrap block removed from AGENTS.md, README, hand-over report

## Notes while implementing

_Assumptions made, questions asked and answered, deviations from the template (with ADR links)._
