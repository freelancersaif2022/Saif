// Alien enemies: pooled skinned-mesh actors with a finite-state machine AI
// (spawn -> chase -> attack / special -> dead), flow-field navigation,
// separation, per-type behaviours and bone-attached hit spheres.
import * as THREE from 'three';
import { ENEMIES } from '../core/config.js';
import { alienTemplate } from '../actors/models.js';
import { instantiate } from '../actors/skeleton.js';
import { Animator, CLIPSETS } from '../actors/anim.js';
import { clamp, damp, dampAngle, raySphere, wrapAngle } from '../core/math.js';
import { Textures } from '../render/textures.js';
import { WATER_Y } from '../world/terrain.js';

const _v = new THREE.Vector3(), _w = new THREE.Vector3(), _flow = { x: 0, z: 0 }, _cf = new THREE.Vector3();

// [bone, radius, part]
const HIT = {
  humanoid: [['head', 0.17, 'head', 0.1], ['chest', 0.3, 'body', 0.12], ['spine', 0.22, 'body', 0.05], ['hips', 0.22, 'body', 0], ['thighL', 0.12, 'limb', -0.2], ['thighR', 0.12, 'limb', -0.2], ['shinL', 0.1, 'limb', -0.2], ['shinR', 0.1, 'limb', -0.2], ['foreL', 0.1, 'limb', -0.1], ['foreR', 0.1, 'limb', -0.1]],
  brute: [['head', 0.2, 'head', 0.06], ['chest', 0.5, 'body', 0.12], ['spine', 0.32, 'body', 0.08], ['hips', 0.3, 'body', 0], ['thighL', 0.18, 'limb', -0.16], ['thighR', 0.18, 'limb', -0.16], ['shinL', 0.15, 'limb', -0.16], ['shinR', 0.15, 'limb', -0.16], ['foreL', 0.18, 'limb', -0.16], ['foreR', 0.18, 'limb', -0.16]],
  crawler: [['head', 0.16, 'head', 0.06], ['chest', 0.24, 'body', 0.1], ['spine', 0.22, 'body', 0.15], ['hips', 0.2, 'body', 0], ['tail', 0.12, 'limb', 0]],
  bloater: [['head', 0.13, 'head', 0.06], ['spine', 0.34, 'body', 0.12], ['chest', 0.28, 'body', 0.05], ['thighL', 0.11, 'limb', -0.15], ['thighR', 0.11, 'limb', -0.15]],
  flyer: [['head', 0.15, 'head', 0.1], ['chest', 0.26, 'body', 0.1], ['spine', 0.2, 'body', 0.05], ['hips', 0.18, 'body', 0], ['wingL', 0.3, 'limb', 0], ['wingR', 0.3, 'limb', 0]],
};
const PART_MUL = { head: 2.2, body: 1, limb: 0.75 };

let glowTex = null;

export class Enemy {
  constructor(game, def) {
    this.game = game;
    this.def = def;
    this.inst = instantiate(alienTemplate(def), true);
    this.mesh = this.inst.mesh;
    this.mesh.castShadow = game.quality.enemyShadows;
    this.anim = new Animator(this.inst, CLIPSETS[def.rig]);
    this.bodyMat = this.mesh.material[0];
    this.glowMat = this.mesh.material[1];
    this.glowColor = new THREE.Color(def.colors[2]);
    if (game.quality.standardMaterials) {
      if (!glowTex) glowTex = Textures.glow();
      this.glowSprite = new THREE.Sprite(new THREE.SpriteMaterial({ map: glowTex, color: this.glowColor, blending: THREE.AdditiveBlending, depthWrite: false, transparent: true, opacity: 0.7, toneMapped: false }));
      const chest = this.inst.b.chest;
      const s = def.rig === 'brute' ? 0.9 : def.rig === 'bloater' ? 1.1 : 0.55;
      this.glowSprite.scale.setScalar(s);
      this.glowSprite.position.set(0, def.rig === 'crawler' ? 0.05 : 0.15, def.rig === 'brute' ? 0.32 : 0.2);
      chest.add(this.glowSprite);
    }
    this.hitDefs = HIT[def.rig] || HIT.humanoid;
    this.spheres = this.hitDefs.map(() => new THREE.Vector3());
    this.hitFrame = -1;
    this.pos = new THREE.Vector3();
    this.vel = new THREE.Vector3();
    this.alive = false;
    this.active = false;
  }

  reset(pos, level, opts = {}) {
    const def = this.def;
    const g = this.game;
    this.pos.copy(pos);
    this.vel.set(0, 0, 0);
    this.scale = def.scale * (opts.scaleMul || 1);
    this.maxHp = def.hp * level.hp * (opts.hpMul || 1);
    this.hp = this.maxHp;
    this.dmgMul = level.dmg;
    this.speedMul = level.speed;
    this.alive = true;
    this.active = true;
    this.state = 'spawn';
    this.stateT = 0;
    this.attackCd = 1 + Math.random();
    this.specialCd = 4 + Math.random() * 3;
    this.special2Cd = 9;
    this.dodgeCd = 2;
    this.side = 1;
    this.flash = 0;
    this.deadT = 0;
    this.phase = Math.random() * 6;
    this.growlT = 2 + Math.random() * 5;
    this.stepAcc = 0;
    this.knock = new THREE.Vector3();
    this.strafeSign = Math.random() < 0.5 ? -1 : 1;
    this.stuckT = 0; this.detour = 0;
    this.lastProgress = Infinity;
    this.fuse = -1;
    this.summoned = 0;
    this.altitude = def.behavior === 'flyer' ? 4.5 + Math.random() * 2 : 0;
    this.y0 = g.world.groundHeight(pos.x, pos.z);
    this.pos.y = this.y0 + this.altitude;
    this.yaw = Math.atan2(g.player.pos.x - pos.x, g.player.pos.z - pos.z);
    this.mesh.scale.setScalar(this.scale);
    this.mesh.position.copy(this.pos);
    this.mesh.rotation.set(0, this.yaw, 0);
    this.mesh.visible = true;
    this.bodyMat.emissive.setRGB(0, 0, 0);
    this.bodyMat.transparent = false; this.bodyMat.opacity = 1;
    if (this.glowSprite) this.glowSprite.visible = true;
    this.anim.additive.length = 0;
    this.anim.cur = null; this.anim.prev = null;
    this.anim.play('spawn', 0, true);
    this.animAcc = 0;
    if (!this.mesh.parent) g.scene.add(this.mesh);
    if (!g.quietSpawn) {
      g.fx.portal(this.pos, def.colors[2], def.rig === 'brute' ? 3 : 2);
      g.sfx('spawn_portal', this.pos, 0.9);
    }
    if (def.behavior === 'boss') {
      this.state = 'roar'; this.stateT = 0; this.anim.play('roar', 0.2, true);
      g.sfx('boss_roar', this.pos, 1, 30);
    }
  }

  get height() { return this.def.height * this.scale; }

  updateSpheres() {
    if (this.hitFrame === this.game.frame) return;
    this.hitFrame = this.game.frame;
    this.mesh.updateMatrixWorld(true);
    for (let i = 0; i < this.hitDefs.length; i++) {
      const [bone, , , off] = this.hitDefs[i];
      const b = this.inst.b[bone];
      this.spheres[i].set(0, off, 0).applyMatrix4(b.matrixWorld);
    }
  }

  rayHit(o, d, maxT) {
    // cheap reject with the bounding sphere
    const cy = this.pos.y + this.height * 0.5;
    const R = Math.max(this.height * 0.7, this.def.radius * this.scale * 2.2);
    if (raySphere(o.x, o.y, o.z, d.x, d.y, d.z, this.pos.x, cy, this.pos.z, R) < 0) return null;
    this.updateSpheres();
    let best = maxT, part = null;
    for (let i = 0; i < this.hitDefs.length; i++) {
      const s = this.spheres[i];
      const r = this.hitDefs[i][1] * this.scale;
      const t = raySphere(o.x, o.y, o.z, d.x, d.y, d.z, s.x, s.y, s.z, r);
      if (t >= 0 && t < best) { best = t; part = this.hitDefs[i][2]; }
    }
    return part ? { enemy: this, t: best, part } : null;
  }

  center(out) {
    this.updateSpheres();
    return out.copy(this.spheres[1]);
  }

  knockback(dir, amount) {
    const m = this.def.behavior === 'tank' || this.def.behavior === 'boss' ? 0.15 : 1;
    this.knock.addScaledVector(dir, amount * m);
  }

  damage(amount, point, dir, part = 'body', opts = {}) {
    if (!this.alive) return false;
    const g = this.game;
    const def = this.def;
    let mul = PART_MUL[part] || 1;
    if (!opts.explosive && !opts.armorPiercing) mul *= def.resist;
    if (def.behavior === 'tank' && opts.weapon === 'sniper') mul *= 1.2;
    const dmg = amount * mul;
    this.hp -= dmg;
    this.flash = 0.12;
    g.fx.alienHit(point, dir, def.colors[2], dmg > 60);
    g.sfx('impact_flesh', point, 0.9);
    if (part === 'head') g.sfx('headshot', null, 0.7);
    if (Math.random() < 0.25) g.sfx(Math.random() < 0.5 ? 'alien_hurt_1' : 'alien_hurt_2', this.pos, 0.8, this.def.rig === 'brute' ? 0.7 : 1.1);
    this.anim.impulse('hit', Math.min(1, dmg / 40 + 0.3), 5);
    g.director.onDamage(this, dmg);
    if (this.state === 'spawn') { this.state = 'chase'; this.stateT = 0; }
    // heavy hits stagger light aliens
    if (dmg > this.maxHp * 0.35 && def.behavior !== 'tank' && def.behavior !== 'boss' && this.state !== 'attack') {
      this.knock.addScaledVector(dir, 2);
    }
    if (this.hp <= 0) { this.die(opts); return true; }
    return false;
  }

  die(opts = {}) {
    const g = this.game;
    this.alive = false;
    this.state = 'dead';
    this.stateT = 0;
    this.deadT = 0;
    this.anim.play('death', 0.12, true);
    g.sfx(Math.random() < 0.5 ? 'alien_death_1' : 'alien_death_2', this.pos, 1, this.def.rig === 'brute' ? 0.65 : this.def.rig === 'crawler' ? 1.3 : 1);
    const c = this.pos.clone(); c.y += this.height * 0.5;
    g.fx.alienBurst(c, this.def.colors[2], this.def.behavior === 'boss' ? 3 : 1);
    if (this.glowSprite) this.glowSprite.visible = false;
    if (this.def.behavior === 'exploder') {
      this.mesh.visible = false;
      g.combat.explode(c, 4.5, this.def.damage * this.dmgMul, 'enemy', { ignore: this });
    }
    if (this.def.behavior === 'boss') { g.camRig.shake(0.8); g.sfx('boss_roar', this.pos, 1, 30); }
    g.director.onKill(this, opts);
  }

  // --------------------------------------------------------------- AI ----
  update(dt) {
    const g = this.game;
    const def = this.def;
    const P = g.player;
    this.stateT += dt;
    this.flash = Math.max(0, this.flash - dt);
    if (this.flash > 0) this.bodyMat.emissive.copy(this.glowColor).multiplyScalar(this.flash * 5);
    else if (this.fuse >= 0) this.bodyMat.emissive.copy(this.glowColor).multiplyScalar(0.5 + 0.5 * Math.sin(this.stateT * 30));
    else this.bodyMat.emissive.setRGB(0, 0, 0);

    if (this.state === 'dead') return this._updateDead(dt);

    const toX = P.pos.x - this.pos.x, toZ = P.pos.z - this.pos.z;
    const dist = Math.hypot(toX, toZ);
    this.dist = dist;
    const dirX = toX / (dist || 1), dirZ = toZ / (dist || 1);
    let moveX = 0, moveZ = 0, speed = 0, faceYaw = Math.atan2(dirX, dirZ), gait = 0;
    const playerAlive = P.alive;
    const reach = def.range * this.scale + 0.4;
    this.attackCd -= dt; this.specialCd -= dt; this.special2Cd -= dt; this.dodgeCd -= dt;

    // growls
    this.growlT -= dt;
    if (this.growlT <= 0) {
      this.growlT = 4 + Math.random() * 6;
      if (dist < 45) g.sfx(`growl_${1 + Math.floor(Math.random() * 3)}`, this.pos, 0.9, def.rig === 'brute' ? 0.6 : def.rig === 'crawler' ? 1.4 : 1);
    }

    switch (this.state) {
      case 'spawn':
        if (this.stateT > 1.0) { this.state = 'chase'; this.stateT = 0; }
        break;
      case 'roar':
        if (this.stateT > 1.3) { this.state = 'chase'; this.stateT = 0; }
        break;
      case 'attack': {
        const dur = this.attackDur;
        this.anim.ctx.attackT = this.stateT / dur;
        faceYaw = this.attackYaw ?? faceYaw;
        if (!this.hitDone && this.stateT >= dur * this.hitAt) {
          this.hitDone = true;
          this._resolveAttack(dist);
        }
        if (this.lunge) {
          moveX = this.lunge.x; moveZ = this.lunge.z; speed = this.lunge.s * (1 - this.stateT / dur);
        }
        if (this.stateT >= dur) { this.state = 'chase'; this.stateT = 0; this.lunge = null; }
        break;
      }
      case 'chase':
      default: {
        if (!playerAlive) {
          // wander and roar over the fallen soldier
          gait = 0; speed = 0;
          if (this.stateT > 2 && Math.random() < 0.01) { this.anim.play('roar', 0.2, true); }
          break;
        }
        const b = def.behavior;
        gait = dist > 16 && b !== 'fast' && b !== 'crawler' ? 0.25 : 1;
        speed = (gait > 0.5 ? def.run : def.walk) * this.speedMul;
        // navigation
        if (b === 'flyer') {
          this._flyer(dt, dist, dirX, dirZ);
          return this._finish(dt, this.fx, this.fz, this.fs, Math.atan2(dirX, dirZ), 1);
        }
        let nx = dirX, nz = dirZ;
        if (dist > 3 && g.flow.direction(this.pos.x, this.pos.z, _flow)) { nx = _flow.x; nz = _flow.z; }
        // behaviour-specific movement
        if (b === 'spitter') {
          if (dist < 9) { nx = -dirX; nz = -dirZ; speed = def.walk * this.speedMul; gait = 0.3; }
          else if (dist < 17) { nx = -dirZ * this.strafeSign; nz = dirX * this.strafeSign; speed = def.walk * 0.7 * this.speedMul; gait = 0.25; if (Math.random() < 0.005) this.strafeSign *= -1; }
          if (this.attackCd <= 0 && dist < 24 && dist > 5 && this._los()) this._startAttack('spit', 1.0, 0.6);
        } else if (b === 'crawler') {
          const zig = Math.sin(this.stateT * 4 + this.phase) * 0.6;
          if (dist > 5) { nx += -nz * zig; nz += nx * zig; }
          if (dist < 5 && this.attackCd <= 0) this._startAttack('attack', 0.75, 0.45, { lunge: 9 });
        } else if (b === 'fast') {
          // dodge when the player aims at it
          if (this.dodgeCd <= 0 && dist < 26 && P.aiming) {
            g.camera.getWorldDirection(_cf);
            const ex = this.pos.x - g.camera.position.x, ez = this.pos.z - g.camera.position.z;
            const l = Math.hypot(ex, ez) || 1;
            if ((_cf.x * ex + _cf.z * ez) / l > 0.985) {
              this.dodgeCd = 2.5 + Math.random() * 2;
              this.strafeSign = Math.random() < 0.5 ? -1 : 1;
              this.knock.set(-dirZ * this.strafeSign * 8, 0, dirX * this.strafeSign * 8);
            }
          }
          if (dist < 12 && dist > 4 && this.specialCd <= 0) { this.specialCd = 4; this.chargeT = 0.8; }
          if (this.chargeT > 0) { this.chargeT -= dt; speed *= 1.7; }
        } else if (b === 'exploder') {
          if (dist < 2.4 && this.fuse < 0) { this.fuse = 0.7; g.sfx('bloater_beep', this.pos, 1); }
        } else if (b === 'tank') {
          if (dist < 9 && this.specialCd <= 0 && this._los()) { this.specialCd = 7; this._startAttack('slam', 1.4, 0.55, { slam: 7.5 }); }
        } else if (b === 'elite') {
          if (dist < 10 && dist > 4 && this.specialCd <= 0) { this.specialCd = 5; this.knock.set(dirX * 10, 0, dirZ * 10); g.fx.trail(this.pos.clone().setY(this.pos.y + 1), def.colors[2], 0.4); }
        } else if (b === 'boss') {
          this._boss(dt, dist, dirX, dirZ);
        }
        if (this.fuse >= 0) {
          this.fuse -= dt;
          if (this.fuse < 0) {
            this.hp = 0;
            this.die({ selfDestruct: true });
            return;
          }
        }
        if (this.state === 'chase' && dist < reach && this.attackCd <= 0 && b !== 'spitter' && b !== 'exploder') {
          if (b === 'tank' || b === 'boss') this._startAttack('attack', 1.3, 0.62);
          else this._startAttack('attack', b === 'fast' ? 0.6 : 0.85, 0.55);
        }
        // stop at melee range
        if (dist < reach * 0.8 && b !== 'spitter') speed = 0;
        // stuck detection: try a detour sideways
        if (speed > 0) {
          if (dist < this.lastProgress - 0.5) { this.lastProgress = dist; this.stuckT = 0; }
          else this.stuckT += dt;
          if (this.stuckT > 1.5) { this.detour = 1.2; this.stuckT = 0; this.lastProgress = dist; this.strafeSign *= -1; }
        }
        if (this.detour > 0) { this.detour -= dt; const tx = -nz * this.strafeSign, tz = nx * this.strafeSign; nx = tx * 0.8 + nx * 0.2; nz = tz * 0.8 + nz * 0.2; }
        const l = Math.hypot(nx, nz) || 1;
        moveX = nx / l; moveZ = nz / l;
        if (b !== 'spitter' || dist > 17) faceYaw = Math.atan2(moveX, moveZ);
        if (dist < 6) faceYaw = Math.atan2(dirX, dirZ);
      }
    }
    this._finish(dt, moveX, moveZ, speed, faceYaw, gait);
  }

  _los() {
    const g = this.game, P = g.player;
    const o = _v.set(this.pos.x, this.pos.y + this.height * 0.7, this.pos.z);
    const d = _w.set(P.pos.x, P.pos.y + 1.2, P.pos.z).sub(o);
    const len = d.length();
    d.multiplyScalar(1 / len);
    const hit = g.world.colliders.raycast(o.x, o.y, o.z, d.x, d.y, d.z, len, (c) => c.kind !== 'rail');
    if (hit) return false;
    const t = g.world.raycastTerrain(o, d, len);
    return t < 0;
  }

  _startAttack(clip, dur, hitAt, opts = {}) {
    this.state = 'attack';
    this.stateT = 0;
    this.attackDur = dur;
    this.hitAt = hitAt;
    this.hitDone = false;
    this.attackKind = opts.slam ? 'slam' : clip === 'spit' ? 'spit' : opts.volley ? 'volley' : 'melee';
    this.slamRadius = opts.slam || 0;
    this.side = -this.side;
    this.anim.ctx.side = this.side;
    this.anim.play(clip, 0.12, true);
    this.attackCd = this.def.cooldown * (0.8 + Math.random() * 0.4);
    const P = this.game.player;
    this.attackYaw = Math.atan2(P.pos.x - this.pos.x, P.pos.z - this.pos.z);
    if (opts.lunge) {
      const dx = P.pos.x - this.pos.x, dz = P.pos.z - this.pos.z, l = Math.hypot(dx, dz) || 1;
      this.lunge = { x: dx / l, z: dz / l, s: opts.lunge };
    }
    if (this.attackKind === 'melee') this.game.sfx('alien_attack', this.pos, 0.9, this.def.rig === 'brute' ? 0.7 : 1.1);
  }

  _resolveAttack(dist) {
    const g = this.game, P = g.player, def = this.def;
    if (!P.alive) return;
    const dmg = def.damage * this.dmgMul;
    if (this.attackKind === 'volley') {
      const o = this.center(_v).clone(); o.y += 1;
      const dx = (P.pos.x - this.pos.x) / (dist || 1), dz = (P.pos.z - this.pos.z) / (dist || 1);
      for (let i = -2; i <= 2; i++) {
        const t = P.pos.clone();
        t.x += -dz * i * 2.2; t.z += dx * i * 2.2; t.y += 1;
        g.projectiles.acid(o, t, dmg * 0.35, this);
      }
      g.sfx('acid_spit', this.pos, 1, 12);
    } else if (this.attackKind === 'spit') {
      const o = this.center(_v).clone();
      o.y += 0.3;
      g.projectiles.acid(o, P.pos.clone().setY(P.pos.y + 1.0), dmg, this);
      g.sfx('acid_spit', this.pos, 1);
    } else if (this.attackKind === 'slam') {
      const ground = g.world.groundHeight(this.pos.x, this.pos.z);
      g.fx.shockwave(new THREE.Vector3(this.pos.x, ground, this.pos.z), this.slamRadius, def.colors[2]);
      g.sfx('boss_slam', this.pos, 1, 10);
      g.sfx('shockwave', this.pos, 1, 10);
      g.camRig.shake(Math.max(0.15, 0.7 - dist / 25));
      if (dist < this.slamRadius && P.onGround) P.takeDamage(dmg * 0.9, this.pos, 'shockwave');
    } else {
      const reach = def.range * this.scale + 0.9;
      // must be roughly facing the player
      const fx = Math.sin(this.yaw), fz = Math.cos(this.yaw);
      const dx = (P.pos.x - this.pos.x) / (dist || 1), dz = (P.pos.z - this.pos.z) / (dist || 1);
      if (dist < reach && fx * dx + fz * dz > 0.3 && Math.abs(P.pos.y - this.pos.y) < 2 + this.height * 0.3) {
        P.takeDamage(dmg, this.pos, 'melee');
        if (def.behavior === 'tank' || def.behavior === 'boss') {
          P.vel.x += dx * 8; P.vel.z += dz * 8; P.vel.y += 3;
          g.sfx('boss_slam', this.pos, 0.8, 10);
        }
      }
    }
  }

  _flyer(dt, dist, dirX, dirZ) {
    const g = this.game, P = g.player;
    // circle at a distance, then dive
    this.diveCd = (this.diveCd ?? 3) - dt;
    if (this.diving) {
      const tx = P.pos.x - this.pos.x, ty = P.pos.y + 1.2 - this.pos.y, tz = P.pos.z - this.pos.z;
      const l = Math.hypot(tx, ty, tz) || 1;
      this.fx = tx / l; this.fz = tz / l; this.fs = 12 * this.speedMul;
      this.altitudeVel = (ty / l) * 12;
      this.diveT += dt;
      if (l < 1.6) {
        P.takeDamage(this.def.damage * this.dmgMul, this.pos, 'melee');
        this.diving = false; this.diveCd = 3 + Math.random() * 2;
      }
      if (this.diveT > 2.5) { this.diving = false; this.diveCd = 2; }
      this.anim.ctx.attackT = Math.min(1, this.diveT / 1.2);
      this.anim.play('attack', 0.15);
    } else {
      const r = 9;
      const ang = Math.atan2(this.pos.x - P.pos.x, this.pos.z - P.pos.z) + this.strafeSign * 0.8;
      const tx = P.pos.x + Math.sin(ang) * r - this.pos.x, tz = P.pos.z + Math.cos(ang) * r - this.pos.z;
      const l = Math.hypot(tx, tz) || 1;
      this.fx = tx / l; this.fz = tz / l; this.fs = Math.min(this.def.walk, l * 2) * this.speedMul;
      const wantY = this.game.world.groundHeight(this.pos.x, this.pos.z) + this.altitude;
      this.altitudeVel = (wantY - this.pos.y) * 2;
      if (this.diveCd <= 0 && dist < 18) { this.diving = true; this.diveT = 0; this.game.sfx('wing_flap', this.pos, 1); }
      this.anim.play(dist > 12 ? 'move' : 'idle', 0.2);
    }
    if (Math.random() < dt * 1.5) this.game.sfx('wing_flap', this.pos, 0.5);
  }

  _boss(dt, dist, dirX, dirZ) {
    const g = this.game;
    // summon escorts at 66% and 33%
    const frac = this.hp / this.maxHp;
    if ((this.summoned === 0 && frac < 0.66) || (this.summoned === 1 && frac < 0.33)) {
      this.summoned++;
      this.state = 'roar'; this.stateT = 0; this.anim.play('roar', 0.2, true);
      g.sfx('boss_roar', this.pos, 1, 30);
      g.director.summon(this.pos, 3 + this.summoned);
      return;
    }
    if (this.special2Cd <= 0 && dist > 9 && dist < 30 && this._los()) {
      this.special2Cd = 9;
      this._startAttack('attack', 1.2, 0.45, { volley: true });
      return;
    }
    if (this.specialCd <= 0 && dist < 13) {
      this.specialCd = 8;
      this._startAttack('slam', 1.5, 0.55, { slam: 12 });
      return;
    }
    if (dist > 16 && this.chargeCd === undefined) this.chargeCd = 6;
    this.chargeCd = (this.chargeCd ?? 6) - dt;
    if (this.chargeCd <= 0 && dist > 14) {
      this.chargeCd = 12;
      this.knock.set(dirX * 14, 0, dirZ * 14);
      g.sfx('boss_roar', this.pos, 0.7, 30);
    }
  }

  _finish(dt, mx, mz, speed, faceYaw, gait) {
    const g = this.game;
    const def = this.def;
    // separation from other aliens
    let sx = 0, sz = 0;
    const R = def.radius * this.scale;
    for (const o of g.enemies.active) {
      if (o === this || !o.alive) continue;
      const dx = this.pos.x - o.pos.x, dz = this.pos.z - o.pos.z;
      const min = R + o.def.radius * o.scale;
      const d2 = dx * dx + dz * dz;
      if (d2 < min * min && d2 > 1e-6) {
        const d = Math.sqrt(d2);
        sx += (dx / d) * (min - d); sz += (dz / d) * (min - d);
      }
    }
    const tvx = mx * speed, tvz = mz * speed;
    this.vel.x += (tvx - this.vel.x) * damp(8, dt);
    this.vel.z += (tvz - this.vel.z) * damp(8, dt);
    this.pos.x += (this.vel.x + this.knock.x) * dt + sx * 0.5;
    this.pos.z += (this.vel.z + this.knock.z) * dt + sz * 0.5;
    this.knock.multiplyScalar(Math.max(0, 1 - dt * 5));
    const flyer = def.behavior === 'flyer';
    if (!flyer) {
      g.world.colliders.resolve(this.pos, R * 0.8, this.height);
      const ground = g.world.groundHeight(this.pos.x, this.pos.z, this.pos.y + 1);
      // lunges and charges get a little hop
      if (this.lunge && this.state === 'attack') this.pos.y = ground + Math.sin(Math.min(1, this.stateT / this.attackDur) * Math.PI) * 0.8;
      else this.pos.y += (ground - this.pos.y) * Math.min(1, dt * 15);
      // wading
      if (ground < WATER_Y - 0.3) this.vel.multiplyScalar(0.96);
    } else {
      this.pos.y += (this.altitudeVel || 0) * dt;
      const ground = g.world.groundHeight(this.pos.x, this.pos.z);
      if (this.pos.y < ground + 0.6) this.pos.y = ground + 0.6;
    }
    this.yaw = dampAngle(this.yaw, faceYaw, 10, dt);
    // spawning aliens rise out of the ground
    let yOff = 0;
    if (this.state === 'spawn' && !flyer) yOff = -this.height * 0.8 * (1 - Math.min(1, this.stateT / 0.9));
    this.mesh.position.set(this.pos.x, this.pos.y + yOff, this.pos.z);
    this.mesh.rotation.y = this.yaw;

    // animation choice
    const hs = Math.hypot(this.vel.x, this.vel.z);
    this.phase += hs * dt * (def.rig === 'brute' ? 1.1 : def.rig === 'crawler' ? 2.4 : 1.6) / this.scale;
    const a = this.anim;
    a.ctx.phase = this.phase;
    a.ctx.gait = clamp(gait, 0, 1);
    if (this.state === 'chase' && !flyer) {
      if (!a.cur || a.cur === 'spawn' || a.cur === 'attack' || a.cur === 'slam' || a.cur === 'spit' || a.cur === 'roar' || a.cur === 'idle' || a.cur === 'move') {
        if (!(a.cur === 'roar' && a.t < 1.2)) a.play(hs > 0.3 ? 'move' : 'idle', 0.2);
      }
    }
    // footsteps for heavy aliens
    this.stepAcc += hs * dt;
    if (this.stepAcc > (def.rig === 'brute' ? 1.8 * this.scale : 1.4)) {
      this.stepAcc = 0;
      if (this.dist < 30) {
        g.sfx('alien_step', this.pos, def.rig === 'brute' ? 1 : 0.4, def.rig === 'brute' ? 0.6 : 1.2);
        if (def.behavior === 'boss') { g.camRig.shake(0.08); g.fx.dust(this.pos, 2); }
      }
    }
    // LOD: far aliens animate at a reduced rate
    this.animAcc += dt;
    const step = this.dist > 55 ? 0.1 : this.dist > 35 ? 0.05 : 0;
    if (this.animAcc >= step) { a.update(this.animAcc); this.animAcc = 0; }
  }

  _updateDead(dt) {
    const g = this.game;
    this.deadT += dt;
    if (this.mesh.visible) {
      this.anim.update(dt);
      if (this.deadT > 3.2) {
        const k = (this.deadT - 3.2) / 1.3;
        this.mesh.position.y = this.pos.y - k * this.height * 0.6;
      }
    }
    if (this.deadT > 4.5) {
      this.active = false;
      this.mesh.visible = false;
    }
  }
}

export class EnemyManager {
  constructor(game) {
    this.game = game;
    this.pools = new Map();
    this.active = [];
  }

  spawn(type, pos, level, opts) {
    const def = ENEMIES[type];
    let pool = this.pools.get(type);
    if (!pool) { pool = []; this.pools.set(type, pool); }
    let e = pool.find((x) => !x.active);
    if (!e) { e = new Enemy(this.game, def); pool.push(e); }
    e.reset(pos, level, opts);
    if (!this.active.includes(e)) this.active.push(e);
    return e;
  }

  get aliveCount() {
    let n = 0;
    for (const e of this.active) if (e.alive) n++;
    return n;
  }

  // nearest alien centre within a cone around the aim ray
  assistTarget(o, d, cone, range) {
    let best = null, bestA = cone;
    for (const e of this.active) {
      if (!e.alive || e.state === 'spawn') continue;
      const c = e.center(_v);
      const tx = c.x - o.x, ty = c.y - o.y, tz = c.z - o.z;
      const l = Math.hypot(tx, ty, tz);
      if (l > range || l < 1) continue;
      const a = Math.acos(clamp((tx * d.x + ty * d.y + tz * d.z) / l, -1, 1));
      if (a < bestA) { bestA = a; best = c.clone(); }
    }
    return best;
  }

  update(dt) {
    for (let i = this.active.length - 1; i >= 0; i--) {
      const e = this.active[i];
      e.update(dt);
      if (!e.active) this.active.splice(i, 1);
    }
  }

  clear() {
    for (const e of this.active) { e.active = false; e.alive = false; e.mesh.visible = false; }
    this.active.length = 0;
  }
}

export { wrapAngle };
