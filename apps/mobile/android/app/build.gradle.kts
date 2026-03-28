import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use(keystoreProperties::load)
}

fun releaseProperty(name: String): String? {
    val fromFile = keystoreProperties.getProperty(name)?.trim().orEmpty()
    if (fromFile.isNotEmpty()) {
        return fromFile
    }
    return System.getenv("LINGSTACK_${name.uppercase()}")?.trim()?.takeIf { it.isNotEmpty() }
}

val releaseStoreFile = releaseProperty("storeFile")
val releaseStorePassword = releaseProperty("storePassword")
val releaseKeyAlias = releaseProperty("keyAlias")
val releaseKeyPassword = releaseProperty("keyPassword")

val hasReleaseSigning =
    !releaseStoreFile.isNullOrBlank() &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

val isReleaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("Release", ignoreCase = true) ||
        it.contains("bundle", ignoreCase = true)
}

if (isReleaseBuildRequested && !hasReleaseSigning) {
    throw GradleException(
        "Missing Android release signing config. Copy android/key.properties.example to android/key.properties and provide a valid keystore.",
    )
}

android {
    namespace = "com.jayyu.lingstack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseStoreFile!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                enableV1Signing = true
                enableV2Signing = true
            }
        }
    }

    defaultConfig {
        applicationId = "com.jayyu.lingstack"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
}

flutter {
    source = "../.."
}
