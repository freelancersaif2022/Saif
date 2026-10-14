// Alien Survival 3D engine entry point. Builds the renderer and all systems,
// runs the frame loop and exposes window.game for the Flutter bridge.
import * as THREE from 'three';
import { QUALITY, defaultConfig, mergeConfig } from './core/config.js';
import { send, hasHost } from './core/bridge.js';
import { World } from './world/world.js';
import { windUniform } from './world/foliage.js';
import { createSky, SKY } from './render/sky.js';
import { Effects } from './fx/effects.js';
import { AudioEngine } from './audio/audio.js';
import { Player } from './game/player.js';
import { CameraRig } from './game/camera.js';
import { Combat } from './game/combat.js';
import { EnemyManager } from './game/enemies.js';
import { Director } from './game/director.js';
import { Pickups } from './game/pickups.js';
import { PropSystem } from './game/propsys.js';
import { Projectiles } from './game/projectiles.js';
import { FlowField } from './game/flowfield.js';
import { Hud } from './ui/hud.js';
import { Controls } from './ui/controls.js';
import { makeIcons, capture, lights } from './render/snapshot.js';
import { alienTemplate, soldierTemplate, weaponModel } from './actors/models.js';
import { instantiate } from './actors/skeleton.js';
import { Animator, CLIPSETS } from './actors/anim.js';
import { ENEMIES } from './core/config.js';
import { WATER_Y } from './world/terrain.js';

const _v = new THREE.Vector3();

function newStats() {
  return {
    score: 0, kills: 0, killsByType: {}, wave: 0, time: 0, coins: 0, gems: 0, headshots: 0, shotsFired: 0, shotsHit: 0,
    damageTaken: 0, bossesKilled: 0, pickups: 0, cratesBroken: 0, barrels: 0, mines: 0, grenadesThrown: 0, maxCombo: 1,
  };
}

class Game {
  constructor() {
    this.running = false;
    this.paused = false;
    this.frame = 0;
    this.time = 0;
  }

  async boot(cfgIn) {
    const cfg = mergeConfig(defaultConfig(), typeof cfgIn === 'string' ? JSON.parse(cfgIn) : cfgIn || {});
    this.cfg = cfg;
    const qName = QUALITY[cfg.settings.quality] ? cfg.settings.quality : 'MEDIUM';
    this.qualityName = qName;
    this.quality = { ...QUALITY[qName] };
    const q = this.quality;
    const root = document.getElementById('game');
    this.root = root;
    this._loading(0.05, 'Building renderer');

    // renderer
    const renderer = new THREE.WebGLRenderer({ antialias: q.antialias, powerPreference: 'high-performance', stencil: false });
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, q.pixelRatio));
    this.pixelRatio = renderer.getPixelRatio();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.outputColorSpace = THREE.SRGBColorSpace;
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.05;
    renderer.shadowMap.enabled = q.shadows;
    renderer.shadowMap.type = qName === 'HIGH' ? THREE.PCFSoftShadowMap : THREE.PCFShadowMap;
    root.prepend(renderer.domElement);
    this.renderer = renderer;
    renderer.domElement.addEventListener('webglcontextlost', (e) => { e.preventDefault(); send('error', { message: 'WebGL context lost' }); });

    const scene = new THREE.Scene();
    scene.fog = new THREE.Fog(SKY.fog, q.fogNear, q.fogFar);
    this.scene = scene;
    this.camera = new THREE.PerspectiveCamera(cfg.settings.fov, window.innerWidth / window.innerHeight, 0.08, 1500);
    scene.add(createSky());
    this.skyGroup = scene.children[scene.children.length - 1];
    const hemi = new THREE.HemisphereLight(0xd6e8ff, 0x4d5b38, 1.25);
    scene.add(hemi);
    const sun = new THREE.DirectionalLight(0xfff0d0, 2.7);
    sun.castShadow = q.shadows;
    sun.shadow.mapSize.set(q.shadowMapSize, q.shadowMapSize);
    const sc = sun.shadow.camera;
    sc.left = -34; sc.right = 34; sc.top = 34; sc.bottom = -34; sc.near = 1; sc.far = 160;
    sun.shadow.bias = -0.0006;
    sun.shadow.normalBias = 0.04;
    scene.add(sun, sun.target);
    this.sun = sun;

    // systems
    this.stats = newStats();
    this.audio = new AudioEngine(cfg.settings, qName);
    this.fx = new Effects(scene, q);
    this.world = new World(scene, q, cfg.seed);
    this.flow = new FlowField(this.world);
    this.combat = new Combat(this);
    this.enemies = new EnemyManager(this);
    this.director = new Director(this);
    this.pickups = new Pickups(this);
    this.props = new PropSystem(this);
    this.projectiles = new Projectiles(this);
    this.world.onPickupSpawned = (type, pos, id) => this.pickups.spawnWorld(type, pos, id);
    this.world.onChunkUnloaded = (ch) => this.pickups.onChunkUnloaded(ch);
    this.fx.groundAt = (x, z) => this.world.groundHeight(x, z);
    this.fx.onShellLand = (p) => { if (Math.random() < 0.5) this.sfx(`shell_${1 + Math.floor(Math.random() * 3)}`, p, 0.6); };

    const spot = this.world.field.findDrySpot(0, 0);
    this.world.spawnSafe = { x: spot.x, z: spot.z, r: 14 };
    this._loading(0.2, 'Growing the forest');
    await this._tick();
    this.world.warmup(spot.x, spot.z);
    this._loading(0.45, 'Deploying soldier');
    await this._tick();

    this.player = new Player(this, cfg);
    this.player.spawn(spot.x, spot.z);
    this.camRig = new CameraRig(this.camera, this.world, cfg.settings);
    this.camRig.yaw = Math.random() * Math.PI * 2;
    this.flow.build(spot.x, spot.z);

    // UI
    this.controls = new Controls(root, cfg.settings, (layout) => {
      cfg.settings.layout = layout;
      send('layoutSaved', { layout });
    });
    this.controls.onFirstInput = () => this.audio.unlock();
    this.hud = new Hud(root, this);
    this.controls.registerExtra('pause', this.hud.pauseBtn);
    this.controls.registerExtra('switch', this.hud.weaponPanel);
    try {
      const icons = makeIcons(renderer);
      this.icons = icons;
      this.hud.setImages(icons.portrait, icons.weapons, icons.grenade);
    } catch (e) {
      console.warn('icon render failed', e);
    }

    this._loading(0.55, 'Loading audio');
    await this.audio.load('audio/', (p) => this._loading(0.55 + p * 0.4, 'Loading audio'));
    this._loading(1, 'Ready');

    window.addEventListener('resize', () => this._resize());
    document.addEventListener('visibilitychange', () => { if (document.hidden && this.running && !this.over) this.pause(true); });
    this._resize();
    this._fpsWindow = []; this._perfT = 0;
    this.running = true;
    this.over = false;
    this.mode = cfg.mode;
    if (cfg.mode === 'layout') this._enterLayoutMode();
    if (cfg.mode === 'showcase') this._enterShowcase(cfg.shot || 'menu');
    this.last = performance.now();
    this._raf = requestAnimationFrame((t) => this._loop(t));
    document.getElementById('loading')?.classList.add('done');
    this.audio.unlock();
    this.audio.loop('forest', 'amb_forest', 1, 'amb');
    this.audio.loop('wind', 'amb_wind', 0.5, 'amb');
    send('ready', { quality: qName, mode: cfg.mode });
  }

  _tick() { return new Promise((r) => setTimeout(r, 0)); }

  _loading(p, text) {
    const bar = document.getElementById('loading-bar');
    if (bar) bar.style.width = `${Math.round(p * 100)}%`;
    const t = document.getElementById('loading-text');
    if (t && text) t.textContent = text;
    send('loading', { progress: p });
  }

  _resize() {
    const w = window.innerWidth, h = window.innerHeight;
    this.renderer.setSize(w, h);
    this.camera.aspect = w / h;
    this.camera.updateProjectionMatrix();
    this.controls?.applyLayout();
  }

  sfx(name, pos = null, volume = 1, x = undefined) {
    // x < 4 is a playback rate, x >= 4 a reference distance for loud sounds
    const opts = { volume };
    if (pos) opts.pos = pos;
    if (x !== undefined) { if (x >= 4) opts.ref = x; else opts.rate = x * (0.95 + Math.random() * 0.1); }
    return this.audio.play(name, opts);
  }

  haptic(kind) { if (hasHost()) send('haptic', { kind }); }

  // ---------------------------------------------------------- loop ----------
  _loop(now) {
    this._raf = requestAnimationFrame((t) => this._loop(t));
    const minFrame = this.cfg.settings.fps === 30 ? 1000 / 30 - 3 : 0;
    if (now - this.last < minFrame) return;
    let dt = (now - this.last) / 1000;
    this.realDt = dt;
    this.last = now;
    if (dt > 0.05) dt = 0.05;
    if (this.paused) { this.renderer.render(this.scene, this.camera); return; }
    dt *= this.cfg.debug.timeScale || 1;
    this.update(dt);
    this.renderer.render(this.scene, this.camera);
    this._adapt();
  }

  // Lower the render resolution when the device cannot hold the target rate.
  _adapt() {
    const dt = this.realDt;
    this._perfT += dt;
    this._fpsWindow.push(dt);
    if (this._perfT < 4) return;
    const avg = this._fpsWindow.reduce((a, b) => a + b, 0) / this._fpsWindow.length;
    const fps = 1 / avg;
    this._fpsWindow.length = 0; this._perfT = 0;
    this.avgFps = fps;
    const target = this.cfg.settings.fps === 30 ? 30 : 60;
    if (fps < target * 0.8 && this.pixelRatio > 0.6) {
      this.pixelRatio = Math.max(0.6, this.pixelRatio - 0.15);
      this.renderer.setPixelRatio(this.pixelRatio);
      send('perf', { fps: Math.round(fps), pixelRatio: this.pixelRatio });
    }
  }

  update(dt) {
    this.frame++;
    this.time += dt;
    const P = this.player;
    const C = this.controls;
    const s = C.state;
    if (this.mode === 'play' && P.alive) this.stats.time += dt;

    if (this.mode === 'play') {
      // input -> actions
      const [lx, ly] = C.takeLook();
      this.camRig.addLook(lx, ly, P.aiming);
      if (C.consume('pause')) { this.pause(); return; }
      if (C.consume('reload')) P.reload();
      if (C.consume('jump')) P.jump();
      if (C.consume('crouch')) P.toggleCrouch();
      if (C.consume('grenade')) P.throwGrenade();
      if (C.consume('switch')) P.switchWeapon(1);
      if (C.consume('roll')) {
        this.camRig.flatForward(_v).multiplyScalar(s.moveY).add(this.camRig.flatRight(new THREE.Vector3()).multiplyScalar(s.moveX));
        P.roll(_v);
      }
      if (C.consume('interact')) this._interact();
      P.update(dt, { moveX: s.moveX, moveY: s.moveY, sprint: C.wantsSprint(), fire: s.fire, aim: s.aim });
      C.setActive('aim', P.aiming);
      C.setActive('sprint', P.sprinting);
      C.setActive('crouch', P.crouch);
    } else {
      const [lx, ly] = C.takeLook();
      if (this.mode !== 'showcase') this.camRig.addLook(lx * 0.3, 0, false);
      P.update(dt, { moveX: 0, moveY: 0, sprint: false, fire: false, aim: false });
    }

    this.world.update(P.pos);
    this.flow.update(dt, P.pos.x, P.pos.z);
    if (this.mode === 'play' && !this.cfg.debug.noDirector) this.director.update(dt);
    this.enemies.update(dt);
    this.projectiles.update(dt);
    this.props.update(dt);
    this.pickups.update(dt);
    const sniper = P.weapon.def.id === 'sniper';
    this.camRig.update(dt, P, P.aiming, P.weapon.def.zoomFov, sniper);
    P.mesh.visible = !this.camRig.scoped;

    // sun + shadow camera follow the player
    this.sun.position.set(P.pos.x + SKY.sunDir.x * 60, P.pos.y + SKY.sunDir.y * 60, P.pos.z + SKY.sunDir.z * 60);
    this.sun.target.position.copy(P.pos);
    this.skyGroup.position.copy(this.camera.position);
    windUniform.value = this.time;
    this.world.water.material.uniforms.uTime.value = this.time;

    this.fx.update(dt, this.camera, this.renderer.domElement.height);
    this.audio.setListener(this.camera);
    this._ambience(dt);
    if (this.mode === 'play') {
      const near = this.pickups.interactable || this.props.nearestCrate(P.pos);
      C.setInteractVisible(!!near && P.alive);
      this.hud.setPrompt(near ? (this.pickups.interactable ? 'OPEN GUN UPGRADE CASE' : 'KICK OPEN CRATE') : '');
      this.hud.update(dt);
    }
  }

  _interact() {
    const P = this.player;
    if (!P.alive) return;
    const it = this.pickups.interactable;
    if (it) {
      P.startAction('pickup', 0.45);
      this.pickups.collect(it);
      return;
    }
    const crate = this.props.nearestCrate(P.pos);
    if (crate) {
      P.startAction('interact', 0.5);
      P.facing = Math.atan2(crate.x - P.pos.x, crate.z - P.pos.z);
      setTimeout(() => { if (crate.alive) this.props.breakCrate(crate); }, 220);
    }
  }

  _ambience(dt) {
    this._ambT = (this._ambT || 0) - dt;
    if (this._ambT > 0) return;
    this._ambT = 0.5;
    const P = this.player.pos;
    // water proximity
    let nearWater = 0;
    for (let i = 0; i < 8; i++) {
      const a = (i / 8) * Math.PI * 2;
      for (const r of [4, 9, 15]) {
        if (this.world.height(P.x + Math.cos(a) * r, P.z + Math.sin(a) * r) < WATER_Y) { nearWater = Math.max(nearWater, 1 - r / 18); break; }
      }
    }
    if (nearWater > 0) this.audio.loop('water', 'amb_water', nearWater, 'amb'); else this.audio.stopLoop('water', 1);
    if (Math.random() < 0.08) {
      const a = Math.random() * Math.PI * 2;
      this.audio.play(`bird_${1 + Math.floor(Math.random() * 3)}`, { pos: _v.set(P.x + Math.cos(a) * 20, P.y + 8, P.z + Math.sin(a) * 20).clone(), bus: 'amb', volume: 0.8 });
    }
    if (Math.random() < 0.03) this.audio.play('leaves', { bus: 'amb', volume: 0.6 });
  }

  onPlayerDeath() {
    if (this.over) return;
    this.over = true;
    this.audio.stopLoop('heart');
    this.audio.stopLoop('minigun');
    this.camRig.shake(0.6);
    setTimeout(() => {
      this.audio.playMusic('music_gameover', 0.5);
      this.sfx('game_over');
      const st = this.stats;
      const result = {
        ...st,
        accuracy: st.shotsFired ? Math.round((st.shotsHit / st.shotsFired) * 100) : 0,
        time: Math.round(st.time),
        maxCombo: Math.round(st.maxCombo * 100) / 100,
      };
      send('gameOver', { stats: result });
      if (!hasHost()) this._showStandaloneGameOver(result);
    }, 2600);
  }

  _showStandaloneGameOver(r) {
    const d = document.createElement('div');
    d.className = 'standalone-over';
    d.innerHTML = `<h1>GAME OVER</h1><p>Score ${r.score} · Wave ${r.wave} · Kills ${r.kills} · ${r.time}s</p><button id="again">PLAY AGAIN</button>`;
    this.root.appendChild(d);
    d.querySelector('#again').onclick = () => { d.remove(); this.restart(); };
  }

  // -------------------------------------------------------- bridge API ------
  pause(fromUser = true) {
    if (this.paused || !this.running) return;
    this.paused = true;
    this.controls.reset();
    this.audio.suspend();
    send('paused', { user: fromUser });
    if (!hasHost()) document.body.classList.add('paused');
  }

  resume() {
    if (!this.paused) return;
    this.paused = false;
    this.last = performance.now();
    this.audio.resume();
    document.body.classList.remove('paused');
    send('resumed');
  }

  restart() {
    // new run in the same world renderer
    this.enemies.clear();
    this.pickups.clear();
    this.projectiles.clear();
    this.audio.stopLoop('heart');
    const old = this.player.pos.clone();
    this.scene.remove(this.player.mesh, this.player.shieldMesh);
    this.stats = newStats();
    this.director = new Director(this);
    this.player = new Player(this, this.cfg);
    const spot = this.world.field.findDrySpot(old.x + 30, old.z + 30);
    this.player.spawn(spot.x, spot.z);
    this.world.spawnSafe = { x: spot.x, z: spot.z, r: 14 };
    this.world.warmup(spot.x, spot.z);
    this.flow.build(spot.x, spot.z);
    this.over = false;
    this.hud.bossBar(null);
    this.hud.weaponChanged();
    this.controls.reset();
    this.paused = false;
    this.audio.resume();
    this.audio.playMusic(null);
    this.last = performance.now();
    send('restarted');
  }

  setSettings(json) {
    const s = typeof json === 'string' ? JSON.parse(json) : json;
    Object.assign(this.cfg.settings, s);
    this.audio.setVolumes(this.cfg.settings);
    this.controls.settings = this.cfg.settings;
    if (s.layout) this.controls.layout = { ...this.controls.layout, ...s.layout };
    this.controls.applyLayout();
    this.camRig.settings = this.cfg.settings;
    if (s.shoulder !== undefined) this.camRig.shoulder = s.shoulder;
  }

  quit() {
    this.running = false;
    cancelAnimationFrame(this._raf);
    this.audio.stopAll();
    this.audio.suspend();
  }

  editLayout(on = true) {
    this.controls.setEditing(on);
    this.hud.show(!on);
    document.body.classList.toggle('layout-edit', on);
  }

  resetLayout() { this.controls.resetLayout(); }

  _enterLayoutMode() {
    const bar = document.createElement('div');
    bar.className = 'layout-bar';
    bar.innerHTML = '<span>Drag the controls to place them</span><button data-a="reset">RESET</button><button data-a="done">DONE</button>';
    // buttons must react to touch while touch events are captured by controls
    const act = (a) => {
      if (a === 'reset') this.resetLayout();
      else { send('layoutDone', { layout: this.controls.layout }); if (!hasHost()) this.editLayout(false); }
    };
    for (const b of bar.querySelectorAll('button')) {
      b.addEventListener('touchstart', (e) => { e.stopPropagation(); e.preventDefault(); act(b.dataset.a); }, { passive: false });
      b.addEventListener('mousedown', (e) => { e.stopPropagation(); act(b.dataset.a); });
    }
    document.body.appendChild(bar);
    this.editLayout(true);
  }

  _enterShowcase(shot) {
    this.hud.show(false);
    this.controls.el.style.display = 'none';
    this.showcaseShot = shot;
    this.cfg.debug.noDirector = true;
  }

  // Renders promotional/menu art from the real models (used by
  // engine_src/dev/render_ui_assets.mjs to produce the Flutter UI images).
  showcase(kind, id) {
    const R = this.renderer;
    if (kind === 'menu') {
      // Hero shot in the live forest: soldier aiming at approaching aliens,
      // composed in a dry clearing so trees do not block the view.
      const F = this.world.field;
      let best = null;
      for (let i = 0; i < 400 && !best; i++) {
        const a = i * 2.39996, r = 10 + i * 0.8;
        const x = Math.cos(a) * r, z = Math.sin(a) * r;
        if (F.clearing(x, z) < 0.75 || F.pathMask(x, z) > 0.3 || F.height(x, z) < WATER_Y + 1) continue;
        const n = F.normal(x, z, new THREE.Vector3());
        if (n.y < 0.97) continue;
        best = { x, z };
      }
      best = best || F.findDrySpot(0, 0);
      const P = this.player;
      this.debug.teleport(best.x, best.z);
      this.world.update(P.pos, true);
      P.facing = 0.9;
      const f = new THREE.Vector3(Math.sin(P.facing), 0, Math.cos(P.facing));
      const side = new THREE.Vector3(f.z, 0, -f.x);
      this.quietSpawn = true;
      const lineup = [['grunt', 8, -1.5], ['runner', 10.5, 1.8], ['tank', 14, -4.2], ['crawler', 6.2, 2.6], ['spitter', 16, 3.8], ['grunt', 18, 0.5]];
      for (const [type, d, s] of lineup) {
        const p = P.pos.clone().addScaledVector(f, d).addScaledVector(side, s);
        p.y = this.world.groundHeight(p.x, p.z);
        const e = this.enemies.spawn(type, p, { hp: 1, dmg: 0, speed: 0 });
        e.state = 'chase'; e.stateT = 2; e.yaw = Math.atan2(-f.x, -f.z) + (Math.random() - 0.5) * 0.4;
        e.anim.play('move', 0); e.anim.ctx.gait = 1; e.anim.ctx.phase = Math.random() * 6; e.anim.update(0.016);
        e.mesh.position.copy(p); e.mesh.rotation.y = e.yaw;
      }
      this.quietSpawn = false;
      // clear spawn particles
      this.fx.update(5, this.camera, R.domElement.height);
      P.aiming = true;
      P.anim.playUpper('aim', 0); P.anim.uWeight = 1; P.anim.play('idle', 0);
      const cam = this.camera;
      cam.fov = 42; cam.updateProjectionMatrix();
      const camPos = P.pos.clone().addScaledVector(f, -2.4).addScaledVector(side, -4.6);
      camPos.y = Math.max(P.pos.y + 1.25, this.world.height(camPos.x, camPos.z) + 1.2);
      cam.position.copy(camPos);
      cam.lookAt(P.pos.clone().addScaledVector(f, 4.2).setY(P.pos.y + 1.45));
      cam.updateMatrixWorld();
      this.camRig.yaw = Math.atan2(-f.x, -f.z);
      this.camRig.pitch = 0;
      for (let i = 0; i < 3; i++) P._updateAnimation(0.016, 0, new THREE.Vector3());
      P.mesh.position.copy(P.pos); P.mesh.rotation.y = P.facing; P.mesh.visible = true;
      this.sun.position.set(P.pos.x + SKY.sunDir.x * 60, P.pos.y + SKY.sunDir.y * 60, P.pos.z + SKY.sunDir.z * 60);
      this.sun.target.position.copy(P.pos);
      this.skyGroup.position.copy(cam.position);
      this.paused = true;
      R.render(this.scene, cam);
      return R.domElement.toDataURL('image/jpeg', 0.88);
    }
    const scene = new THREE.Scene();
    lights(scene);
    let obj, cam, w = 256, h = 256;
    if (kind === 'alien') {
      const def = ENEMIES[id];
      const inst = instantiate(alienTemplate(def));
      const an = new Animator(inst, CLIPSETS[def.rig]);
      an.play('idle', 0); an.update(0.4);
      obj = inst.mesh;
      obj.rotation.y = 0.45;
      const H = def.rig === 'crawler' ? 1.2 : def.rig === 'brute' ? 2.3 : def.rig === 'flyer' ? 1.9 : 2.0;
      cam = new THREE.PerspectiveCamera(30, 1, 0.05, 20);
      const dist = H / Math.tan((15 * Math.PI) / 180) * 0.62;
      cam.position.set(0, H * 0.55, dist);
      cam.lookAt(0, H * 0.45, 0);
    } else if (kind === 'soldier') {
      const inst = instantiate(soldierTemplate());
      obj = inst.mesh;
      const P = this.player;
      // copy the live soldier pose (gun shouldered) onto the render copy
      const gun = weaponModel(id || 'rifle');
      const pivot = new THREE.Object3D();
      inst.b.chest.add(pivot);
      pivot.add(gun.group);
      P.anim.playUpper('ready', 0); P.anim.play('idle', 0); P.anim.uWeight = 1;
      P._updateAnimation(0.016, 0, new THREE.Vector3());
      inst.bones.forEach((b, i) => { b.quaternion.copy(P.inst.bones[i].quaternion); b.position.copy(P.inst.bones[i].position); });
      pivot.position.copy(P.pivot.position); pivot.quaternion.copy(P.pivot.quaternion);
      gun.group.position.copy(P.weapon.model.group.position);
      obj.rotation.y = 0.5;
      w = 384; h = 576;
      cam = new THREE.PerspectiveCamera(28, w / h, 0.05, 20);
      cam.position.set(0, 1.0, 4.3);
      cam.lookAt(0, 0.95, 0);
    } else if (kind === 'weapon') {
      const m = weaponModel(id);
      obj = m.group;
      obj.rotation.y = Math.PI / 2;
      const box = new THREE.Box3().setFromObject(obj);
      const c = box.getCenter(new THREE.Vector3()), size = box.getSize(new THREE.Vector3());
      w = 512; h = 256;
      const span = Math.max(size.x, size.y * 2.3);
      cam = new THREE.OrthographicCamera(-span * 0.55, span * 0.55, span * 0.275, -span * 0.275, 0.01, 10);
      cam.position.set(c.x, c.y, c.z + 2);
      const rim = new THREE.DirectionalLight(0xffffff, 1.6);
      rim.position.set(-1, 1, 2);
      scene.add(rim);
      cam.lookAt(c);
      obj.rotation.x = 0;
      obj.rotation.z = 0;
    }
    scene.add(obj);
    return capture(R, scene, cam, w, h);
  }

  // ------------------------------------------------------- test hooks ------
  get debug() {
    const g = this;
    return {
      state: () => ({
        pos: g.player.pos.toArray().map((v) => Math.round(v * 100) / 100), health: g.player.health, armor: g.player.armor,
        alive: g.player.alive, weapon: g.player.weapon.def.id, mag: g.player.weapon.mag, reserve: g.player.weapon.reserve,
        grenades: g.player.grenades, wave: g.director.wave, dirState: g.director.state, enemies: g.enemies.aliveCount,
        queue: g.director.queue.length, stats: { ...g.stats }, paused: g.paused, chunks: g.world.chunks.size, props: g.world.props.length,
        pickups: g.pickups.items.length, fps: g.avgFps, drawCalls: g.renderer.info.render.calls, triangles: g.renderer.info.render.triangles,
        yaw: g.camRig.yaw, pitch: g.camRig.pitch, crouch: g.player.crouch, anim: g.player.anim.cur, upper: g.player.anim.upper,
        onGround: g.player.onGround, aiming: g.player.aiming, shield: g.player.shieldT, speed: g.player.speedT,
      }),
      spawn: (type, dist = 10, angle = 0) => {
        const P = g.player.pos;
        const f = g.camRig.flatForward(new THREE.Vector3());
        const a = Math.atan2(f.x, f.z) + angle;
        const x = P.x + Math.sin(a) * dist, z = P.z + Math.cos(a) * dist;
        const e = g.enemies.spawn(type, new THREE.Vector3(x, g.world.groundHeight(x, z), z), g.director.level(Math.max(1, g.director.wave)));
        e.state = 'chase';
        return e.def.id;
      },
      enemies: () => g.enemies.active.filter((e) => e.alive).map((e) => ({ type: e.def.id, hp: Math.round(e.hp), state: e.state, dist: Math.round(e.dist * 10) / 10, pos: e.pos.toArray().map((v) => Math.round(v * 10) / 10) })),
      teleport: (x, z) => { g.player.spawn(x, z); g.world.update(g.player.pos, true); },
      setHealth: (h) => { g.player.health = h; if (h <= 0) g.player.die(); },
      give: (type) => g.pickups.drop(type, g.player.pos.clone()),
      dropAt: (type, dx, dz) => g.pickups.drop(type, g.player.pos.clone().add(new THREE.Vector3(dx, 0, dz))),
      killAll: () => { for (const e of [...g.enemies.active]) if (e.alive) e.damage(1e6, e.pos.clone(), new THREE.Vector3(0, 0, 1), 'body', { explosive: true }); },
      faceNearest: () => {
        const e = g.enemies.active.find((x) => x.alive);
        if (!e) return false;
        const c = e.center(new THREE.Vector3());
        const d = c.sub(g.camera.position);
        g.camRig.yaw = Math.atan2(-d.x, -d.z);
        g.camRig.pitch = Math.atan2(d.y, Math.hypot(d.x, d.z));
        return true;
      },
      props: (type) => g.world.props.filter((p) => p.alive && (!type || p.type === type)).map((p) => ({ type: p.type, x: p.x, z: p.z, id: p.id })),
      startWaveNow: () => { if (g.director.state === 'intermission') g.director.timer = 0; },
      setTimeScale: (s) => { g.cfg.debug.timeScale = s; },
      god: (on) => { g.cfg.debug.god = on; },
      director: (on) => { g.cfg.debug.noDirector = !on; },
      bridge: () => window.__bridgeLog.slice(),
      press: (id, down = true) => g.controls._press(id, down),
    };
  }
}

const game = new Game();
window.game = game;

// Standalone (desktop browser) start: ?quality=HIGH&mode=play
// Inside the Flutter app the page is opened with ?host=1 and the shell calls
// window.game.boot(config) once the JavaScript channel is ready.
const hostMode = new URLSearchParams(location.search).get('host') === '1';
if (!hostMode) {
  window.addEventListener('DOMContentLoaded', () => {
    const p = new URLSearchParams(location.search);
    const cfg = {};
    if (p.get('quality')) cfg.settings = { quality: p.get('quality') };
    if (p.get('mode')) cfg.mode = p.get('mode');
    if (p.get('seed')) cfg.seed = +p.get('seed');
    if (p.get('shot')) cfg.shot = p.get('shot');
    if (p.get('loadout')) cfg.loadout = p.get('loadout').split(',');
    if (p.get('fps')) cfg.settings = { ...(cfg.settings || {}), showFps: true };
    setTimeout(() => { if (!game.cfg) game.boot(cfg).catch((e) => { console.error(e); send('error', { message: String(e && e.stack || e) }); }); }, p.get('delay') ? +p.get('delay') : 0);
  });
}
