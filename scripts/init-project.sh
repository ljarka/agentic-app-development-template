#!/usr/bin/env bash
# One-time identity change of the template: app name, base package (= applicationId),
# Gradle project name. Moves the source directories and rewrites every reference.
#
#   ./scripts/init-project.sh "Shopping Buddy" com.acme.shoppingbuddy
#
# Run on a clean working tree, then: ./scripts/verify.sh && git commit.
set -euo pipefail

[ "$#" -eq 2 ] || { echo "Usage: $0 \"<App Name>\" <base.package>"; exit 1; }
APP_NAME="$1"; NEW_PKG="$2"
[[ "$NEW_PKG" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]] || { echo "Invalid package: $NEW_PKG"; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
OLD_PKG="$(sed -n 's/^project\.basePackage=//p' gradle.properties)"
[ "$OLD_PKG" != "$NEW_PKG" ] || { echo "Package is already $NEW_PKG"; exit 1; }
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  echo "Working tree not clean: commit or stash first, so the rename is one reviewable commit."; exit 1
fi
SLUG="$(tr '[:upper:]' '[:lower:]' <<< "$APP_NAME" | tr -cs 'a-z0-9' '-' | sed 's/^-//; s/-$//')"
OLD_DIR="${OLD_PKG//.//}"; NEW_DIR="${NEW_PKG//.//}"

echo "Renaming $OLD_PKG -> $NEW_PKG, app \"$APP_NAME\", project \"$SLUG\""

# 1. Move source directories (every module, every source set).
while IFS= read -r d; do
  base="${d%/$OLD_DIR}"
  mkdir -p "$base/$NEW_DIR"
  (shopt -s dotglob nullglob; for item in "$d"/*; do [ -e "$item" ] && mv "$item" "$base/$NEW_DIR"/; done)
  # Remove the now-empty old package directories.
  p="$d"; while [ "$p" != "$base" ] && rmdir "$p" 2>/dev/null; do p="$(dirname "$p")"; done
done < <(find . -type d -path "*/src/*/$OLD_DIR" -not -path "*/build/*" -not -path "./.git/*")

# 2. Rewrite references in text files (code, Gradle, docs, Maestro, scripts).
OLD_RE="${OLD_PKG//./\\.}"
OLD_DIR_RE="${OLD_DIR//\//\\/}"
grep -rlI --exclude-dir={.git,build,.gradle,.kotlin,.idea} -e "$OLD_PKG" -e "$OLD_DIR" . | while read -r f; do
  perl -pi -e "s/$OLD_RE/$NEW_PKG/g; s/$OLD_DIR_RE/${NEW_DIR//\//\\/}/g" "$f"
done

# 3. Snapshot file names contain the package.
find . -path "*/src/test/snapshots/images/*" -name "${OLD_PKG}*" -not -path "*/build/*" | while read -r f; do
  mv "$f" "$(dirname "$f")/$(basename "$f" | sed "s/^$OLD_RE/$NEW_PKG/")"
done

# 4. Names (safely escaped for XML and Gradle Kotlin script).
python3 - "$APP_NAME" "$SLUG" <<'PY'
import sys, re, html

app_name, slug = sys.argv[1], sys.argv[2]

strings_path = "app/src/main/res/values/strings.xml"
escaped_name = html.escape(app_name, quote=False).replace("'", r"\'").replace('"', r'\"')
with open(strings_path, "r", encoding="utf-8") as f:
    strings_content = f.read()
strings_content = re.sub(
    r'<string name="app_name">.*?</string>',
    f'<string name="app_name">{escaped_name}</string>',
    strings_content,
)
with open(strings_path, "w", encoding="utf-8") as f:
    f.write(strings_content)

settings_path = "settings.gradle.kts"
with open(settings_path, "r", encoding="utf-8") as f:
    settings_content = f.read()
settings_content = re.sub(
    r'rootProject\.name\s*=\s*".*?"',
    f'rootProject.name = "{slug}"',
    settings_content,
)
with open(settings_path, "w", encoding="utf-8") as f:
    f.write(settings_content)
PY

# 5. Import order depends on the package name: reformat.
./gradlew --quiet ktlintFormat

echo "Done. Now: ./scripts/verify.sh, then commit (\"chore: init project as $APP_NAME\")."
