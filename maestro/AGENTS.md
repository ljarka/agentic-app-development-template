# maestro/ — device flows

- `smoke.yaml`: every top-level screen opens on a clean install. Update it with each new destination.
- One flow per risky user journey (`<feature>-<journey>.yaml`), named in the task's acceptance criteria.
- Shared steps in `subflows/`. Select by visible text or content description, not coordinates.
- Secrets/accounts only via `MAESTRO_*` env (`scripts/maestro-smoke.sh`), test backend only.
