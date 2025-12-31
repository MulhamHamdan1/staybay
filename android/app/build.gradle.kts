plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.staybay"
    compileSdk = 36 // replace flutter.compileSdkVersion with actual number
    ndkVersion = "27.0.12077973" // replace with your flutter.ndkVersion if needed

    defaultConfig {
        applicationId = "com.example.staybay"
        minSdk = flutter.minSdkVersion // replace flutter.minSdkVersion
        targetSdk = 36 // replace flutter.targetSdkVersion
        versionCode = 1 // replace flutter.versionCode
        versionName = "1.0" // replace flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ enable desugaring
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")

    // ✅ Required for flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
