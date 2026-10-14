// Static game data plus the default run configuration. The Flutter shell owns
// progression and sends a config (loadout, upgraded weapon stats, settings) via
// window.game.boot(); these defaults are used when the engine runs standalone
// in a desktop browser for development and automated tests.

export const QUALITY = {
  LOW: {
    pixelRatio: 0.75, shadows: false, shadowMapSize: 512, viewChunks: 1, terrainRes: 14,
    grassDensity: 0, bushDensity: 0.5, treeDensity: 0.75, maxEnemies: 12, particles: 1200,
    fogNear: 30, fogFar: 95, antialias: false, enemyShadows: false, standardMaterials: false,
  },
  MEDIUM: {
    pixelRatio: 1.0, shadows: true, shadowMapSize: 1024, viewChunks: 2, terrainRes: 20,
    grassDensity: 0.55, bushDensity: 0.8, treeDensity: 0.9, maxEnemies: 18, particles: 2500,
    fogNear: 40, fogFar: 140, antialias: false, enemyShadows: false, standardMaterials: true,
  },
  HIGH: {
    pixelRatio: 1.5, shadows: true, shadowMapSize: 2048, viewChunks: 2, terrainRes: 28,
    grassDensity: 1.0, bushDensity: 1.0, treeDensity: 1.0, maxEnemies: 26, particles: 4000,
    fogNear: 50, fogFar: 170, antialias: true, enemyShadows: true, standardMaterials: true,
  },
};

export const WEAPONS = {
  rifle: {
    id: 'rifle', name: 'Assault Rifle', auto: true, damage: 24, fireInterval: 0.1, pellets: 1,
    mag: 30, reserve: 180, maxReserve: 300, reload: 2.0, spreadHip: 1.6, spreadAim: 0.45,
    recoil: 0.9, range: 120, zoomFov: 50, penetration: 1, armorPiercing: 0, spinUp: 0,
    moveMul: 0.95, sound: 'fire_rifle', reloadSound: 'reload_rifle', shellScale: 1, falloff: 60,
  },
  shotgun: {
    id: 'shotgun', name: 'Shotgun', auto: false, damage: 15, fireInterval: 0.75, pellets: 9,
    mag: 8, reserve: 40, maxReserve: 64, reload: 2.6, spreadHip: 6.5, spreadAim: 4.5,
    recoil: 3.2, range: 35, zoomFov: 58, penetration: 1, armorPiercing: 0, spinUp: 0,
    moveMul: 0.95, sound: 'fire_shotgun', reloadSound: 'reload_shotgun', shellScale: 1.6, falloff: 12,
  },
  sniper: {
    id: 'sniper', name: 'Sniper Rifle', auto: false, damage: 160, fireInterval: 1.25, pellets: 1,
    mag: 5, reserve: 30, maxReserve: 50, reload: 2.8, spreadHip: 5.0, spreadAim: 0.05,
    recoil: 5.0, range: 320, zoomFov: 16, penetration: 3, armorPiercing: 1, spinUp: 0,
    moveMul: 0.88, sound: 'fire_sniper', reloadSound: 'reload_rifle', shellScale: 1.4, falloff: 250,
  },
  smg: {
    id: 'smg', name: 'SMG', auto: true, damage: 15, fireInterval: 0.066, pellets: 1,
    mag: 35, reserve: 210, maxReserve: 350, reload: 1.6, spreadHip: 2.4, spreadAim: 1.0,
    recoil: 0.6, range: 60, zoomFov: 55, penetration: 1, armorPiercing: 0, spinUp: 0,
    moveMul: 1.0, sound: 'fire_smg', reloadSound: 'reload_pistol', shellScale: 0.8, falloff: 25,
  },
  pistol: {
    id: 'pistol', name: 'Pistol', auto: false, damage: 32, fireInterval: 0.2, pellets: 1,
    mag: 12, reserve: Infinity, maxReserve: Infinity, reload: 1.2, spreadHip: 1.4, spreadAim: 0.5,
    recoil: 1.5, range: 70, zoomFov: 55, penetration: 1, armorPiercing: 0, spinUp: 0,
    moveMul: 1.05, sound: 'fire_pistol', reloadSound: 'reload_pistol', shellScale: 0.7, falloff: 30,
  },
  minigun: {
    id: 'minigun', name: 'Minigun', auto: true, damage: 19, fireInterval: 0.045, pellets: 1,
    mag: 200, reserve: 400, maxReserve: 800, reload: 4.2, spreadHip: 2.8, spreadAim: 1.8,
    recoil: 0.35, range: 90, zoomFov: 58, penetration: 1, armorPiercing: 0, spinUp: 0.55,
    moveMul: 0.7, sound: 'fire_minigun', reloadSound: 'reload_rifle', shellScale: 1, falloff: 45,
  },
};

export const GRENADE = { damage: 160, radius: 6.5, fuse: 2.2, throwSpeed: 17 };

// Alien roster. colors: [body, plate, glow]. resist: multiplier for ordinary bullets.
export const ENEMIES = {
  grunt: {
    id: 'grunt', name: 'Purple Grunt', hp: 110, walk: 2.6, run: 4.6, damage: 12, range: 1.9,
    cooldown: 1.1, radius: 0.55, height: 2.0, scale: 1.0, colors: [0x2a1a3d, 0x5b3a8a, 0xb44dff],
    resist: 1.0, score: 100, coins: 3, behavior: 'melee', rig: 'humanoid',
  },
  runner: {
    id: 'runner', name: 'Red Stalker', hp: 70, walk: 4.5, run: 8.0, damage: 9, range: 1.8,
    cooldown: 0.7, radius: 0.5, height: 1.9, scale: 0.92, colors: [0x3a0d0d, 0x8f1d1d, 0xff3b2f],
    resist: 1.0, score: 130, coins: 3, behavior: 'fast', rig: 'humanoid',
  },
  tank: {
    id: 'tank', name: 'Blue Brute', hp: 650, walk: 2.0, run: 2.6, damage: 28, range: 2.8,
    cooldown: 1.8, radius: 1.0, height: 3.1, scale: 1.55, colors: [0x0d1f3d, 0x284d8f, 0x2ee6ff],
    resist: 0.5, score: 400, coins: 10, behavior: 'tank', rig: 'brute',
  },
  crawler: {
    id: 'crawler', name: 'Green Crawler', hp: 60, walk: 4.0, run: 7.2, damage: 10, range: 1.7,
    cooldown: 0.8, radius: 0.55, height: 0.9, scale: 1.0, colors: [0x22300d, 0x5c7a1a, 0x9dff2e],
    resist: 1.0, score: 120, coins: 3, behavior: 'crawler', rig: 'crawler',
  },
  spitter: {
    id: 'spitter', name: 'Acid Spitter', hp: 95, walk: 2.4, run: 3.4, damage: 14, range: 18,
    cooldown: 2.4, radius: 0.55, height: 2.0, scale: 1.0, colors: [0x2b330a, 0x8a9a1c, 0xd8ff3a],
    resist: 1.0, score: 160, coins: 4, behavior: 'spitter', rig: 'humanoid',
  },
  exploder: {
    id: 'exploder', name: 'Bloater', hp: 55, walk: 3.6, run: 5.8, damage: 45, range: 2.2,
    cooldown: 1.0, radius: 0.6, height: 1.6, scale: 0.95, colors: [0x3d200a, 0xa3561c, 0xff9b1f],
    resist: 1.0, score: 150, coins: 4, behavior: 'exploder', rig: 'bloater',
  },
  flyer: {
    id: 'flyer', name: 'Sky Wraith', hp: 60, walk: 6.0, run: 9.0, damage: 10, range: 2.0,
    cooldown: 1.4, radius: 0.6, height: 1.4, scale: 0.85, colors: [0x0d2a33, 0x1c7a8f, 0x4dfff0],
    resist: 1.0, score: 180, coins: 5, behavior: 'flyer', rig: 'flyer',
  },
  elite: {
    id: 'elite', name: 'Void Elite', hp: 420, walk: 3.2, run: 5.6, damage: 22, range: 2.1,
    cooldown: 0.9, radius: 0.65, height: 2.3, scale: 1.18, colors: [0x101015, 0x6b5a1c, 0xff2ee6],
    resist: 0.7, score: 450, coins: 12, behavior: 'elite', rig: 'humanoid',
  },
  boss: {
    id: 'boss', name: 'Hive Titan', hp: 3600, walk: 2.4, run: 3.4, damage: 40, range: 4.5,
    cooldown: 2.0, radius: 1.8, height: 6.0, scale: 3.0, colors: [0x170d33, 0x3d2a8f, 0x7a5cff],
    resist: 0.8, score: 3000, coins: 60, behavior: 'boss', rig: 'brute',
  },
};

export const PICKUPS = {
  health: { id: 'health', label: 'Health Pack' },
  ammo: { id: 'ammo', label: 'Ammo Box' },
  armor: { id: 'armor', label: 'Armor' },
  coin: { id: 'coin', label: 'Coin' },
  gem: { id: 'gem', label: 'Gem' },
  upgrade: { id: 'upgrade', label: 'Gun Upgrade' },
  shield: { id: 'shield', label: 'Shield' },
  speed: { id: 'speed', label: 'Speed Boost' },
  grenade: { id: 'grenade', label: 'Grenades' },
  hpboost: { id: 'hpboost', label: 'HP Boost' },
};

export function defaultConfig() {
  return {
    mode: 'play', // 'play' | 'layout' (control layout editor) | 'showcase' (menu art renders)
    seed: Math.floor(Math.random() * 1e9),
    loadout: ['rifle', 'shotgun', 'pistol'],
    weapons: {}, // per-weapon stat overrides computed by the Flutter upgrade system
    player: { maxHealth: 100, maxArmor: 100, startArmor: 50, grenades: 3, maxGrenades: 6 },
    settings: {
      quality: 'MEDIUM', fps: 60, sensitivity: 1.0, aimSensitivity: 0.6, fov: 70,
      invertY: false, aimAssist: true, shoulder: 1, cameraShake: 1.0,
      musicVolume: 0.6, sfxVolume: 0.9, ambienceVolume: 0.7, masterVolume: 1.0,
      controlScale: 1.0, controlOpacity: 0.85, showFps: false, layout: null,
    },
    debug: { god: false, timeScale: 1 },
  };
}

export function mergeConfig(base, over) {
  if (!over || typeof over !== 'object') return base;
  const out = Array.isArray(base) ? [...base] : { ...base };
  for (const k of Object.keys(over)) {
    const v = over[k];
    if (v && typeof v === 'object' && !Array.isArray(v) && base[k] && typeof base[k] === 'object' && !Array.isArray(base[k])) {
      out[k] = mergeConfig(base[k], v);
    } else if (v !== undefined) {
      out[k] = v;
    }
  }
  return out;
}
