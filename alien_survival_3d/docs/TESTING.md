# Test results and known limitations

Environment: Linux cloud container. Flutter 3.47.7 / Dart 3.13.5. Headless
Chromium 1194 with SwiftShader (software WebGL 2). No Android device or
emulator was available (no KVM).

## Automated tests: what actually ran

| Suite | Command | Result |
| --- | --- | --- |
| Static analysis | `flutter analyze` | No issues |
| Flutter unit + widget tests (32) | `flutter test` | All pass |
| Engine controls (16 checks) | `node engine_src/dev/run.mjs controls … 480 270 LOW` | All pass |
| Engine systems (26 checks) | `node engine_src/dev/run.mjs systems … 480 270 LOW` | 25 pass on the recorded run. The shield check failed for test-ordering reasons (the 10 s buff expired while other pickups were collected); the order has been fixed but not re-run. |
| Flutter ↔ engine contract (18 checks) | `node engine_src/dev/host_test.mjs` | All pass |
| Combat smoke | `node engine_src/dev/run.mjs combat` | Shots, hits, kill, score and drops register |
| Stress / pooling | `node engine_src/dev/run.mjs stress … 640 288 HIGH` | 26 alien instances reused across 78 spawns; textures and heap flat |

The engine scenarios need a static server: `npx http-server -p 8765 .` in `alien_survival_3d/`.

What these cover:

- **Flutter:** save/settings JSON round-trip and validation; recovery from a corrupted main record via the backup; defaults when everything is corrupted. Economy (purchases, gem prices, growing upgrade costs, max levels, locked weapons), run rewards, the high-score table capped at 10, malformed engine results, and upgraded stats in the boot config. The loopback asset server is tested over real HTTP (content types, 403/404/405, traversal). All engine bridge messages are parsed, and every sound named in the engine exists on disk. Widget tests cover every menu button, the exit confirmation, shop purchase persisted, upgrades, settings persisted, loadout selection, and no layout overflow at 640×320 and 915×412.
- **Engine (real game loop in Chromium):** joystick moves the soldier camera-forward while a second touch fires (multi-touch); drag rotates the camera; reload; switching through the loadout and firing each weapon; grenade throw and explosion; crouch, jump and roll; pause through the HUD button with time frozen, then resume. Every pickup type, the interact button for gun-upgrade cases and crates, landmine, spike trap and barrel chain explosion. All 9 alien types approach and damage the player. Game-over message with stats, then restart.
- **Contract:** the exact config produced by `GameState.engineConfig()` boots the engine in host mode. Upgrades, loadout, saved layout and live settings are applied. Pause, resume, restart and game over are reported. The layout editor saves dragged positions and DONE returns.

## Not tested (no device available)

- An Android build in this container: the Android SDK download host (`dl.google.com`) is blocked by the environment's network policy. The GitHub Actions workflow builds the APK instead; see the workflow run for its status.
- On-device behaviour: WebView WebGL performance, real frame rates, touch latency, audio output, haptics, lifecycle pausing, the back button. **No frame rate is guaranteed.** SwiftShader software rendering ran at roughly 3–20 FPS depending on resolution, which says nothing about phone GPUs. Measured renderer load at HIGH with 26 aliens was about 160–260 draw calls and 190–230k triangles. LOW (fewer chunks, no shadows, no grass, Lambert materials) is the intended preset for weak devices.
- Memory-leak checking beyond the pooling/heap observation above.

## Known limitations

- **Art fidelity:** the art is stylised procedural low/mid-poly. It follows the reference's colours, silhouettes and layout but is not photo-real AAA art (see ASSET_MANIFEST.md).
- **Pathfinding:** aliens path-find with a 108 m flow field around the player. Beyond it they steer directly until they enter the field.
- **Elevated structures:** the player cannot climb the watchtowers. Bridges are walkable.
- **Audio quality:** all audio is synthesised. It is functional and varied, but not studio-recorded.
- **Graphics quality changes** take effect at the next game, because the renderer is rebuilt on boot.
- **WebView requirement:** the engine needs a WebGL 2-capable Android System WebView (Android 7+, updated WebView). Otherwise the game screen shows an error with instructions.
