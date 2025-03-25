pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.3.0" apply false
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
}

include(":app")
include(":facebook_login")
include(":facebook_core")
include(":facebook_app_events")
include(":facebook_share")

project(":facebook_login").projectDir = file("../.flutter-plugins/flutter_facebook_auth/android")
project(":facebook_core").projectDir = file("../.flutter-plugins/flutter_facebook_auth/android/facebook_core")
project(":facebook_app_events").projectDir = file("../.flutter-plugins/flutter_facebook_auth/android/facebook_app_events")
project(":facebook_share").projectDir = file("../.flutter-plugins/flutter_facebook_auth/android/facebook_share")
