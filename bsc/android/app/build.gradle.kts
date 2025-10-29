import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    
    namespace = "com.example.bsc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.bsc"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Load release signing configuration from key.properties if present
    val keystoreProperties = Properties()
    val keystorePropertiesFile = rootProject.file("key.properties")
    if (keystorePropertiesFile.exists()) {
        FileInputStream(keystorePropertiesFile).use { fis ->
            keystoreProperties.load(fis)
        }
    }
    val hasReleaseKeystore: Boolean = run {
        val path = (keystoreProperties["storeFile"] ?: "").toString()
        if (path.isBlank()) false else file(path).exists()
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKeystore) {
                storeFile = file(keystoreProperties["storeFile"] ?: "")
                storePassword = (keystoreProperties["storePassword"] ?: "").toString()
                keyAlias = (keystoreProperties["keyAlias"] ?: "").toString()
                keyPassword = (keystoreProperties["keyPassword"] ?: "").toString()
            }
        }
    }

    buildTypes {
        release {
            // Use release signing if provided, otherwise fall back to debug keystore for local builds
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            // Disable resource shrinking unless code shrinking (R8) is enabled
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            // Ensure debug builds also do not attempt resource shrinking
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
