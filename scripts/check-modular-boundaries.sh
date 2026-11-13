#!/usr/bin/env bash
# Architecture boundaries as an executable contract (docs/decisions/0001-modular-architecture.md).
# Modules are discovered from settings.gradle.kts, so nothing here needs editing when one is added.
# Run before and after every change; CI runs it on every push and pull request.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

BASE_PACKAGE="$(sed -n 's/^project\.basePackage=//p' gradle.properties)"
MAX_AGENTS_LINES="${MAX_AGENTS_LINES:-80}"
FAILED=0
fail() { echo "  [ERROR] $*"; FAILED=1; }
ok() { echo "  [OK] $*"; }

MODULES=()
while IFS= read -r m; do MODULES+=("$m"); done < <(
  sed -n 's/^include("\(:[^"]*\)")/\1/p' settings.gradle.kts
)
dir_of() { local p="${1#:}"; echo "${p//://}"; }

echo "=== Modular architecture boundaries (${#MODULES[@]} modules) ==="

echo "1. Every module exists and has a short AGENTS.md"
for m in "${MODULES[@]}"; do
  d="$(dir_of "$m")"
  [ -f "$d/build.gradle.kts" ] || { fail "$m: $d/build.gradle.kts missing"; continue; }
  if [ ! -f "$d/AGENTS.md" ]; then
    fail "$m: $d/AGENTS.md missing"
  else
    lines=$(wc -l < "$d/AGENTS.md" | tr -d ' ')
    if [ "$lines" -gt "$MAX_AGENTS_LINES" ]; then
      fail "$d/AGENTS.md has $lines lines (max $MAX_AGENTS_LINES: move details to an ADR or task)"
    else
      ok "$d/AGENTS.md ($lines lines)"
    fi
  fi
done
lines=$(wc -l < AGENTS.md | tr -d ' ')
[ "$lines" -le 150 ] && ok "AGENTS.md ($lines lines)" || fail "AGENTS.md has $lines lines (max 150)"

echo "2. Features never depend on other features (build files and imports)"
for m in "${MODULES[@]}"; do
  [[ "$m" == :feature:* ]] || continue
  d="$(dir_of "$m")"; name="${m##*:}"
  if grep -nE 'project\(":feature:|projects\.feature\.' "$d/build.gradle.kts"; then
    fail "$m depends on another feature module"
  fi
  if [ -d "$d/src" ] && grep -rnE "^import ${BASE_PACKAGE//./\\.}\.feature\.[a-z_0-9]+" "$d/src" \
      | grep -vE "^[^:]+:[0-9]+:import ${BASE_PACKAGE//./\\.}\.feature\.${name}(\.|$)"; then
    fail "$m imports code of another feature"
  fi
  ok "$m is isolated"
done

echo "3. Core modules stay below features"
for m in "${MODULES[@]}"; do
  [[ "$m" == :core:* ]] || continue
  d="$(dir_of "$m")"
  if grep -nE 'project\(":feature:|project\(":app"' "$d/build.gradle.kts"; then
    fail "$m depends on a feature or :app"
  fi
done
if [ -f core/model/build.gradle.kts ] && grep -nE 'project\(' core/model/build.gradle.kts; then
  fail ":core:model must not depend on any module"
fi
if [ -f core/ui/build.gradle.kts ] && grep -nE 'project\(":core:(network|database|data)' core/ui/build.gradle.kts; then
  fail ":core:ui must not depend on network/database/data"
fi
for f in app/build.gradle.kts core/*/build.gradle.kts feature/*/build.gradle.kts; do
  [ -f "$f" ] || continue
  if grep -nE '^\s*(implementation|api|compileOnly)\(project\(":core:testing"\)\)' "$f"; then
    fail "$f: :core:testing is test-only (testImplementation)"
  fi
done
[ "$FAILED" -eq 0 ] && ok "core layering respected"

echo "4. Only :app depends on features"
for f in core/*/build.gradle.kts; do
  [ -f "$f" ] && grep -qE 'project\(":feature:' "$f" && fail "$f depends on a feature"
done
ok "checked"

echo "5. Design tokens: no color literals in features (use MaterialTheme.colorScheme)"
if ls -d feature/*/src/main >/dev/null 2>&1 && grep -rnE 'Color\(0x[0-9A-Fa-f]{6,8}\)' feature/*/src/main; then
  fail "color literals found in feature code: move them to :core:ui theme"
else
  ok "no color literals in features"
fi

if [ "$FAILED" -ne 0 ]; then
  echo "=== Modular boundaries check FAILED ==="
  exit 1
fi
echo "=== All modular boundaries checks PASSED ==="
