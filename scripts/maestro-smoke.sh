#!/usr/bin/env bash
# Runs the Maestro device flows in maestro/ on a connected emulator/device (playbook: device testing).
#
#   ./scripts/maestro-smoke.sh                     # all flows, first connected device
#   DEVICE=emulator-5556 ./scripts/maestro-smoke.sh
#   ./scripts/maestro-smoke.sh maestro/smoke.yaml  # one flow
#
# Needs: maestro (https://maestro.dev), the debug app installed (./gradlew :app:installDebug).
# If the app talks to a backend: test credentials live OUTSIDE the repo in
# ~/.config/<project>/test.env (TEST_ENV overrides the path) and point at a TEST server, never
# production. Every MAESTRO_* variable in that file is visible to the flows as ${MAESTRO_...}.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$(sed -n 's/^rootProject\.name = "\(.*\)"/\1/p' "$ROOT/settings.gradle.kts")"
ENV_FILE="${TEST_ENV:-$HOME/.config/$PROJECT/test.env}"

command -v maestro >/dev/null || { echo "maestro not found: https://maestro.dev" >&2; exit 1; }
if [ -f "$ENV_FILE" ]; then
  set -a; source "$ENV_FILE"; set +a
fi

DEVICE_ARGS=()
[ -n "${DEVICE:-}" ] && DEVICE_ARGS=(--device "$DEVICE")

if [ $# -eq 0 ]; then set -- "$ROOT/maestro"; fi
exec maestro "${DEVICE_ARGS[@]+"${DEVICE_ARGS[@]}"}" test "$@"
