# 0002 — ktlint for Kotlin code style

**Status:** accepted (template default)  
**Date:** template  

## Context

Code written by people and by agents in many sessions drifts in style: imports, wrapping, braces,
trailing commas. Review time goes to noise and diffs mix formatting with real changes.

## Decision

- Gradle plugin `org.jlleitschuh.gradle.ktlint` applied to every subproject from the root
  `build.gradle.kts`; ktlint version is `ktlint` in `gradle/libs.versions.toml`. `build/` excluded.
- Rules in `.editorconfig` (the IDE formats the same way): `android_studio` style, 120 columns,
  4 spaces, trailing commas allowed (house style), PascalCase for `@Composable` functions.
- `./gradlew ktlintCheck` in CI and in `./scripts/verify.sh`; `./gradlew ktlintFormat` fixes almost
  everything. A file-level `@Suppress("ktlint:standard:<rule>")` only with a written reason.
- Versioned pre-commit hook (`scripts/git-hooks/pre-commit`, installed by
  `./scripts/install-git-hooks.sh`) formats only the staged `.kt`/`.kts` files.

## Consequences

- One style everywhere; formatting never discussed in review.
- A ktlint upgrade may bring new rules: upgrade on purpose, `ktlintFormat`, commit separately and
  list that commit in `.git-blame-ignore-revs`.
