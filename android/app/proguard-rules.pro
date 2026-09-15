# Flutter Engine Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Ignore missing optional Play Store deferred loading classes
-dontwarn com.google.android.play.core.**

# Preserve native methods and plugins used by Flutter
-keepclasseswithmembernames class * {
    native <methods>;
}