# ProGuard / R8 Rules for QuickClip Pro

# Preserve Flutter Wrapper and Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.**  { *; }

# Preserve FFmpeg Kit Native bindings and callbacks
-keep class com.arthenica.ffmpegkit.** { *; }
-dontwarn com.arthenica.ffmpegkit.**

# Preserve Native MediaCodec and System Inspection classes
-keep class id.cakfi.quickclippro.MainActivity { *; }
-keepclassmembers class id.cakfi.quickclippro.MainActivity {
    private *;
}

# Preserve Video Player & Gallery saver classes
-keep class io.flutter.plugins.videoplayer.** { *; }
-keep class com.mr.flutter.plugin.filepicker.** { *; }

