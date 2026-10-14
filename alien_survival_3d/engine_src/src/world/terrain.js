// Infinite procedural terrain: a deterministic height field with dirt paths,
// carved streams, ponds and clearings, meshed per chunk with analytic normals
// so chunk seams are invisible.
import * as THREE from 'three';
import { makeNoise2D, fbm, smoothstep, clamp, lerp } from '../core/math.js';
import { Textures } from '../render/textures.js';

export const CHUNK = 48;
export const WATER_Y = -1.55;

export class TerrainField {
  constructor(seed) {
    this.nh = makeNoise2D(seed);
    this.nd = makeNoise2D(seed + 101);
    this.np = makeNoise2D(seed + 202);
    this.ns = makeNoise2D(seed + 303);
    this.nc = makeNoise2D(seed + 404);
    this.nw = makeNoise2D(seed + 505);
  }

  pathMask(x, z) {
    const wx = x + 18 * this.nw(x * 0.01, z * 0.01);
    const wz = z + 18 * this.nw(z * 0.01 + 50, x * 0.01);
    const v = this.np(wx * 0.0042, wz * 0.0042);
    return 1 - smoothstep(0.022, 0.05, Math.abs(v));
  }

  streamMask(x, z) {
    const wx = x + 25 * this.nw(x * 0.007 + 9, z * 0.007);
    const v = this.ns(wx * 0.0028 + 31.7, z * 0.0028 - 12.3);
    return 1 - smoothstep(0.014, 0.034, Math.abs(v));
  }

  clearing(x, z) {
    return smoothstep(0.35, 0.6, this.nc(x * 0.011, z * 0.011));
  }

  baseHeight(x, z) {
    const hills = fbm(this.nh, x * 0.0055, z * 0.0055, 4) * 6.5;
    const detail = this.nd(x * 0.05, z * 0.05) * 0.35;
    return hills + detail + 1.2;
  }

  height(x, z) {
    let h = this.baseHeight(x, z);
    const p = this.pathMask(x, z);
    if (p > 0) h -= p * 0.18;
    const s = this.streamMask(x, z);
    if (s > 0) h = lerp(h, Math.min(h, WATER_Y - 0.85), s);
    return h;
  }

  normal(x, z, out) {
    const e = 0.6;
    const hx = this.height(x + e, z) - this.height(x - e, z);
    const hz = this.height(x, z + e) - this.height(x, z - e);
    out.set(-hx, 2 * e, -hz).normalize();
    return out;
  }

  isWater(x, z) { return this.height(x, z) < WATER_Y - 0.1; }

  // Finds a dry, gently sloped spot near (x,z).
  findDrySpot(x, z, maxR = 80) {
    const n = new THREE.Vector3();
    for (let r = 0; r <= maxR; r += 3) {
      const steps = Math.max(1, Math.floor(r * 0.8));
      for (let i = 0; i < steps; i++) {
        const a = (i / steps) * Math.PI * 2;
        const px = x + Math.cos(a) * r, pz = z + Math.sin(a) * r;
        if (this.height(px, pz) < WATER_Y + 0.4) continue;
        if (this.normal(px, pz, n).y < 0.93) continue;
        return { x: px, z: pz };
      }
    }
    return { x, z };
  }
}

const cGrassA = new THREE.Color(0x4f7a2a);
const cGrassB = new THREE.Color(0x6b8f34);
const cDry = new THREE.Color(0x8f8a46);
const cDirt = new THREE.Color(0x7a5a3a);
const cDirtDark = new THREE.Color(0x5e432b);
const cRock = new THREE.Color(0x6e6a62);
const cMud = new THREE.Color(0x4a3f30);
const cMoss = new THREE.Color(0x3b5a22);
const tmpC = new THREE.Color();
const tmpN = new THREE.Vector3();

export function buildTerrainGeometry(field, cx, cz, res) {
  const size = CHUNK;
  const verts = (res + 1) * (res + 1);
  const pos = new Float32Array(verts * 3);
  const nor = new Float32Array(verts * 3);
  const col = new Float32Array(verts * 3);
  const uv = new Float32Array(verts * 2);
  const ox = cx * size, oz = cz * size;
  let minY = Infinity, maxY = -Infinity;
  for (let j = 0, v = 0; j <= res; j++) {
    for (let i = 0; i <= res; i++, v++) {
      const x = ox + (i / res) * size;
      const z = oz + (j / res) * size;
      const y = field.height(x, z);
      minY = Math.min(minY, y); maxY = Math.max(maxY, y);
      pos[v * 3] = x - ox; pos[v * 3 + 1] = y; pos[v * 3 + 2] = z - oz;
      field.normal(x, z, tmpN);
      nor[v * 3] = tmpN.x; nor[v * 3 + 1] = tmpN.y; nor[v * 3 + 2] = tmpN.z;
      uv[v * 2] = x * 0.22; uv[v * 2 + 1] = z * 0.22;

      // Surface colour: grass variants, dry patches, dirt paths, mud banks, rock on slopes.
      const g = field.nd(x * 0.03, z * 0.03) * 0.5 + 0.5;
      tmpC.copy(cGrassA).lerp(cGrassB, g);
      const dry = smoothstep(0.3, 0.8, field.nc(x * 0.02 + 7, z * 0.02));
      tmpC.lerp(cDry, dry * 0.45);
      tmpC.lerp(cMoss, field.clearing(x, z) < 0.1 ? 0.15 : 0);
      const p = field.pathMask(x, z);
      if (p > 0) {
        tmpC.lerp(field.nd(x * 0.3, z * 0.3) > 0 ? cDirt : cDirtDark, smoothstep(0.0, 0.6, p));
      }
      const wet = 1 - smoothstep(WATER_Y + 0.1, WATER_Y + 1.0, y);
      if (wet > 0) tmpC.lerp(cMud, wet);
      const slope = 1 - tmpN.y;
      if (slope > 0.12) tmpC.lerp(cRock, smoothstep(0.12, 0.3, slope));
      col[v * 3] = tmpC.r; col[v * 3 + 1] = tmpC.g; col[v * 3 + 2] = tmpC.b;
    }
  }
  const idx = new (verts > 65535 ? Uint32Array : Uint16Array)(res * res * 6);
  let k = 0;
  for (let j = 0; j < res; j++) {
    for (let i = 0; i < res; i++) {
      const a = j * (res + 1) + i, b = a + 1, c = a + res + 1, d = c + 1;
      idx[k++] = a; idx[k++] = c; idx[k++] = b;
      idx[k++] = b; idx[k++] = c; idx[k++] = d;
    }
  }
  const geo = new THREE.BufferGeometry();
  geo.setAttribute('position', new THREE.BufferAttribute(pos, 3));
  geo.setAttribute('normal', new THREE.BufferAttribute(nor, 3));
  geo.setAttribute('color', new THREE.BufferAttribute(col, 3));
  geo.setAttribute('uv', new THREE.BufferAttribute(uv, 2));
  geo.setIndex(new THREE.BufferAttribute(idx, 1));
  geo.boundingBox = new THREE.Box3(new THREE.Vector3(0, minY, 0), new THREE.Vector3(size, maxY, size));
  geo.boundingSphere = new THREE.Sphere();
  geo.boundingBox.getBoundingSphere(geo.boundingSphere);
  return geo;
}

let terrainMat = null;
export function terrainMaterial(standard) {
  if (!terrainMat) {
    const opts = { vertexColors: true, map: Textures.ground() };
    terrainMat = standard
      ? new THREE.MeshStandardMaterial({ ...opts, roughness: 0.96, metalness: 0 })
      : new THREE.MeshLambertMaterial(opts);
  }
  return terrainMat;
}

// Animated water surface (shared by streams and ponds): one large plane that
// follows the player; the terrain hides it wherever the ground is higher.
export function createWater() {
  const geo = new THREE.PlaneGeometry(600, 600, 1, 1);
  geo.rotateX(-Math.PI / 2);
  const mat = new THREE.ShaderMaterial({
    transparent: true,
    fog: true,
    depthWrite: false,
    uniforms: THREE.UniformsUtils.merge([
      THREE.UniformsLib.fog,
      { uTime: { value: 0 }, uDeep: { value: new THREE.Color(0x1d4a52) }, uShallow: { value: new THREE.Color(0x4f9aa0) }, uSky: { value: new THREE.Color(0xbfd9ea) } },
    ]),
    vertexShader: `
      varying vec3 vWorld;
      #include <fog_pars_vertex>
      void main() {
        vec4 wp = modelMatrix * vec4(position, 1.0);
        vWorld = wp.xyz;
        vec4 mvPosition = viewMatrix * wp;
        gl_Position = projectionMatrix * mvPosition;
        #include <fog_vertex>
      }`,
    fragmentShader: `
      uniform float uTime; uniform vec3 uDeep; uniform vec3 uShallow; uniform vec3 uSky;
      varying vec3 vWorld;
      #include <fog_pars_fragment>
      float wave(vec2 p) {
        return sin(p.x * 1.7 + uTime * 1.3) * 0.5 + sin(p.y * 2.3 - uTime * 1.1) * 0.5
             + sin((p.x + p.y) * 3.1 + uTime * 2.0) * 0.25;
      }
      void main() {
        vec2 p = vWorld.xz;
        float e = 0.15;
        vec3 n = normalize(vec3(wave(p + vec2(e, 0.0)) - wave(p - vec2(e, 0.0)), 6.0, wave(p + vec2(0.0, e)) - wave(p - vec2(0.0, e))));
        vec3 v = normalize(cameraPosition - vWorld);
        float fres = pow(1.0 - max(dot(n, v), 0.0), 3.0);
        vec3 col = mix(uDeep, uShallow, 0.35 + 0.25 * n.x);
        col = mix(col, uSky, clamp(fres * 0.8 + 0.1, 0.0, 1.0));
        // sun glints from the perturbed normal (no regular pattern)
        vec3 h = normalize(normalize(vec3(0.45, 0.62, -0.64)) + v);
        float glint = pow(max(dot(n, h), 0.0), 220.0) * 0.6;
        gl_FragColor = vec4(col + glint, 0.82);
        #include <fog_fragment>
      }`,
  });
  const mesh = new THREE.Mesh(geo, mat);
  mesh.position.y = WATER_Y;
  mesh.renderOrder = 2;
  return mesh;
}

export { clamp };
