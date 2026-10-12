/// Every bundled asset path used by the game lives here so that the code and
/// `pubspec.yaml` stay in sync.
class AssetPaths {
  AssetPaths._();

  static const String splashBg = 'assets/backgrounds/splash_bg.jpg';
  static const String lobbyBg = 'assets/backgrounds/lobby_bg.jpg';
  static const String skyline = 'assets/backgrounds/skyline.png';

  static const String groundDirt = 'assets/maps/ground_dirt.png';
  static const String groundRoad = 'assets/maps/ground_road.png';

  static const String wallRuin = 'assets/images/wall_ruin.png';
  static const String concrete = 'assets/images/concrete.png';
  static const String roof = 'assets/images/roof.png';
  static const String sandbag = 'assets/images/sandbag.png';
  static const String crate = 'assets/images/crate.png';

  static const String tree = 'assets/sprites/tree.png';
  static const String treeDead = 'assets/sprites/tree_dead.png';
  static const String rock = 'assets/sprites/rock.png';
  static const String tankWreck = 'assets/sprites/tank_wreck.png';
  static const String truckWreck = 'assets/sprites/truck_wreck.png';
  static const String hedgehog = 'assets/sprites/hedgehog.png';
  static const String barrel = 'assets/sprites/barrel.png';
  static const String debris = 'assets/sprites/debris.png';

  static const String fxAtlas = 'assets/effects/fx_atlas.png';
  static const String crater = 'assets/effects/crater.png';

  static const String camoPlayer = 'assets/characters/camo_player.png';
  static const String camoDesert = 'assets/enemies/camo_desert.png';
  static const String camoUrban = 'assets/enemies/camo_urban.png';
  static const String camoDark = 'assets/enemies/camo_dark.png';
  static const String camoBoss = 'assets/enemies/camo_boss.png';

  static const String weaponAssault = 'assets/weapons/assault_rifle.png';
  static const String weaponSmg = 'assets/weapons/smg.png';
  static const String weaponShotgun = 'assets/weapons/shotgun.png';
  static const String weaponSniper = 'assets/weapons/sniper.png';

  static const String iconFire = 'assets/ui/icon_fire.png';
  static const String iconAim = 'assets/ui/icon_aim.png';
  static const String iconReload = 'assets/ui/icon_reload.png';
  static const String iconSprint = 'assets/ui/icon_sprint.png';
  static const String iconPause = 'assets/ui/icon_pause.png';
  static const String emblem = 'assets/ui/emblem.png';

  /// Images decoded into `dart:ui` images for the game renderer.
  static const List<String> gameImages = [
    skyline,
    groundDirt,
    groundRoad,
    wallRuin,
    concrete,
    roof,
    sandbag,
    crate,
    tree,
    treeDead,
    rock,
    tankWreck,
    truckWreck,
    hedgehog,
    barrel,
    debris,
    fxAtlas,
    crater,
    camoPlayer,
    camoDesert,
    camoUrban,
    camoDark,
    camoBoss,
  ];

  /// Images shown through Flutter widgets.
  static const List<String> widgetImages = [
    splashBg,
    lobbyBg,
    weaponAssault,
    weaponSmg,
    weaponShotgun,
    weaponSniper,
    iconFire,
    iconAim,
    iconReload,
    iconSprint,
    iconPause,
  ];
}

/// Audio file names relative to `assets/audio/` (the flame_audio prefix).
class Sfx {
  Sfx._();

  static const String shotAr = 'shot_ar.wav';
  static const String shotSmg = 'shot_smg.wav';
  static const String shotShotgun = 'shot_shotgun.wav';
  static const String shotSniper = 'shot_sniper.wav';
  static const String enemyShot = 'enemy_shot.wav';
  static const String bossShot = 'boss_shot.wav';
  static const String reload = 'reload.wav';
  static const String empty = 'empty.wav';
  static const String impact = 'impact.wav';
  static const String hit = 'hit.wav';
  static const String enemyAlert = 'enemy_alert.wav';
  static const String enemyDeath = 'enemy_death.wav';
  static const String playerHurt = 'player_hurt.wav';
  static const String playerDeath = 'player_death.wav';
  static const String bossRoar = 'boss_roar.wav';
  static const String explosion = 'explosion.wav';
  static const String heartbeat = 'heartbeat.wav';
  static const String uiClick = 'ui_click.wav';
  static const String uiSelect = 'ui_select.wav';

  static const String musicMenu = 'music_menu.wav';
  static const String musicBattle = 'music_battle.wav';
  static const String ambient = 'ambient_battle.wav';

  /// Sound effect name -> maximum simultaneous players.
  static const Map<String, int> pools = {
    shotAr: 5,
    shotSmg: 6,
    shotShotgun: 3,
    shotSniper: 2,
    enemyShot: 5,
    bossShot: 3,
    reload: 2,
    empty: 2,
    impact: 3,
    hit: 4,
    enemyAlert: 2,
    enemyDeath: 3,
    playerHurt: 2,
    playerDeath: 1,
    bossRoar: 1,
    explosion: 3,
    heartbeat: 1,
    uiClick: 2,
    uiSelect: 2,
  };
}
