import java.util.Properties
import java.io.FileInputStream
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.JVM_17)
    }
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

// Release signing (#106). A release build must be signed with the real key.
// It used to fall back to the debug key when key.properties was missing, so
// a CI run with a missing secret published a debug-signed APK that users
// can't tell from a tampered one and that can't update a store install.
// Now a release build without a usable key fails. For a local release
// build without the key, opt in explicitly:
//   HEALTHFLARE_ALLOW_DEBUG_SIGNING=true flutter build apk --release
val releaseKeyProblem: String? = when {
    !keyPropertiesFile.exists() -> "android/key.properties is missing"
    listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        .any { (keyProperties[it] as String?).isNullOrBlank() } ->
        "android/key.properties is missing storeFile, storePassword, " +
            "keyAlias or keyPassword"
    !file(keyProperties["storeFile"] as String).let { it.exists() && it.length() > 0 } ->
        "the keystore named in android/key.properties is missing or empty"
    else -> null
}
val allowDebugSigning = System.getenv("HEALTHFLARE_ALLOW_DEBUG_SIGNING") == "true"

android {
    namespace = "org.healthflare.app.healthflare"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "org.healthflare.app.healthflare"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keyProperties["keyAlias"] as String?
            keyPassword = keyProperties["keyPassword"] as String?
            storeFile = keyProperties["storeFile"]?.let { file(it as String) }
            storePassword = keyProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseKeyProblem == null) {
                signingConfigs.getByName("release")
            } else {
                // Only reached by a release task if allowDebugSigning is set;
                // otherwise the check below stops the build first.
                signingConfigs.getByName("debug")
            }
        }
    }
}

// Fail when a release variant is actually being built, not at configuration
// time, so debug builds and `flutter run` work without the key.
gradle.taskGraph.whenReady {
    val buildingRelease = allTasks.any {
        it.project == project && it.name.contains("Release")
    }
    if (buildingRelease && releaseKeyProblem != null && !allowDebugSigning) {
        throw GradleException(
            "Refusing to build a release without the release signing key: " +
                "$releaseKeyProblem. In CI, check the KEYSTORE_BASE64, " +
                "STORE_PASSWORD, KEY_ALIAS and KEY_PASSWORD secrets. For a " +
                "local test build, set HEALTHFLARE_ALLOW_DEBUG_SIGNING=true " +
                "(never publish that build)."
        )
    }
}

flutter {
    source = "../.."
}

dependencies {
    // AppCompat themes in res/values*/styles.xml (local_auth, #100).
    implementation("androidx.appcompat:appcompat:1.7.0")
}
