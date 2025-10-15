plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_pomodo"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.app_pomodo"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

// ✅ FIX SEGURO: Copiar APK solo si la tarea existe (sin romper el build)
gradle.projectsEvaluated {
    tasks.findByName("assembleDebug")?.finalizedBy(
        tasks.create<Copy>("copyDebugApkToFlutterDir") {
            from(layout.buildDirectory.dir("outputs/flutter-apk"))
            into("../../build/app/outputs/flutter-apk")
            include("app-debug.apk")
        }
    )
}
