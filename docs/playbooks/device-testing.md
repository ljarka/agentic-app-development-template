# Playbook: device testing with Maestro

Unit and screenshot tests run on the JVM. What they cannot see (real navigation, permissions,
keyboard, system dialogs, process death, real backend) is checked on an emulator with
[Maestro](https://maestro.dev) flows in `maestro/`.

## Run

```bash
./gradlew :app:installDebug
./scripts/maestro-smoke.sh                       # all flows
./scripts/maestro-smoke.sh maestro/smoke.yaml    # one flow
DEVICE=emulator-5556 ./scripts/maestro-smoke.sh  # a specific device
```

Agents with a Maestro MCP server can also inspect the screen and run inline flows directly
(`list_devices` → `inspect_screen` → `run`); prefer that over raw `adb` taps.

## Write flows

- `smoke.yaml` visits every top-level destination after a clean install: keep it updated.
- One flow per risky journey: `maestro/<feature>-<journey>.yaml`, named in the task's acceptance
  criteria. Shared steps (open app, login) in `maestro/subflows/`.
- Select elements by visible text or content description (which also keeps accessibility honest),
  never by coordinates.

## Test accounts and backends

- **Never** run flows against production or a real person's account.
- Credentials and test-server addresses live outside the repo in
  `~/.config/<project>/test.env` (`<project>` = `rootProject.name`), e.g.:
  ```bash
  MAESTRO_TEST_EMAIL=test@example.com
  MAESTRO_TEST_PASSWORD=...
  MAESTRO_API_URL=http://10.0.2.2:5051    # the host machine as seen from the emulator
  ```
  `scripts/maestro-smoke.sh` exports them; flows use `${MAESTRO_TEST_EMAIL}`.
- Flows that need data create it themselves (a Maestro `runScript` against the **test** server),
  so they don't depend on leftovers from earlier runs.
- No emulator screenshots with personal data in the repo.
