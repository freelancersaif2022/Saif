// Bone layouts and skinned-mesh assembly. Every character is a single
// THREE.SkinnedMesh driven by a THREE.Skeleton; body parts are modelled in
// bone space and rigidly weighted to their bone.
import * as THREE from 'three';
import { GeoBuilder } from '../render/geo.js';

// [name, parent, x, y, z] rest offsets (character faces +Z, right side is -X).
export const LAYOUTS = {
  humanoid: (s = {}) => {
    const sw = s.shoulderW ?? 0.2, hipW = s.hipW ?? 0.1, ua = s.upperArm ?? 0.3, fa = s.foreArm ?? 0.27;
    const th = s.thigh ?? 0.45, sh = s.shin ?? 0.45, hip = s.hipH ?? 0.98;
    return [
      ['root', null, 0, 0, 0],
      ['hips', 'root', 0, hip, 0],
      ['spine', 'hips', 0, 0.12, 0],
      ['chest', 'spine', 0, s.chestH ?? 0.2, 0],
      ['neck', 'chest', 0, s.neckH ?? 0.28, 0],
      ['head', 'neck', 0, 0.08, 0],
      ['armL', 'chest', sw, 0.22, 0],
      ['foreL', 'armL', 0, -ua, 0],
      ['handL', 'foreL', 0, -fa, 0],
      ['armR', 'chest', -sw, 0.22, 0],
      ['foreR', 'armR', 0, -ua, 0],
      ['handR', 'foreR', 0, -fa, 0],
      ['thighL', 'hips', hipW, -0.05, 0],
      ['shinL', 'thighL', 0, -th, 0],
      ['footL', 'shinL', 0, -sh, 0],
      ['thighR', 'hips', -hipW, -0.05, 0],
      ['shinR', 'thighR', 0, -th, 0],
      ['footR', 'shinR', 0, -sh, 0],
      ...(s.wings ? [['wingL', 'chest', 0.12, 0.18, -0.12], ['wingR', 'chest', -0.12, 0.18, -0.12]] : []),
      ...(s.tail ? [['tail', 'hips', 0, 0.0, -0.15], ['tail2', 'tail', 0, 0, -0.4]] : []),
    ];
  },
  // Quadruped crawler: spine runs horizontally along +Z.
  crawler: () => [
    ['root', null, 0, 0, 0],
    ['hips', 'root', 0, 0.55, -0.35],
    ['spine', 'hips', 0, 0.02, 0.3],
    ['chest', 'spine', 0, 0.02, 0.32],
    ['neck', 'chest', 0, 0.06, 0.25],
    ['head', 'neck', 0, 0.02, 0.12],
    ['armL', 'chest', 0.2, -0.02, 0.05],
    ['foreL', 'armL', 0, -0.3, 0],
    ['handL', 'foreL', 0, -0.28, 0],
    ['armR', 'chest', -0.2, -0.02, 0.05],
    ['foreR', 'armR', 0, -0.3, 0],
    ['handR', 'foreR', 0, -0.28, 0],
    ['thighL', 'hips', 0.17, -0.02, 0],
    ['shinL', 'thighL', 0, -0.3, 0],
    ['footL', 'shinL', 0, -0.26, 0],
    ['thighR', 'hips', -0.17, -0.02, 0],
    ['shinR', 'thighR', 0, -0.3, 0],
    ['footR', 'shinR', 0, -0.26, 0],
    ['tail', 'hips', 0, 0.05, -0.15],
    ['tail2', 'tail', 0, 0, -0.45],
  ],
};

export class RigBuilder {
  constructor(layout) {
    this.layout = layout;
    this.bones = [];
    this.index = {};
    for (const [name, parent, x, y, z] of layout) {
      const b = new THREE.Bone();
      b.name = name;
      b.position.set(x, y, z);
      this.index[name] = this.bones.length;
      this.bones.push(b);
      if (parent) this.bones[this.index[parent]].add(b);
    }
    this.root = this.bones[0];
    this.root.updateMatrixWorld(true);
    this.builder = new GeoBuilder();
    this._m = new THREE.Matrix4();
    this._q = new THREE.Quaternion();
  }

  // Adds a part in the named bone's local space.
  part(boneName, geometry, opts = {}) {
    const bi = this.index[boneName];
    if (bi === undefined) throw new Error('no bone ' + boneName);
    const bone = this.bones[bi];
    const s = opts.scale ?? 1;
    const scale = Array.isArray(s) ? new THREE.Vector3(...s) : new THREE.Vector3(s, s, s);
    const r = opts.rot || [0, 0, 0];
    this._q.setFromEuler(new THREE.Euler(r[0], r[1], r[2]));
    const local = new THREE.Matrix4().compose(new THREE.Vector3(...(opts.pos || [0, 0, 0])), this._q, scale);
    const m = new THREE.Matrix4().multiplyMatrices(bone.matrixWorld, local);
    this.builder.add(geometry, { ...opts, matrix: m, bone: bi });
    return this;
  }

  // Mirrors a part definition onto both sides (L uses +x, R uses -x).
  pair(base, geometry, opts = {}) {
    const p = opts.pos || [0, 0, 0];
    const r = opts.rot || [0, 0, 0];
    this.part(base + 'L', geometry, opts);
    this.part(base + 'R', geometry, { ...opts, pos: [-p[0], p[1], p[2]], rot: [r[0], -r[1], -r[2]] });
    return this;
  }

  build(materials, { radius = 2, centerY = 1 } = {}) {
    const geo = this.builder.build({ groups: true, skin: true });
    return { geometry: geo, layout: this.layout, radius, centerY, materials };
  }
}

// Creates a new skinned instance (own bones, shared geometry and materials).
export function instantiate(template, cloneMaterials = false) {
  const bones = [];
  const index = {};
  for (const [name, parent, x, y, z] of template.layout) {
    const b = new THREE.Bone();
    b.name = name;
    b.position.set(x, y, z);
    index[name] = bones.length;
    bones.push(b);
    if (parent) bones[index[parent]].add(b);
  }
  const mats = cloneMaterials ? template.materials.map((m) => m.clone()) : template.materials;
  const mesh = new THREE.SkinnedMesh(template.geometry, mats);
  mesh.add(bones[0]);
  mesh.updateMatrixWorld(true);
  mesh.bind(new THREE.Skeleton(bones));
  mesh.boundingSphere = new THREE.Sphere(new THREE.Vector3(0, template.centerY, 0), template.radius);
  mesh.frustumCulled = true;
  const bonesByName = {};
  for (const b of bones) bonesByName[b.name] = b;
  return { mesh, bones, index, b: bonesByName, rest: bones.map((b) => b.position.clone()) };
}
