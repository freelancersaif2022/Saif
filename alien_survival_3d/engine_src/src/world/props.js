// Environment props and traps: wooden crates, explosive barrels, barricades,
// spike traps, landmines, fallen trees, bridges, watchtowers and glowing caves.
import * as THREE from 'three';
import { GeoBuilder, G } from '../render/geo.js';
import { rng } from '../core/math.js';
import { Textures } from '../render/textures.js';
import { rockGeometry, logGeometry } from './foliage.js';

let A = null;
function assets(standard) {
  if (A) return A;
  const mk = (o) => {
    if (standard) return new THREE.MeshStandardMaterial({ roughness: 0.85, metalness: 0, ...o });
    const { roughness, metalness, ...lambert } = o;
    return new THREE.MeshLambertMaterial(lambert);
  };
  const wood = mk({ vertexColors: true, map: Textures.wood() });
  const plain = mk({ vertexColors: true, map: Textures.metal() });
  const rock = mk({ vertexColors: true, map: Textures.rock() });
  const glow = new THREE.MeshBasicMaterial({ vertexColors: true, toneMapped: false });

  const crateGeo = new THREE.BoxGeometry(1.2, 1.2, 1.2);
  const crateMat = mk({ map: Textures.crate() });

  const barrelGeo = new THREE.CylinderGeometry(0.42, 0.42, 1.25, 16, 1);
  const barrelSide = mk({ map: Textures.barrel(), roughness: 0.5, metalness: 0.3 });
  const barrelCap = mk({ color: 0x9a1a10, roughness: 0.5, metalness: 0.3 });

  // Wood barrier: crossed logs with planks, as in the reference sheet.
  const bar = new GeoBuilder();
  for (let i = 0; i < 3; i++) bar.add(G.cyl(0.16, 0.16, 3.6, 8), { pos: [0, 0.3 + i * 0.36, 0], rot: [0, 0, Math.PI / 2], color: i % 2 ? 0x7a5634 : 0x6a4a2c });
  for (const x of [-1.5, 1.5]) {
    bar.add(G.cyl(0.12, 0.12, 2.0, 6), { pos: [x, 0.7, 0.25], rot: [0.5, 0, 0.35], color: 0x5c4028 });
    bar.add(G.cyl(0.12, 0.12, 2.0, 6), { pos: [x, 0.7, -0.25], rot: [-0.5, 0, -0.35], color: 0x5c4028 });
  }
  bar.add(G.box(0.08, 0.1, 3.4), { pos: [0, 0.66, 0], rot: [0, Math.PI / 2, 0.25], color: 0x8f8f8f });

  const spikes = new GeoBuilder();
  spikes.add(G.box(2.0, 0.12, 2.0), { pos: [0, 0.06, 0], color: 0x5a3e24 });
  const r = rng(77);
  for (let i = 0; i < 16; i++) {
    const x = -0.75 + (i % 4) * 0.5 + (r() - 0.5) * 0.1, z = -0.75 + Math.floor(i / 4) * 0.5 + (r() - 0.5) * 0.1;
    spikes.add(G.cone(0.09, 0.85 + r() * 0.3, 5), { pos: [x, 0.5, z], rot: [(r() - 0.5) * 0.25, 0, (r() - 0.5) * 0.25], color: 0x8a6a44, gradient: [0.8, 1.3] });
  }

  const mine = new GeoBuilder();
  mine.add(G.cyl(0.36, 0.42, 0.14, 16), { pos: [0, 0.07, 0], color: 0x3c4a2c });
  mine.add(G.cyl(0.24, 0.3, 0.08, 16), { pos: [0, 0.17, 0], color: 0x56603c });
  mine.add(G.cyl(0.06, 0.06, 0.06, 8), { pos: [0, 0.23, 0], color: 0x222222 });
  for (let i = 0; i < 6; i++) {
    const a = (i / 6) * Math.PI * 2;
    mine.add(G.box(0.05, 0.05, 0.05), { pos: [Math.cos(a) * 0.3, 0.16, Math.sin(a) * 0.3], color: 0x2a2a2a });
  }
  const mineLight = new GeoBuilder();
  mineLight.add(G.sphere(0.045, 8, 6), { pos: [0.12, 0.23, 0], color: 0xff2a1a, glow: true });

  // Watchtower
  const tower = new GeoBuilder();
  for (const [x, z] of [[-1.4, -1.4], [1.4, -1.4], [-1.4, 1.4], [1.4, 1.4]]) {
    tower.add(G.cyl(0.14, 0.18, 7.2, 7), { pos: [x * 0.92, 3.6, z * 0.92], rot: [z * 0.03, 0, -x * 0.03], color: 0x5c4028 });
  }
  for (const y of [1.6, 3.8]) {
    tower.add(G.box(0.1, 0.1, 3.8), { pos: [-1.3, y, 0], rot: [0.75, 0, 0], color: 0x6a4a2c });
    tower.add(G.box(0.1, 0.1, 3.8), { pos: [1.3, y, 0], rot: [-0.75, 0, 0], color: 0x6a4a2c });
    tower.add(G.box(3.8, 0.1, 0.1), { pos: [0, y, -1.3], rot: [0, 0, 0.75], color: 0x6a4a2c });
    tower.add(G.box(3.8, 0.1, 0.1), { pos: [0, y, 1.3], rot: [0, 0, -0.75], color: 0x6a4a2c });
  }
  tower.add(G.box(3.6, 0.2, 3.6), { pos: [0, 6.2, 0], color: 0x7a5634 });
  for (const s of [-1, 1]) {
    tower.add(G.box(3.6, 0.9, 0.08), { pos: [0, 6.75, s * 1.76], color: 0x6a4a2c });
    tower.add(G.box(0.08, 0.9, 3.6), { pos: [s * 1.76, 6.75, 0], color: 0x6a4a2c });
  }
  for (const [x, z] of [[-1.7, -1.7], [1.7, -1.7], [-1.7, 1.7], [1.7, 1.7]]) {
    tower.add(G.cyl(0.07, 0.07, 2.4, 5), { pos: [x, 7.4, z], color: 0x5c4028 });
  }
  tower.add(G.cone(3.1, 1.6, 4), { pos: [0, 9.3, 0], rot: [0, Math.PI / 4, 0], color: 0x4a3a2a });
  for (let i = 0; i < 9; i++) tower.add(G.box(0.7, 0.07, 0.07), { pos: [0, 0.6 + i * 0.7, 1.85], color: 0x7a5634 });
  tower.add(G.box(0.07, 6.6, 0.07), { pos: [-0.35, 3.3, 1.85], color: 0x5c4028 });
  tower.add(G.box(0.07, 6.6, 0.07), { pos: [0.35, 3.3, 1.85], color: 0x5c4028 });

  // Cave: a rocky mound with a dark mouth and glowing blue crystals.
  const cave = new GeoBuilder();
  const cr = rng(91);
  for (let i = 0; i < 9; i++) {
    const a = Math.PI * 0.15 + (i / 8) * Math.PI * 0.7;
    cave.add(G.dodeca(1.9 + cr() * 0.9, 1), {
      pos: [Math.cos(a) * 3.6, 1.0 + cr() * 1.4, -Math.sin(a) * 2.0 - 1.2], scale: [1, 1.2, 1], color: 0x6a665e,
      jitter: 0.7, rng: cr, flat: true,
    });
  }
  cave.add(G.dodeca(3.4, 1), { pos: [0, 3.6, -2.4], scale: [1.4, 0.75, 1], color: 0x625e56, jitter: 0.8, rng: cr, flat: true });
  cave.add(G.dodeca(2.6, 1), { pos: [0, 1.8, -4.4], scale: [1.6, 1.1, 1], color: 0x55524b, jitter: 0.6, rng: cr, flat: true });
  const caveGlow = new GeoBuilder();
  caveGlow.add(G.sphere(1.6, 16, 10), { pos: [0, 1.2, -2.2], scale: [1.2, 1.0, 0.25], color: 0x0a1a2a, glow: true });
  for (let i = 0; i < 7; i++) {
    caveGlow.add(G.cone(0.18 + cr() * 0.15, 0.8 + cr() * 0.8, 5), {
      pos: [(cr() - 0.5) * 3, 0.3 + cr() * 0.6, -1.6 - cr() * 0.6], rot: [(cr() - 0.5) * 0.8, 0, (cr() - 0.5) * 0.8], color: 0x4fd8ff, glow: true,
    });
  }

  const bridge = new GeoBuilder();
  for (let i = 0; i < 18; i++) {
    bridge.add(G.box(0.72, 0.12, 3.2), { pos: [-6.2 + i * 0.73, 0, 0], rot: [0, 0, (r() - 0.5) * 0.04], color: i % 3 ? 0x7a5634 : 0x6a4a2c });
  }
  for (const s of [-1, 1]) {
    bridge.add(G.box(13.2, 0.18, 0.2), { pos: [0, -0.12, s * 1.2], color: 0x5c4028 });
    bridge.add(G.box(13.2, 0.12, 0.12), { pos: [0, 1.0, s * 1.55], color: 0x6a4a2c });
    for (let i = 0; i < 7; i++) bridge.add(G.box(0.14, 1.1, 0.14), { pos: [-6 + i * 2, 0.5, s * 1.55], color: 0x5c4028 });
    for (const x of [-5.5, 0, 5.5]) bridge.add(G.cyl(0.18, 0.2, 3.6, 7), { pos: [x, -1.8, s * 1.4], color: 0x4a3420 });
  }

  A = {
    wood, plain, rock, glow, crateGeo, crateMat, barrelGeo, barrelSide, barrelCap,
    barricade: bar.build(), spikes: spikes.build(), mine: mine.build(), mineLight: mineLight.build(),
    tower: tower.build(), cave: cave.build(), caveGlow: caveGlow.build(), bridge: bridge.build(),
    log: logGeometry(), boulder: rockGeometry(55, 1),
  };
  return A;
}

export function makeProp(type, standard) {
  const a = assets(standard);
  let obj;
  switch (type) {
    case 'crate':
      obj = new THREE.Mesh(a.crateGeo, a.crateMat);
      obj.position.y = 0.6;
      break;
    case 'barrel': {
      obj = new THREE.Mesh(a.barrelGeo, [a.barrelSide, a.barrelCap, a.barrelCap]);
      obj.position.y = 0.62;
      break;
    }
    case 'barricade': obj = new THREE.Mesh(a.barricade, a.wood); break;
    case 'spikes': obj = new THREE.Mesh(a.spikes, a.wood); break;
    case 'mine': {
      obj = new THREE.Group();
      obj.add(new THREE.Mesh(a.mine, a.plain));
      const light = new THREE.Mesh(a.mineLight, a.glow);
      light.name = 'light';
      obj.add(light);
      break;
    }
    case 'tower': obj = new THREE.Mesh(a.tower, a.wood); break;
    case 'cave': {
      obj = new THREE.Group();
      obj.add(new THREE.Mesh(a.cave, a.rock));
      obj.add(new THREE.Mesh(a.caveGlow, a.glow));
      break;
    }
    case 'bridge': obj = new THREE.Mesh(a.bridge, a.wood); break;
    case 'log': obj = new THREE.Mesh(a.log, a.wood); break;
    case 'boulder': obj = new THREE.Mesh(a.boulder, a.rock); break;
    default: throw new Error('unknown prop ' + type);
  }
  obj.traverse((o) => { if (o.isMesh) { o.castShadow = type !== 'mine' && type !== 'spikes'; o.receiveShadow = true; } });
  const root = new THREE.Group();
  root.add(obj);
  return root;
}
