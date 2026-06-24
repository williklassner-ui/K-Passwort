-keep class com.kpasswort.** { *; }
-keep class io.flutter.** { *; }
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**

# AndroidX Biometric
-keep class androidx.biometric.** { *; }

# Prevent stripping crypto-related classes
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Flutter deferred components reference Play Core which may be absent in builds
-dontwarn com.google.android.play.core.**
