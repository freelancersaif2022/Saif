plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// AdMob application IDs. The debug build always uses Google's public test app ID.
// Supply the production ID for release builds with
//   -PadmobAppId=ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
// (or add `admobAppId=...` to android/gradle.properties / ~/.gradle/gradle.properties).
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val admobReleaseAppId: String =
    (project.findProperty("admobAppId") as String?) ?: admobTestAppId

android {
    namespace = "com.moixlimited.dragonland"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.moixlimited.dragonland"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = admobTestAppId
    }

    buildTypes {
        release {
            manifestPlaceholders["admobAppId"] = admobReleaseAppId
            // Signed with the debug key so `flutter run --release` works out of the box.
            // Replace with your upload keystore before publishing to Google Play.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
