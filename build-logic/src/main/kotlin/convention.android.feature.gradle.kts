/**
 * A feature module (`:feature:<name>`): library + Compose + Hilt + Paparazzi + the core
 * modules every feature may use. A feature build file then only lists what is special to it.
 *
 * Features never depend on each other (docs/decisions/0001-modular-architecture.md,
 * enforced by scripts/check-modular-boundaries.sh).
 */
plugins {
    id("convention.android.library")
}

// Applied by id: the root build.gradle.kts puts these plugins on the classpath (`apply false`).
pluginManager.apply("org.jetbrains.kotlin.plugin.compose")
pluginManager.apply("org.jetbrains.kotlin.plugin.serialization")
pluginManager.apply("com.google.devtools.ksp")
pluginManager.apply("com.google.dagger.hilt.android")
pluginManager.apply("app.cash.paparazzi")

android {
    buildFeatures {
        compose = true
    }
}

val libs = the<VersionCatalogsExtension>().named("libs")
fun lib(alias: String) = libs.findLibrary(alias).get()

dependencies {
    "implementation"(project(":core:model"))
    "implementation"(project(":core:ui"))
    "testImplementation"(project(":core:testing"))

    "ksp"(lib("hilt-android-compiler"))
    "implementation"(lib("hilt-android"))
    "implementation"(lib("hilt-navigation-compose"))
    "implementation"(lib("navigation-compose"))
    "implementation"(lib("kotlin-serialization-json"))
    "implementation"(platform(lib("androidx-compose-bom")))
    "implementation"(lib("androidx-ui"))
    "implementation"(lib("androidx-ui-graphics"))
    "implementation"(lib("androidx-ui-tooling-preview"))
    "implementation"(lib("androidx-material3"))
    "implementation"(lib("material-icons-core"))
    "implementation"(lib("androidx-lifecycle-runtime-compose"))
    "debugImplementation"(lib("androidx-ui-tooling"))

    "testImplementation"(lib("junit"))
    "testImplementation"(lib("kotlinx-coroutines-test"))
}
