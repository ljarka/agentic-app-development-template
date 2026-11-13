# 0005 — One KSP task at a time

**Status:** accepted (template default; lesson from a production project)  
**Date:** template  

## Context

KSP2 runs inside the Gradle daemon, so KSP tasks of several modules can run at once even without
`--parallel`. In a multi-module Hilt project this sometimes left one module with no generated
code, and `:app:hiltJavaCompile*` failed with a random `[Dagger/MissingBinding]`, locally and in
release CI. Agents then "fix" the binding by moving code around, which is wrong.

## Decision

- Root `build.gradle.kts` registers a `kspLock` build service with `maxParallelUsages = 1`; every
  `ksp*Kotlin` task uses it. Other tasks still run in parallel.
- After KSP in a Hilt module, a check fails the build **in that module** if Hilt annotations exist
  but no `hilt_aggregated_deps` were generated, with the message "Run the build again".

## Consequences

- Slightly longer clean builds; no more random MissingBinding failures.
- If you see the "generated no Hilt code" message: rerun, don't change code.
