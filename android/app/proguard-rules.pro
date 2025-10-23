# Flutter rules are compiled into the base Flutter Gradle script. See
# https://github.com/flutter/flutter/blob/master/packages/flutter_tools/gradle/flutter.gradle#L1365

# Add custom rules here

# Firebase Core, Auth, and Firestore rules
-keep class com.google.firebase.** { *; }
-keep class org.json.** { *; }
-keepnames class com.google.android.gms.common.api.internal.IStatusCallback
-dontwarn com.google.firebase.auth.**
-keep class com.google.android.gms.internal.firebase-auth.** { *; }