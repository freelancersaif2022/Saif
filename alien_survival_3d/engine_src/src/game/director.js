// Endless survival director: wave composition and escalation, spawn pacing
// under a bounded alive count, valid off-screen spawn points (including cave
// mouths), boss waves, kill rewards, drops, score and combo multiplier.
import * as THREE from 'three';
import { ENEMIES } from '../core/config.js';

const UNLOCK = [
  ['grunt', 1, 1, 10], ['runner', 2, 1, 7], ['crawler', 3, 1, 7], ['spitter', 4, 1.5, 5],
  ['tank', 6, 4, 3], ['exploder', 7, 1.5, 5], ['flyer', 8, 1.5, 5], ['elite', 10, 5, 2],
];

const _v = new THREE.Vector3();
const _frustum = new THREE.Frustum();
const _pm = new THREE.Matrix4();

export class Director {
  constructor(game) {
    this.game = game;
    this.wave = 0;
    this.state = 'intermission';
    this.timer = 3;
    this.queue = [];
    this.spawnT = 0;
    this.combo = 1;
    this.comboT = 0;
    this.bossAlive = null;
  }

  level(n = this.wave) {
    return {
      hp: 1 + 0.09 * (n - 1) + Math.max(0, n - 15) * 0.05,
      dmg: 1 + 0.05 * (n - 1),
      speed: Math.min(1.3, 1 + 0.012 * (n - 1)),
    };
  }

  composeWave(n) {
    const isBoss = n % 5 === 0;
    let budget = Math.round(6 + n * 2.6);
    const list = [];
    if (isBoss) { list.push('boss'); budget = Math.round(budget * 0.5); }
    const avail = UNLOCK.filter((u) => n >= u[1]);
    const totalW = avail.reduce((s, u) => s + u[3] * (n - u[1] < 2 ? 1.6 : 1), 0);
    let guard = 0;
    while (budget > 0 && guard++ < 400) {
      let r = Math.random() * totalW;
      let pick = avail[0];
      for (const u of avail) { r -= u[3] * (n - u[1] < 2 ? 1.6 : 1); if (r <= 0) { pick = u; break; } }
      if (pick[2] > budget && budget < 4) pick = avail[0];
      list.push(pick[0]);
      budget -= pick[2];
    }
    // shuffle (boss first so it gets an entrance)
    for (let i = list.length - 1; i > (isBoss ? 1 : 0); i--) {
      const j = (isBoss ? 1 : 0) + Math.floor(Math.random() * (i - (isBoss ? 1 : 0) + 1));
      [list[i], list[j]] = [list[j], list[i]];
    }
    return list;
  }

  startWave() {
    const g = this.game;
    this.wave++;
    g.stats.wave = this.wave;
    this.queue = this.composeWave(this.wave);
    this.waveTotal = this.queue.length;
    this.state = 'active';
    this.spawnT = 0.5;
    const boss = this.wave % 5 === 0;
    g.hud.banner(boss ? `WAVE ${this.wave}` : `WAVE ${this.wave}`, boss ? 'BOSS INCOMING: HIVE TITAN' : `${this.waveTotal} hostiles detected`, boss);
    g.sfx(boss ? 'boss_alert' : 'wave_start');
    g.audio.playMusic(boss ? 'music_boss' : 'music_combat');
  }

  noise() { /* every alien already hunts the player; kept for future stealth mechanics */ }

  onDamage() {}

  onKill(e, opts) {
    const g = this.game;
    const st = g.stats;
    st.kills++;
    st.killsByType[e.def.id] = (st.killsByType[e.def.id] || 0) + 1;
    this.comboT = 4;
    this.combo = Math.min(5, this.combo + 0.25);
    st.maxCombo = Math.max(st.maxCombo, this.combo);
    const pts = Math.round(e.def.score * this.combo * (1 + this.wave * 0.05));
    st.score += pts;
    g.hud.killFeed(e.def.name, pts, this.combo);
    if (e.def.behavior === 'boss') { st.bossesKilled++; this.bossAlive = null; g.hud.bossBar(null); }
    // rewards
    const pos = e.pos;
    const coins = e.def.coins;
    const n = Math.min(6, Math.ceil(coins / 3));
    for (let i = 0; i < n; i++) {
      const p = pos.clone();
      p.x += (Math.random() - 0.5) * 1.5; p.z += (Math.random() - 0.5) * 1.5;
      g.pickups.drop('coin', p, { value: Math.max(1, Math.round(coins / n)) });
    }
    const P = g.player;
    const w = P.weapon;
    const lowAmmo = w.reserve !== Infinity && w.reserve < w.def.mag * 2;
    const r = Math.random();
    let drop = null;
    const healthChance = 0.07 + (P.health < P.maxHealth * 0.4 ? 0.12 : 0);
    const ammoChance = 0.08 + (lowAmmo ? 0.2 : 0);
    if (r < healthChance) drop = 'health';
    else if (r < healthChance + ammoChance) drop = 'ammo';
    else if (r < healthChance + ammoChance + 0.04) drop = 'armor';
    else if (r < healthChance + ammoChance + 0.07) drop = 'grenade';
    else if (r < healthChance + ammoChance + 0.09) drop = 'speed';
    else if (r < healthChance + ammoChance + 0.105) drop = 'upgrade';
    else if (r < healthChance + ammoChance + 0.115) drop = 'shield';
    else if (r < healthChance + ammoChance + 0.122) drop = 'hpboost';
    if (drop) g.pickups.drop(drop, pos.clone().add(_v.set(0.6, 0, 0.4)));
    if (e.def.behavior === 'elite' || e.def.behavior === 'boss' || Math.random() < 0.03) g.pickups.drop('gem', pos.clone().add(_v.set(-0.6, 0, 0.2)));
    if (e.def.behavior === 'boss') {
      for (const t of ['upgrade', 'shield', 'hpboost', 'ammo', 'health', 'gem', 'gem']) {
        g.pickups.drop(t, pos.clone().add(_v.set((Math.random() - 0.5) * 4, 0, (Math.random() - 0.5) * 4)));
      }
    }
  }

  // Finds a valid, reachable spawn point out of the player's view.
  spawnPoint(type) {
    const g = this.game;
    const P = g.player.pos;
    const def = ENEMIES[type];
    const cam = g.camera;
    _pm.multiplyMatrices(cam.projectionMatrix, cam.matrixWorldInverse);
    _frustum.setFromProjectionMatrix(_pm);
    const ambush = def.behavior === 'crawler';
    const near = ambush ? 14 : 24, far = ambush ? 22 : 40;
    // caves are natural hives
    if (def.behavior !== 'flyer' && def.behavior !== 'boss' && Math.random() < 0.3) {
      for (const c of g.world.caves) {
        const d = Math.hypot(c.x - P.x, c.z - P.z);
        if (d > 12 && d < 45 && g.world.validSpawn(c.x, c.z, 0.6)) return _v.set(c.x, 0, c.z).clone();
      }
    }
    let fallback = null;
    for (let tries = 0; tries < 24; tries++) {
      const a = Math.random() * Math.PI * 2;
      const r = near + Math.random() * (far - near);
      const x = P.x + Math.cos(a) * r, z = P.z + Math.sin(a) * r;
      const R = def.radius * def.scale;
      if (!g.world.validSpawn(x, z, R)) continue;
      if (def.behavior !== 'flyer' && !g.flow.reachable(x, z)) continue;
      const y = g.world.groundHeight(x, z);
      _v.set(x, y + 1, z);
      const p = _v.clone();
      if (_frustum.containsPoint(p) && tries < 18) { fallback = fallback || p; continue; }
      return p.setY(y);
    }
    return fallback ? fallback.setY(g.world.groundHeight(fallback.x, fallback.z)) : null;
  }

  summon(pos, n) {
    const g = this.game;
    for (let i = 0; i < n; i++) {
      const a = (i / n) * Math.PI * 2;
      const x = pos.x + Math.cos(a) * 4, z = pos.z + Math.sin(a) * 4;
      if (!g.world.validSpawn(x, z, 0.6)) continue;
      const type = i % 2 ? 'crawler' : 'grunt';
      g.enemies.spawn(type, new THREE.Vector3(x, g.world.groundHeight(x, z), z), this.level());
    }
  }

  update(dt) {
    const g = this.game;
    if (!g.player.alive) return;
    this.comboT -= dt;
    if (this.comboT <= 0 && this.combo > 1) { this.combo = Math.max(1, this.combo - dt * 0.8); }
    if (this.state === 'intermission') {
      this.timer -= dt;
      g.hud.countdown(Math.ceil(this.timer));
      if (this.timer <= 0) { g.hud.countdown(null); this.startWave(); }
      return;
    }
    const maxAlive = g.quality.maxEnemies + Math.min(6, Math.floor(this.wave / 4));
    this.spawnT -= dt;
    if (this.queue.length && this.spawnT <= 0 && g.enemies.aliveCount < maxAlive) {
      const type = this.queue[0];
      const p = this.spawnPoint(type);
      if (p) {
        this.queue.shift();
        const e = g.enemies.spawn(type, p, this.level());
        if (type === 'boss') { this.bossAlive = e; g.hud.bossBar(e); }
      }
      this.spawnT = Math.max(0.35, 1.5 - this.wave * 0.06) * (0.6 + Math.random() * 0.8);
    }
    if (this.bossAlive) g.hud.bossBar(this.bossAlive);
    if (!this.queue.length && g.enemies.aliveCount === 0) {
      this.state = 'intermission';
      this.timer = 6;
      const bonus = 250 * this.wave;
      g.stats.score += bonus;
      g.hud.banner('WAVE CLEARED', `+${bonus} survival bonus`, false);
      g.sfx('wave_clear');
      g.audio.playMusic('music_combat');
      // resupply a little between waves
      g.player.armor = Math.min(g.player.maxArmor, g.player.armor + 10);
    }
  }

  remaining() { return this.queue.length + this.game.enemies.aliveCount; }
}
