plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.ticbook.ticbookapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.ticbook.ticbookapp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = System.getenv("CM_KEY_ALIAS") ?: "upload"
            keyPassword = System.getenv("CM_KEY_PASSWORD") ?: ""
            storeFile = file("../../upload-key.jks")
            storePassword = System.getenv("CM_STORE_PASSWORD") ?: ""
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Use the Firebase BoM to align versions
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    // Core library desugaring for Java 8+ APIs on older Android devices
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

// Align Compose runtime to avoid NoSuchMethodError in PaymentSheet
configurations.all {
    resolutionStrategy.eachDependency {
        val g = requested.group ?: ""
        // Material3 has its own version line separate from compose-ui artifacts
        if (g == "androidx.compose.material3") {
            useVersion("1.3.1")
            because("Align Material3 with Compose 1.7.x stack used by Stripe")
        } else if (g.startsWith("androidx.compose")) {
            useVersion("1.7.5")
            because("Stripe PaymentSheet depends on newer Compose APIs")
        }
        if (g == "androidx.activity") {
            useVersion("1.9.2")
        }
    }
}
