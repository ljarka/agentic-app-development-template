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
python3 - "$num" "$file" "$1" "$(date +%F)" <<'PY'
import sys
num, file_path, title, today = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
with open("TEMPLATE.md", "r", encoding="utf-8") as f:
    text = f.read()
text = text.replace("# NNNN — Title", f"# {num} — {title}").replace("YYYY-MM-DD", today)
with open(file_path, "w", encoding="utf-8") as f:
    f.write(text)
PY
escaped_title=$(echo "$1" | sed 's/|/\\|/g')
echo "| [$num]($file) | $escaped_title |" >> README.md
echo "docs/decisions/$file"
