// app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("rust") // provided by buildSrc from Tauri
}

android {
    namespace = "com.spellboundscents.app"
    compileSdk = 35
    defaultConfig {
        applicationId = "com.spellboundscents.app"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        ndkVersion = "29.0.14033849"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildTypes {
        debug {
            manifestPlaceholders["usesCleartextTraffic"] = "true"
            isDebuggable = true
            isJniDebuggable = true
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                *fileTree(".") { include("**/*.pro") }.toList().toTypedArray()
            )
        }
    }

    // Keep native debug symbols for all variants (move into debug{} if you prefer)
    packaging {
        jniLibs.keepDebugSymbols.add("**/arm64-v8a/*.so")
        jniLibs.keepDebugSymbols.add("**/armeabi-v7a/*.so")
        jniLibs.keepDebugSymbols.add("**/x86/*.so")
        jniLibs.keepDebugSymbols.add("**/x86_64/*.so")
    }

    buildFeatures { buildConfig = true }
}

rust {
    // path from :app to your Tauri (workspace) root
    rootDirRel = "../../../"
}

dependencies {
    implementation("androidx.webkit:webkit:1.14.0")
    implementation("androidx.appcompat:appcompat:1.7.1")
    implementation("androidx.activity:activity-ktx:1.9.3")
    implementation("com.google.android.material:material:1.12.0")

    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}

// Only apply this if the file actually exists.
// apply(from = "tauri.build.gradle.kts")