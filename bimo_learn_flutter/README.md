# Bimo – Learn Flutter (Android)

A native **Kotlin + Jetpack Compose + Material 3** Android app that teaches Dart and Flutter.
Flutter is the *subject* of the lessons; the app itself contains no Flutter code.

## What's inside
- **Curriculum (offline, in `app/src/main/assets/curriculum`)**: Dart course (7 modules, 79 lessons with quizzes),
  Flutter course (20 modules, 226 lessons; modules 1–2 have quizzes, modules 3–20 are short lessons completed with
  "Mark as complete"), 15 real-world projects, a 25-question final assessment and 6 coding challenges.
- **Learning engine**: strict sequential unlocking, quizzes (multiple choice, true/false, code output, fill-in,
  code ordering, scenario), 70% pass mark, retries, quiz history, mistake review, XP ledger (no reward farming),
  levels, streaks, daily goal, 22 achievements.
- **Certificate**: "BIMO — CERTIFICATE OF COMPLETION", signed "Saif A", unique checksummed ID, PDF and PNG
  export, share, local verification. Clearly labelled as an educational certificate, not an accreditation.
- **Monetisation**: AdMob **test** interstitial/rewarded ads with UMP consent; mock Weekly/Monthly/Yearly premium
  via a billing abstraction (a Google Play Billing implementation is included); 7-day promo trial (demo flow).
- **Other**: onboarding, welcome/profile, dashboard, settings (theme, premium palettes, text size, reduce motion,
  sound, reminders with WorkManager, export JSON, reset), dark mode, splash screen.

Stack: Kotlin 2.0, Compose (BOM 2024.12), Material 3, Navigation Compose, Hilt, Room, DataStore, Coroutines/Flow,
WorkManager, Coil, Play Services Ads, UMP, Play Billing 7. minSdk 26, targetSdk 35.

## 1. Open in Android Studio
File ▸ Open ▸ select the `bimo_learn_flutter` folder. Use a recent Android Studio with JDK 17+.

## 2. Sync Gradle
Android Studio syncs automatically (or File ▸ Sync Project with Gradle Files). The Gradle wrapper (8.11.1) downloads itself.

## 3. Run
Select an emulator/device and press Run, or `./gradlew installDebug`.

## 4. Build an APK
`./gradlew assembleDebug` → `app/build/outputs/apk/debug/app-debug.apk`

## 5. Configure AdMob
Ad IDs live in `app/build.gradle.kts` (`admobAppId`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID`). They are Google's
official **test** IDs. Ad rules (never for premium, only after a saved first completion, frequency cap) are in
`core/domain/Monetization.kt` (`AdPolicy`).

## 6. Use production ad units
Create an app and ad units in AdMob, replace the three IDs (ideally only for the `release` build type), set
`ALLOW_SIMULATED_REWARDS` to false (already false in release), and configure your consent message in AdMob ▸ Privacy & messaging.

## 7. Real Google Play Billing
Create subscriptions `bimo_premium_weekly`, `bimo_premium_monthly`, `bimo_premium_yearly` in Play Console, set
`USE_MOCK_BILLING` to `false`; `PlayBillingSubscriptionGateway` is then used. Verify purchases on a backend for production.

## 8. Update curriculum content
Edit the `.bimo` files in `app/src/main/assets/curriculum`. Format: `docs/CURRICULUM_FORMAT.md`. Validate with
`python3 tools/validate_curriculum.py`. Never change released lesson ids (progress is stored by id).

## 9. Customise branding
Colours: `ui/theme/Color.kt`, `res/values/colors.xml`. Logo/launcher: `res/drawable/ic_launcher_*.xml`.
App name: `res/values/strings.xml`. Certificate design: `certificate/CertificateRenderer.kt`.

## 10. Release builds
Create `keystore.properties` in the project root (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`), then
`./gradlew bundleRelease` (AAB for Play) or `./gradlew assembleRelease`. R8 shrinking is enabled.

## Tests
- `app/src/test`: 61 JVM unit tests (parser, real curriculum assets, progression/unlocking, quiz scoring & retries,
  XP and anti-farming, levels, streaks, onboarding routing, achievements, certificate eligibility & IDs,
  premium activation/expiry, ad eligibility, syntax tokenizer). Run `./gradlew test`.
- `tools/check_dart_snippets.py`: analyzes Dart/Flutter code samples in lessons with a real SDK.

## Verification status (honest)
- Built in a sandbox **without access to Google's Maven repository or the Android SDK**, so the Android project
  was **not compiled with Gradle** and no APK, screenshots or on-device testing were produced.
- The pure-Kotlin core (`core/`) and its 61 unit tests **were compiled with kotlinc 2.0.21 and pass**.
- All Android source files passed a Kotlin parse check (no syntax errors); type-checking against AndroidX was not possible.
- All 271 Dart code samples in the Dart course pass `dart analyze` (Dart 3.7.2); code-output quiz answers were
  verified by running them. Flutter modules 1–2 samples pass `flutter analyze` (Flutter 3.29.2); samples in Flutter
  modules 3–20 and projects were not machine-checked.
- Expect to fix minor compile issues on first Gradle sync, if any.
