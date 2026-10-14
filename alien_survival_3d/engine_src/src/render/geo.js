// Geometry builder: composes primitive pieces with per-piece colour, transform
// and an optional "glow" flag into one merged, vertex-coloured BufferGeometry.
// Used for vegetation, props, weapons and the skinned characters (which also
// get per-vertex bone indices).
import * as THREE from 'three';
import { mergeGeometries } from 'three/examples/jsm/utils/BufferGeometryUtils.js';

const _m = new THREE.Matrix4();
const _q = new THREE.Quaternion();
const _e = new THREE.Euler();
const _s = new THREE.Vector3();
const _p = new THREE.Vector3();

export class GeoBuilder {
  constructor() {
    this.parts = [];
  }

  // opts: { pos:[x,y,z], rot:[x,y,z], scale:[x,y,z]|number, color, glow, bone, jitter, matrix }
  add(geometry, opts = {}) {
    let g = geometry.index ? geometry.toNonIndexed() : geometry.clone();
    if (!g.attributes.uv) {
      g.setAttribute('uv', new THREE.BufferAttribute(new Float32Array(g.attributes.position.count * 2), 2));
    }
    if (opts.jitter) {
      const pos = g.attributes.position;
      const rnd = opts.rng || Math.random;
      // Jitter shared vertices consistently by hashing their position.
      const map = new Map();
      for (let i = 0; i < pos.count; i++) {
        const k = `${pos.getX(i).toFixed(3)},${pos.getY(i).toFixed(3)},${pos.getZ(i).toFixed(3)}`;
        let off = map.get(k);
        if (!off) { off = [(rnd() - 0.5) * opts.jitter, (rnd() - 0.5) * opts.jitter, (rnd() - 0.5) * opts.jitter]; map.set(k, off); }
        pos.setXYZ(i, pos.getX(i) + off[0], pos.getY(i) + off[1], pos.getZ(i) + off[2]);
      }
    }
    if (opts.matrix) {
      g.applyMatrix4(opts.matrix);
    } else {
      const s = opts.scale ?? 1;
      if (Array.isArray(s)) _s.set(s[0], s[1], s[2]); else _s.set(s, s, s);
      const r = opts.rot || [0, 0, 0];
      _q.setFromEuler(_e.set(r[0], r[1], r[2]));
      const p = opts.pos || [0, 0, 0];
      _p.set(p[0], p[1], p[2]);
      _m.compose(_p, _q, _s);
      g.applyMatrix4(_m);
    }
    if (opts.jitter || opts.flat) g.computeVertexNormals();
    const n = g.attributes.position.count;
    const col = new Float32Array(n * 3);
    const c = new THREE.Color(opts.color ?? 0xffffff);
    const shade = opts.gradient; // [bottomMul, topMul] vertical shading in local space
    let minY = 0, maxY = 1;
    if (shade) {
      g.computeBoundingBox();
      minY = g.boundingBox.min.y; maxY = g.boundingBox.max.y;
    }
    for (let i = 0; i < n; i++) {
      let k = 1;
      if (shade) {
        const t = (g.attributes.position.getY(i) - minY) / Math.max(1e-4, maxY - minY);
        k = shade[0] + (shade[1] - shade[0]) * t;
      }
      col[i * 3] = c.r * k; col[i * 3 + 1] = c.g * k; col[i * 3 + 2] = c.b * k;
    }
    g.setAttribute('color', new THREE.BufferAttribute(col, 3));
    // Keep attribute sets identical across parts so they merge.
    for (const name of Object.keys(g.attributes)) {
      if (!['position', 'normal', 'uv', 'color'].includes(name)) g.deleteAttribute(name);
    }
    this.parts.push({ g, glow: !!opts.glow, bone: opts.bone ?? 0 });
    return this;
  }

  // Merged geometry. With `groups`, glowing parts go into material group 1.
  build({ groups = false, skin = false } = {}) {
    const ordered = groups ? [...this.parts.filter((p) => !p.glow), ...this.parts.filter((p) => p.glow)] : this.parts;
    if (skin) {
      for (const p of ordered) {
        const n = p.g.attributes.position.count;
        const si = new Uint16Array(n * 4);
        const sw = new Float32Array(n * 4);
        for (let i = 0; i < n; i++) { si[i * 4] = p.bone; sw[i * 4] = 1; }
        p.g.setAttribute('skinIndex', new THREE.Uint16BufferAttribute(si, 4));
        p.g.setAttribute('skinWeight', new THREE.Float32BufferAttribute(sw, 4));
      }
    }
    const merged = mergeGeometries(ordered.map((p) => p.g), false);
    merged.clearGroups();
    if (groups) {
      let solidCount = 0;
      for (const p of ordered) if (!p.glow) solidCount += p.g.attributes.position.count;
      merged.addGroup(0, solidCount, 0);
      const total = merged.attributes.position.count;
      if (total > solidCount) merged.addGroup(solidCount, total - solidCount, 1);
    }
    for (const p of this.parts) p.g.dispose();
    merged.computeBoundingSphere();
    merged.computeBoundingBox();
    return merged;
  }
}

export const G = {
  box: (w = 1, h = 1, d = 1, ws = 1, hs = 1, ds = 1) => new THREE.BoxGeometry(w, h, d, ws, hs, ds),
  cyl: (rt, rb, h, seg = 10, hseg = 1, open = false) => new THREE.CylinderGeometry(rt, rb, h, seg, hseg, open),
  cone: (r, h, seg = 10, hseg = 1) => new THREE.ConeGeometry(r, h, seg, hseg),
  sphere: (r, ws = 12, hs = 8) => new THREE.SphereGeometry(r, ws, hs),
  ico: (r, d = 0) => new THREE.IcosahedronGeometry(r, d),
  dodeca: (r, d = 0) => new THREE.DodecahedronGeometry(r, d),
  capsule: (r, len, cs = 4, rs = 10) => new THREE.CapsuleGeometry(r, len, cs, rs),
  torus: (r, t, rs = 8, ts = 16, arc = Math.PI * 2) => new THREE.TorusGeometry(r, t, rs, ts, arc),
  lathe: (pts, seg = 12) => new THREE.LatheGeometry(pts.map(([x, y]) => new THREE.Vector2(x, y)), seg),
};
