# Keep rules for libraries that create classes by reflection at startup.
# Google Mobile Ads pulls in WorkManager, whose Room database implementation
# (WorkDatabase_Impl) is instantiated reflectively; if R8 removes it the app
# crashes on launch with "Failed to create an instance of WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.** { *; }
-keep class androidx.room.** { *; }
-keep class androidx.startup.** { *; }
-keep class com.google.android.gms.ads.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.google.android.play.core.**
