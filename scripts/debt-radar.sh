#!/usr/bin/env bash
# Debt radar (playbook rule 12): counts patterns AI agents tend to overproduce. Report-only by
# default; STRICT=1 fails when a count grows above the baseline in scripts/debt-baseline.txt.
#
#   ./scripts/debt-radar.sh                     # report
#   STRICT=1 ./scripts/debt-radar.sh            # CI mode
#   UPDATE_BASELINE=1 ./scripts/debt-radar.sh   # after paying debt down (or with a reason in the task)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
BASELINE=scripts/debt-baseline.txt
MAX_FILE_LINES="${MAX_FILE_LINES:-500}"

# name<TAB>regex<TAB>why   (regex counted over production Kotlin: */src/main/**/*.kt)
CHECKS="$(printf '%s\t%s\t%s\n' \
  'broad_catch' 'catch \([a-zA-Z_]+: (Exception|Throwable)\)' 'catch-all hides cancellation and real bugs' \
  'while_true' 'while \(true\)' 'use pollEvery() from :core:model' \
  'run_blocking' 'runBlocking' 'blocks a thread in production code' \
  'global_scope' 'GlobalScope' 'unscoped coroutines leak' \
  'thread_sleep' 'Thread\.sleep' 'blocks a thread in production code' \
  'not_null_assert' '[a-zA-Z0-9_)]!!' '!! crashes instead of handling null' \
  'todo' '(TODO|FIXME)' 'unfinished work left in code')"

FILES="$(find app core feature -path '*/src/main/*' -name '*.kt' -not -path '*/build/*' 2>/dev/null || true)"
count() {
  [ -z "$FILES" ] && { echo 0; return; }
  echo "$FILES" | { xargs grep -nE "$1" 2>/dev/null || true; } | wc -l | tr -d " "
}
large_files() {
  [ -z "$FILES" ] && { echo 0; return; }
  echo "$FILES" | { xargs wc -l || true; } | awk -v m="$MAX_FILE_LINES" '$2 != "total" && $1 > m' | wc -l | tr -d ' '
}
baseline() { [ -f "$BASELINE" ] && sed -n "s/^$1=//p" "$BASELINE" | head -1 || true; }

RESULTS=""
while IFS=$'\t' read -r name regex why; do
  [ -z "$name" ] && continue
  RESULTS="$RESULTS$name|$(count "$regex")|$why"$'\n'
done <<< "$CHECKS"
RESULTS="$RESULTS""large_files|$(large_files)|files over $MAX_FILE_LINES lines: split by responsibility"$'\n'

if [ "${UPDATE_BASELINE:-0}" = 1 ]; then
  echo "$RESULTS" | awk -F'|' 'NF >= 2 { print $1 "=" $2 }' > "$BASELINE"
  echo "Baseline updated: $BASELINE"; exit 0
fi

echo "=== Debt radar (production Kotlin) ==="
grew=0
while IFS='|' read -r name now why; do
  [ -z "$name" ] && continue
  base="$(baseline "$name")"; base="${base:-0}"
  mark="  "
  if [ "$now" -gt "$base" ]; then mark="↑ "; grew=1; fi
  printf "%s%-16s %4s (baseline %s)  %s\n" "$mark" "$name" "$now" "$base" "$why"
done <<< "$RESULTS"
if [ "$grew" = 1 ]; then
  echo "Debt grew (↑). Fix it, or justify it in the task file and run UPDATE_BASELINE=1."
  [ "${STRICT:-0}" = 1 ] && exit 1
fi
exit 0
