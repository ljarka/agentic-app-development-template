#!/usr/bin/env bash
# The local Definition-of-Done gate: the same checks CI runs, in the same order.
#
#   ./scripts/verify.sh                      # everything
#   ./scripts/verify.sh :feature:shopping    # boundaries + one module's tests/screenshots (fast loop)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

step() { printf '\n\033[1m== %s\033[0m\n' "$*"; }

step "Architecture boundaries"
./scripts/check-modular-boundaries.sh

if [ $# -gt 0 ]; then
  tasks=()
  for m in "$@"; do tasks+=("$m:ktlintCheck" "$m:testDebugUnitTest"); done
  for m in "$@"; do
    [[ "$m" == :feature:* ]] && tasks+=("$m:verifyPaparazziDebug")
  done
  step "Module checks: ${tasks[*]}"
  ./gradlew "${tasks[@]}"
else
  step "Code style, unit tests, screenshots, lint, build"
  ./gradlew ktlintCheck testDebugUnitTest verifyPaparazziDebug lintDebug assembleDebug
fi

step "Debt radar"
./scripts/debt-radar.sh

if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -n "$(git status --porcelain)" ]; then
  step "Secret scan (uncommitted changes)"
  if git diff HEAD | grep -nE '^\+.*(AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9_]{36,}|AIza[0-9A-Za-z_-]{35}|-----BEGIN .*PRIVATE KEY-----)'; then
    echo "[ERROR] Possible secret in uncommitted changes (above)."; exit 1
  fi
  echo "[OK] No high-confidence secrets in uncommitted changes."
fi

printf '\n\033[1;32mAll checks passed.\033[0m Remaining DoD items: module AGENTS.md, ADR/task/STATUS updates.\n'
