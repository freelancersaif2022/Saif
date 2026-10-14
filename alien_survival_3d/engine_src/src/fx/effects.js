// Visual effects tied to gameplay events: muzzle flashes, tracers, shell
// casings, surface impacts, alien hit splashes, explosions with smoke/fire and
// scorch decals, shockwave rings, acid, spawn portals and pickup sparkles.
import * as THREE from 'three';
import { ParticleSystem } from './particles.js';
import { Textures } from '../render/textures.js';

const SURFACE = {
  dirt: [[0.42, 0.32, 0.2], [0.55, 0.45, 0.3]],
  rock: [[0.55, 0.53, 0.5], [0.7, 0.68, 0.64]],
  wood: [[0.5, 0.33, 0.18], [0.65, 0.48, 0.3]],
  metal: [[0.6, 0.6, 0.6], [0.9, 0.9, 0.9]],
  water: [[0.7, 0.85, 0.95], [0.9, 0.95, 1.0]],
};

const tmpV = new THREE.Vector3();
const tmpQ = new THREE.Quaternion();
const Z = new THREE.Vector3(0, 0, 1);

export class Effects {
  constructor(scene, quality) {
    this.scene = scene;
    this.quality = quality;
    const cap = quality.particles;
    this.add = new ParticleSystem(cap, true);
    this.alpha = new ParticleSystem(Math.round(cap * 0.75), false);
    scene.add(this.add.points, this.alpha.points);
    this.mul = quality.particles / 4000 + 0.4;

    // muzzle flash: crossed quads + front sprite
    const flashMat = new THREE.MeshBasicMaterial({ map: Textures.muzzle(), transparent: true, blending: THREE.AdditiveBlending, depthWrite: false, side: THREE.DoubleSide, toneMapped: false });
    this.flashes = [];
    for (let i = 0; i < 3; i++) {
      const g = new THREE.Group();
      const q1 = new THREE.Mesh(new THREE.PlaneGeometry(0.22, 0.6), flashMat);
      q1.position.z = 0.25; q1.rotation.x = Math.PI / 2;
      const q2b = new THREE.Mesh(new THREE.PlaneGeometry(0.6, 0.22), flashMat);
      q2b.position.z = 0.25; q2b.rotation.y = Math.PI / 2;
      const front = new THREE.Mesh(new THREE.PlaneGeometry(0.42, 0.42), flashMat);
      g.add(q1, q2b, front);
      g.visible = false;
      g.userData.t = 0;
      g.renderOrder = 6;
      scene.add(g);
      this.flashes.push(g);
    }
    this.flashIdx = 0;
    this.lightsOn = quality.standardMaterials;
    this.muzzleLight = new THREE.PointLight(0xffa040, 0, 9, 2);
    this.boomLight = new THREE.PointLight(0xff7a20, 0, 22, 2);
    if (this.lightsOn) scene.add(this.muzzleLight, this.boomLight);

    // tracers
    const trGeo = new THREE.BoxGeometry(0.035, 0.035, 1);
    trGeo.translate(0, 0, -0.5);
    const trMat = new THREE.MeshBasicMaterial({ color: 0xffc860, transparent: true, opacity: 0.9, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false });
    this.tracers = [];
    for (let i = 0; i < 40; i++) {
      const m = new THREE.Mesh(trGeo, trMat);
      m.visible = false;
      m.userData = { from: new THREE.Vector3(), to: new THREE.Vector3(), t: 0, dur: 0, len: 3 };
      scene.add(m);
      this.tracers.push(m);
    }
    this.trIdx = 0;

    // shell casings (instanced, simple bounce physics)
    const shellGeo = new THREE.CylinderGeometry(0.008, 0.008, 0.035, 6);
    shellGeo.rotateX(Math.PI / 2);
    this.shellMesh = new THREE.InstancedMesh(shellGeo, new THREE.MeshStandardMaterial({ color: 0xc8a040, metalness: 0.9, roughness: 0.3 }), 48);
    this.shellMesh.frustumCulled = false;
    this.shells = [];
    for (let i = 0; i < 48; i++) this.shells.push({ p: new THREE.Vector3(), v: new THREE.Vector3(), r: new THREE.Euler(), w: new THREE.Vector3(), t: 99, s: 1, bounced: false });
    this.shellIdx = 0;
    this.shellMesh.count = 48;
    scene.add(this.shellMesh);
    this.onShellLand = null;

    // decals (scorch marks, acid puddles)
    const decalGeo = new THREE.PlaneGeometry(1, 1);
    decalGeo.rotateX(-Math.PI / 2);
    this.decals = [];
    const scorchMat = new THREE.MeshBasicMaterial({ map: Textures.scorch(), transparent: true, depthWrite: false, polygonOffset: true, polygonOffsetFactor: -2 });
    for (let i = 0; i < 14; i++) {
      const m = new THREE.Mesh(decalGeo, scorchMat.clone());
      m.visible = false;
      m.renderOrder = 1;
      scene.add(m);
      this.decals.push({ m, t: 0, life: 0 });
    }
    this.decalIdx = 0;

    // shockwave rings
    const ringGeo = new THREE.RingGeometry(0.85, 1, 48);
    ringGeo.rotateX(-Math.PI / 2);
    this.rings = [];
    for (let i = 0; i < 4; i++) {
      const m = new THREE.Mesh(ringGeo, new THREE.MeshBasicMaterial({ color: 0x66e6ff, transparent: true, blending: THREE.AdditiveBlending, depthWrite: false, side: THREE.DoubleSide, toneMapped: false }));
      m.visible = false;
      scene.add(m);
      this.rings.push({ m, t: 0, dur: 0, r: 0 });
    }
    // explosion fireballs
    const ballMat = new THREE.MeshBasicMaterial({ map: Textures.glow(), color: 0xffa040, transparent: true, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false });
    this.balls = [];
    for (let i = 0; i < 4; i++) {
      const s = new THREE.Sprite(ballMat.clone());
      s.visible = false;
      scene.add(s);
      this.balls.push({ s, t: 0, r: 0 });
    }
    this.lightT = 0;
    this.boomT = 0;
  }

  muzzleFlash(pos, quat, scale = 1) {
    const g = this.flashes[this.flashIdx++ % this.flashes.length];
    g.position.copy(pos);
    g.quaternion.copy(quat);
    g.rotateZ(Math.random() * Math.PI);
    g.scale.setScalar(scale * (0.8 + Math.random() * 0.4));
    g.visible = true;
    g.userData.t = 0.045;
    if (this.lightsOn) {
      this.muzzleLight.position.copy(pos);
      this.muzzleLight.intensity = 6 * scale;
      this.lightT = 0.05;
    }
    for (let i = 0; i < 3 * this.mul; i++) {
      tmpV.set((Math.random() - 0.5) * 0.6, (Math.random() - 0.5) * 0.6, 1).applyQuaternion(quat).multiplyScalar(2 + Math.random() * 3);
      this.add.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, 1, 0.75, 0.3, 1, 0.12, 0.05, 0.01, 0);
    }
    this.alpha.emit(pos.x, pos.y, pos.z, (Math.random() - 0.5) * 0.3, 0.4, (Math.random() - 0.5) * 0.3, 0.6, 0.6, 0.6, 0.18, 0.7, 0.12, 0.45, -0.3);
  }

  tracer(from, to, speed = 260) {
    const m = this.tracers[this.trIdx++ % this.tracers.length];
    const u = m.userData;
    u.from.copy(from); u.to.copy(to);
    const dist = from.distanceTo(to);
    u.dur = Math.max(0.03, dist / speed);
    u.t = 0;
    u.len = Math.min(4, dist * 0.5);
    m.visible = true;
    m.position.copy(from);
    m.lookAt(to);
  }

  shell(pos, dir, scale = 1) {
    const s = this.shells[this.shellIdx++ % this.shells.length];
    s.p.copy(pos);
    s.v.copy(dir).multiplyScalar(1.8 + Math.random()).add(tmpV.set((Math.random() - 0.5) * 0.6, 2 + Math.random(), (Math.random() - 0.5) * 0.6));
    s.w.set(Math.random() * 20, Math.random() * 20, Math.random() * 20);
    s.t = 0; s.s = scale; s.bounced = false;
  }

  impact(pos, normal, surface = 'dirt') {
    const c = SURFACE[surface] || SURFACE.dirt;
    const n = Math.max(2, Math.round(7 * this.mul));
    for (let i = 0; i < n; i++) {
      const k = Math.random();
      const col = k > 0.5 ? c[0] : c[1];
      tmpV.set(normal.x + (Math.random() - 0.5) * 1.4, normal.y + Math.random() * 0.8, normal.z + (Math.random() - 0.5) * 1.4).multiplyScalar(2.5 + Math.random() * 3);
      this.alpha.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, col[0], col[1], col[2], 0.95, 0.5 + Math.random() * 0.4, 0.05, 0.03, 9.8);
    }
    this.alpha.emit(pos.x, pos.y, pos.z, normal.x * 0.4, 0.5, normal.z * 0.4, c[1][0], c[1][1], c[1][2], 0.45, 0.9, 0.15, 0.6, -0.2);
    if (surface === 'rock' || surface === 'metal') {
      for (let i = 0; i < 4; i++) {
        tmpV.set(normal.x + (Math.random() - 0.5) * 2, normal.y + Math.random(), normal.z + (Math.random() - 0.5) * 2).multiplyScalar(4 + Math.random() * 4);
        this.add.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, 1, 0.8, 0.4, 1, 0.25, 0.04, 0.01, 9.8);
      }
    }
  }

  alienHit(pos, dir, color, big = false) {
    const col = new THREE.Color(color);
    const n = Math.round((big ? 16 : 8) * this.mul);
    for (let i = 0; i < n; i++) {
      tmpV.set(-dir.x + (Math.random() - 0.5) * 1.6, -dir.y + Math.random() * 1.2, -dir.z + (Math.random() - 0.5) * 1.6).multiplyScalar(2 + Math.random() * 4);
      this.add.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, col.r, col.g, col.b, 1, 0.35 + Math.random() * 0.3, 0.07, 0.02, 7);
    }
    for (let i = 0; i < Math.max(2, n / 3); i++) {
      tmpV.set((Math.random() - 0.5) * 2, Math.random() * 2, (Math.random() - 0.5) * 2);
      this.alpha.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, col.r * 0.5, col.g * 0.5, col.b * 0.5, 0.9, 0.7, 0.08, 0.05, 9.8);
    }
  }

  alienBurst(pos, color, scale = 1) {
    const col = new THREE.Color(color);
    const n = Math.round(40 * this.mul * scale);
    for (let i = 0; i < n; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() * 0.8, Math.random() - 0.5).normalize().multiplyScalar((2 + Math.random() * 5) * scale);
      this.add.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, col.r, col.g, col.b, 1, 0.5 + Math.random() * 0.5, 0.12 * scale, 0.02, 5);
    }
  }

  explosion(pos, radius = 6, ground = null) {
    const n = Math.round(60 * this.mul);
    for (let i = 0; i < n; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() * 0.9 + 0.1, Math.random() - 0.5).normalize().multiplyScalar(radius * (0.8 + Math.random() * 1.6));
      const hot = Math.random();
      this.add.emit(pos.x, pos.y + 0.3, pos.z, tmpV.x, tmpV.y, tmpV.z, 1, 0.45 + hot * 0.4, 0.1 + hot * 0.2, 1, 0.45 + Math.random() * 0.4, 0.9, 0.2, 2);
    }
    for (let i = 0; i < n * 0.5; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() * 0.8 + 0.4, Math.random() - 0.5).normalize().multiplyScalar(radius * (0.3 + Math.random() * 0.6));
      const g = 0.18 + Math.random() * 0.15;
      this.alpha.emit(pos.x, pos.y + 0.5, pos.z, tmpV.x, tmpV.y, tmpV.z, g, g, g, 0.65, 1.6 + Math.random() * 1.4, 1.0, 3.2, -0.4);
    }
    for (let i = 0; i < n * 0.3; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() + 0.5, Math.random() - 0.5).multiplyScalar(radius * 2);
      this.alpha.emit(pos.x, pos.y + 0.3, pos.z, tmpV.x, tmpV.y, tmpV.z, 0.2, 0.15, 0.1, 1, 1.2, 0.08, 0.06, 14);
    }
    const b = this.balls[Math.floor(Math.random() * this.balls.length)];
    b.s.visible = true; b.t = 0; b.r = radius;
    b.s.position.copy(pos).y += 0.8;
    if (this.lightsOn) {
      this.boomLight.position.copy(pos).y += 1.5;
      this.boomLight.intensity = 40;
      this.boomT = 0.35;
    }
    if (ground !== null) this.decal(pos.x, ground, pos.z, radius * 0.75, 'scorch', 25);
  }

  decal(x, y, z, size, kind = 'scorch', life = 20, color = null) {
    const d = this.decals[this.decalIdx++ % this.decals.length];
    d.m.position.set(x, y + 0.05, z);
    d.m.scale.set(size, 1, size);
    d.m.rotation.y = Math.random() * 6.28;
    d.m.material.color.set(color ?? 0xffffff);
    d.m.material.opacity = 1;
    d.m.material.blending = kind === 'acid' ? THREE.AdditiveBlending : THREE.NormalBlending;
    d.m.visible = true;
    d.t = 0; d.life = life;
  }

  shockwave(pos, radius, color = 0x66e6ff, dur = 0.6) {
    const r = this.rings.find((x) => !x.m.visible) || this.rings[0];
    r.m.position.copy(pos).y += 0.15;
    r.m.material.color.set(color);
    r.m.visible = true;
    r.t = 0; r.dur = dur; r.r = radius;
    const n = Math.round(30 * this.mul);
    for (let i = 0; i < n; i++) {
      const a = (i / n) * Math.PI * 2;
      this.alpha.emit(pos.x + Math.cos(a) * 0.8, pos.y + 0.2, pos.z + Math.sin(a) * 0.8, Math.cos(a) * radius * 1.2, 1.2, Math.sin(a) * radius * 1.2, 0.45, 0.38, 0.28, 0.7, 0.9, 0.5, 1.6, 2);
    }
  }

  acid(pos, n = 10) {
    for (let i = 0; i < n * this.mul; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() * 1.2, Math.random() - 0.5).multiplyScalar(4);
      this.add.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, 0.75, 1, 0.15, 1, 0.5 + Math.random() * 0.4, 0.09, 0.03, 9);
    }
  }

  trail(pos, color, size = 0.12) {
    const c = new THREE.Color(color);
    this.add.emit(pos.x, pos.y, pos.z, (Math.random() - 0.5) * 0.4, (Math.random() - 0.5) * 0.4, (Math.random() - 0.5) * 0.4, c.r, c.g, c.b, 0.9, 0.35, size, 0.01, 0);
  }

  smoke(pos, amount = 1) {
    for (let i = 0; i < 2 * amount; i++) {
      this.alpha.emit(pos.x, pos.y, pos.z, (Math.random() - 0.5) * 0.6, 0.8 + Math.random() * 0.6, (Math.random() - 0.5) * 0.6, 0.25, 0.25, 0.25, 0.4, 1.5, 0.3, 1.4, -0.2);
    }
  }

  dust(pos, amount = 1, color = [0.55, 0.47, 0.36]) {
    for (let i = 0; i < 3 * amount; i++) {
      this.alpha.emit(pos.x + (Math.random() - 0.5) * 0.3, pos.y + 0.05, pos.z + (Math.random() - 0.5) * 0.3, (Math.random() - 0.5) * 1.2, 0.3 + Math.random() * 0.5, (Math.random() - 0.5) * 1.2, color[0], color[1], color[2], 0.4, 0.8, 0.15, 0.6, 0);
    }
  }

  splash(pos) {
    for (let i = 0; i < 10 * this.mul; i++) {
      tmpV.set((Math.random() - 0.5) * 2, 2 + Math.random() * 2, (Math.random() - 0.5) * 2);
      this.alpha.emit(pos.x, pos.y, pos.z, tmpV.x, tmpV.y, tmpV.z, 0.85, 0.92, 1, 0.8, 0.6, 0.06, 0.03, 9.8);
    }
  }

  portal(pos, color, height = 2) {
    const c = new THREE.Color(color);
    for (let i = 0; i < 26 * this.mul; i++) {
      const a = Math.random() * Math.PI * 2, r = 0.4 + Math.random() * 0.8;
      this.add.emit(pos.x + Math.cos(a) * r, pos.y + Math.random() * 0.3, pos.z + Math.sin(a) * r, -Math.cos(a) * 0.5, height * (0.6 + Math.random()), -Math.sin(a) * 0.5, c.r, c.g, c.b, 1, 0.9, 0.16, 0.02, 0);
    }
    this.dust(pos, 3, [0.3, 0.25, 0.2]);
  }

  sparkle(pos, color) {
    const c = new THREE.Color(color);
    for (let i = 0; i < 14 * this.mul; i++) {
      tmpV.set(Math.random() - 0.5, Math.random() * 1.5, Math.random() - 0.5).multiplyScalar(2.5);
      this.add.emit(pos.x, pos.y + 0.4, pos.z, tmpV.x, tmpV.y, tmpV.z, c.r, c.g, c.b, 1, 0.6, 0.1, 0.02, 2);
    }
  }

  update(dt, camera, viewportH) {
    this.add.update(dt, viewportH, camera.fov);
    this.alpha.update(dt, viewportH, camera.fov);
    for (const f of this.flashes) {
      if (!f.visible) continue;
      f.userData.t -= dt;
      if (f.userData.t <= 0) f.visible = false;
    }
    if (this.lightsOn) {
      this.lightT -= dt;
      if (this.lightT <= 0) this.muzzleLight.intensity = 0;
      this.boomT -= dt;
      this.boomLight.intensity = this.boomT > 0 ? 40 * (this.boomT / 0.35) : 0;
    }
    for (const m of this.tracers) {
      if (!m.visible) continue;
      const u = m.userData;
      u.t += dt;
      const k = u.t / u.dur;
      if (k >= 1) { m.visible = false; continue; }
      m.position.lerpVectors(u.from, u.to, Math.min(1, k + 0.15));
      m.scale.set(1, 1, u.len);
    }
    const mtx = new THREE.Matrix4();
    let anyShell = false;
    for (let i = 0; i < this.shells.length; i++) {
      const s = this.shells[i];
      if (s.t > 1.6) { mtx.makeScale(0, 0, 0); this.shellMesh.setMatrixAt(i, mtx); continue; }
      anyShell = true;
      s.t += dt;
      if (!s.bounced || s.v.lengthSq() > 0.01) {
        s.v.y -= 14 * dt;
        s.p.addScaledVector(s.v, dt);
        s.r.x += s.w.x * dt; s.r.y += s.w.y * dt; s.r.z += s.w.z * dt;
        if (this.groundAt) {
          const gy = this.groundAt(s.p.x, s.p.z);
          if (s.p.y < gy + 0.01) {
            s.p.y = gy + 0.01;
            if (!s.bounced && this.onShellLand) this.onShellLand(s.p);
            s.bounced = true;
            s.v.multiplyScalar(0.3); s.v.y = Math.abs(s.v.y) * 0.4; s.w.multiplyScalar(0.4);
          }
        }
      }
      tmpQ.setFromEuler(s.r);
      mtx.compose(s.p, tmpQ, tmpV.set(s.s, s.s, s.s));
      this.shellMesh.setMatrixAt(i, mtx);
    }
    if (anyShell || this._shellsWereVisible) this.shellMesh.instanceMatrix.needsUpdate = true;
    this._shellsWereVisible = anyShell;
    for (const d of this.decals) {
      if (!d.m.visible) continue;
      d.t += dt;
      if (d.t > d.life) d.m.visible = false;
      else if (d.t > d.life - 3) d.m.material.opacity = (d.life - d.t) / 3;
    }
    for (const r of this.rings) {
      if (!r.m.visible) continue;
      r.t += dt;
      const k = r.t / r.dur;
      if (k >= 1) { r.m.visible = false; continue; }
      const s = 0.5 + r.r * k;
      r.m.scale.set(s, 1, s);
      r.m.material.opacity = 1 - k;
    }
    for (const b of this.balls) {
      if (!b.s.visible) continue;
      b.t += dt;
      const k = b.t / 0.45;
      if (k >= 1) { b.s.visible = false; continue; }
      b.s.scale.setScalar(b.r * (0.5 + k * 1.3));
      b.s.material.opacity = 1 - k * k;
    }
  }
}

export { Z };
