// Forest vegetation: shared low/high detail geometries rendered with one
// InstancedMesh per type per chunk. Grass and bushes sway in the wind via a
// small vertex-shader patch.
import * as THREE from 'three';
import { GeoBuilder, G } from '../render/geo.js';
import { rng } from '../core/math.js';
import { Textures } from '../render/textures.js';
import { WATER_Y } from './terrain.js';

export const windUniform = { value: 0 };

function addWind(mat, strength) {
  mat.onBeforeCompile = (shader) => {
    shader.uniforms.uWind = windUniform;
    shader.vertexShader = 'uniform float uWind;\n' + shader.vertexShader.replace(
      '#include <begin_vertex>',
      `#include <begin_vertex>
       #ifdef USE_INSTANCING
         vec3 ip = vec3(instanceMatrix[3][0], instanceMatrix[3][1], instanceMatrix[3][2]);
       #else
         vec3 ip = vec3(0.0);
       #endif
       float sway = sin(uWind * 1.7 + ip.x * 0.37 + ip.z * 0.23) + 0.5 * sin(uWind * 3.1 + ip.z * 0.5);
       transformed.x += sway * ${strength.toFixed(3)} * max(position.y, 0.0);
       transformed.z += sway * ${(strength * 0.6).toFixed(3)} * max(position.y, 0.0);`,
    );
  };
  mat.customProgramCacheKey = () => 'wind' + strength;
  return mat;
}

function pine(lod, seed) {
  const r = rng(seed);
  const b = new GeoBuilder();
  const h = 10.5;
  b.add(G.cyl(0.12, 0.32, h * 0.75, lod ? 7 : 5), { pos: [0, h * 0.375, 0], color: 0x5a3d26, gradient: [0.7, 1.0] });
  const tiers = lod ? 6 : 3;
  for (let i = 0; i < tiers; i++) {
    const t = i / (tiers - 1);
    const rad = 2.9 - t * 2.1;
    const ch = 3.4 - t * 1.2;
    const y = 2.6 + t * (h - 3.6);
    b.add(G.cone(rad, ch, lod ? 9 : 6, lod ? 2 : 1), {
      pos: [0, y + ch * 0.5, 0], rot: [0, r() * 3, 0], color: i % 2 ? 0x1f4a25 : 0x24552b,
      gradient: [0.55, 1.15], jitter: lod ? 0.35 : 0.2, rng: r,
    });
  }
  return b.build();
}

function broadleaf(seed) {
  const r = rng(seed);
  const b = new GeoBuilder();
  b.add(G.cyl(0.1, 0.2, 3.6, 6), { pos: [0, 1.8, 0], color: 0x5c4630 });
  for (let i = 0; i < 5; i++) {
    const a = r() * Math.PI * 2, d = r() * 0.9;
    b.add(G.ico(1.0 + r() * 0.5, 1), {
      pos: [Math.cos(a) * d, 3.6 + r() * 1.3, Math.sin(a) * d], color: r() > 0.5 ? 0x4c7a2a : 0x3f6a26,
      gradient: [0.6, 1.2], jitter: 0.3, rng: r,
    });
  }
  return b.build();
}

function deadTree(seed) {
  const r = rng(seed);
  const b = new GeoBuilder();
  b.add(G.cyl(0.1, 0.3, 7, 6), { pos: [0, 3.5, 0], color: 0x6b5a4a, jitter: 0.06, rng: r });
  for (let i = 0; i < 6; i++) {
    const y = 2.5 + r() * 4, a = r() * Math.PI * 2, len = 1 + r() * 1.6;
    b.add(G.cyl(0.03, 0.08, len, 4), {
      pos: [Math.cos(a) * len * 0.4, y + len * 0.3, Math.sin(a) * len * 0.4],
      rot: [Math.sin(a) * 0.9, 0, -Math.cos(a) * 0.9], color: 0x6b5a4a,
    });
  }
  return b.build();
}

function bush(seed) {
  const r = rng(seed);
  const b = new GeoBuilder();
  for (let i = 0; i < 4; i++) {
    const a = (i / 4) * Math.PI * 2 + r();
    b.add(G.ico(0.42 + r() * 0.22, 1), {
      pos: [Math.cos(a) * 0.38, 0.3 + r() * 0.2, Math.sin(a) * 0.38], scale: [1, 0.8, 1],
      color: r() > 0.5 ? 0x4f8030 : 0x416f27, gradient: [0.55, 1.25], jitter: 0.16, rng: r,
    });
  }
  return b.build();
}

function fern(seed) {
  const r = rng(seed);
  const b = new GeoBuilder();
  for (let i = 0; i < 7; i++) {
    const a = (i / 7) * Math.PI * 2 + r() * 0.3;
    b.add(G.box(0.18, 0.02, 1.1), {
      pos: [Math.cos(a) * 0.45, 0.32, Math.sin(a) * 0.45], rot: [0.5 * Math.sin(a), -a + Math.PI / 2, 0.5 * -Math.cos(a)],
      color: 0x4f8a2c,
    });
  }
  return b.build();
}

function grassTuft(seed, flowerColor) {
  const r = rng(seed);
  const b = new GeoBuilder();
  const blades = 7;
  for (let i = 0; i < blades; i++) {
    const a = r() * Math.PI * 2, h = 0.35 + r() * 0.4;
    const tri = new THREE.BufferGeometry();
    tri.setAttribute('position', new THREE.Float32BufferAttribute([-0.04, 0, 0, 0.04, 0, 0, 0, h, 0], 3));
    tri.setAttribute('normal', new THREE.Float32BufferAttribute([0, 0.6, 0.8, 0, 0.6, 0.8, 0, 1, 0], 3));
    b.add(tri, {
      pos: [Math.cos(a) * 0.15, 0, Math.sin(a) * 0.15], rot: [(r() - 0.5) * 0.6, a, (r() - 0.5) * 0.6],
      color: r() > 0.5 ? 0x6f9a35 : 0x86a83c, gradient: [0.45, 1.15],
    });
  }
  if (flowerColor) {
    for (let i = 0; i < 3; i++) {
      b.add(G.ico(0.05, 0), { pos: [(r() - 0.5) * 0.3, 0.45 + r() * 0.2, (r() - 0.5) * 0.3], color: flowerColor });
    }
  }
  return b.build();
}

export function rockGeometry(seed, detail = 1) {
  const r = rng(seed);
  const b = new GeoBuilder();
  b.add(G.dodeca(1, detail), { scale: [1.2, 0.8, 1], color: 0x7d7a72, jitter: 0.35, rng: r, flat: true });
  const g = b.build();
  // Moss on upward faces.
  const n = g.attributes.normal, c = g.attributes.color;
  for (let i = 0; i < n.count; i++) {
    const up = n.getY(i);
    if (up > 0.6) c.setXYZ(i, c.getX(i) * 0.7, c.getY(i) * 0.95, c.getZ(i) * 0.55);
  }
  return g;
}

export function logGeometry() {
  const b = new GeoBuilder();
  b.add(G.cyl(0.42, 0.5, 7, 10, 3), { rot: [0, 0, Math.PI / 2], color: 0x6a4a2e, jitter: 0.05, rng: rng(5) });
  b.add(G.cyl(0.36, 0.36, 0.05, 10), { pos: [3.51, 0, 0], rot: [0, 0, Math.PI / 2], color: 0xb08a5a });
  b.add(G.cyl(0.44, 0.44, 0.05, 10), { pos: [-3.51, 0, 0], rot: [0, 0, Math.PI / 2], color: 0xb08a5a });
  b.add(G.box(1.8, 0.12, 0.6), { pos: [0.5, 0.45, 0], color: 0x3f5f22, jitter: 0.08, rng: rng(6) });
  b.add(G.cyl(0.05, 0.08, 1.2, 4), { pos: [-1.2, 0.6, 0.2], rot: [0.6, 0, 0.3], color: 0x6a4a2e });
  return b.build();
}

let shared = null;
function sharedAssets(quality) {
  if (shared) return shared;
  const std = quality.standardMaterials;
  const mk = (opts) => (std ? new THREE.MeshStandardMaterial({ roughness: 0.9, metalness: 0, ...opts }) : new THREE.MeshLambertMaterial(opts));
  const leafMat = mk({ vertexColors: true, map: Textures.fabric() });
  const barkMat = mk({ vertexColors: true, map: Textures.bark() });
  const rockMat = mk({ vertexColors: true, map: Textures.rock() });
  const grassMat = addWind(mk({ vertexColors: true, side: THREE.DoubleSide }), 0.12);
  const bushMat = addWind(mk({ vertexColors: true, map: Textures.fabric() }), 0.03);
  shared = {
    pineHi: pine(true, 1), pineLo: pine(false, 1), broadleaf: broadleaf(2), dead: deadTree(3),
    bush: bush(4), fern: fern(5), grass: grassTuft(6), flowers: [grassTuft(7, 0xf2f2e6), grassTuft(8, 0xf2d43a), grassTuft(9, 0xb07ad8)],
    rock: rockGeometry(10), log: logGeometry(),
    leafMat, barkMat, rockMat, grassMat, bushMat,
  };
  return shared;
}

const _m = new THREE.Matrix4();
const _q = new THREE.Quaternion();
const _s = new THREE.Vector3();
const _p = new THREE.Vector3();
const _up = new THREE.Vector3(0, 1, 0);

function instanced(geo, mat, items, castShadow) {
  if (items.length === 0) return null;
  const mesh = new THREE.InstancedMesh(geo, mat, items.length);
  for (let i = 0; i < items.length; i++) {
    const it = items[i];
    _q.setFromAxisAngle(_up, it.rot);
    if (it.tilt) _q.multiply(new THREE.Quaternion().setFromEuler(new THREE.Euler(it.tilt[0], 0, it.tilt[1])));
    _p.set(it.x, it.y, it.z);
    _s.set(it.sx ?? it.s, it.sy ?? it.s, it.sz ?? it.s);
    mesh.setMatrixAt(i, _m.compose(_p, _q, _s));
  }
  mesh.instanceMatrix.needsUpdate = true;
  mesh.computeBoundingSphere();
  mesh.castShadow = castShadow;
  mesh.receiveShadow = true;
  return mesh;
}

// Places vegetation for a chunk. Returns { group, detail[], hi, lo } and
// registers trunk/rock colliders through addCollider.
export function populateFoliage(chunk, field, quality, addCollider, reserved) {
  const A = sharedAssets(quality);
  const r = rng(chunk.seed ^ 0x9e3779b9);
  const ox = chunk.cx * 48, oz = chunk.cz * 48;
  const pines = [], broad = [], dead = [], bushes = [], ferns = [], grass = [], rocks = [], flowers = [[], [], []];

  const ok = (x, z, clear = 0) => {
    if (field.pathMask(x, z) > 0.05 || field.streamMask(x, z) > 0.02) return false;
    if (field.height(x, z) < WATER_Y + 0.1) return false;
    for (const rv of reserved) {
      const dx = x - rv.x, dz = z - rv.z;
      if (dx * dx + dz * dz < (rv.r + clear) * (rv.r + clear)) return false;
    }
    return true;
  };

  // Trees on a jittered grid, thinned in clearings.
  const cell = 7;
  for (let gx = 0; gx < 48; gx += cell) {
    for (let gz = 0; gz < 48; gz += cell) {
      const x = ox + gx + r() * cell, z = oz + gz + r() * cell;
      const clearing = field.clearing(x, z);
      if (r() > (0.85 - clearing * 0.8) * quality.treeDensity) continue;
      if (!ok(x, z, 1.5)) continue;
      const y = field.height(x, z);
      const kind = r();
      const s = 0.75 + r() * 0.6;
      if (kind < 0.8) {
        pines.push({ x, y: y - 0.2, z, rot: r() * 6.28, s });
        addCollider({ x, z, r: 0.35 * s, y0: y - 1, y1: y + 10 * s, kind: 'tree' });
      } else if (kind < 0.94) {
        broad.push({ x, y: y - 0.1, z, rot: r() * 6.28, s });
        addCollider({ x, z, r: 0.22 * s, y0: y - 1, y1: y + 5 * s, kind: 'tree' });
      } else {
        dead.push({ x, y: y - 0.1, z, rot: r() * 6.28, s });
        addCollider({ x, z, r: 0.28 * s, y0: y - 1, y1: y + 7 * s, kind: 'tree' });
      }
    }
  }

  const scatter = (count, list, fn) => {
    for (let i = 0; i < count; i++) {
      const x = ox + r() * 48, z = oz + r() * 48;
      if (!ok(x, z)) continue;
      fn(x, field.height(x, z), z, list);
    }
  };
  scatter(Math.round(7 * quality.bushDensity), rocks, (x, y, z) => {
    const s = 0.4 + r() * 1.3;
    rocks.push({ x, y: y + 0.1 * s, z, rot: r() * 6.28, s, tilt: [r() * 0.3, r() * 0.3] });
    if (s > 0.6) addCollider({ x, z, r: 1.05 * s, y0: y - 1, y1: y + 0.9 * s, kind: 'rock' });
  });
  scatter(Math.round(26 * quality.bushDensity), bushes, (x, y, z) => bushes.push({ x, y: y - 0.05, z, rot: r() * 6.28, s: 0.55 + r() * 0.5 }));
  scatter(Math.round(18 * quality.bushDensity), ferns, (x, y, z) => ferns.push({ x, y, z, rot: r() * 6.28, s: 0.7 + r() * 0.6 }));
  if (quality.grassDensity > 0) {
    const n = Math.round(420 * quality.grassDensity);
    for (let i = 0; i < n; i++) {
      const x = ox + r() * 48, z = oz + r() * 48;
      if (field.pathMask(x, z) > 0.4 || field.streamMask(x, z) > 0.3) continue;
      const y = field.height(x, z);
      if (y < WATER_Y + 0.15) continue;
      if (r() < 0.06) flowers[Math.floor(r() * 3)].push({ x, y, z, rot: r() * 6.28, s: 0.8 + r() * 0.5 });
      else grass.push({ x, y, z, rot: r() * 6.28, s: 0.8 + r() * 0.8 });
    }
  }

  const group = new THREE.Group();
  const detail = [];
  const sh = quality.shadows;
  const hi = instanced(A.pineHi, A.leafMat, pines, sh);
  const lo = instanced(A.pineLo, A.leafMat, pines, sh);
  if (hi) { group.add(hi); group.add(lo); lo.visible = false; }
  for (const m of [instanced(A.broadleaf, A.leafMat, broad, sh), instanced(A.dead, A.barkMat, dead, sh), instanced(A.rock, A.rockMat, rocks, sh)]) {
    if (m) group.add(m);
  }
  for (const m of [instanced(A.bush, A.bushMat, bushes, false), instanced(A.fern, A.bushMat, ferns, false), instanced(A.grass, A.grassMat, grass, false),
    ...flowers.map((f, i) => instanced(A.flowers[i], A.grassMat, f, false))]) {
    if (m) { group.add(m); detail.push(m); }
  }
  return { group, detail, hi, lo };
}

export function foliageAssets() { return shared; }
