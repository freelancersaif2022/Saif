// Daylight sky dome with sun glow and a ring of distant mountains that follows
// the camera, so the endless forest always has a horizon.
import * as THREE from 'three';
import { makeNoise2D, fbm } from '../core/math.js';

export const SKY = {
  top: new THREE.Color(0x5d93cf),
  horizon: new THREE.Color(0xc6dbe6),
  fog: new THREE.Color(0xaec8d4),
  sunDir: new THREE.Vector3(0.45, 0.62, -0.64).normalize(),
};

export function createSky() {
  const group = new THREE.Group();
  const dome = new THREE.Mesh(
    new THREE.SphereGeometry(900, 32, 16),
    new THREE.ShaderMaterial({
      side: THREE.BackSide,
      depthWrite: false,
      fog: false,
      uniforms: {
        uTop: { value: SKY.top }, uHorizon: { value: SKY.horizon }, uSun: { value: SKY.sunDir },
      },
      vertexShader: `varying vec3 vDir; void main(){ vDir = normalize(position); gl_Position = projectionMatrix * modelViewMatrix * vec4(position,1.0); gl_Position.z = gl_Position.w; }`,
      fragmentShader: `
        uniform vec3 uTop; uniform vec3 uHorizon; uniform vec3 uSun; varying vec3 vDir;
        void main(){
          float h = clamp(vDir.y, -0.2, 1.0);
          vec3 col = mix(uHorizon, uTop, pow(max(h, 0.0), 0.55));
          float s = max(dot(normalize(vDir), uSun), 0.0);
          col += vec3(1.0, 0.92, 0.75) * (pow(s, 600.0) * 2.5 + pow(s, 12.0) * 0.25);
          // soft clouds
          vec2 p = vDir.xz / max(vDir.y, 0.08) * 1.4;
          float c = sin(p.x * 1.3 + sin(p.y * 0.7)) * sin(p.y * 1.1 + sin(p.x * 0.9)) ;
          c = smoothstep(0.35, 0.9, c) * smoothstep(0.02, 0.3, vDir.y) * 0.35;
          col = mix(col, vec3(1.0), c);
          gl_FragColor = vec4(col, 1.0);
        }`,
    }),
  );
  dome.renderOrder = -10;
  dome.frustumCulled = false;
  group.add(dome);

  // Distant mountain ring, two layers for depth.
  const noise = makeNoise2D(4242);
  const makeRing = (radius, height, color, seed, segs = 160) => {
    const pos = [];
    const idx = [];
    for (let i = 0; i <= segs; i++) {
      const a = (i / segs) * Math.PI * 2;
      const n = fbm(noise, Math.cos(a) * 2 + seed, Math.sin(a) * 2 + seed, 5);
      const peak = Math.max(0.1, 0.55 + n * 0.9);
      const x = Math.cos(a) * radius, z = Math.sin(a) * radius;
      pos.push(x, -40, z, x, height * peak, z);
      if (i < segs) {
        const b = i * 2;
        idx.push(b, b + 2, b + 1, b + 1, b + 2, b + 3);
      }
    }
    const geo = new THREE.BufferGeometry();
    geo.setAttribute('position', new THREE.Float32BufferAttribute(pos, 3));
    geo.setIndex(idx);
    const col = [];
    const cLow = new THREE.Color(color).lerp(SKY.horizon, 0.35);
    const cHigh = new THREE.Color(color).lerp(new THREE.Color(0xe8eef2), 0.25);
    for (let i = 0; i < pos.length / 3; i++) {
      const y = pos[i * 3 + 1];
      const t = Math.max(0, y / height);
      const c = cLow.clone().lerp(cHigh, t > 0.75 ? 0.9 : t * 0.4);
      col.push(c.r, c.g, c.b);
    }
    geo.setAttribute('color', new THREE.Float32BufferAttribute(col, 3));
    const mesh = new THREE.Mesh(geo, new THREE.MeshBasicMaterial({ vertexColors: true, fog: false, side: THREE.DoubleSide, depthWrite: false }));
    mesh.renderOrder = -9;
    mesh.frustumCulled = false;
    return mesh;
  };
  group.add(makeRing(720, 210, 0x6f8494, 3.1));
  group.add(makeRing(560, 110, 0x55705a, 7.7));
  return group;
}
