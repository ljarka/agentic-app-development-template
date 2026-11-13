# Task queue

One implementation brief per task (`T-<number>-<slug>.md`), created with
`./scripts/new-task.sh "<title>"` from [TEMPLATE.md](TEMPLATE.md).

## Source of truth

- **Order, status and priorities:** [`../STATUS.md`](../STATUS.md)
- **Why things are built this way:** [`../decisions/`](../decisions/README.md)
- **What the product must do:** [`../REQUIREMENTS.md`](../REQUIREMENTS.md)

## Conventions

- Status values: `draft`, `ready`, `in-progress`, `done`, `blocked`.
- **`ready` means an agent can implement the task without any further product decision.**
  If you have to guess, it is `draft`: write the question in the task and ask the owner.
- A task fits one reviewable change: ≤ 60 files, ≤ 6 code modules (scope guard). Split bigger ones.
- When done: status `done (<commit hash>)` in the task file and in STATUS.md. Keep the file as the
  implementation record (what was decided while building it, device check results).
