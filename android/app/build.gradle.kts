plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.arrows_game"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // VERY IMPORTANT FIX
    compileSdkPreview = null

    // Java & Kotlin compatibility
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.arrows_game"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Change to real keystore later
            signingConfig = signingConfigs.getByName("debug")

            // Recommended for CI
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // no manual dependencies needed
}
