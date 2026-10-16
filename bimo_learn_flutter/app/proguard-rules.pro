# Bimo – Learn Flutter R8 rules.
# Most libraries used here (Hilt, Room, Compose, WorkManager, Play services, Billing)
# ship their own consumer rules. Only app-specific keeps are listed below.

# Keep line numbers for readable crash reports.
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Room entities are referenced reflectively by generated code only, but keeping
# field names makes exported schemas and debugging consistent.
-keep class com.bimo.learnflutter.data.db.entity.** { *; }

# Hilt workers are instantiated through HiltWorkerFactory.
-keep class * extends androidx.work.ListenableWorker { <init>(...); }
