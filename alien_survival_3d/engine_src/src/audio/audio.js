// WebAudio engine: music / sfx / ambience buses with independent volumes,
// 3D positional sound (HRTF on HIGH quality), per-sound voice limits and
// re-trigger gaps so rapid fire never distorts, and music crossfades.

export const SOUNDS = {
  // name: [maxVoices, minGapSeconds, baseVolume]
  fire_rifle: [6, 0.03, 0.75], fire_shotgun: [3, 0.05, 0.9], fire_sniper: [2, 0.1, 1.0], fire_smg: [6, 0.025, 0.65],
  fire_pistol: [4, 0.04, 0.75], fire_minigun: [6, 0.02, 0.55], minigun_spin: [1, 0.2, 0.5], reload_rifle: [1, 0.2, 0.8],
  reload_shotgun: [1, 0.2, 0.8], reload_pistol: [1, 0.2, 0.8], empty_click: [1, 0.15, 0.7], weapon_switch: [1, 0.1, 0.7],
  shell_1: [4, 0.03, 0.25], shell_2: [4, 0.03, 0.25], shell_3: [4, 0.03, 0.25], grenade_pin: [1, 0.1, 0.8],
  grenade_bounce: [3, 0.08, 0.6], explosion_1: [4, 0.05, 1.0], explosion_2: [4, 0.05, 1.0], impact_dirt: [5, 0.03, 0.4],
  impact_rock: [5, 0.03, 0.45], impact_wood: [5, 0.03, 0.45], impact_flesh: [6, 0.02, 0.55], headshot: [2, 0.05, 0.7],
  hitmarker: [3, 0.03, 0.35], growl_1: [3, 0.4, 0.75], growl_2: [3, 0.4, 0.75], growl_3: [3, 0.4, 0.75],
  alien_attack: [4, 0.1, 0.8], alien_hurt_1: [4, 0.08, 0.6], alien_hurt_2: [4, 0.08, 0.6], alien_death_1: [4, 0.06, 0.85],
  alien_death_2: [4, 0.06, 0.85], alien_step: [6, 0.05, 0.35], boss_roar: [1, 1.0, 1.0], boss_slam: [2, 0.2, 1.0],
  acid_spit: [3, 0.1, 0.7], acid_splash: [3, 0.1, 0.6], wing_flap: [3, 0.15, 0.5], bloater_beep: [3, 0.1, 0.6],
  shockwave: [2, 0.2, 0.9], spawn_portal: [4, 0.1, 0.55], amb_forest: [1, 0, 0.7], amb_wind: [1, 0, 0.5], amb_water: [1, 0, 0.7],
  bird_1: [2, 1, 0.45], bird_2: [2, 1, 0.45], bird_3: [2, 1, 0.45], leaves: [2, 0.3, 0.4], step_grass_1: [3, 0.08, 0.35],
  step_grass_2: [3, 0.08, 0.35], step_grass_3: [3, 0.08, 0.35], step_dirt_1: [3, 0.08, 0.35], step_dirt_2: [3, 0.08, 0.35],
  step_water: [3, 0.08, 0.45], step_wood: [3, 0.08, 0.45], pickup_coin: [3, 0.04, 0.6], pickup_gem: [2, 0.05, 0.7],
  pickup_health: [2, 0.1, 0.75], pickup_armor: [2, 0.1, 0.75], pickup_ammo: [2, 0.1, 0.75], pickup_power: [2, 0.1, 0.8],
  heal: [1, 0.3, 0.7], shield_on: [1, 0.3, 0.8], speed_on: [1, 0.3, 0.8], player_hurt_1: [2, 0.15, 0.8],
  player_hurt_2: [2, 0.15, 0.8], player_death: [1, 1, 0.9], armor_break: [1, 0.5, 0.8], ui_click: [2, 0.03, 0.6],
  ui_select: [2, 0.03, 0.6], wave_start: [1, 1, 0.8], wave_clear: [1, 1, 0.8], boss_alert: [1, 1, 0.9], game_over: [1, 1, 0.9],
  mine_beep: [3, 0.1, 0.7], spike_hit: [3, 0.1, 0.7], crate_break: [3, 0.05, 0.8], jump: [1, 0.2, 0.5], land: [2, 0.1, 0.5],
  roll: [1, 0.2, 0.6], low_health: [1, 0, 0.6],
  music_menu: [1, 0, 0.6], music_combat: [1, 0, 0.55], music_boss: [1, 0, 0.6], music_gameover: [1, 0, 0.7],
};

const MAX_VOICES = 36;

export class AudioEngine {
  constructor(settings, quality) {
    this.ok = false;
    this.buffers = new Map();
    this.voices = new Map();
    this.lastPlay = new Map();
    this.active = 0;
    this.hrtf = quality === 'HIGH';
    try {
      const AC = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AC({ latencyHint: 'interactive' });
      this.master = this.ctx.createGain();
      // Gentle limiter so stacked explosions do not clip.
      this.comp = this.ctx.createDynamicsCompressor();
      this.comp.threshold.value = -10; this.comp.knee.value = 8; this.comp.ratio.value = 6;
      this.comp.attack.value = 0.003; this.comp.release.value = 0.2;
      this.master.connect(this.comp).connect(this.ctx.destination);
      this.music = this.ctx.createGain(); this.music.connect(this.master);
      this.sfx = this.ctx.createGain(); this.sfx.connect(this.master);
      this.amb = this.ctx.createGain(); this.amb.connect(this.master);
      this.ok = true;
    } catch (e) {
      console.warn('WebAudio unavailable', e);
    }
    this.setVolumes(settings);
    this.musicTrack = null;
    this.loops = new Map();
  }

  setVolumes(s) {
    if (!this.ok) return;
    const t = this.ctx.currentTime;
    this.master.gain.setTargetAtTime(s.masterVolume ?? 1, t, 0.05);
    this.music.gain.setTargetAtTime(s.musicVolume ?? 0.6, t, 0.05);
    this.sfx.gain.setTargetAtTime(s.sfxVolume ?? 0.9, t, 0.05);
    this.amb.gain.setTargetAtTime(s.ambienceVolume ?? 0.7, t, 0.05);
  }

  unlock() {
    if (this.ok && this.ctx.state !== 'running') this.ctx.resume().catch(() => {});
  }

  suspend() { if (this.ok) this.ctx.suspend().catch(() => {}); }
  resume() { if (this.ok) this.ctx.resume().catch(() => {}); }

  async load(base = 'audio/', onProgress) {
    if (!this.ok) return;
    const names = Object.keys(SOUNDS);
    let done = 0;
    await Promise.all(names.map(async (name) => {
      try {
        const res = await fetch(`${base}${name}.ogg`);
        if (!res.ok) throw new Error(res.status);
        const data = await res.arrayBuffer();
        const buf = await new Promise((resolve, reject) => this.ctx.decodeAudioData(data, resolve, reject));
        this.buffers.set(name, buf);
      } catch (e) {
        console.warn('sound failed', name, e && e.message);
      }
      done++;
      if (onProgress) onProgress(done / names.length);
    }));
  }

  setListener(cam) {
    if (!this.ok) return;
    const L = this.ctx.listener;
    const p = cam.position;
    const e = cam.matrixWorld.elements;
    const fx = -e[8], fy = -e[9], fz = -e[10];
    const ux = e[4], uy = e[5], uz = e[6];
    if (L.positionX) {
      const t = this.ctx.currentTime;
      L.positionX.setValueAtTime(p.x, t); L.positionY.setValueAtTime(p.y, t); L.positionZ.setValueAtTime(p.z, t);
      L.forwardX.setValueAtTime(fx, t); L.forwardY.setValueAtTime(fy, t); L.forwardZ.setValueAtTime(fz, t);
      L.upX.setValueAtTime(ux, t); L.upY.setValueAtTime(uy, t); L.upZ.setValueAtTime(uz, t);
    } else {
      L.setPosition(p.x, p.y, p.z);
      L.setOrientation(fx, fy, fz, ux, uy, uz);
    }
  }

  // opts: { pos, volume, rate, loop, bus: 'sfx'|'amb'|'music', ref }
  play(name, opts = {}) {
    if (!this.ok || this.ctx.state !== 'running') return null;
    const buf = this.buffers.get(name);
    if (!buf) return null;
    const [maxVoices, gap, base] = SOUNDS[name] || [4, 0, 1];
    const now = this.ctx.currentTime;
    const last = this.lastPlay.get(name) || -1;
    if (gap > 0 && now - last < gap) return null;
    let list = this.voices.get(name);
    if (!list) { list = []; this.voices.set(name, list); }
    if (list.length >= maxVoices) this._stop(list[0]);
    if (this.active >= MAX_VOICES && !opts.loop) {
      // Drop the oldest one-shot voice anywhere.
      for (const l of this.voices.values()) { if (l.length && !l[0].loop) { this._stop(l[0]); break; } }
    }
    this.lastPlay.set(name, now);
    const src = this.ctx.createBufferSource();
    src.buffer = buf;
    src.loop = !!opts.loop;
    src.playbackRate.value = opts.rate ?? (0.94 + Math.random() * 0.12);
    const gain = this.ctx.createGain();
    gain.gain.value = base * (opts.volume ?? 1);
    let node = src.connect(gain);
    let panner = null;
    if (opts.pos) {
      panner = this.ctx.createPanner();
      panner.panningModel = this.hrtf ? 'HRTF' : 'equalpower';
      panner.distanceModel = 'inverse';
      panner.refDistance = opts.ref ?? 4;
      panner.rolloffFactor = 1.1;
      panner.maxDistance = 150;
      if (panner.positionX) {
        panner.positionX.value = opts.pos.x; panner.positionY.value = opts.pos.y; panner.positionZ.value = opts.pos.z;
      } else panner.setPosition(opts.pos.x, opts.pos.y, opts.pos.z);
      node = node.connect(panner);
    }
    node.connect(opts.bus === 'amb' ? this.amb : opts.bus === 'music' ? this.music : this.sfx);
    const voice = { name, src, gain, panner, loop: !!opts.loop, list };
    src.onended = () => this._release(voice);
    list.push(voice);
    this.active++;
    src.start();
    return voice;
  }

  setVoicePos(v, pos) {
    if (!v || !v.panner) return;
    if (v.panner.positionX) {
      const t = this.ctx.currentTime;
      v.panner.positionX.setTargetAtTime(pos.x, t, 0.03); v.panner.positionY.setTargetAtTime(pos.y, t, 0.03); v.panner.positionZ.setTargetAtTime(pos.z, t, 0.03);
    } else v.panner.setPosition(pos.x, pos.y, pos.z);
  }

  setVoiceVolume(v, vol, tc = 0.1) {
    if (!v) return;
    const base = (SOUNDS[v.name] || [0, 0, 1])[2];
    v.gain.gain.setTargetAtTime(base * vol, this.ctx.currentTime, tc);
  }

  _stop(v) {
    try { v.src.onended = null; v.src.stop(); } catch (e) { /* already stopped */ }
    this._release(v);
  }

  stop(v, fade = 0) {
    if (!v || !this.ok) return;
    if (fade > 0) {
      v.gain.gain.setTargetAtTime(0, this.ctx.currentTime, fade / 3);
      setTimeout(() => this._stop(v), fade * 1000 + 50);
    } else this._stop(v);
  }

  _release(v) {
    const i = v.list.indexOf(v);
    if (i >= 0) { v.list.splice(i, 1); this.active--; }
    try { v.src.disconnect(); v.gain.disconnect(); if (v.panner) v.panner.disconnect(); } catch (e) { /* ignore */ }
  }

  // Keyed looping sound (ambience, minigun spin, heartbeat).
  loop(key, name, volume = 1, bus = 'amb') {
    let v = this.loops.get(key);
    if (v && v.name !== name) { this.stop(v, 0.5); v = null; }
    if (!v || !v.list.includes(v)) {
      v = this.play(name, { loop: true, volume: 0.0001, bus, rate: 1 });
      if (!v) return;
      this.loops.set(key, v);
    }
    this.setVoiceVolume(v, volume, 0.3);
  }

  stopLoop(key, fade = 0.4) {
    const v = this.loops.get(key);
    if (v) { this.stop(v, fade); this.loops.delete(key); }
  }

  playMusic(name, fade = 1.5) {
    if (this.musicName === name) return;
    this.musicName = name;
    if (this.musicTrack) this.stop(this.musicTrack, fade);
    this.musicTrack = null;
    if (!name) return;
    const loop = name !== 'music_gameover';
    const v = this.play(name, { loop, volume: 0.0001, bus: 'music', rate: 1 });
    if (v) { this.setVoiceVolume(v, 1, fade / 3); this.musicTrack = v; }
    else this.musicName = null; // retry later (e.g. context still locked)
  }

  stopAll() {
    for (const list of this.voices.values()) for (const v of [...list]) this._stop(v);
    this.loops.clear();
    this.musicTrack = null; this.musicName = null;
  }
}
