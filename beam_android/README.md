# Beam — nearby file sharing for Android

Send photos, videos, apps and any file to a phone next to you. No internet, no cables.
Built with Kotlin, Jetpack Compose (Material 3) and Google **Nearby Connections**
(Bluetooth to find phones, then Wi-Fi Direct / hotspot for fast transfer).

## Open and run

1. Install **Android Studio** (Ladybug 2024.2 or newer).
2. Unzip this folder and open it via **File › Open** and choose the `Beam` folder.
3. Wait for Gradle sync to finish (first time downloads the Android libraries).
4. Connect a phone with **USB debugging** on and press **Run ▶**.

## Build an APK

- **Build › Build App Bundle(s) / APK(s) › Build APK(s)**,
  then the APK is at `app/build/outputs/apk/debug/app-debug.apk`.
- Or from a terminal: `./gradlew assembleDebug` (Windows: `gradlew.bat assembleDebug`).
- `./gradlew assembleRelease` gives a smaller, optimized APK (signed with the debug key
  for testing; use your own keystore before publishing on the Play Store).

## Test it

You need **two real Android phones** (the emulator has no Bluetooth / Wi-Fi Direct).
Both need Android 8.0+ and Google Play services.

1. Install the APK on both phones and allow the permissions on first launch.
2. Phone B: open Beam, tap **Receive**.
3. Phone A: tap **Send**, pick files, tap **Next**, then tap Phone B in the list.
4. Phone B: check the 4-digit code matches, tap **Accept**.
5. Files are saved in **Download › Beam** on Phone B.

You can also share from Gallery / Files: **Share › Send with Beam**.

## Features

- Onboarding with permission explanations
- Home with visibility switch, Send / Receive and recent transfers
- Picker tabs: Photos and Videos (gallery grid), Apps (installed apps as APK), Files (any document)
- Nearby screen with live radar and device list
- Receive screen (keeps the screen awake while waiting)
- Accept / Decline sheet with a security code and the list of incoming files
- Live progress: percent ring, speed, time left and per-file bars
- Completed / failed / declined / cancelled screens; open received files or install APKs
- History (All / Sent / Received), detail sheet, delete and clear
- Settings: device name, visibility, Light / Dark / System theme, keep screen on, vibration
- Foreground notification with progress, so transfers continue with the screen off
- Banners when Bluetooth, Wi-Fi or Location is off, each with a one-tap fix

## Project layout

```
app/src/main/java/com/beam/share/
  BeamApp.kt, AppContainer.kt, MainActivity.kt
  transfer/  TransferEngine (Nearby logic), Protocol, FileSaver, TransferService
  data/      Settings (DataStore), History (Room), SelectionStore
  media/     MediaRepository (gallery, apps, file info)
  ui/        BeamRoot (navigation), theme/, components/, screens/
```

Change colours in `ui/theme/Theme.kt` and the app name in `res/values/strings.xml`.
