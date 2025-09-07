# -------------------------------
# Android SDK / NDK environment
# -------------------------------

# SDK root
export ANDROID_SDK_ROOT="/home/nick/Android/Sdk"
export ANDROID_HOME="$ANDROID_SDK_ROOT"

# NDK root (version 29.0.14033849)
export ANDROID_NDK_HOME="$ANDROID_SDK_ROOT/ndk/29.0.14033849"
export ANDROID_NDK_ROOT="$ANDROID_NDK_HOME"
export NDK_HOME="$ANDROID_NDK_HOME"
export NDK_ROOT="$ANDROID_NDK_HOME"

# Add SDK tools to PATH
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools"
export PATH="$PATH:$ANDROID_SDK_ROOT/emulator"
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"

# -------------------------------
# Java (JDK 17 required by Gradle/AGP)
# -------------------------------
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"
