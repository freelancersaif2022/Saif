// Physical projectiles: bouncing frag grenades with a fuse, and arcing acid
// globs that splash and leave a damaging puddle.
import * as THREE from 'three';
import { grenadeModel } from '../actors/models.js';
import { GRENADE } from '../core/config.js';
import { Textures } from '../render/textures.js';

const _n = new THREE.Vector3();

export class Projectiles {
  constructor(game) {
    this.game = game;
    this.list = [];
    this.puddles = [];
    this.grenadePool = [];
    this.acidPool = [];
    this.acidMat = new THREE.MeshBasicMaterial({ color: 0xc8ff2a, toneMapped: false });
    this.acidGeo = new THREE.SphereGeometry(0.16, 10, 8);
    this.puddleMat = new THREE.MeshBasicMaterial({ map: Textures.glow(), color: 0x9dff2e, transparent: true, opacity: 0.6, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false });
    this.puddleGeo = new THREE.PlaneGeometry(1, 1).rotateX(-Math.PI / 2);
  }

  grenade(from, vel, owner) {
    const g = this.game;
    let mesh = this.grenadePool.pop();
    if (!mesh) { mesh = grenadeModel(); mesh.scale.setScalar(1.6); }
    mesh.visible = true;
    g.scene.add(mesh);
    this.list.push({ kind: 'grenade', mesh, pos: from.clone(), vel: vel.clone(), fuse: GRENADE.fuse, owner, spin: new THREE.Vector3(8, 3, 5), bounces: 0 });
    g.stats.grenadesThrown++;
  }

  acid(from, target, damage, owner) {
    const g = this.game;
    let mesh = this.acidPool.pop();
    if (!mesh) mesh = new THREE.Mesh(this.acidGeo, this.acidMat);
    mesh.visible = true;
    g.scene.add(mesh);
    // ballistic arc reaching the target in time T
    const d = target.clone().sub(from);
    const flat = Math.hypot(d.x, d.z);
    const T = Math.max(0.5, flat / 16);
    const grav = 12;
    const vel = new THREE.Vector3(d.x / T, (d.y + 0.5 * grav * T * T) / T, d.z / T);
    this.list.push({ kind: 'acid', mesh, pos: from.clone(), vel, grav, damage, owner, life: 4 });
  }

  update(dt) {
    const g = this.game, W = g.world, P = g.player;
    for (let i = this.list.length - 1; i >= 0; i--) {
      const p = this.list[i];
      if (p.kind === 'grenade') {
        p.vel.y -= 18 * dt;
        const prev = p.pos.clone();
        p.pos.addScaledVector(p.vel, dt);
        // obstacles
        const sp = p.vel.length();
        if (sp > 0.01) {
          const c = W.colliders.raycast(prev.x, prev.y, prev.z, p.vel.x / sp, p.vel.y / sp, p.vel.z / sp, sp * dt + 0.1, (k) => k.kind !== 'rail');
          if (c) {
            _n.set(prev.x - c.collider.x, 0, prev.z - c.collider.z).normalize();
            p.pos.copy(prev);
            p.vel.reflect(_n).multiplyScalar(0.45);
            if (p.bounces++ < 6) g.sfx('grenade_bounce', p.pos, 0.8);
          }
        }
        const gy = W.groundHeight(p.pos.x, p.pos.z, p.pos.y);
        if (p.pos.y < gy + 0.08) {
          p.pos.y = gy + 0.08;
          W.field.normal(p.pos.x, p.pos.z, _n);
          if (p.vel.y < -1.5 && p.bounces++ < 6) g.sfx('grenade_bounce', p.pos, 0.7);
          p.vel.reflect(_n).multiplyScalar(0.42);
          p.spin.multiplyScalar(0.6);
        }
        p.mesh.position.copy(p.pos);
        p.mesh.rotation.x += p.spin.x * dt; p.mesh.rotation.y += p.spin.y * dt; p.mesh.rotation.z += p.spin.z * dt;
        if (Math.random() < 0.5) g.fx.trail(p.pos, 0xff5020, 0.05);
        p.fuse -= dt;
        if (p.fuse <= 0) {
          g.combat.explode(p.pos.clone().setY(p.pos.y + 0.3), GRENADE.radius, GRENADE.damage * (g.player.damageMul || 1), 'player');
          this._release(p, i);
        }
      } else if (p.kind === 'acid') {
        p.vel.y -= p.grav * dt;
        p.pos.addScaledVector(p.vel, dt);
        p.life -= dt;
        p.mesh.position.copy(p.pos);
        if (Math.random() < 0.7) g.fx.trail(p.pos, 0xc8ff2a, 0.14);
        let hit = false;
        const pd = Math.hypot(P.pos.x - p.pos.x, P.pos.y + 1 - p.pos.y, P.pos.z - p.pos.z);
        if (P.alive && pd < 0.9) { P.takeDamage(p.damage, p.pos, 'acid'); hit = true; }
        const gy = W.groundHeight(p.pos.x, p.pos.z);
        if (!hit && p.pos.y < gy + 0.1) hit = true;
        if (!hit && W.colliders.blocked(p.pos.x, p.pos.z, 0.1)) hit = true;
        if (hit || p.life <= 0) {
          g.fx.acid(p.pos, 14);
          g.sfx('acid_splash', p.pos, 1);
          if (p.pos.y - gy < 1.5) this._puddle(p.pos.x, gy, p.pos.z, p.damage);
          this._release(p, i);
        }
      }
    }
    // acid puddles burn whoever stands in them
    for (let i = this.puddles.length - 1; i >= 0; i--) {
      const pu = this.puddles[i];
      pu.t += dt;
      pu.tick -= dt;
      pu.mesh.material.opacity = 0.6 * Math.min(1, (4 - pu.t) / 1);
      if (pu.tick <= 0 && P.alive && Math.hypot(P.pos.x - pu.x, P.pos.z - pu.z) < 1.1 && P.pos.y - pu.y < 0.5) {
        pu.tick = 0.5;
        P.takeDamage(pu.dps * 0.5, null, 'acid');
      }
      if (Math.random() < dt * 6) g.fx.trail(new THREE.Vector3(pu.x + (Math.random() - 0.5), pu.y + 0.05, pu.z + (Math.random() - 0.5)), 0x9dff2e, 0.08);
      if (pu.t > 4) { pu.mesh.visible = false; this.puddles.splice(i, 1); }
    }
  }

  _puddle(x, y, z, dmg) {
    const g = this.game;
    let pu = this.puddles.length > 6 ? this.puddles.shift() : null;
    const mesh = pu ? pu.mesh : new THREE.Mesh(this.puddleGeo, this.puddleMat.clone());
    mesh.visible = true;
    mesh.position.set(x, y + 0.06, z);
    mesh.scale.set(2.4, 1, 2.4);
    if (!mesh.parent) g.scene.add(mesh);
    this.puddles.push({ mesh, x, y, z, t: 0, tick: 0.3, dps: dmg * 0.6 });
  }

  _release(p, i) {
    p.mesh.visible = false;
    (p.kind === 'grenade' ? this.grenadePool : this.acidPool).push(p.mesh);
    this.list.splice(i, 1);
  }

  clear() {
    for (let i = this.list.length - 1; i >= 0; i--) this._release(this.list[i], i);
    for (const pu of this.puddles) pu.mesh.visible = false;
    this.puddles.length = 0;
  }
}
