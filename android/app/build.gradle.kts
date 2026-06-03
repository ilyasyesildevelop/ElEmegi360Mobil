import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val localProperties = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) f.inputStream().use { load(it) }
}
val flutterSdk = localProperties.getProperty("flutter.sdk")
    ?: System.getenv("FLUTTER_ROOT")
    ?: "D:\\AndroidSDK\\FlutterSDK"
val pubCache = System.getenv("PUB_CACHE") ?: "D:\\AndroidSDK\\PubCache"

/** Android Studio bazen C: Pub Cache ile plugin üretir → Gradle "different roots". */
tasks.register("ensureDartPubCacheOnD") {
    group = "flutter"
    doLast {
        val deps = rootProject.file("../.flutter-plugins-dependencies")
        val needsRefresh = !deps.exists() ||
            deps.readText().contains("AppData\\Local\\Pub\\Cache")
        if (!needsRefresh) return@doLast
        logger.lifecycle("PUB_CACHE=$pubCache ile flutter pub get yenileniyor…")
        exec {
            environment("PUB_CACHE", pubCache)
            workingDir = rootProject.file("..")
            if (System.getProperty("os.name").lowercase().contains("win")) {
                commandLine("$flutterSdk\\bin\\flutter.bat", "pub", "get")
            } else {
                commandLine("$flutterSdk/bin/flutter", "pub", "get")
            }
        }
    }
}

android {
    namespace = "com.greenlabs.development.elemegi360"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.greenlabs.development.elemegi360"
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
}

android.applicationVariants.configureEach {
    outputs.configureEach {
        val impl = this as com.android.build.gradle.internal.api.BaseVariantOutputImpl
        val suffix = if (name.contains("release", ignoreCase = true)) "release" else "debug"
        impl.outputFileName = "El Emeği 360 v${flutter.versionName}-$suffix.apk"
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

tasks.configureEach {
    if (name == "preBuild" || name == "compileFlutterBuildDebug" || name == "compileFlutterBuildRelease") {
        dependsOn("ensureDartPubCacheOnD")
    }
}
