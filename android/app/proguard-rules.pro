# Flutter's core ProGuard rules.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# NUEVO: Reglas específicas para proteger las bibliotecas de Google Play Core.
# Esto soluciona el error "Missing class com.google.android.play.core".
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Reglas genéricas para librerías de red y JSON que usa Supabase.
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep class com.google.gson.** { *; }