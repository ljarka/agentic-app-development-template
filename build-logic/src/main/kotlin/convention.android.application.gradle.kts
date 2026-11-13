/**
 * Android application defaults: SDK levels, Java/Kotlin target, namespace from
 * `project.basePackage` (gradle.properties).
 */
plugins {
    id("com.android.application")
}

android {
    namespace = providers.gradleProperty("project.basePackage").get()
    compileSdk = AppSdk.COMPILE

    defaultConfig {
        minSdk = AppSdk.MIN
        targetSdk = AppSdk.TARGET
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
