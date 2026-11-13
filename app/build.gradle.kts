plugins {
    id("convention.android.application")
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.ksp)
    alias(libs.plugins.hilt)
}

android {
    defaultConfig {
        applicationId = providers.gradleProperty("project.basePackage").get()
        // Set by the release workflow from the git tag; local builds are 1 / "dev".
        versionCode = System.getenv("APP_VERSION_CODE")?.toInt() ?: 1
        versionName = System.getenv("APP_VERSION_NAME") ?: "dev"
    }

    // Release signing comes from the environment (GitHub secrets in the release workflow).
    // Without it, release builds fall back to the debug key so they still build locally.
    val releaseKeystore = System.getenv("APP_KEYSTORE_PATH")?.let(::file)?.takeIf { it.exists() }
    signingConfigs {
        if (releaseKeystore != null) {
            create("release") {
                storeFile = releaseKeystore
                storePassword = System.getenv("APP_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("APP_KEY_ALIAS")
                keyPassword = System.getenv("APP_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName(if (releaseKeystore != null) "release" else "debug")
        }
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:model"))
    implementation(project(":core:ui"))
    // Features: the app shell is the only module allowed to depend on them.
    // scripts/new-feature.sh adds new ones below this line.
    implementation(project(":feature:home"))

    ksp(libs.hilt.android.compiler)
    implementation(libs.hilt.android)
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.navigation.compose)
    implementation(libs.kotlin.serialization.json)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.material3)

    testImplementation(libs.junit)
}
