# Impeller/Vulkan Troubleshooting Guide

If your Flutter app is stuck on the splash screen and you see "Impeller rendering backend (Vulkan)" in the console, you may need to disable Impeller.

## Quick Fix (Temporary)

Run your app with Impeller disabled:

```bash
flutter run --enable-impeller=false
```

## Persistent Fix (Android)

### Option 1: Add to `android/app/src/main/AndroidManifest.xml`

Add this inside the `<application>` tag:

```xml
<meta-data
    android:name="io.flutter.embedding.android.EnableImpeller"
    android:value="false" />
```

### Option 2: Disable in `android/app/build.gradle`

Add to the `android` block:

```gradle
android {
    defaultConfig {
        // ... existing config ...
        manifestPlaceholders = [
            'io.flutter.embedding.android.EnableImpeller': 'false'
        ]
    }
}
```

## For iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>FLTEnableImpeller</key>
<false/>
```

## Note

The app startup fix implemented in `main.dart` should resolve most hanging issues. Only disable Impeller if the problem persists after applying the non-blocking startup changes.

