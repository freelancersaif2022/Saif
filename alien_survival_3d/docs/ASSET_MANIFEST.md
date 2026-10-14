# Asset manifest and licensing

The attached concept sheet (`58390.png`) was used only as an **art-direction
reference**. It is not shipped, cropped or displayed by the game. Every asset in
the app is original and generated from source in this repository, so there are
no third-party art or audio licences. The project's own licence covers these
assets.

Third-party code:

| Component | Version | Licence | Use |
| --- | --- | --- | --- |
| three.js | 0.180.0 | MIT | 3D renderer (bundled into `assets/game/game.js`; licence text kept at the end of the bundle) |
| esbuild | 0.25.10 | MIT | build tool only |
| webview_flutter / webview_flutter_android | 4.14.x | BSD-3 | hosts the engine surface |
| shared_preferences | 2.5.x | BSD-3 | local save data |
| audioplayers | 6.8.x | MIT | menu music and UI sounds |

## 3D models (procedural, `engine_src/src/actors/models.js`)

All characters are **real skinned meshes** (`THREE.SkinnedMesh` + `THREE.Skeleton`). Each part is rigidly weighted to one bone. They are built from primitives, lathe/extrude shapes and jittered polyhedra.

| Asset | Reference item | Notes |
| --- | --- | --- |
| Soldier | Main character | Olive shirt with chest pockets and sleeve patches, dark-blue trousers, knee pads, boots, gloves, backpack with bedroll, belt pouches, thigh holster, short dark hair. 18 bones. |
| Purple Grunt | Alien 1 (Normal) | Violet armour plates, glowing chest core and eyes, shoulder spikes, claws |
| Red Stalker | Alien 2 (Fast) | Red armour, longer claws |
| Blue Brute | Alien 3 (Big) | Massive brute rig, cyan core with rays, horns, armoured fists |
| Green Crawler | Alien 4 (Crawler) | Quadruped rig with tail stinger, glowing back nodes |
| Acid Spitter, Bloater, Sky Wraith (winged), Void Elite, Hive Titan (boss) | Special aliens from the brief | Same pipeline, distinct rigs and colours |
| Assault rifle, shotgun, sniper (scope), SMG, pistol, minigun (spinning barrel mesh), grenade | Weapons row | Static meshes with grip / foregrip / muzzle / ejection sockets |
| Health pack, ammo box, armor vest, coin, gem, gun-upgrade case, shield, speed boot, grenade, HP boost | Pickups row | `game/pickups.js` |
| Wooden spikes, landmine, crate, explosive barrel, wood barrier, rock, fallen log | Traps / obstacles row | `world/props.js`, `world/foliage.js` |
| Pine / broadleaf / dead trees, bushes, ferns, grass, flowers, rocks | Trees / plants row | Instanced per chunk with LOD |
| Watchtower, wooden bridge, cave with glowing crystals, streams/ponds, dirt paths, distant mountains, sky | Environment panels | `world/*`, `render/sky.js` |

## Animations (procedural clips, `engine_src/src/actors/anim.js`)

- **Soldier, base layer:** idle, locomotion (walk to run to sprint, played in reverse when backpedalling), crouch, crouch-walk, jump, fall, land, roll, death, pickup.
- **Soldier, upper layer** (arms solved with two-bone IK to the weapon): aim, low-ready, sprint carry, reload, weapon switch, grenade throw, heal, interact, pickup.
- **Soldier, additive:** hit reaction and recoil.
- **Aliens, per rig** (humanoid / brute / crawler / bloater / flyer): idle, move (walk/run), attack (claw swipe, smash, slam, lunge, dive), spit, roar, spawn (rise from the ground), death, plus an additive hit reaction.

## Textures (procedural canvas, `engine_src/src/render/textures.js`)

Ground detail, fabric, skin, bark, rock, alien chitin, brushed metal, wood
planks, crate, hazard barrel, medkit, ammo box, muzzle flash, glow sprite,
scorch decal and sleeve patches.

## Effects (`engine_src/src/fx/`)

GPU particles simulated in the vertex shader, with additive and alpha pools. They cover muzzle flashes with lights, tracers, brass casings, dirt/rock/wood/metal/water impacts, alien hit splashes in each alien's colour, explosions (fireball, fire, smoke, debris, light, scorch decal), shockwave rings, acid with damaging puddles, spawn portals, pickup sparkles and the shield bubble.

## Audio (86 files, `tool/gen_audio.py` → `assets/game/audio/*.ogg`)

All synthesised with numpy/scipy and encoded to OGG Vorbis with ffmpeg:

- **Weapons:** six gunshots, minigun spin loop, three reloads, empty click, weapon switch, three shell casings, grenade pin and bounce.
- **Impacts:** two explosions, dirt / rock / wood / alien-flesh impacts, headshot ding, hit marker.
- **Aliens:** three growls, attack screech, two hurts, two deaths, footsteps, boss roar and slam, acid spit and splash, wing flaps, bloater beeps, shockwave, spawn portal.
- **Environment:** forest, wind and water ambience loops; three bird calls, leaves; footsteps on grass, dirt, water and wood.
- **Gameplay and UI:** ten pickup/buff sounds, player hurt/death, armor break, UI click/select, wave start/clear, boss alert, game over, mine beep, spike hit, crate break, jump, land, roll, low-health heartbeat.
- **Music:** menu (Am-F-C-G, 84 BPM), combat (E minor, 124 BPM), boss (D minor, 146 BPM), game-over sting.

## UI images (`assets/images/`)

`menu_bg.jpg`, `soldier.png`, `alien_*.png` and `weapon_*.png` are renders of the
in-game 3D models, produced by `engine_src/dev/render_ui_assets.mjs` (engine
showcase mode). HUD icons are inline SVG in `engine_src/src/ui/icons.js`.

## Fidelity note

The reference sheet is a photo-realistic concept painting. These assets are
stylised, low/mid-poly procedural recreations that follow its colours,
silhouettes, props and layout. They are **not** equivalent to production-scanned or
hand-sculpted AAA models. Swapping in licensed glTF characters would need a
GLTFLoader path in `actors/models.js` mapped onto the same bone names. That is
not implemented yet.
