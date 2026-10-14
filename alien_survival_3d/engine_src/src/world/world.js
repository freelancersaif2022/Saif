// Streams the endless forest in chunks around the player: terrain, vegetation,
// props, traps, colliders and occasional world pickups. Chunks are built
// incrementally (one per frame) and disposed when far away.
import * as THREE from 'three';
import { TerrainField, CHUNK, WATER_Y, buildTerrainGeometry, terrainMaterial, createWater } from './terrain.js';
import { populateFoliage } from './foliage.js';
import { makeProp } from './props.js';
import { CollisionWorld } from './colliders.js';
import { hash2, rng, smoothstep } from '../core/math.js';

export class World {
  constructor(scene, quality, seed) {
    this.scene = scene;
    this.quality = quality;
    this.seed = seed;
    this.field = new TerrainField(seed);
    this.colliders = new CollisionWorld();
    this.chunks = new Map();
    this.props = []; // active interactive props (crates, barrels, traps)
    this.caves = [];
    this.destroyed = new Set();
    this.collected = new Set();
    this.water = createWater();
    scene.add(this.water);
    this.onPropSpawned = null; // (prop) => void
    this.onPickupSpawned = null; // (type, pos, persistId) => void
    this.onChunkUnloaded = null; // (chunk) => void
    this.center = { cx: 1e9, cz: 1e9 };
    this.spawnSafe = { x: 0, z: 0, r: 14 };
    this._queue = [];
  }

  height(x, z) { return this.field.height(x, z); }

  // Ground height for a character: terrain or a bridge deck under it.
  groundHeight(x, z, y = Infinity) {
    const t = this.field.height(x, z);
    const d = this.colliders.deckHeight(x, z, y);
    return d > t ? d : t;
  }

  isWater(x, z) { return this.groundHeight(x, z) < WATER_Y - 0.1; }

  // Ray vs terrain by marching then bisecting. Returns distance or -1.
  raycastTerrain(o, d, maxDist) {
    let step = 1.0, t = 0.2;
    let prevT = 0;
    let prevAbove = o.y - this.field.height(o.x, o.z) > 0;
    if (!prevAbove) return 0;
    while (t <= maxDist) {
      const x = o.x + d.x * t, y = o.y + d.y * t, z = o.z + d.z * t;
      const above = y - this.field.height(x, z) > 0;
      if (!above) {
        let lo = prevT, hi = t;
        for (let i = 0; i < 6; i++) {
          const m = (lo + hi) * 0.5;
          if (o.y + d.y * m - this.field.height(o.x + d.x * m, o.z + d.z * m) > 0) lo = m; else hi = m;
        }
        return hi;
      }
      prevT = t;
      t += step;
      if (t > 20) step = 2.0;
    }
    return -1;
  }

  // Forces every chunk around (x,z) to exist (used at start).
  warmup(x, z) {
    this.update(new THREE.Vector3(x, 0, z), true);
  }

  update(playerPos, sync = false) {
    const cx = Math.floor(playerPos.x / CHUNK), cz = Math.floor(playerPos.z / CHUNK);
    this.water.position.x = Math.round(playerPos.x / 50) * 50;
    this.water.position.z = Math.round(playerPos.z / 50) * 50;
    const R = this.quality.viewChunks;
    if (cx !== this.center.cx || cz !== this.center.cz) {
      this.center = { cx, cz };
      // Queue missing chunks nearest first.
      const want = [];
      for (let dz = -R; dz <= R; dz++) for (let dx = -R; dx <= R; dx++) {
        const k = `${cx + dx},${cz + dz}`;
        if (!this.chunks.has(k)) want.push({ cx: cx + dx, cz: cz + dz, d: dx * dx + dz * dz });
      }
      want.sort((a, b) => a.d - b.d);
      this._queue = want;
      // Unload far chunks (with one chunk of hysteresis).
      for (const [k, ch] of this.chunks) {
        if (Math.abs(ch.cx - cx) > R + 1 || Math.abs(ch.cz - cz) > R + 1) this._unload(k, ch);
      }
      for (const ch of this.chunks.values()) this._applyLod(ch);
    }
    let budget = sync ? Infinity : 1;
    while (budget-- > 0 && this._queue.length) {
      const c = this._queue.shift();
      const k = `${c.cx},${c.cz}`;
      if (!this.chunks.has(k)) {
        const ch = this._build(c.cx, c.cz);
        this.chunks.set(k, ch);
        this._applyLod(ch);
      }
    }
  }

  _applyLod(ch) {
    const d = Math.max(Math.abs(ch.cx - this.center.cx), Math.abs(ch.cz - this.center.cz));
    const near = d <= 1;
    if (ch.foliage.hi) { ch.foliage.hi.visible = near; ch.foliage.lo.visible = !near; }
    for (const m of ch.foliage.detail) m.visible = near;
  }

  _build(cx, cz) {
    const seed = hash2(cx, cz, this.seed);
    const ch = { cx, cz, seed, key: `${cx},${cz}`, colliders: [], decks: [], props: [], group: new THREE.Group() };
    const ox = cx * CHUNK, oz = cz * CHUNK;
    const terrain = new THREE.Mesh(buildTerrainGeometry(this.field, cx, cz, this.quality.terrainRes), terrainMaterial(this.quality.standardMaterials));
    terrain.position.set(ox, 0, oz);
    terrain.receiveShadow = true;
    ch.group.add(terrain);

    const addCollider = (c) => { c.chunk = ch.key; ch.colliders.push(this.colliders.add(c)); return c; };
    const r = rng(seed);
    const reserved = [];
    if (Math.hypot(this.spawnSafe.x - (ox + 24), this.spawnSafe.z - (oz + 24)) < 60) {
      reserved.push({ x: this.spawnSafe.x, z: this.spawnSafe.z, r: 4 });
    }
    const F = this.field;
    const std = this.quality.standardMaterials;
    const place = (type, x, z, rot, extra = {}) => {
      const y = F.height(x, z);
      const obj = makeProp(type, std);
      obj.position.set(x, y, z);
      obj.rotation.y = rot;
      ch.group.add(obj);
      return { obj, y };
    };
    const freeSpot = (pathWanted, clear) => {
      for (let tries = 0; tries < 12; tries++) {
        const x = ox + 4 + r() * 40, z = oz + 4 + r() * 40;
        const p = F.pathMask(x, z);
        if (pathWanted === true && p < 0.3) continue;
        if (pathWanted === false && p > 0.05) continue;
        if (F.streamMask(x, z) > 0.02 || F.height(x, z) < WATER_Y + 0.3) continue;
        let blocked = false;
        for (const rv of reserved) if (Math.hypot(x - rv.x, z - rv.z) < rv.r + clear) blocked = true;
        if (Math.hypot(x - this.spawnSafe.x, z - this.spawnSafe.z) < this.spawnSafe.r) blocked = true;
        if (blocked) continue;
        reserved.push({ x, z, r: clear });
        return { x, z };
      }
      return null;
    };

    // Bridge where a path crosses a stream.
    for (let i = 0; i < 64 && ch.decks.length === 0; i++) {
      const x = ox + (i % 8) * 6 + 3, z = oz + Math.floor(i / 8) * 6 + 3;
      if (F.pathMask(x, z) > 0.6 && F.streamMask(x, z) > 0.8) {
        // Path direction: perpendicular to the path-noise gradient.
        const e = 1.5;
        const gx = F.pathMask(x + e, z) - F.pathMask(x - e, z);
        const gz = F.pathMask(x, z + e) - F.pathMask(x, z - e);
        let dirX = -gz, dirZ = gx;
        const len = Math.hypot(dirX, dirZ);
        if (len < 1e-4) { dirX = 1; dirZ = 0; } else { dirX /= len; dirZ /= len; }
        // Prefer the orientation that crosses the stream (stream mask lower at the ends).
        const endA = F.streamMask(x + dirX * 6, z + dirZ * 6), endB = F.streamMask(x - dirZ * 6, z + dirX * 6);
        if (endB < endA) { const t = dirX; dirX = -dirZ; dirZ = t; }
        const hA = F.height(x + dirX * 6.6, z + dirZ * 6.6), hB = F.height(x - dirX * 6.6, z - dirZ * 6.6);
        const deckY = Math.max(hA, hB, WATER_Y + 0.5) + 0.12;
        const obj = makeProp('bridge', std);
        obj.position.set(x, deckY - 0.06, z);
        obj.rotation.y = Math.atan2(-dirZ, dirX);
        ch.group.add(obj);
        const deck = { x, z, dirX, dirZ, halfLen: 6.6, halfWidth: 1.5, y: deckY };
        ch.decks.push(this.colliders.addDeck(deck));
        reserved.push({ x, z, r: 8 });
        for (const s of [-1, 1]) for (let k = -3; k <= 3; k++) {
          addCollider({ x: x + dirX * k * 2 - dirZ * s * 1.6, z: z + dirZ * k * 2 + dirX * s * 1.6, r: 0.15, y0: deckY - 3, y1: deckY + 1.1, kind: 'rail' });
        }
      }
    }

    // Landmarks
    if (r() < 0.12) {
      const s = freeSpot(false, 5);
      if (s) {
        const { y } = place('tower', s.x, s.z, r() * 6.28);
        for (const [lx, lz] of [[-1.3, -1.3], [1.3, -1.3], [-1.3, 1.3], [1.3, 1.3]]) {
          // leg positions rotate with the prop; a symmetric footprint is close enough
          addCollider({ x: s.x + lx, z: s.z + lz, r: 0.25, y0: y - 1, y1: y + 9, kind: 'wood' });
        }
      }
    }
    if (r() < 0.07) {
      const s = freeSpot(false, 8);
      if (s) {
        const rot = r() * 6.28;
        const { y } = place('cave', s.x, s.z, rot);
        const c = Math.cos(rot), sn = Math.sin(rot);
        const loc = (lx, lz) => ({ x: s.x + lx * c + lz * sn, z: s.z - lx * sn + lz * c });
        for (const [lx, lz, rr] of [[-3.6, -1.6, 2.0], [3.6, -1.6, 2.0], [-2.4, -3.4, 2.0], [2.4, -3.4, 2.0], [0, -4.4, 2.6]]) {
          const p = loc(lx, lz);
          addCollider({ x: p.x, z: p.z, r: rr, y0: y - 1, y1: y + 5, kind: 'rock' });
        }
        const mouth = loc(0, 0.5);
        this.caves.push({ x: mouth.x, z: mouth.z, chunk: ch.key });
      }
    }

    // Logs and boulders
    const nLogs = r() < 0.5 ? 1 : 0;
    for (let i = 0; i < nLogs; i++) {
      const s = freeSpot(false, 4);
      if (!s) continue;
      const rot = r() * 6.28;
      const { obj, y } = place('log', s.x, s.z, rot);
      obj.position.y = y + 0.35;
      for (let k = -3; k <= 3; k += 1.5) {
        addCollider({ x: s.x + Math.cos(rot) * k, z: s.z - Math.sin(rot) * k, r: 0.5, y0: y - 1, y1: y + 0.85, kind: 'wood' });
      }
    }
    if (r() < 0.35) {
      const s = freeSpot(false, 3);
      if (s) {
        const { obj, y } = place('boulder', s.x, s.z, r() * 6.28);
        const sc = 1.3 + r() * 0.8;
        obj.scale.setScalar(sc);
        addCollider({ x: s.x, z: s.z, r: 1.15 * sc, y0: y - 1, y1: y + 0.8 * sc, kind: 'rock' });
      }
    }

    // Interactive props and traps
    const spawnProp = (type, spot, rot, collider, extra = {}) => {
      const id = `${ch.key}:${ch.props.length}:${type}`;
      if (this.destroyed.has(id)) { ch.props.push(null); return null; }
      const { obj, y } = place(type, spot.x, spot.z, rot);
      const prop = { id, type, x: spot.x, y, z: spot.z, obj, alive: true, chunk: ch.key, ...extra };
      if (collider) prop.collider = addCollider({ x: spot.x, z: spot.z, ...collider(y), kind: type, prop });
      ch.props.push(prop);
      this.props.push(prop);
      if (this.onPropSpawned) this.onPropSpawned(prop);
      return prop;
    };
    const nCrates = r() < 0.55 ? 1 + Math.floor(r() * 3) : 0;
    const crateSpot = nCrates ? freeSpot(false, 3) : null;
    if (crateSpot) {
      for (let i = 0; i < nCrates; i++) {
        const spot = { x: crateSpot.x + (i % 2) * 1.3 - 0.6, z: crateSpot.z + Math.floor(i / 2) * 1.3 - 0.6 };
        spawnProp('crate', spot, r() * 0.4, (y) => ({ r: 0.72, y0: y - 1, y1: y + 1.2 }), { hp: 45 });
      }
    }
    if (r() < 0.4) {
      const s = freeSpot(null, 2);
      if (s) spawnProp('barrel', s, r() * 6.28, (y) => ({ r: 0.45, y0: y - 1, y1: y + 1.25 }), { hp: 25 });
    }
    if (r() < 0.32) {
      const s = freeSpot(true, 4) || freeSpot(false, 4);
      if (s) {
        const rot = r() * 6.28;
        const p = spawnProp('barricade', s, rot, null, { hp: Infinity });
        if (p) {
          for (let k = -1.6; k <= 1.6; k += 0.8) {
            addCollider({ x: s.x + Math.cos(rot) * k, z: s.z - Math.sin(rot) * k, r: 0.32, y0: p.y - 1, y1: p.y + 1.15, kind: 'barricade' });
          }
        }
      }
    }
    if (r() < 0.28) {
      const s = freeSpot(null, 2.5);
      if (s) spawnProp('spikes', s, r() * 6.28, null, { radius: 1.15, tick: 0 });
    }
    if (r() < 0.3) {
      const s = freeSpot(true, 2) || freeSpot(false, 2);
      if (s) spawnProp('mine', s, r() * 6.28, null, { radius: 1.0, armed: true, fuse: -1 });
    }
    // World pickups (persisted so they cannot be farmed by re-streaming).
    if (r() < 0.22 && this.onPickupSpawned) {
      const s = freeSpot(null, 1.5);
      const id = `${ch.key}:pickup`;
      if (s && !this.collected.has(id)) {
        const type = r.pick(['ammo', 'health', 'ammo', 'armor', 'grenade', 'coin']);
        this.onPickupSpawned(type, new THREE.Vector3(s.x, F.height(s.x, s.z), s.z), id);
      }
    }

    ch.foliage = populateFoliage(ch, F, this.quality, addCollider, reserved);
    ch.group.add(ch.foliage.group);
    this.scene.add(ch.group);
    return ch;
  }

  _unload(k, ch) {
    this.scene.remove(ch.group);
    ch.group.traverse((o) => {
      // Shared geometries/materials are reused; only terrain geometry and instance buffers are per chunk.
      if (o.isInstancedMesh) o.dispose();
      else if (o.isMesh && o.geometry && o.geometry.attributes.color && o.geometry.attributes.uv && o.parent === ch.group) o.geometry.dispose();
    });
    for (const c of ch.colliders) this.colliders.remove(c);
    for (const d of ch.decks) this.colliders.removeDeck(d);
    for (const p of ch.props) if (p) { p.alive = false; p.unloaded = true; }
    this.props = this.props.filter((p) => !p.unloaded);
    this.caves = this.caves.filter((c) => c.chunk !== k);
    if (this.onChunkUnloaded) this.onChunkUnloaded(ch);
    this.chunks.delete(k);
  }

  destroyProp(prop) {
    if (!prop.alive) return;
    prop.alive = false;
    this.destroyed.add(prop.id);
    if (prop.collider) this.colliders.remove(prop.collider);
    prop.obj.parent && prop.obj.parent.remove(prop.obj);
  }

  // Bounds-free "is this a sensible place to stand" check for spawning.
  validSpawn(x, z, radius = 0.8) {
    if (this.field.height(x, z) < WATER_Y + 0.2) return false;
    if (this.colliders.blocked(x, z, radius)) return false;
    const R = this.quality.viewChunks;
    const cx = Math.floor(x / CHUNK), cz = Math.floor(z / CHUNK);
    if (Math.abs(cx - this.center.cx) > R || Math.abs(cz - this.center.cz) > R) return false;
    return this.chunks.has(`${cx},${cz}`);
  }
}

export { CHUNK, WATER_Y, smoothstep };
