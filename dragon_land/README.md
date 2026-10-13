# Dragon Land 🐉

*Discover Your Dragon Adventure* — a landscape cartoon fantasy endless runner for Android, built with
Flutter 3.47 and Flame 1.38.

- Package: `com.moixlimited.dragonland` · Flutter project: `dragon_land`
- Android: compileSdk 36, targetSdk 36, minSdk 24 (Flutter default), Java/Kotlin target 17, Gradle Kotlin DSL (`.kts`)

## Features

**Gameplay (Flame)**
- Endless side-view runner on a scrolling world of floating islands. Five parallax layers (sky, sun, snowy
  mountains with a castle, floating islands with waterfalls, forest hills), drifting clouds, birds,
  butterflies, distance fog, soft ground shadows and a foreground grass layer give a 3D cartoon look.
  It is a 2D engine: the depth is illustrated, not real 3D geometry.
- Five dragons, each with its own look, attack and special ability:

  | Dragon | Element | Attack | Special | Price |
  |---|---|---|---|---|
  | Ember | Fire | Fire breath (short-range fireball) | **Fire Burst**: a rolling fire wall that burns enemies, obstacles and thorns | Free |
  | Aqua | Water | Water blast | **Water Shield**: 4 s invulnerable bubble that also pulls in coins | 2,000 |
  | Shadow | Shadow magic | Shadow wave (pierces 2 targets) | **Shadow Dash**: invulnerable high-speed dash that hits everything in its way | 5,000 |
  | Leaf | Nature | Leaf storm | **Nature Shield**: blocks the next 2 hits and damages attackers | 8,000 |
  | Solar | Solar magic | Sun orb (2 damage) | **Solar Blast**: a full-screen beam | 15,000 |

- Controls (landscape, multi-touch, and they can be swapped for left-handed players): hold **LEFT / RIGHT**
  to move, **JUMP** (coyote time and jump buffer, no infinite jumps), **FLY** (uses flight energy, tap again
  to land, energy refills on the ground), **SPRINT** (toggle, uses stamina, 1.45× speed with speed lines),
  **ATTACK** (0.42 s cooldown), **SPECIAL** (shows a cooldown ring) and **PAUSE**.
- Health: 3 hearts, hit flash, damage vignette, blinking invulnerability. A sustained overlap with one
  hazard hurts only once. Falling into a chasm costs a heart and a magic bubble lifts you back to safety.
  Stomping on ground enemies damages them.
- Enemies: Slime (hops), Flying Bat (sine pattern; low and high variants), Stone Monster (4 HP), Goblin Rider
  (fast charge with a "!" warning) and the **Crystal Golem** mini boss. The golem has a health bar and three
  attack patterns: telegraphed ground-slam shockwaves, arcing rock throws and summoned bats. It shows up at
  1,200 m and then every 1,600 m.
- Obstacles: thorn bushes, destructible boulders (2 HP), crystal clusters (drop coins), magic barriers that
  are too tall to jump (fly over them or break them in 3 hits), floating thorn pods and chasms.
- Pickups: coins, coin clusters (5–10), gems, hearts, coin magnets, treasure chests and magic gates
  (magnet or double-coins buff).
- Procedural course generation (`SpawningSystem`) uses weighted patterns that unlock with distance. The
  clearance after every hazard grows with speed, chasms are always narrower than a jump, and combo patterns
  place aerial hazards so there is always a way through. Speed eases from 360 to 700 units/s
  (`DifficultySystem`).

**Meta game**
- Animated splash. Startup is time-boxed and tolerates failures, so the game can never get stuck there.
- Lobby: the dragon breathes, blinks, sways its tail, flaps its wings, does idle animations, reacts to taps
  and celebrates when you pick a new one. It stands on a bobbing floating island. The top bar has your coin
  and gem balances, a free-coins rewarded video, sound and music toggles and settings.
- Dragon Shop (card grid) and Select Dragon (carousel). Each shows the dragon, its element, ability, price
  and lock or equipped state. Buying a dragon checks your balance and deducts the coins exactly once, and the
  purchase is saved. If you don't have enough coins, it offers the coin shop.
- Coin & Gem Shop with Coins, Gems, Special Offers (starter bundle plus gem→coin exchanges) and Remove Ads
  tabs, all on Google Play Billing.
- 7-day daily reward streak, plus 6 mission lines with endless tiers.
- Settings: music, sound, volumes, vibration, graphics quality, left-handed layout, Remove Ads, Restore
  Purchases, ad privacy options (UMP), Privacy Policy, Terms and About.
- Game Over: score, distance, coins, gems, enemies, best distance, a new-record badge and the dragon. Buttons:
  **Revive** (rewarded ad, or 5 gems; once per run), **Double Coins** and **Bonus Chest** (rewarded ads, once
  per run), Play Again, Shop and Menu.

## Project structure

```
lib/
  main.dart                       landscape + immersive mode, runApp
  app/                            DragonLandApp, theme, AppScope (service locator), routes
  config/                         economy_config.dart, product_config.dart, ad_config.dart  ← all tunables
  models/                         dragon, enemy, mission, shop product, player progress (+ settings)
  services/                       storage, progress_controller, reward (daily/missions/free coins),
                                  audio, purchase (Google Play Billing), ad (AdMob + UMP consent)
  art/                            procedural vector art: dragon_art, enemy_art, prop_art, sprite_cache
  game/
    dragon_land_game.dart         FlameGame: loop, combat, abilities, rewards, boss, HUD feed
    game_config.dart, input_state.dart, run_state.dart
    components/                   dragon, enemy (+boss), obstacle, coin (pickups), projectile,
                                  environment (parallax, ground with chasms, foreground), particle
    systems/                      spawning, collision, difficulty, scoring, currency (run commit)
  screens/                        splash, lobby, gameplay, game_over, dragon_shop, dragon_select,
                                  coin_shop, daily_rewards, missions, settings, legal
  widgets/                        game_button, coin_counter, currency_icons, dragon_card, dragon_view,
                                  game_hud, game_controls, health_bar, stamina_bar, flight_energy_bar,
                                  meter_bar, pause_overlay, banner_ad_widget, logo, panel, scenic_background
assets/
  images/   sky, sun, 4 clouds, bg_far/mid/near parallax, ground, foreground, lobby_island
  audio/    26 sound effects + 2 music loops (WAV)
  fonts/    Lilita One, Fredoka (SIL OFL 1.1, licenses included)
tool/
  gen_images.py, gen_audio.py     procedural generators for every bundled bitmap and sound
  gen_icon_test.dart              renders launcher icons + store/icon_512.png from the dragon art
  preview/                        render tests that save PNG previews of art, gameplay and screens
test/                             economy, persistence, rewards, currency, assets, headless gameplay
                                  simulation (all 5 dragons, 4-minute runs) and full app-flow widget tests
store/icon_512.png                Play Store icon
```

### Assets and licensing
All artwork and audio is original:
- The background and terrain bitmaps come from `tool/gen_images.py` (numpy + Pillow).
- The sounds come from `tool/gen_audio.py`.
- Dragons, enemies, pickups, obstacles and effects are vector-drawn in `lib/art/`. Frequently drawn sprites
  are rasterised once at load into an atlas-like frame cache (`SpriteCache`).
- The fonts are from Google Fonts under the SIL Open Font License.

There are no third-party game assets.

## Building

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug          # debug APK
flutter build appbundle --release  # Play Store bundle (configure signing first)
```

To regenerate the assets:

```bash
python3 tool/gen_images.py && python3 tool/gen_audio.py
flutter test tool/gen_icon_test.dart
```

## AdMob setup
1. Create the app in AdMob, then create one **Banner**, one **Interstitial** and one **Rewarded** ad unit.
2. Put the unit IDs in `lib/config/ad_config.dart` (`prodBanner`, `prodInterstitial`, `prodRewarded`).
   - Debug and profile builds always use Google's test units.
   - Release builds use the production IDs once you replace the `REPLACE_...` placeholders. Until then they
     fall back to the test units.
3. Pass the AdMob **App ID** to release builds:
   `flutter build appbundle --release -PadmobAppId=ca-app-pub-XXXX~YYYY`, or add
   `admobAppId=ca-app-pub-XXXX~YYYY` to `android/gradle.properties`. Debug builds use Google's test App ID
   (see `android/app/build.gradle.kts`).
4. In AdMob → Privacy & messaging, create a GDPR (and US state) consent message. The app runs the UMP consent
   flow before requesting ads, and Settings has an "Ad privacy options" entry.
5. Add your test device IDs to `AdConfig.testDeviceIds` while testing production units.

Placement rules built into the app:
- Banners appear only on the Daily Rewards, Missions and Settings screens.
- Interstitials appear only when you leave the results screen, at most once every 3 runs and 3 minutes, and
  never with Remove Ads.
- Rewarded ads are always started by the player, and rewards are granted only from `onUserEarnedReward`.
  When a revive is earned, the game resumes only after the ad closes.

## Google Play Console setup
1. Create the app with package name `com.moixlimited.dragonland` and upload a signed release bundle. First
   replace the debug signing in `android/app/build.gradle.kts` with your upload keystore.
2. In Monetize → Products → In-app products, create these product IDs and set their prices there (the app
   always displays the price that Google Play returns):

   | Product ID | Type | Grants | Intended price |
   |---|---|---|---|
   | `coins_starter` | Consumable | 250 coins | $0.20 (check Play's minimum price for each country) |
   | `coins_small` | Consumable | 1,500 coins | $0.99 |
   | `coins_medium` | Consumable | 5,000 coins | $2.99 |
   | `coins_large` | Consumable | 9,500 coins | $4.99 |
   | `coins_mega` | Consumable | 21,000 coins | $9.99 |
   | `coins_ultimate` | Consumable | 45,000 coins | $19.99 |
   | `gems_small` | Consumable | 20 gems | $0.99 |
   | `gems_medium` | Consumable | 65 gems | $2.99 |
   | `gems_large` | Consumable | 115 gems | $4.99 |
   | `gems_premium` | Consumable | 250 gems | $9.99 |
   | `gems_ultimate` | Consumable | 550 gems | $19.99 |
   | `bundle_dragon_starter` | Consumable | 3,000 coins + 30 gems | $1.99 |
   | `remove_ads` | Non-consumable | Removes banners and interstitials | $3.99 |

3. Add license testers (Setup → License testing) to buy without being charged.
4. Fill in the Data safety form (AdMob collects device identifiers) and host the privacy policy. Then update
   the placeholder URLs and contact details in `lib/screens/legal_screen.dart`.
5. **Recommended:** server-side verification.
   - Deploy a backend that calls the Google Play Developer API (`purchases.products.get`) with a service
     account, keeps an idempotency record per purchase token, and returns `{"valid": true}`.
   - Put its URL in `ProductConfig.verificationEndpoint`.
   - Never ship service-account keys in the app.
   - Without a backend, the app checks the purchase status, the product ID and that a purchase token is
     present, and grants each purchase ID only once.

## Economy configuration
- Dragon prices, pickup and enemy rewards, chest values, ad rewards, the gem revive cost, gem exchanges, the
  daily reward schedule and score weights are all in `lib/config/economy_config.dart`.
- Mission lines are in `lib/models/mission_model.dart`.
- Gameplay tuning (physics, speeds, meters, cooldowns, boss timing) is in `lib/game/game_config.dart`.

## Persistence
`StorageService` stores one JSON document in SharedPreferences and mirrors it to a backup key; if the primary
copy can't be read, the backup is used. It saves:
- coins, gems, unlocked and equipped dragons
- best score and distance, totals and runs
- missions, daily streak and settings
- the Remove Ads entitlement and processed purchase IDs

Run coins are banked when a run ends, or when you quit from the pause menu. Revives commit only what was
collected since the last commit.

## Known limitations
- **The APK was not built in the development container.** The container has no Android SDK, and its network
  policy blocks `dl.google.com`, which is the only official source for SDK platforms and build tools.
  `flutter build apk --debug` stops with "No Android SDK found". Everything else ran: `flutter analyze` is
  clean and every `flutter test` suite passes, including the headless gameplay simulation and the app-flow
  widget tests. Run the build commands above on a machine with the Android SDK (API 36) installed.
- AdMob and Google Play Billing could not be exercised against the real services in the container. Both are
  wired to the official plugins and handle the "store unavailable" and "no ad loaded" states.
- Purchase verification is local unless you configure a backend (see above).
- Daily rewards and missions use the device clock. Moving the clock back blocks claiming, but the checks are
  not server-authoritative.
- The 3D look is illustrated 2D (parallax, shading, shadows, fog), not real 3D geometry.
- Audio is shipped as WAV for simplicity (about 2 MB). Convert it to OGG to shrink the APK if you want.
