# Reglas de Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# No mostrar advertencias para las clases de Google Play Core
-dontwarn com.google.android.play.core.**

# Mantener las clases de Google Play Core
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# NUEVO: Mantener explícitamente las clases de los paquetes de Supabase y app_links
-keep class io.supabase.** { *; }
-keep class com.llfbandit.app_links.** { *; }

# Reglas de red y JSON
-keepattributes Signature
-keepattributes *Annotation*
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-keep class com.google.gson.** { *; }