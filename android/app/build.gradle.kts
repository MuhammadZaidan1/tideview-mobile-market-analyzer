import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Baca key.properties (file ini TIDAK di-commit ke git -- lihat .gitignore).
// Kalau file belum ada (misal build debug biasa di laptop yang belum setup
// keystore), fallback ke debug signing biar gak error pas dev, tapi WAJIB
// diisi sebelum publish beneran.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreProperties = keystorePropertiesFile.exists()
if (hasKeystoreProperties) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.tideview.tideview"

    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true 
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.tideview.tideview"
        
        // Tetap di 21 agar aman untuk HP lama
        minSdk = flutter.minSdkVersion 
        targetSdk = 36 
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasKeystoreProperties) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // FIX (Fase 4): pakai release keystore asli kalau key.properties
            // ada. Kalau belum di-setup (dev machine lain, CI belum config),
            // fallback ke debug signing biar tetap bisa build -- tapi INI
            // HARUS diisi sebelum publish ke Play Store / distribusi asli.
            signingConfig = if (hasKeystoreProperties) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // FIX (Fase 4): minify + shrink resources diaktifkan.
            // proguard-rules.pro udah disiapin buat plugin yang kita pake
            // (Isar, workmanager, flutter_local_notifications, home_widget).
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}