## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

## Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

## Firestore
-keep class com.google.firestore.** { *; }
-keepclassmembers class com.google.firestore.** { *; }

## General optimizations
-optimizationpasses 5
-dontusemixedcaseclassnames
-dontskipnonpubliclibraryclasses
-dontpreverify
-verbose

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Keep custom exceptions
-keep public class * extends java.lang.Exception

## Prevent obfuscation of model classes
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
