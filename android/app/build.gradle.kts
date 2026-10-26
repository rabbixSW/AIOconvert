plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningEnvironment = mapOf(
    "ANDROID_KEYSTORE_PATH" to System.getenv("ANDROID_KEYSTORE_PATH"),
    "ANDROID_KEYSTORE_PASSWORD" to System.getenv("ANDROID_KEYSTORE_PASSWORD"),
    "ANDROID_KEY_ALIAS" to System.getenv("ANDROID_KEY_ALIAS"),
    "ANDROID_KEY_PASSWORD" to System.getenv("ANDROID_KEY_PASSWORD"),
)
val hasReleaseSigningValues = releaseSigningEnvironment.values.any { !it.isNullOrBlank() }
val hasCompleteReleaseSigningValues =
    releaseSigningEnvironment.values.all { !it.isNullOrBlank() }

if (hasReleaseSigningValues && !hasCompleteReleaseSigningValues) {
    error(
        "Set all Android signing environment variables: " +
            releaseSigningEnvironment.keys.joinToString(", ")
    )
}

android {
    namespace = "com.aioconvert.aioconvert"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    if (hasCompleteReleaseSigningValues) {
        signingConfigs {
            create("release") {
                storeFile = file(requireNotNull(releaseSigningEnvironment["ANDROID_KEYSTORE_PATH"]))
                storePassword = requireNotNull(releaseSigningEnvironment["ANDROID_KEYSTORE_PASSWORD"])
                keyAlias = requireNotNull(releaseSigningEnvironment["ANDROID_KEY_ALIAS"])
                keyPassword = requireNotNull(releaseSigningEnvironment["ANDROID_KEY_PASSWORD"])
            }
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.aioconvert.aioconvert"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasCompleteReleaseSigningValues) {
                signingConfig = signingConfigs.getByName("release")
            }
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
