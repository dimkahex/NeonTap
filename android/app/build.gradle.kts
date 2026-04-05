import com.android.build.api.dsl.ApplicationExtension
import java.io.File

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.neonpulse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.neonpulse"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// After `flutter build apk`, copy universal APK to `build/app/outputs/apk/release/` with version in filename.
afterEvaluate {
    val androidExt = extensions.findByType(ApplicationExtension::class.java) ?: return@afterEvaluate
    tasks.named("assembleRelease").configure {
        doLast {
            val rootDir = rootProject.layout.projectDirectory.asFile.parentFile ?: return@doLast
            val src = File(rootDir, "build/app/outputs/flutter-apk/app-release.apk")
            if (!src.exists()) {
                logger.warn("Versioned APK copy skipped (output not found yet): ${src.invariantSeparatorsPath}")
                return@doLast
            }
            val destDir = File(rootDir, "build/app/outputs/apk/release")
            destDir.mkdirs()
            val ver = androidExt.defaultConfig.versionName ?: "0.0.0"
            val code = androidExt.defaultConfig.versionCode ?: 1
            val dst = File(destDir, "NeonPulse-v${ver}-b${code}.apk")
            src.copyTo(dst, overwrite = true)
            logger.lifecycle("Copied release APK to: ${dst.invariantSeparatorsPath}")
        }
    }
}
