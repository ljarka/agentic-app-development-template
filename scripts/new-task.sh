#!/usr/bin/env bash
# Creates the next task brief from docs/tasks/TEMPLATE.md. Add it to docs/STATUS.md yourself
# (the phase it belongs to is a planning decision).
#   ./scripts/new-task.sh "Shopping list screen"
set -euo pipefail
[ "$#" -eq 1 ] || { echo "Usage: $0 \"<title>\""; exit 1; }
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs/tasks"
last=$(ls T-[0-9][0-9][0-9]-*.md 2>/dev/null | sed 's/^T-//; s/-.*//' | sort -n | tail -1)
num=$(printf "%03d" $((10#${last:-0} + 1)))
slug=$(tr '[:upper:]' '[:lower:]' <<< "$1" | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')
file="T-$num-$slug.md"
sed -e "s/^# T-NNN — Title/# T-$num — $1/" TEMPLATE.md > "$file"
echo "docs/tasks/$file"
