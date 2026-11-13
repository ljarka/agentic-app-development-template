# 0004 — Guardrails for agent changes

**Status:** accepted (template default)  
**Date:** template  

## Context

Agents can produce large, plausible changes quickly. The failure modes are different from a
human's: very wide diffs, convenient couplings, catch-all error handling, ad-hoc loops, secrets
pasted into code, and instructions picked up from untrusted text. Review alone does not scale.

## Decision

Automated, transparent checks, the same locally (`./scripts/verify.sh`) and in CI:

| Check | Script | Fails when |
|---|---|---|
| Architecture boundaries | `check-modular-boundaries.sh` | feature→feature, core layering, missing/long AGENTS.md, color literals in features |
| Change scope | `check-agent-change-scope.sh` | > 60 files, > 6 code modules, or a critical path (`critical-paths.txt`) touched with > 3 modules |
| Secrets | `check-no-secrets-in-diff.sh` | token/key patterns in added lines, keystore/.env added |
| Debt radar | `debt-radar.sh` (CI: `STRICT=1`) | catch-all, `while (true)`, `runBlocking`, `GlobalScope`, `Thread.sleep`, `!!`, TODO, files > 500 lines grew above `debt-baseline.txt` |
| KPIs | `collect-agent-kpi.py` | never; writes `agent-kpi.json` per CI run (first-pass green, change size, tests, snapshot failures) |

- Large changes are allowed only explicitly: `ALLOW_LARGE_AGENT_DIFF=1` with reviewer approval
  (e.g. bootstrap phases, a mechanical rename).
- Critical paths have owners in `.github/CODEOWNERS`.

## Consequences

- Agents get fast, specific feedback instead of a reviewer's "this is too big".
- Thresholds are heuristics: tune them in the scripts with an amendment here, never silently.
