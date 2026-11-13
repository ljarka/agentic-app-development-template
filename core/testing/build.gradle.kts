plugins {
    id("convention.android.library")
    alias(libs.plugins.kotlin.compose)
}

android {
    buildFeatures {
        compose = true
    }
}

dependencies {
    api(project(":core:ui"))
    api(libs.paparazzi)
    api(libs.junit)
    api(libs.kotlinx.coroutines.test)
}
