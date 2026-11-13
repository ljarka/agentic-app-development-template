# Architecture decision records (ADRs)

Each file documents one significant decision: context, decision, consequences. Agents read the
ADRs a module's `AGENTS.md` links before changing that module. Create one with
`./scripts/new-adr.sh "<title>"` ([TEMPLATE.md](TEMPLATE.md)); it appends a row below.

An accepted ADR is changed only by the owner's decision: add an "Amendment YYYY-MM-DD" section
or a new ADR that supersedes it, never a silent edit.

## Index

| ADR | Topic |
|---|---|
| [0001](0001-modular-architecture.md) | Multi-module architecture for small agent contexts |
| [0002](0002-ktlint.md) | ktlint for Kotlin code style, pre-commit hook and CI |
| [0003](0003-deterministic-screenshot-tests.md) | Paparazzi screenshot tests under a fixed runtime |
| [0004](0004-agent-guardrails.md) | Guardrails for agent changes: scope, secrets, debt radar, KPIs |
| [0005](0005-serial-ksp.md) | One KSP task at a time (parallel KSP2 lost Hilt code) |
