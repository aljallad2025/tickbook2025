plugins {
    id("com.android.application")
    id("kotlin-android")
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
        applicationId = "com.ticbook.ticbookapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = "key0"
            keyPassword = "ticboook"
            storeFile = file("ticboook.jks")
            storePassword = "ticboook"
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
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

configurations.all {
    resolutionStrategy.eachDependency {
        val g = requested.group ?: ""
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