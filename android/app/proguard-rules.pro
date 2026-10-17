# Room databases are created by reflection (e.g. WorkManager's WorkDatabase_Impl,
# pulled in by the Google Mobile Ads SDK). Without these rules R8 strips them and
# the app crashes on launch.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.** { *; }
-keep class androidx.startup.** { *; }

# Google Play Billing, Mobile Ads and ML Kit (QR scanning).
-keep class com.android.billingclient.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.android.play.core.**
