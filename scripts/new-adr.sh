#!/usr/bin/env bash
# Creates the next ADR from docs/decisions/TEMPLATE.md and adds it to the index.
#   ./scripts/new-adr.sh "Offline-first storage with Room"
set -euo pipefail
[ "$#" -eq 1 ] || { echo "Usage: $0 \"<title>\""; exit 1; }
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/docs/decisions"
last=$(ls [0-9][0-9][0-9][0-9]-*.md 2>/dev/null | sed 's/-.*//' | sort -n | tail -1)
num=$(printf "%04d" $((10#${last:-0} + 1)))
slug=$(tr '[:upper:]' '[:lower:]' <<< "$1" | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')
file="$num-$slug.md"
sed -e "s/^# NNNN — Title/# $num — $1/" -e "s/YYYY-MM-DD/$(date +%F)/g" TEMPLATE.md > "$file"
echo "| [$num]($file) | $1 |" >> README.md
echo "docs/decisions/$file"
