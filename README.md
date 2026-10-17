# VoiceBeast Arena 🎤👹

**Your voice creates your monster.** Roar into the phone and the app turns your voice into a one-of-a-kind beast. Your pitch, power and rasp decide its element, stats and look. Battle through a 60-stage arena, evolve your beasts, challenge friends with a QR code, or fight them **live** phone-to-phone.

- Flutter (Android first)
- 100% offline gameplay, no backend
- AdMob interstitial + rewarded ads, Google Play in-app purchases

---

## 1. Run it

```bash
flutter pub get
flutter run                      # on a phone or emulator
flutter build apk --release      # build an APK
flutter build appbundle          # build an .aab for Google Play
```

Requires Flutter 3.38+ (built and tested with Flutter 3.47 / Dart 3.13).

## 2. Test mode (on right now)

`lib/config/monetization_config.dart` → `testMode = true`

| Situation | What happens |
|---|---|
| Online | Real **Google test ads** (safe, no earnings) |
| Offline / ad failed to load | A built-in **TEST AD** screen (5 s countdown), so rewards still work |
| Store not reachable / app not on Play yet | A **TEST PURCHASE** sheet. Confirm it and the item is delivered. No money moves. |

That means every ad reward and every purchase can be tested with no internet.

## 3. Going live (checklist)

1. **AdMob**: create an app and 2 ad units (Interstitial, Rewarded).
   - Paste the unit IDs into `_liveInterstitial` / `_liveRewarded` in `monetization_config.dart`
   - Replace the `APPLICATION_ID` value in `android/app/src/main/AndroidManifest.xml`
2. **Play Console → Monetize → Products**: create these product IDs exactly:
   | ID | Type | Suggested price |
   |---|---|---|
   | `remove_ads` | One-time (non-consumable) | $2.99 |
   | `starter_pack` | One-time (non-consumable) | $1.99 |
   | `gems_small` | Consumable | $0.99 (80 gems) |
   | `gems_medium` | Consumable | $4.99 (500 gems) |
   | `gems_large` | Consumable | $9.99 (1200 gems) |
3. Set `testMode = false`.
4. Create your own upload key and signing config in `android/app/build.gradle.kts`. It currently signs release builds with the debug key.
5. Package name is `com.voicebeast.arena`. Change `applicationId` if you want a different one, and update `_storeLink` in `lib/widgets/share_card.dart`.
6. Play Console **Data safety**: the microphone is used on-device only (nothing is uploaded). Declare AdMob's advertising ID usage. A privacy policy URL is required because the app uses the microphone and ads.

## 4. Live multiplayer (no server)

- **Arena → Live Battle → Host** shows a room QR. The friend taps **Join** and scans it (or pastes the room code).
- Both phones must be on the **same Wi-Fi** or one phone connects to the other's **hotspot**. No internet needed.
- The host phone runs the battle engine and streams each round to the guest, so both screens always show the same result.
- Both players pick a move at the same time (20 s turn timer; idle players auto-attack). Leaving mid-battle gives the other player a win by forfeit.
- Some public/office Wi-Fi networks block phone-to-phone traffic. Use a hotspot in that case.

## 5. Monetization design

| Placement | Type | Where |
|---|---|---|
| After battles | Interstitial | Every 2nd battle, at least 90 s apart, never during a player's first 3 battles, never when Remove Ads is owned |
| Revive on defeat | Rewarded | Once per battle, 50 % HP |
| 2× battle coins | Rewarded | Victory/defeat screen |
| Reforge monster | Rewarded | Summon screen, 3 per roar |
| +5 energy | Rewarded | Arena / out-of-energy popup |
| Double daily chest | Rewarded | Lair |
| Free gems | Rewarded | Shop, 5 per day |

Gems are spent on monster slots (60), evolution stones (40) and energy refills (15).

## 6. Project layout

```
lib/
  audio/        voice_analyzer.dart (pitch/loudness/rasp detection), roar_recorder.dart
  game/         genome.dart (visual DNA), monster_factory.dart (voice→stats, AI ladder), battle_engine.dart
  models/       monster.dart (+ QR challenge codes), element.dart
  services/     game_store.dart (local save), ads/, iap/, sfx.dart
  screens/      onboarding, lair, summon, monster detail, arena, battle, shop, settings, scan
  widgets/      monster_painter.dart (procedural monster art), ui.dart, feedback.dart (snackbars & popups), share_card.dart
tool/           icon + preview generators (flutter test tool/generate_icon_test.dart)
store_assets/   Play Store icon 512, feature graphic, 10 screenshots
```

Monsters are drawn in code (`monster_painter.dart`) from a seed, so millions of different beasts exist without any image files. The same painter produced the launcher icon.

## 7. Tests

```bash
flutter analyze   # no issues
flutter test      # 30 tests: voice analysis, battle engine, live multiplayer over real sockets, QR codes, save system, UI flows
```

Fonts: Lilita One & Nunito (SIL Open Font License, see `assets/fonts/`).
