// GPU particle system: particles are written once into a ring buffer and
// simulated entirely in the vertex shader (ballistic motion, growth, fade), so
// CPU cost per live particle is zero.
import * as THREE from 'three';

const vert = `
  attribute vec3 aVel;
  attribute vec4 aColor;
  attribute vec4 aParams; // birth, life, size0, size1
  attribute float aGrav;
  uniform float uTime;
  uniform float uScale;
  varying vec4 vColor;
  varying float vAge;
  void main() {
    float age = (uTime - aParams.x) / aParams.y;
    if (age < 0.0 || age > 1.0) { gl_Position = vec4(2.0, 2.0, 2.0, 1.0); gl_PointSize = 0.0; return; }
    float t = uTime - aParams.x;
    // velocity drag
    vec3 p = position + aVel * (1.0 - exp(-2.2 * t)) / 2.2 + vec3(0.0, -0.5 * aGrav * t * t, 0.0);
    vec4 mv = modelViewMatrix * vec4(p, 1.0);
    gl_Position = projectionMatrix * mv;
    float size = mix(aParams.z, aParams.w, age);
    gl_PointSize = size * uScale / max(0.1, -mv.z);
    vColor = aColor;
    vAge = age;
  }`;

const frag = `
  varying vec4 vColor;
  varying float vAge;
  uniform float uSoft;
  void main() {
    vec2 c = gl_PointCoord - 0.5;
    float d = length(c) * 2.0;
    float a = smoothstep(1.0, uSoft, d);
    float fade = 1.0 - smoothstep(0.55, 1.0, vAge);
    gl_FragColor = vec4(vColor.rgb, vColor.a * a * fade);
    if (gl_FragColor.a < 0.01) discard;
  }`;

export class ParticleSystem {
  constructor(capacity, additive) {
    this.capacity = capacity;
    this.cursor = 0;
    this.time = 0;
    const g = new THREE.BufferGeometry();
    this.pos = new Float32Array(capacity * 3);
    this.vel = new Float32Array(capacity * 3);
    this.col = new Float32Array(capacity * 4);
    this.par = new Float32Array(capacity * 4).fill(-1000);
    this.grav = new Float32Array(capacity);
    this.attrs = {
      position: new THREE.BufferAttribute(this.pos, 3),
      aVel: new THREE.BufferAttribute(this.vel, 3),
      aColor: new THREE.BufferAttribute(this.col, 4),
      aParams: new THREE.BufferAttribute(this.par, 4),
      aGrav: new THREE.BufferAttribute(this.grav, 1),
    };
    for (const [k, a] of Object.entries(this.attrs)) { a.setUsage(THREE.DynamicDrawUsage); g.setAttribute(k, a); }
    this.uniforms = { uTime: { value: 0 }, uScale: { value: 300 }, uSoft: { value: additive ? 0.0 : 0.3 } };
    const mat = new THREE.ShaderMaterial({
      vertexShader: vert, fragmentShader: frag, uniforms: this.uniforms, transparent: true, depthWrite: false,
      blending: additive ? THREE.AdditiveBlending : THREE.NormalBlending,
    });
    this.points = new THREE.Points(g, mat);
    this.points.frustumCulled = false;
    this.points.renderOrder = additive ? 5 : 4;
    this.dirtyMin = Infinity; this.dirtyMax = -1;
  }

  emit(x, y, z, vx, vy, vz, r, gr, b, a, life, size0, size1, gravity = 0) {
    const i = this.cursor;
    this.cursor = (this.cursor + 1) % this.capacity;
    this.pos[i * 3] = x; this.pos[i * 3 + 1] = y; this.pos[i * 3 + 2] = z;
    this.vel[i * 3] = vx; this.vel[i * 3 + 1] = vy; this.vel[i * 3 + 2] = vz;
    this.col[i * 4] = r; this.col[i * 4 + 1] = gr; this.col[i * 4 + 2] = b; this.col[i * 4 + 3] = a;
    this.par[i * 4] = this.time; this.par[i * 4 + 1] = life; this.par[i * 4 + 2] = size0; this.par[i * 4 + 3] = size1;
    this.grav[i] = gravity;
    if (i < this.dirtyMin) this.dirtyMin = i;
    if (i > this.dirtyMax) this.dirtyMax = i;
  }

  update(dt, viewportHeight, fov) {
    this.time += dt;
    this.uniforms.uTime.value = this.time;
    this.uniforms.uScale.value = viewportHeight / (2 * Math.tan((fov * Math.PI) / 360));
    if (this.dirtyMax >= 0) {
      const start = this.dirtyMin, count = this.dirtyMax - this.dirtyMin + 1;
      for (const [k, a] of Object.entries(this.attrs)) {
        const size = k === 'aGrav' ? 1 : k === 'position' || k === 'aVel' ? 3 : 4;
        a.clearUpdateRanges();
        a.addUpdateRange(start * size, count * size);
        a.needsUpdate = true;
      }
      this.dirtyMin = Infinity; this.dirtyMax = -1;
    }
  }
}
