/**
 * Android library defaults. The namespace is derived from the module path:
 * `:core:model` -> `<project.basePackage>.core.model`, so module build files don't set it.
 */
plugins {
    id("com.android.library")
}

android {
    namespace = providers.gradleProperty("project.basePackage").get() +
        path.replace(':', '.').replace('-', '_')
    compileSdk = AppSdk.COMPILE

    defaultConfig {
        minSdk = AppSdk.MIN
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_11)
    }
}
