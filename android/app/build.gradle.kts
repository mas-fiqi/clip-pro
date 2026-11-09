import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "id.cakfi.quickclippro"
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
        applicationId = "id.cakfi.quickclippro"
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyAliasProp = keystoreProperties.getProperty("keyAlias")
            val keyPasswordProp = keystoreProperties.getProperty("keyPassword")
            val storeFileProp = keystoreProperties.getProperty("storeFile")
            val storePasswordProp = keystoreProperties.getProperty("storePassword")

            if (keyAliasProp != null && keyPasswordProp != null && storeFileProp != null && storePasswordProp != null) {
                val resolvedStoreFile = rootProject.file(storeFileProp)
                if (!resolvedStoreFile.exists()) {
                    throw GradleException("Release keystore file does not exist at: ${resolvedStoreFile.absolutePath}. Please check key.properties.")
                }
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storeFile = resolvedStoreFile
                storePassword = storePasswordProp
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            val releaseSigning = signingConfigs.getByName("release")
            if (releaseSigning.storeFile == null || !releaseSigning.storeFile!!.exists()) {
                // If release signing credentials are not provided, do NOT fall back to debug signing.
                // Leave signingConfig unconfigured or fail explicitly so release APK can never be debug-signed silently.
                gradle.taskGraph.whenReady {
                    val hasReleaseTask = allTasks.any { it.name.contains("Release", ignoreCase = true) }
                    if (hasReleaseTask) {
                        throw GradleException(
                            "Release signing configuration is missing or incomplete in android/key.properties. " +
                            "Configure required release keystore credentials (storeFile, storePassword, keyAlias, keyPassword) before building a release artifact."
                        )
                    }
                }
            } else {
                signingConfig = releaseSigning
            }
        }
    }
}

flutter {
    source = "../.."
}
