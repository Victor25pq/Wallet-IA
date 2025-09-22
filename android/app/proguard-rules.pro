# Supabase & dependencies
-keep class io.supabase.** { *; }
-keep class io.realtime.** { *; }
-keep class io.ktor.** { *; }
-keep class kotlinx.coroutines.** { *; }

# OkHttp (dependency of Supabase)
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okio.**
-dontwarn okhttp3.**

# For Gson serialization
-keep class com.google.gson.** { *; }