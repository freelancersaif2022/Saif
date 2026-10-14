// Collectible items: health packs, ammo boxes, armor, coins, gems, gun
// upgrades, shields, speed boosts, grenades and HP boosts. Each has a 3D
// model with a hover/spin animation, a pickup radius (or interaction for gun
// upgrades), a sound, a gameplay effect and HUD feedback.
import * as THREE from 'three';
import { GeoBuilder, G } from '../render/geo.js';
import { Textures } from '../render/textures.js';
import { grenadeModel } from '../actors/models.js';

const COLORS = {
  health: 0xff4040, ammo: 0xe8c547, armor: 0x9ab0c0, coin: 0xffc21a, gem: 0x3fb6ff, upgrade: 0xd1fe17,
  shield: 0xffd23a, speed: 0x3a8cff, grenade: 0x9acd32, hpboost: 0x30ff60,
};

let models = null;
function buildModels() {
  const std = (o) => new THREE.MeshStandardMaterial({ roughness: 0.5, metalness: 0.2, ...o });
  const vc = std({ vertexColors: true, map: Textures.metal() });
  const glow = new THREE.MeshBasicMaterial({ vertexColors: true, toneMapped: false });
  const m = {};
  const mk = (build, glowParts) => {
    const g = new THREE.Group();
    const b = new GeoBuilder(); build(b);
    if (b.parts.length) g.add(new THREE.Mesh(b.build(), vc));
    if (glowParts) { const gb = new GeoBuilder(); glowParts(gb); g.add(new THREE.Mesh(gb.build(), glow)); }
    return g;
  };
  m.health = (() => {
    const g = new THREE.Group();
    const box = new THREE.Mesh(new THREE.BoxGeometry(0.62, 0.42, 0.3), std({ map: Textures.medkit() }));
    g.add(box);
    const b = new GeoBuilder();
    b.add(G.torus(0.09, 0.025, 6, 12, Math.PI), { pos: [0, 0.21, 0], color: 0x222222 });
    b.add(G.box(0.64, 0.05, 0.32), { pos: [0, -0.2, 0], color: 0xa01010 });
    g.add(new THREE.Mesh(b.build(), vc));
    return g;
  })();
  m.ammo = (() => {
    const g = new THREE.Group();
    g.add(new THREE.Mesh(new THREE.BoxGeometry(0.66, 0.36, 0.36), std({ map: Textures.ammo() })));
    const b = new GeoBuilder();
    b.add(G.box(0.7, 0.06, 0.4), { pos: [0, 0.19, 0], color: 0x2f4420 });
    b.add(G.box(0.16, 0.05, 0.05), { pos: [0, 0.25, 0], color: 0x222222 });
    for (let i = 0; i < 4; i++) b.add(G.cyl(0.025, 0.025, 0.14, 8), { pos: [-0.15 + i * 0.1, 0.28, 0.1], color: 0xc8a040 });
    g.add(new THREE.Mesh(b.build(), vc));
    return g;
  })();
  m.armor = mk((b) => {
    b.add(G.capsule(0.22, 0.25, 4, 12), { scale: [1.15, 1, 0.55], color: 0x5c6670 });
    b.add(G.box(0.12, 0.12, 0.05), { pos: [-0.12, -0.05, 0.13], color: 0x3a4248 });
    b.add(G.box(0.12, 0.12, 0.05), { pos: [0.12, -0.05, 0.13], color: 0x3a4248 });
    b.add(G.box(0.4, 0.05, 0.05), { pos: [0, 0.12, 0.13], color: 0x2a3036 });
    b.add(G.torus(0.1, 0.03, 6, 12), { pos: [0, 0.3, 0], rot: [Math.PI / 2, 0, 0], color: 0x1a1a1a });
  });
  m.coin = mk((b) => {
    b.add(G.cyl(0.24, 0.24, 0.06, 24), { rot: [Math.PI / 2, 0, 0], color: 0xf2b21a });
    b.add(G.torus(0.21, 0.02, 6, 24), { pos: [0, 0, 0.03], color: 0xc88a10 });
    b.add(G.box(0.05, 0.22, 0.02), { pos: [0, 0, 0.035], color: 0xc88a10 });
    b.add(G.torus(0.065, 0.02, 6, 12, Math.PI * 1.2), { pos: [0, 0.04, 0.035], rot: [0, 0, 0.6], color: 0xc88a10 });
    b.add(G.torus(0.065, 0.02, 6, 12, Math.PI * 1.2), { pos: [0, -0.04, 0.035], rot: [0, 0, Math.PI + 0.6], color: 0xc88a10 });
  });
  m.coin.children[0].material = std({ vertexColors: true, metalness: 0.9, roughness: 0.25 });
  m.gem = mk(() => {}, (b) => {
    b.add(G.cone(0.22, 0.14, 8), { pos: [0, 0.07, 0], color: 0x7fd6ff });
    b.add(G.cone(0.22, 0.32, 8), { pos: [0, -0.16, 0], rot: [Math.PI, 0, 0], color: 0x1f7fe0 });
  });
  m.upgrade = mk((b) => {
    b.add(G.box(0.7, 0.4, 0.4), { color: 0x3c4146 });
    b.add(G.box(0.72, 0.05, 0.42), { pos: [0, 0.1, 0], color: 0x1e2226 });
    b.add(G.box(0.2, 0.06, 0.06), { pos: [0, 0.24, 0], color: 0x1a1a1a });
    for (const x of [-0.3, 0.3]) b.add(G.box(0.06, 0.42, 0.42), { pos: [x, 0, 0], color: 0x2a2e33 });
  }, (b) => { b.add(G.box(0.5, 0.05, 0.01), { pos: [0, -0.06, 0.205], color: 0xd1fe17 }); b.add(G.box(0.08, 0.08, 0.01), { pos: [0, 0.03, 0.205], color: 0xd1fe17 }); });
  m.shield = (() => {
    const s = new THREE.Shape();
    s.moveTo(0, 0.32); s.quadraticCurveTo(0.2, 0.26, 0.26, 0.28); s.lineTo(0.24, 0.0);
    s.quadraticCurveTo(0.2, -0.22, 0, -0.34); s.quadraticCurveTo(-0.2, -0.22, -0.24, 0.0);
    s.lineTo(-0.26, 0.28); s.quadraticCurveTo(-0.2, 0.26, 0, 0.32);
    const geo = new THREE.ExtrudeGeometry(s, { depth: 0.06, bevelEnabled: true, bevelSize: 0.02, bevelThickness: 0.02, bevelSegments: 2 });
    geo.translate(0, 0, -0.03);
    const g = new THREE.Group();
    g.add(new THREE.Mesh(geo, std({ color: 0xffc21a, metalness: 0.8, roughness: 0.3 })));
    const inner = new THREE.Mesh(new THREE.ShapeGeometry(s), new THREE.MeshBasicMaterial({ color: 0xfff09a, toneMapped: false }));
    inner.scale.setScalar(0.7); inner.position.z = 0.06;
    g.add(inner);
    return g;
  })();
  m.speed = mk((b) => {
    b.add(G.box(0.16, 0.3, 0.2), { pos: [0, 0.12, -0.04], color: 0x1f4fd8 });
    b.add(G.box(0.18, 0.12, 0.38), { pos: [0, -0.06, 0.04], color: 0x2a62ff });
    b.add(G.box(0.2, 0.04, 0.4), { pos: [0, -0.13, 0.04], color: 0xe8eef8 });
  }, (b) => { for (let i = 0; i < 3; i++) b.add(G.box(0.02, 0.02, 0.18), { pos: [0.11, 0.0 + i * 0.07, -0.25], color: 0x8fd0ff }); });
  m.grenade = (() => { const g = new THREE.Group(); const gm = grenadeModel(); gm.scale.setScalar(2.8); g.add(gm); return g; })();
  m.hpboost = mk(() => {}, (b) => {
    b.add(G.box(0.14, 0.44, 0.12), { color: 0x30ff60 });
    b.add(G.box(0.44, 0.14, 0.12), { color: 0x30ff60 });
    b.add(G.box(0.1, 0.36, 0.13), { color: 0xd8ffe0 });
    b.add(G.box(0.36, 0.1, 0.13), { color: 0xd8ffe0 });
  });
  const ringMat = new THREE.MeshBasicMaterial({ map: Textures.glow(), transparent: true, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false });
  m.ringGeo = new THREE.PlaneGeometry(1.4, 1.4).rotateX(-Math.PI / 2);
  m.ringMat = ringMat;
  return m;
}

const LABEL = {
  health: '+40 HEALTH', ammo: 'AMMO REFILL', armor: '+50 ARMOR', coin: '', gem: '+1 GEM', upgrade: 'GUN OVERCHARGE 20s',
  shield: 'SHIELD 10s', speed: 'SPEED BOOST 12s', grenade: '+2 GRENADES', hpboost: 'MAX HP +25',
};

export class Pickups {
  constructor(game) {
    this.game = game;
    if (!models) models = buildModels();
    this.items = [];
    this.pool = new Map();
  }

  _make(type) {
    let pool = this.pool.get(type);
    if (!pool) { pool = []; this.pool.set(type, pool); }
    let it = pool.find((p) => !p.active);
    if (!it) {
      const root = new THREE.Group();
      const model = models[type].clone();
      model.traverse((o) => { if (o.isMesh) o.castShadow = true; });
      root.add(model);
      const ring = new THREE.Mesh(models.ringGeo, models.ringMat.clone());
      ring.material.color.set(COLORS[type]);
      ring.material.opacity = 0.55;
      root.add(ring);
      it = { type, root, model, ring, active: false, pos: new THREE.Vector3() };
      pool.push(it);
    }
    return it;
  }

  drop(type, pos, opts = {}) {
    const g = this.game;
    const it = this._make(type);
    it.active = true;
    it.pos.copy(pos);
    it.ground = g.world.groundHeight(pos.x, pos.z);
    it.pos.y = it.ground;
    it.t = Math.random() * 6;
    it.life = opts.persist ? Infinity : type === 'coin' ? 25 : 35;
    it.value = opts.value || 1;
    it.persistId = opts.persistId || null;
    it.pop = 0.4; // spawn hop
    it.interact = type === 'upgrade';
    it.root.visible = true;
    it.root.position.copy(it.pos);
    if (!it.root.parent) g.scene.add(it.root);
    this.items.push(it);
    return it;
  }

  // world-placed pickups from chunk generation
  spawnWorld(type, pos, persistId) {
    this.drop(type, pos, { persist: true, persistId, value: type === 'coin' ? 5 : 1 });
  }

  onChunkUnloaded(ch) {
    for (const it of this.items) if (it.persistId && it.persistId.startsWith(ch.key + ':')) this._remove(it);
    this.items = this.items.filter((i) => i.active);
  }

  _remove(it) {
    it.active = false;
    it.root.visible = false;
  }

  nearestInteractable(pos) {
    let best = null, bd = 2.2;
    for (const it of this.items) {
      if (!it.active || !it.interact) continue;
      const d = Math.hypot(it.pos.x - pos.x, it.pos.z - pos.z);
      if (d < bd) { bd = d; best = it; }
    }
    return best;
  }

  collect(it) {
    const g = this.game, P = g.player, st = g.stats;
    let ok = true;
    switch (it.type) {
      case 'health':
        if (P.health >= P.maxHealth) ok = false;
        else { P.heal(40); P.startAction('heal', 0.8); g.sfx('pickup_health'); g.sfx('heal'); }
        break;
      case 'ammo': {
        let added = false;
        for (const w of P.weapons) {
          if (w.reserve === Infinity) continue;
          if (w.reserve < w.def.maxReserve) { w.reserve = Math.min(w.def.maxReserve, w.reserve + Math.max(w.def.mag * 2, Math.round(w.def.maxReserve * 0.4))); added = true; }
        }
        if (!added) ok = false; else g.sfx('pickup_ammo');
        break;
      }
      case 'armor':
        if (P.armor >= P.maxArmor) ok = false;
        else { P.armor = Math.min(P.maxArmor, P.armor + 50); g.sfx('pickup_armor'); }
        break;
      case 'coin': st.coins += it.value; g.sfx('pickup_coin'); break;
      case 'gem': st.gems += 1; g.sfx('pickup_gem'); break;
      case 'upgrade': P.overT = 20; P.startAction('pickup', 0.45); g.sfx('pickup_power'); for (const w of P.weapons) if (w.reserve !== Infinity) w.reserve = Math.min(w.def.maxReserve, w.reserve + w.def.mag); break;
      case 'shield': P.shieldT = 10; g.sfx('shield_on'); break;
      case 'speed': P.speedT = 12; g.sfx('speed_on'); break;
      case 'grenade':
        if (P.grenades >= P.maxGrenades) ok = false;
        else { P.grenades = Math.min(P.maxGrenades, P.grenades + 2); g.sfx('pickup_ammo'); }
        break;
      case 'hpboost': P.maxHealth += 25; P.health = P.maxHealth; g.sfx('pickup_power'); g.sfx('heal'); break;
      default: break;
    }
    if (!ok) return false;
    st.pickups++;
    g.fx.sparkle(it.pos, COLORS[it.type]);
    if (LABEL[it.type]) g.hud.toast(LABEL[it.type], COLORS[it.type]);
    if (it.persistId) g.world.collected.add(it.persistId);
    this._remove(it);
    return true;
  }

  update(dt) {
    const g = this.game, P = g.player;
    const alive = P.alive;
    let interactable = null;
    for (let i = this.items.length - 1; i >= 0; i--) {
      const it = this.items[i];
      if (!it.active) { this.items.splice(i, 1); continue; }
      it.t += dt;
      it.life -= dt;
      if (it.life <= 0) { this._remove(it); this.items.splice(i, 1); continue; }
      const dx = P.pos.x - it.pos.x, dz = P.pos.z - it.pos.z;
      const d = Math.hypot(dx, dz);
      // coins and gems are magnetised to the player
      if (alive && (it.type === 'coin' || it.type === 'gem') && d < 4.5 && d > 0.01) {
        const pull = Math.min(d, (12 / Math.max(d, 0.5)) * dt);
        it.pos.x += (dx / d) * pull; it.pos.z += (dz / d) * pull;
        it.ground = g.world.groundHeight(it.pos.x, it.pos.z);
      }
      if (it.pop > 0) it.pop -= dt;
      const hop = it.pop > 0 ? Math.sin((1 - it.pop / 0.4) * Math.PI) * 0.6 : 0;
      it.root.position.set(it.pos.x, it.ground + 0.45 + Math.sin(it.t * 2.5) * 0.08 + hop, it.pos.z);
      it.model.rotation.y = it.t * 1.6;
      it.ring.position.y = -0.43 - Math.sin(it.t * 2.5) * 0.08 - hop;
      it.ring.material.opacity = 0.35 + Math.sin(it.t * 4) * 0.15;
      it.root.visible = it.life > 5 || Math.sin(it.t * 18) > -0.2;
      if (!alive) continue;
      if (it.interact) {
        if (d < 2.2) interactable = it;
        continue;
      }
      if (d < (it.type === 'coin' ? 0.9 : 1.2) && Math.abs(P.pos.y - it.ground) < 2) {
        if (this.collect(it)) this.items.splice(i, 1);
      }
    }
    this.interactable = interactable;
  }

  clear() {
    for (const it of this.items) this._remove(it);
    this.items.length = 0;
  }
}

export { COLORS };
