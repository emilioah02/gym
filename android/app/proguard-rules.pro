## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

## Firebase Core
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

## Firebase Cloud Messaging (FCM) - CRITICAL
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keepclassmembers class * extends com.google.firebase.messaging.FirebaseMessagingService {
    public void onMessageReceived(com.google.firebase.messaging.RemoteMessage);
    public void onNewToken(java.lang.String);
}

## Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** { *; }

## Firebase Crashlytics
-keep class com.google.firebase.crashlytics.** { *; }
-keepattributes *Annotation*
-keep public class * extends java.lang.Exception

## Google Sign-In
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.tasks.** { *; }

## Firestore & gRPC
-keep class com.google.firestore.** { *; }
-keepclassmembers class com.google.firestore.** { *; }
-keep class io.grpc.** { *; }
-dontwarn io.grpc.**
-keep class com.google.protobuf.** { *; }
-dontwarn com.google.protobuf.**

## OkHttp (used by Firebase)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

## Kotlin Coroutines (used by Firebase internally)
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.coroutines.** {
    volatile <fields>;
}
-dontwarn kotlinx.coroutines.**

## Kotlin Serialization
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}

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

## Keep R8 full mode compatibility
-keepattributes Signature
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

## Audioplayers
-keep class xyz.luan.audioplayers.** { *; }
-dontwarn xyz.luan.audioplayers.**

## URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

## Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

## Cached Network Image
-keep class com.github.nickharak.** { *; }

## Google Play Core (deferred components)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

## Prevent crashes from missing classes
-dontwarn java.lang.invoke.StringConcatFactory
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
