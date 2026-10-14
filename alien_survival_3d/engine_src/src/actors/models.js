// Procedural 3D models: the soldier, nine alien types and six firearms plus the
// grenade, modelled after the reference concept sheet. Characters are skinned
// meshes (see skeleton.js); weapons are static meshes with socket points.
import * as THREE from 'three';
import { G, GeoBuilder } from '../render/geo.js';
import { LAYOUTS, RigBuilder } from './skeleton.js';
import { Textures } from '../render/textures.js';
import { rng } from '../core/math.js';

const templates = new Map();

function bodyMaterials({ map, roughness = 0.75, metalness = 0.05, side = THREE.FrontSide } = {}) {
  return [
    new THREE.MeshStandardMaterial({ vertexColors: true, map, roughness, metalness, side }),
    new THREE.MeshBasicMaterial({ vertexColors: true, toneMapped: false, side }),
  ];
}

// ---------------------------------------------------------------- soldier --
export function soldierTemplate() {
  if (templates.has('soldier')) return templates.get('soldier');
  const layout = LAYOUTS.humanoid({ thigh: 0.43, shin: 0.42 });
  const R = new RigBuilder(layout);
  const SKIN = 0xc28a68, SKIN_D = 0x9a6a50, SHIRT = 0x7a7650, SHIRT_D = 0x5f5c3c, PANTS = 0x2f3f5e, PANTS_D = 0x243250;
  const BOOT = 0x6b4628, SOLE = 0x1d1915, GEAR = 0x4f4c32, STRAP = 0x34332a, GLOVE = 0x2a2724, HAIR = 0x1b1510;

  // pelvis, belt, pouches
  R.part('hips', G.capsule(0.15, 0.08, 4, 14), { pos: [0, -0.02, 0], scale: [1.15, 0.8, 0.85], color: PANTS });
  R.part('hips', G.cyl(0.178, 0.178, 0.065, 18), { pos: [0, 0.075, 0], scale: [1, 1, 0.82], color: 0x3b3226 });
  R.part('hips', G.box(0.06, 0.045, 0.02), { pos: [0, 0.075, 0.148], color: 0x9a9a8a });
  for (const [x, z, ry] of [[0.16, 0.05, 0.4], [-0.16, 0.05, -0.4], [0.12, -0.12, -0.6], [-0.12, -0.12, 0.6], [0, -0.15, 0]]) {
    R.part('hips', G.box(0.085, 0.09, 0.06), { pos: [x, 0.05, z], rot: [0, ry, 0], color: GEAR });
    R.part('hips', G.box(0.088, 0.03, 0.064), { pos: [x, 0.09, z], rot: [0, ry, 0], color: SHIRT_D });
  }
  // abdomen and chest
  R.part('spine', G.capsule(0.14, 0.1, 4, 14), { pos: [0, 0.07, 0], scale: [1.18, 1, 0.8], color: SHIRT });
  R.part('chest', G.capsule(0.16, 0.17, 6, 16), { pos: [0, 0.12, 0], scale: [1.22, 1, 0.8], color: SHIRT });
  for (const s of [1, -1]) {
    R.part('chest', G.box(0.1, 0.11, 0.03), { pos: [s * 0.09, 0.14, 0.125], color: SHIRT_D });
    R.part('chest', G.box(0.104, 0.035, 0.034), { pos: [s * 0.09, 0.2, 0.127], color: 0x55522f });
    R.part('chest', G.box(0.045, 0.34, 0.02), { pos: [s * 0.115, 0.13, 0.133], color: STRAP });
    R.part('chest', G.box(0.05, 0.02, 0.26), { pos: [s * 0.12, 0.31, -0.02], color: STRAP });
    R.part('chest', G.box(0.045, 0.3, 0.02), { pos: [s * 0.115, 0.12, -0.14], color: STRAP });
  }
  R.part('chest', G.torus(0.065, 0.02, 6, 14), { pos: [0, 0.31, 0.01], rot: [Math.PI / 2, 0, 0], color: SHIRT_D });
  R.part('chest', G.box(0.012, 0.22, 0.012), { pos: [0, 0.16, 0.135], color: 0x3a3a2a });
  // backpack
  R.part('chest', G.box(0.34, 0.42, 0.17), { pos: [0, 0.1, -0.23], color: 0x5f5b3b });
  R.part('chest', G.box(0.36, 0.06, 0.18), { pos: [0, 0.3, -0.23], color: 0x504c30 });
  R.part('chest', G.cyl(0.07, 0.07, 0.36, 12), { pos: [0, 0.37, -0.21], rot: [0, 0, Math.PI / 2], color: 0x4a4a30 });
  R.part('chest', G.box(0.24, 0.17, 0.05), { pos: [0, -0.02, -0.33], color: GEAR });
  R.part('chest', G.box(0.07, 0.22, 0.12), { pos: [0.2, 0.04, -0.23], color: GEAR });
  R.part('chest', G.box(0.07, 0.22, 0.12), { pos: [-0.2, 0.04, -0.23], color: GEAR });
  R.part('chest', G.box(0.3, 0.025, 0.02), { pos: [0, 0.15, -0.316], color: STRAP });
  // neck and head
  R.part('neck', G.cyl(0.055, 0.062, 0.12, 12), { pos: [0, 0.03, 0.005], color: SKIN });
  R.part('head', G.sphere(0.104, 18, 14), { pos: [0, 0.1, 0.005], scale: [0.92, 1.08, 1.0], color: SKIN });
  R.part('head', G.sphere(0.084, 14, 10), { pos: [0, 0.04, 0.03], scale: [0.95, 0.72, 1], color: SKIN_D });
  R.part('head', G.box(0.026, 0.045, 0.035), { pos: [0, 0.088, 0.104], rot: [-0.25, 0, 0], color: SKIN });
  R.part('head', G.box(0.04, 0.008, 0.012), { pos: [0, 0.045, 0.097], color: 0x7a4a3a });
  for (const s of [1, -1]) {
    R.part('head', G.sphere(0.026, 8, 6), { pos: [s * 0.097, 0.095, 0], scale: [0.45, 1, 0.8], color: SKIN_D });
    R.part('head', G.sphere(0.013, 8, 6), { pos: [s * 0.036, 0.115, 0.092], scale: [1.2, 0.8, 0.6], color: 0xf0ebe0 });
    R.part('head', G.sphere(0.007, 6, 4), { pos: [s * 0.036, 0.115, 0.099], color: 0x241a12 });
    R.part('head', G.box(0.04, 0.009, 0.012), { pos: [s * 0.037, 0.134, 0.097], rot: [0, 0, s * -0.12], color: HAIR });
  }
  R.part('head', new THREE.SphereGeometry(0.112, 18, 8, 0, Math.PI * 2, 0, Math.PI * 0.5), { pos: [0, 0.12, -0.006], scale: [0.96, 0.85, 1.05], color: HAIR });
  R.part('head', new THREE.SphereGeometry(0.108, 16, 8, Math.PI * 0.6, Math.PI * 0.8, Math.PI * 0.35, Math.PI * 0.3), { pos: [0, 0.1, -0.01], color: HAIR });
  // arms
  for (const side of ['L', 'R']) {
    const s = side === 'L' ? 1 : -1;
    R.part('arm' + side, G.sphere(0.075, 12, 10), { pos: [0, -0.01, 0], scale: [1, 0.9, 1], color: SHIRT });
    R.part('arm' + side, G.capsule(0.062, 0.12, 4, 12), { pos: [0, -0.1, 0], color: SHIRT });
    R.part('arm' + side, G.torus(0.058, 0.016, 6, 12), { pos: [0, -0.18, 0], rot: [Math.PI / 2, 0, 0], color: SHIRT_D });
    R.part('arm' + side, G.capsule(0.05, 0.08, 4, 10), { pos: [0, -0.24, 0], color: SKIN });
    R.part('arm' + side, G.box(0.012, 0.075, 0.07), { pos: [s * 0.06, -0.07, 0], color: 0x3d4a2a });
    R.part('arm' + side, G.box(0.014, 0.035, 0.035), { pos: [s * 0.061, -0.07, 0], color: side === 'L' ? 0xd1fe17 : 0xb03a2e });
    R.part('fore' + side, G.capsule(0.046, 0.17, 4, 10), { pos: [0, -0.12, 0], color: SKIN });
    R.part('fore' + side, G.cyl(0.05, 0.05, 0.05, 10), { pos: [0, -0.235, 0], color: GLOVE });
    R.part('hand' + side, G.box(0.075, 0.09, 0.042), { pos: [0, -0.045, 0.005], color: GLOVE });
    R.part('hand' + side, G.box(0.07, 0.06, 0.035), { pos: [0, -0.11, 0.018], rot: [0.35, 0, 0], color: GLOVE });
    R.part('hand' + side, G.box(0.022, 0.05, 0.025), { pos: [s * 0.042, -0.05, 0.03], rot: [0.3, 0, s * 0.4], color: GLOVE });
  }
  R.part('foreL', G.box(0.03, 0.035, 0.055), { pos: [0.044, -0.2, 0], color: 0x151515 });
  // legs
  for (const side of ['L', 'R']) {
    const s = side === 'L' ? 1 : -1;
    R.part('thigh' + side, G.capsule(0.088, 0.25, 4, 12), { pos: [0, -0.2, 0], color: PANTS });
    R.part('thigh' + side, G.box(0.03, 0.12, 0.11), { pos: [s * 0.088, -0.24, 0.0], color: PANTS_D });
    R.part('shin' + side, G.capsule(0.07, 0.24, 4, 12), { pos: [0, -0.17, 0], color: PANTS });
    R.part('shin' + side, G.sphere(0.07, 10, 8), { pos: [0, -0.02, 0.055], scale: [1, 1.15, 0.6], color: 0x2a2a2a });
    R.part('shin' + side, G.cyl(0.078, 0.074, 0.16, 12), { pos: [0, -0.34, 0], color: BOOT });
    R.part('shin' + side, G.torus(0.077, 0.01, 4, 12), { pos: [0, -0.27, 0], rot: [Math.PI / 2, 0, 0], color: 0x4a3018 });
    R.part('foot' + side, G.box(0.11, 0.085, 0.24), { pos: [0, -0.035, 0.045], color: BOOT });
    R.part('foot' + side, G.sphere(0.056, 10, 8), { pos: [0, -0.04, 0.15], scale: [1, 0.75, 1], color: BOOT });
    R.part('foot' + side, G.box(0.12, 0.03, 0.27), { pos: [0, -0.078, 0.05], color: SOLE });
  }
  R.part('thighR', G.box(0.05, 0.17, 0.1), { pos: [-0.105, -0.17, 0.0], color: 0x24221e });
  R.part('thighR', G.box(0.02, 0.03, 0.1), { pos: [-0.1, -0.06, 0], color: STRAP });
  R.part('thighR', G.box(0.028, 0.06, 0.04), { pos: [-0.11, -0.06, 0.01], color: 0x151515 });

  const t = R.build(bodyMaterials({ map: Textures.fabric() }), { radius: 1.6, centerY: 0.9 });
  templates.set('soldier', t);
  return t;
}

// ----------------------------------------------------------------- aliens --
function humanoidAlien(def, R, cols, variant) {
  const [BODY, PLATE, GLOW] = cols;
  const r = rng(def.id.length * 97);
  const plate = (bone, size, opts) => R.part(bone, G.dodeca(size, 0), { color: PLATE, jitter: size * 0.25, rng: r, flat: true, ...opts });
  const claw = variant === 'runner' ? 0.24 : 0.16;

  R.part('hips', G.sphere(0.15, 12, 8), { scale: [1.2, 0.8, 0.9], color: BODY });
  plate('hips', 0.13, { pos: [0, -0.02, 0.07], scale: [1.4, 0.8, 0.6] });
  for (let i = 0; i < 3; i++) R.part('spine', G.torus(0.09 - i * 0.008, 0.035, 6, 12), { pos: [0, 0.02 + i * 0.07, 0], rot: [Math.PI / 2, 0, 0], color: i % 2 ? BODY : PLATE });
  R.part('spine', G.cyl(0.08, 0.1, 0.24, 10), { pos: [0, 0.08, 0], color: BODY });
  plate('chest', 0.22, { pos: [0, 0.14, 0.01], scale: [1.3, 1.0, 0.85] });
  R.part('chest', G.sphere(0.2, 12, 10), { pos: [0, 0.12, -0.02], scale: [1.25, 1.0, 0.85], color: BODY });
  R.part('chest', G.sphere(0.065, 12, 10), { pos: [0, 0.15, 0.175], color: GLOW, glow: true });
  for (const s of [1, -1]) {
    R.part('chest', G.box(0.02, 0.2, 0.02), { pos: [s * 0.11, 0.1, 0.165], rot: [0, 0, s * 0.35], color: GLOW, glow: true });
    plate('chest', 0.12, { pos: [s * 0.24, 0.26, 0], scale: [1.2, 0.8, 1.1] });
    R.part('chest', G.cone(0.035, 0.18, 5), { pos: [s * 0.29, 0.36, -0.02], rot: [0, 0, -s * 0.6], color: PLATE });
  }
  for (let i = 0; i < 4; i++) R.part('chest', G.cone(0.03, 0.14 + (variant === 'elite' ? 0.1 : 0), 5), { pos: [0, 0.3 - i * 0.09, -0.2], rot: [-1.1, 0, 0], color: PLATE });
  R.part('neck', G.cyl(0.05, 0.07, 0.14, 8), { pos: [0, 0.03, 0], color: BODY });
  // head: elongated skull, glowing eyes, mandibles
  R.part('head', G.sphere(0.12, 14, 10), { pos: [0, 0.09, 0.03], rot: [-0.25, 0, 0], scale: [0.85, 1.0, 1.4], color: PLATE });
  R.part('head', G.cone(0.07, 0.25, 6), { pos: [0, 0.16, -0.1], rot: [-2.1, 0, 0], color: BODY });
  for (const s of [1, -1]) {
    R.part('head', G.sphere(0.024, 8, 6), { pos: [s * 0.048, 0.1, 0.135], scale: [1.6, 0.6, 1], color: GLOW, glow: true });
    R.part('head', G.cone(0.018, 0.11, 5), { pos: [s * 0.04, 0.0, 0.15], rot: [2.5, 0, s * 0.3], color: BODY });
  }
  if (variant === 'spitter') {
    R.part('neck', G.sphere(0.09, 12, 8), { pos: [0, 0.0, 0.07], scale: [1, 0.8, 1], color: GLOW, glow: true });
    for (let i = 0; i < 5; i++) R.part('head', G.cone(0.03, 0.16, 4), { pos: [(i - 2) * 0.05, 0.18, -0.06], rot: [-0.6, 0, (i - 2) * 0.3], color: GLOW, glow: true });
  }
  if (variant === 'elite') {
    R.part('head', G.cone(0.05, 0.3, 4), { pos: [0, 0.27, -0.02], rot: [-0.4, 0, 0], color: PLATE });
    for (const s of [1, -1]) plate('chest', 0.16, { pos: [s * 0.26, 0.28, -0.02], scale: [1.3, 0.9, 1.3] });
    R.part('chest', G.box(0.36, 0.5, 0.03), { pos: [0, -0.05, -0.22], rot: [0.15, 0, 0], color: BODY });
  }
  for (const side of ['L', 'R']) {
    const s = side === 'L' ? 1 : -1;
    R.part('arm' + side, G.capsule(0.064, 0.2, 4, 10), { pos: [0, -0.15, 0], color: BODY });
    plate('arm' + side, 0.08, { pos: [s * 0.04, -0.1, 0], scale: [0.8, 1.4, 1] });
    R.part('fore' + side, G.capsule(0.055, 0.2, 4, 10), { pos: [0, -0.14, 0], color: BODY });
    plate('fore' + side, 0.07, { pos: [s * 0.03, -0.12, -0.02], scale: [0.8, 1.6, 0.9] });
    R.part('fore' + side, G.box(0.012, 0.18, 0.012), { pos: [s * 0.045, -0.13, 0.04], color: GLOW, glow: true });
    R.part('fore' + side, G.cone(0.025, 0.12, 5), { pos: [0, -0.02, -0.07], rot: [-1.9, 0, 0], color: PLATE });
    R.part('hand' + side, G.sphere(0.05, 8, 6), { pos: [0, -0.03, 0], scale: [1, 1.1, 0.7], color: BODY });
    for (let k = -1; k <= 1; k++) R.part('hand' + side, G.cone(0.014, claw, 5), { pos: [k * 0.025, -0.08 - claw * 0.4, 0.015], rot: [Math.PI - 0.25, 0, k * 0.15], color: 0xd8d0c0 });
    R.part('thigh' + side, G.capsule(0.08, 0.28, 4, 10), { pos: [0, -0.2, 0], color: BODY });
    plate('thigh' + side, 0.1, { pos: [0, -0.18, 0.05], scale: [0.9, 1.6, 0.7] });
    R.part('shin' + side, G.capsule(0.06, 0.3, 4, 10), { pos: [0, -0.2, 0], color: BODY });
    R.part('shin' + side, G.cone(0.035, 0.14, 5), { pos: [0, 0.0, 0.08], rot: [1.3, 0, 0], color: PLATE });
    plate('shin' + side, 0.07, { pos: [0, -0.2, 0.04], scale: [0.9, 1.8, 0.7] });
    for (let k = -1; k <= 1; k++) R.part('foot' + side, G.cone(0.025, 0.16, 5), { pos: [k * 0.035, -0.02, 0.09], rot: [Math.PI / 2, 0, 0], color: PLATE });
    R.part('foot' + side, G.sphere(0.05, 8, 6), { pos: [0, -0.01, -0.02], color: BODY });
  }
}

function bruteAlien(def, R, cols, boss) {
  const [BODY, PLATE, GLOW] = cols;
  const r = rng(boss ? 991 : 313);
  const plate = (bone, size, opts) => R.part(bone, G.dodeca(size, 0), { color: PLATE, jitter: size * 0.22, rng: r, flat: true, ...opts });
  R.part('hips', G.sphere(0.2, 12, 8), { scale: [1.3, 0.8, 1], color: BODY });
  plate('hips', 0.16, { pos: [0, -0.02, 0.1], scale: [1.5, 0.8, 0.6] });
  R.part('spine', G.sphere(0.2, 12, 10), { pos: [0, 0.1, 0], scale: [1.2, 1, 0.9], color: BODY });
  plate('chest', 0.36, { pos: [0, 0.16, 0.02], scale: [1.35, 1.0, 0.95] });
  R.part('chest', G.sphere(0.34, 14, 10), { pos: [0, 0.14, -0.04], scale: [1.35, 1, 0.95], color: BODY });
  R.part('chest', G.sphere(0.11, 14, 10), { pos: [0, 0.16, 0.3], color: GLOW, glow: true });
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2;
    R.part('chest', G.box(0.02, 0.16, 0.02), { pos: [Math.cos(a) * 0.17, 0.16 + Math.sin(a) * 0.17, 0.27], rot: [0, 0, a + Math.PI / 2], color: GLOW, glow: true });
  }
  for (const s of [1, -1]) {
    plate('chest', 0.2, { pos: [s * 0.36, 0.3, 0], scale: [1.2, 0.9, 1.2] });
    for (let k = 0; k < 3; k++) R.part('chest', G.cone(0.05, 0.24, 5), { pos: [s * (0.33 + k * 0.06), 0.45, -0.05 + k * 0.05], rot: [0, 0, -s * (0.4 + k * 0.2)], color: PLATE });
  }
  for (let i = 0; i < 5; i++) R.part('chest', G.cone(0.05, 0.22, 5), { pos: [0, 0.4 - i * 0.12, -0.3], rot: [-1.2, 0, 0], color: PLATE });
  if (boss) for (let i = 0; i < 4; i++) R.part('spine', G.sphere(0.05, 8, 6), { pos: [0, 0.05 + i * 0.05, -0.2], color: GLOW, glow: true });
  R.part('neck', G.cyl(0.1, 0.14, 0.15, 8), { pos: [0, 0.0, 0.05], color: BODY });
  R.part('head', G.sphere(0.15, 12, 10), { pos: [0, 0.06, 0.08], scale: [1.1, 0.95, 1.2], color: PLATE });
  R.part('head', G.box(0.2, 0.06, 0.14), { pos: [0, -0.02, 0.15], color: BODY });
  for (const s of [1, -1]) {
    R.part('head', G.sphere(0.03, 8, 6), { pos: [s * 0.06, 0.08, 0.24], scale: [1.5, 0.6, 1], color: GLOW, glow: true });
    R.part('head', G.cone(0.04, boss ? 0.4 : 0.22, 6), { pos: [s * 0.12, 0.2, 0.0], rot: [-0.5, 0, -s * 0.5], color: 0xd8d0c0 });
  }
  if (boss) for (let i = 0; i < 5; i++) R.part('head', G.cone(0.03, 0.26, 5), { pos: [(i - 2) * 0.06, 0.22, -0.05], rot: [-0.3, 0, (i - 2) * 0.25], color: GLOW, glow: true });
  for (const side of ['L', 'R']) {
    const s = side === 'L' ? 1 : -1;
    R.part('arm' + side, G.capsule(0.12, 0.2, 4, 12), { pos: [0, -0.16, 0], color: BODY });
    plate('arm' + side, 0.13, { pos: [s * 0.06, -0.12, 0], scale: [0.9, 1.4, 1.1] });
    R.part('fore' + side, G.capsule(0.13, 0.2, 4, 12), { pos: [0, -0.16, 0], color: BODY });
    plate('fore' + side, 0.12, { pos: [s * 0.05, -0.16, 0.02], scale: [1, 1.5, 1.1] });
    R.part('fore' + side, G.box(0.02, 0.24, 0.02), { pos: [s * 0.1, -0.16, 0.08], color: GLOW, glow: true });
    R.part('hand' + side, G.dodeca(0.13, 0), { pos: [0, -0.08, 0.02], scale: [1, 1.1, 1], color: PLATE, flat: true });
    for (let k = -1; k <= 1; k++) R.part('hand' + side, G.cone(0.025, 0.12, 5), { pos: [k * 0.05, -0.12, 0.1], rot: [1.4, 0, 0], color: 0xd8d0c0 });
    R.part('thigh' + side, G.capsule(0.12, 0.2, 4, 10), { pos: [0, -0.17, 0], color: BODY });
    plate('thigh' + side, 0.14, { pos: [0, -0.15, 0.06], scale: [1, 1.3, 0.8] });
    R.part('shin' + side, G.capsule(0.1, 0.22, 4, 10), { pos: [0, -0.18, 0], color: BODY });
    plate('shin' + side, 0.12, { pos: [0, -0.16, 0.05], scale: [1, 1.5, 0.8] });
    R.part('foot' + side, G.box(0.2, 0.1, 0.3), { pos: [0, -0.04, 0.06], color: PLATE });
    for (let k = -1; k <= 1; k++) R.part('foot' + side, G.cone(0.03, 0.12, 5), { pos: [k * 0.06, -0.05, 0.24], rot: [Math.PI / 2, 0, 0], color: 0xd8d0c0 });
  }
}

function crawlerAlien(def, R, cols) {
  const [BODY, PLATE, GLOW] = cols;
  const r = rng(555);
  const plate = (bone, size, opts) => R.part(bone, G.dodeca(size, 0), { color: PLATE, jitter: size * 0.25, rng: r, flat: true, ...opts });
  R.part('hips', G.sphere(0.16, 10, 8), { scale: [1.2, 0.8, 1.3], color: BODY });
  R.part('spine', G.sphere(0.17, 10, 8), { pos: [0, 0, 0.15], scale: [1.1, 0.75, 1.3], color: BODY });
  R.part('chest', G.sphere(0.19, 10, 8), { pos: [0, 0, 0.1], scale: [1.2, 0.8, 1.2], color: BODY });
  for (const [bone, z] of [['hips', 0], ['spine', 0.15], ['chest', 0.1]]) {
    plate(bone, 0.17, { pos: [0, 0.11, z], scale: [1.3, 0.45, 1.2] });
    R.part(bone, G.cone(0.035, 0.2, 5), { pos: [0, 0.2, z], rot: [-0.4, 0, 0], color: PLATE });
    R.part(bone, G.sphere(0.03, 6, 4), { pos: [0, 0.06, z + 0.12], color: GLOW, glow: true });
  }
  R.part('neck', G.cyl(0.07, 0.09, 0.15, 8), { pos: [0, 0, 0.05], rot: [Math.PI / 2, 0, 0], color: BODY });
  R.part('head', G.sphere(0.12, 12, 8), { pos: [0, 0.0, 0.08], scale: [1.1, 0.75, 1.4], color: PLATE });
  for (const s of [1, -1]) {
    R.part('head', G.sphere(0.024, 8, 6), { pos: [s * 0.06, 0.04, 0.2], scale: [1.5, 0.7, 1], color: GLOW, glow: true });
    R.part('head', G.sphere(0.016, 8, 6), { pos: [s * 0.03, 0.06, 0.23], color: GLOW, glow: true });
    R.part('head', G.cone(0.02, 0.14, 5), { pos: [s * 0.05, -0.05, 0.22], rot: [1.9, 0, s * 0.4], color: 0xd8d0c0 });
  }
  R.part('tail', G.cone(0.09, 0.45, 8), { pos: [0, 0, -0.2], rot: [-Math.PI / 2, 0, 0], color: BODY });
  R.part('tail2', G.cone(0.05, 0.4, 6), { pos: [0, 0, -0.18], rot: [-Math.PI / 2, 0, 0], color: PLATE });
  R.part('tail2', G.cone(0.03, 0.14, 5), { pos: [0, 0.05, -0.4], rot: [-0.6, 0, 0], color: GLOW, glow: true });
  for (const side of ['L', 'R']) {
    for (const [a, b, c] of [['arm', 'fore', 'hand'], ['thigh', 'shin', 'foot']]) {
      R.part(a + side, G.capsule(0.05, 0.22, 4, 8), { pos: [0, -0.15, 0], color: BODY });
      plate(a + side, 0.06, { pos: [0, -0.12, 0.03], scale: [0.8, 1.6, 0.8] });
      R.part(b + side, G.capsule(0.035, 0.22, 4, 8), { pos: [0, -0.14, 0], color: PLATE });
      R.part(c + side, G.cone(0.03, 0.14, 5), { pos: [0, -0.04, 0.03], rot: [Math.PI - 0.6, 0, 0], color: 0xd8d0c0 });
    }
  }
}

function bloaterAlien(def, R, cols) {
  const [BODY, PLATE, GLOW] = cols;
  const r = rng(777);
  R.part('hips', G.sphere(0.17, 10, 8), { scale: [1.2, 0.8, 1], color: BODY });
  R.part('spine', G.sphere(0.3, 16, 12), { pos: [0, 0.12, 0.04], scale: [1.05, 1, 1.05], color: BODY });
  R.part('chest', G.sphere(0.27, 16, 12), { pos: [0, 0.05, 0.02], color: BODY });
  for (let i = 0; i < 7; i++) {
    const a = r() * Math.PI * 2, y = r() * 0.3;
    R.part(i < 4 ? 'spine' : 'chest', G.sphere(0.07 + r() * 0.06, 10, 8), {
      pos: [Math.cos(a) * 0.22, 0.06 + y, 0.08 + Math.abs(Math.sin(a)) * 0.2], color: GLOW, glow: true,
    });
  }
  for (let i = 0; i < 5; i++) R.part('chest', G.dodeca(0.09, 0), { pos: [(r() - 0.5) * 0.4, 0.15 + r() * 0.15, -0.2], color: PLATE, flat: true });
  R.part('neck', G.cyl(0.05, 0.07, 0.1, 8), { color: BODY });
  R.part('head', G.sphere(0.1, 12, 8), { pos: [0, 0.07, 0.04], scale: [0.9, 0.9, 1.2], color: PLATE });
  for (const s of [1, -1]) R.part('head', G.sphere(0.02, 6, 4), { pos: [s * 0.04, 0.09, 0.14], color: GLOW, glow: true });
  for (const side of ['L', 'R']) {
    R.part('arm' + side, G.capsule(0.05, 0.18, 4, 8), { pos: [0, -0.13, 0], color: BODY });
    R.part('fore' + side, G.capsule(0.045, 0.18, 4, 8), { pos: [0, -0.12, 0], color: BODY });
    R.part('hand' + side, G.cone(0.02, 0.1, 5), { pos: [0, -0.05, 0], rot: [Math.PI, 0, 0], color: 0xd8d0c0 });
    R.part('thigh' + side, G.capsule(0.08, 0.2, 4, 8), { pos: [0, -0.16, 0], color: BODY });
    R.part('shin' + side, G.capsule(0.065, 0.22, 4, 8), { pos: [0, -0.17, 0], color: PLATE });
    R.part('foot' + side, G.box(0.1, 0.06, 0.18), { pos: [0, -0.03, 0.05], color: PLATE });
  }
}

function flyerAlien(def, R, cols) {
  humanoidAlien(def, R, cols, 'flyer');
  const [, PLATE, GLOW] = cols;
  const shape = new THREE.Shape();
  shape.moveTo(0, 0);
  shape.lineTo(0.35, 0.18); shape.lineTo(0.9, 0.12); shape.lineTo(1.25, -0.05);
  shape.lineTo(0.95, -0.12); shape.lineTo(0.85, -0.32); shape.lineTo(0.6, -0.22);
  shape.lineTo(0.45, -0.42); shape.lineTo(0.28, -0.24); shape.lineTo(0.05, -0.3);
  shape.lineTo(0, 0);
  const wing = new THREE.ShapeGeometry(shape);
  wing.rotateX(-Math.PI / 2);
  for (const side of ['L', 'R']) {
    const s = side === 'L' ? 1 : -1;
    R.part('wing' + side, wing, { scale: [s, 1, 1], color: PLATE });
    for (let i = 0; i < 3; i++) {
      R.part('wing' + side, G.box(0.85 - i * 0.2, 0.015, 0.015), { pos: [s * (0.4 - i * 0.05), 0.01, 0.05 + i * 0.12], rot: [0, s * (-0.15 - i * 0.25), 0], color: GLOW, glow: true });
    }
  }
}

export function alienTemplate(def) {
  if (templates.has(def.id)) return templates.get(def.id);
  const cols = def.colors;
  let R, radius = 1.6, centerY = 1, side = THREE.FrontSide;
  switch (def.rig) {
    case 'brute':
      R = new RigBuilder(LAYOUTS.humanoid({ shoulderW: 0.36, upperArm: 0.36, foreArm: 0.36, thigh: 0.36, shin: 0.36, hipH: 0.84, chestH: 0.24, neckH: 0.36, hipW: 0.15 }));
      bruteAlien(def, R, cols, def.id === 'boss');
      radius = 1.8; centerY = 1.1;
      break;
    case 'crawler':
      R = new RigBuilder(LAYOUTS.crawler());
      crawlerAlien(def, R, cols);
      radius = 1.3; centerY = 0.4;
      break;
    case 'bloater':
      R = new RigBuilder(LAYOUTS.humanoid({ hipH: 0.78, thigh: 0.36, shin: 0.36, chestH: 0.28, neckH: 0.24, upperArm: 0.26, foreArm: 0.24, shoulderW: 0.26 }));
      bloaterAlien(def, R, cols);
      radius = 1.3; centerY = 0.9;
      break;
    case 'flyer':
      R = new RigBuilder(LAYOUTS.humanoid({ shoulderW: 0.2, upperArm: 0.3, foreArm: 0.3, thigh: 0.36, shin: 0.38, hipH: 0.82, wings: true }));
      flyerAlien(def, R, cols);
      radius = 2.0; centerY = 0.9; side = THREE.DoubleSide;
      break;
    default:
      R = new RigBuilder(LAYOUTS.humanoid({ shoulderW: 0.24, upperArm: 0.34, foreArm: 0.31, thigh: 0.46, shin: 0.48, hipH: 1.0, neckH: 0.3, hipW: 0.11 }));
      humanoidAlien(def, R, cols, def.id === 'runner' ? 'runner' : def.id);
      radius = 1.7; centerY = 1.0;
  }
  const t = R.build(bodyMaterials({ map: Textures.alien(), roughness: 0.42, metalness: 0.55, side }), { radius, centerY });
  t.glowColor = new THREE.Color(cols[2]);
  templates.set(def.id, t);
  return t;
}

// ---------------------------------------------------------------- weapons --
// Each weapon: geometry in gun space (forward +Z, origin at the rear grip) and
// sockets: grip, fore (left hand), muzzle, eject.
const BLACK = 0x1e1f21, GUNMETAL = 0x34373b, WOOD = 0x6e3f1f, WOOD_D = 0x55301a, TAN = 0x7a7454;

function rifleGeo(b) {
  b.add(G.box(0.05, 0.075, 0.34), { pos: [0, 0.05, 0.1], color: GUNMETAL });
  b.add(G.box(0.045, 0.02, 0.3), { pos: [0, 0.095, 0.1], color: BLACK });
  b.add(G.box(0.045, 0.075, 0.26), { pos: [0, 0.03, -0.2], rot: [-0.12, 0, 0], color: WOOD, gradient: [0.8, 1.1] });
  b.add(G.box(0.048, 0.11, 0.05), { pos: [0, 0.0, -0.34], rot: [-0.12, 0, 0], color: WOOD_D });
  b.add(G.box(0.035, 0.11, 0.045), { pos: [0, -0.04, -0.01], rot: [0.35, 0, 0], color: WOOD_D });
  for (let i = 0; i < 4; i++) b.add(G.box(0.038, 0.05, 0.045), { pos: [0, -0.02 - i * 0.04, 0.12 + i * 0.018], rot: [-0.3 - i * 0.05, 0, 0], color: i % 2 ? GUNMETAL : BLACK });
  b.add(G.box(0.055, 0.06, 0.2), { pos: [0, 0.05, 0.36], color: WOOD, gradient: [0.8, 1.1] });
  b.add(G.cyl(0.012, 0.012, 0.3, 8), { pos: [0, 0.075, 0.56], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.008, 0.008, 0.22, 6), { pos: [0, 0.098, 0.4], rot: [Math.PI / 2, 0, 0], color: GUNMETAL });
  b.add(G.box(0.01, 0.035, 0.012), { pos: [0, 0.1, 0.62], color: BLACK });
  b.add(G.cyl(0.018, 0.016, 0.06, 8), { pos: [0, 0.075, 0.72], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.box(0.02, 0.03, 0.04), { pos: [0, 0.11, 0.24], color: BLACK });
  return { grip: [0, -0.02, 0], fore: [0, 0.02, 0.37], muzzle: [0, 0.075, 0.76], eject: [-0.03, 0.07, 0.12] };
}

function shotgunGeo(b) {
  b.add(G.box(0.05, 0.08, 0.26), { pos: [0, 0.05, 0.06], color: BLACK });
  b.add(G.box(0.045, 0.08, 0.3), { pos: [0, 0.02, -0.22], rot: [-0.14, 0, 0], color: WOOD, gradient: [0.8, 1.1] });
  b.add(G.box(0.05, 0.12, 0.04), { pos: [0, -0.01, -0.37], rot: [-0.14, 0, 0], color: 0x1a1a1a });
  b.add(G.cyl(0.015, 0.015, 0.62, 10), { pos: [0, 0.075, 0.5], rot: [Math.PI / 2, 0, 0], color: GUNMETAL });
  b.add(G.cyl(0.014, 0.014, 0.5, 10), { pos: [0, 0.04, 0.42], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.box(0.06, 0.06, 0.18), { pos: [0, 0.04, 0.34], color: WOOD, gradient: [0.8, 1.1] });
  for (let i = 0; i < 6; i++) b.add(G.box(0.062, 0.006, 0.01), { pos: [0, 0.07, 0.27 + i * 0.025], color: WOOD_D });
  b.add(G.box(0.012, 0.012, 0.012), { pos: [0, 0.092, 0.8], color: 0xd0d0d0 });
  return { grip: [0, -0.02, 0], fore: [0, 0.01, 0.34], muzzle: [0, 0.075, 0.82], eject: [-0.03, 0.07, 0.08] };
}

function sniperGeo(b) {
  b.add(G.box(0.05, 0.07, 0.36), { pos: [0, 0.04, 0.1], color: TAN });
  b.add(G.box(0.048, 0.1, 0.3), { pos: [0, 0.01, -0.22], rot: [-0.08, 0, 0], color: TAN, gradient: [0.8, 1.1] });
  b.add(G.box(0.05, 0.05, 0.12), { pos: [0, 0.07, -0.25], color: 0x5a5640 });
  b.add(G.box(0.035, 0.1, 0.045), { pos: [0, -0.045, 0.0], rot: [0.3, 0, 0], color: 0x3a3a2c });
  b.add(G.box(0.04, 0.07, 0.07), { pos: [0, -0.03, 0.12], color: BLACK });
  b.add(G.cyl(0.013, 0.015, 0.62, 10), { pos: [0, 0.06, 0.58], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.02, 0.02, 0.08, 10), { pos: [0, 0.06, 0.9], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.024, 0.024, 0.34, 14), { pos: [0, 0.135, 0.1], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.032, 0.024, 0.07, 14), { pos: [0, 0.135, 0.29], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.03, 0.024, 0.06, 14), { pos: [0, 0.135, -0.09], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.cyl(0.026, 0.026, 0.005, 14), { pos: [0, 0.135, 0.327], rot: [Math.PI / 2, 0, 0], color: 0x3a8fd8, glow: false });
  b.add(G.box(0.02, 0.04, 0.03), { pos: [0, 0.095, 0.04], color: BLACK });
  b.add(G.box(0.02, 0.04, 0.03), { pos: [0, 0.095, 0.18], color: BLACK });
  b.add(G.cyl(0.01, 0.01, 0.06, 6), { pos: [-0.04, 0.06, -0.02], rot: [0, 0, Math.PI / 2], color: BLACK });
  b.add(G.sphere(0.014, 8, 6), { pos: [-0.07, 0.06, -0.02], color: BLACK });
  for (const s of [1, -1]) b.add(G.cyl(0.006, 0.006, 0.22, 6), { pos: [s * 0.015, 0.02, 0.5], rot: [Math.PI / 2, 0, 0], color: BLACK });
  return { grip: [0, -0.03, 0], fore: [0, 0.0, 0.34], muzzle: [0, 0.06, 0.95], eject: [-0.03, 0.06, 0.08], scope: [0, 0.135, 0.1] };
}

function smgGeo(b) {
  b.add(G.box(0.045, 0.07, 0.28), { pos: [0, 0.05, 0.1], color: BLACK });
  b.add(G.box(0.035, 0.1, 0.04), { pos: [0, -0.03, 0.0], rot: [0.3, 0, 0], color: GUNMETAL });
  b.add(G.box(0.03, 0.17, 0.035), { pos: [0, -0.06, 0.16], rot: [0.12, 0, 0], color: GUNMETAL });
  b.add(G.cyl(0.02, 0.02, 0.2, 10), { pos: [0, 0.055, 0.32], rot: [Math.PI / 2, 0, 0], color: BLACK });
  b.add(G.box(0.012, 0.012, 0.22), { pos: [0.015, 0.05, -0.12], color: GUNMETAL });
  b.add(G.box(0.012, 0.012, 0.22), { pos: [-0.015, 0.05, -0.12], color: GUNMETAL });
  b.add(G.box(0.045, 0.06, 0.015), { pos: [0, 0.04, -0.23], color: BLACK });
  b.add(G.box(0.02, 0.03, 0.06), { pos: [0, 0.1, 0.06], color: BLACK });
  return { grip: [0, -0.02, 0], fore: [0, -0.04, 0.17], muzzle: [0, 0.055, 0.43], eject: [-0.03, 0.06, 0.08] };
}

function pistolGeo(b) {
  b.add(G.box(0.032, 0.035, 0.19), { pos: [0, 0.06, 0.07], color: BLACK });
  b.add(G.box(0.03, 0.03, 0.15), { pos: [0, 0.03, 0.06], color: GUNMETAL });
  b.add(G.box(0.03, 0.11, 0.045), { pos: [0, -0.02, 0.0], rot: [0.25, 0, 0], color: 0x2a2a2a });
  b.add(G.torus(0.02, 0.004, 4, 10, Math.PI), { pos: [0, 0.015, 0.05], rot: [0, Math.PI / 2, Math.PI], color: BLACK });
  return { grip: [0, -0.02, 0], fore: [0.03, -0.035, 0.01], muzzle: [0, 0.06, 0.17], eject: [-0.02, 0.07, 0.06] };
}

function minigunGeo(b, spin) {
  b.add(G.box(0.13, 0.14, 0.32), { pos: [0, 0.05, 0.08], color: GUNMETAL });
  b.add(G.box(0.03, 0.1, 0.045), { pos: [0, -0.06, 0], rot: [0.3, 0, 0], color: BLACK });
  b.add(G.box(0.02, 0.1, 0.02), { pos: [0, 0.17, 0.0], color: BLACK });
  b.add(G.box(0.02, 0.02, 0.24), { pos: [0, 0.22, 0.1], color: BLACK });
  b.add(G.box(0.02, 0.1, 0.02), { pos: [0, 0.17, 0.2], color: BLACK });
  b.add(G.box(0.12, 0.14, 0.16), { pos: [0.13, 0.0, 0.05], color: 0x3c4a2c });
  b.add(G.cyl(0.06, 0.06, 0.06, 12), { pos: [0, 0.05, 0.27], rot: [Math.PI / 2, 0, 0], color: BLACK });
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2;
    spin.add(G.cyl(0.011, 0.011, 0.6, 6), { pos: [Math.cos(a) * 0.035, Math.sin(a) * 0.035, 0.3], rot: [Math.PI / 2, 0, 0], color: BLACK });
  }
  spin.add(G.cyl(0.05, 0.05, 0.02, 12), { pos: [0, 0, 0.12], rot: [Math.PI / 2, 0, 0], color: GUNMETAL });
  spin.add(G.cyl(0.05, 0.05, 0.02, 12), { pos: [0, 0, 0.55], rot: [Math.PI / 2, 0, 0], color: GUNMETAL });
  return { grip: [0, -0.04, 0], fore: [0, 0.2, 0.12], muzzle: [0, 0.05, 0.92], eject: [-0.07, 0.03, 0.08], spinOrigin: [0, 0.05, 0.3] };
}

let gunMat = null;
export function weaponModel(id) {
  if (!gunMat) gunMat = new THREE.MeshStandardMaterial({ vertexColors: true, map: Textures.metal(), roughness: 0.5, metalness: 0.45 });
  const b = new GeoBuilder();
  const spin = new GeoBuilder();
  const sockets = {
    rifle: rifleGeo, shotgun: shotgunGeo, sniper: sniperGeo, smg: smgGeo, pistol: pistolGeo,
    minigun: (x) => minigunGeo(x, spin),
  }[id](b);
  const group = new THREE.Group();
  const mesh = new THREE.Mesh(b.build(), gunMat);
  mesh.castShadow = true;
  group.add(mesh);
  let spinner = null;
  if (spin.parts.length) {
    spinner = new THREE.Mesh(spin.build(), gunMat);
    spinner.position.fromArray(sockets.spinOrigin);
    spinner.geometry.translate(0, 0, -0.3);
    spinner.position.z = 0.3;
    spinner.castShadow = true;
    group.add(spinner);
  }
  const s = {};
  for (const k of Object.keys(sockets)) s[k] = new THREE.Vector3().fromArray(sockets[k]);
  return { group, sockets: s, spinner };
}

export function grenadeModel() {
  const b = new GeoBuilder();
  b.add(G.sphere(0.055, 12, 10), { scale: [1, 1.2, 1], color: 0x4a5a2c });
  for (let i = 0; i < 4; i++) b.add(G.torus(0.054 - Math.abs(i - 1.5) * 0.01, 0.006, 4, 12), { pos: [0, -0.04 + i * 0.027, 0], rot: [Math.PI / 2, 0, 0], color: 0x3a4822 });
  b.add(G.cyl(0.02, 0.022, 0.03, 8), { pos: [0, 0.075, 0], color: 0x6a6a5a });
  b.add(G.box(0.012, 0.07, 0.02), { pos: [0.025, 0.06, 0], rot: [0, 0, -0.3], color: 0x8a8a7a });
  b.add(G.torus(0.014, 0.003, 4, 10), { pos: [-0.02, 0.09, 0], color: 0xb0b0a0 });
  if (!gunMat) weaponModel('pistol');
  const m = new THREE.Mesh(b.build(), gunMat);
  m.castShadow = true;
  return m;
}
