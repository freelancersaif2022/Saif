// The player soldier: camera-relative movement, jumping, crouching, rolling,
// water wading, collision, the animation state machine, weapon inventory
// (fire, reload, switch, grenades), buffs and damage.
import * as THREE from 'three';
import { soldierTemplate, weaponModel, grenadeModel } from '../actors/models.js';
import { instantiate } from '../actors/skeleton.js';
import { Animator, SOLDIER_BASE, SOLDIER_UPPER, solveArmIK } from '../actors/anim.js';
import { WEAPONS, GRENADE } from '../core/config.js';
import { clamp, damp, dampAngle, wrapAngle } from '../core/math.js';
import { WATER_Y } from '../world/terrain.js';

const _f = new THREE.Vector3(), _r = new THREE.Vector3(), _v = new THREE.Vector3(), _m = new THREE.Matrix4();
const HAND_ALIGN = new THREE.Quaternion().setFromEuler(new THREE.Euler(-1.25, 0, 0));
const POLE_R = new THREE.Vector3(-0.7, -0.35, -0.45), POLE_L = new THREE.Vector3(0.6, -0.55, -0.15);

export class Player {
  constructor(game, cfg) {
    this.game = game;
    const p = cfg.player;
    this.maxHealth = p.maxHealth; this.health = p.maxHealth;
    this.maxArmor = p.maxArmor; this.armor = Math.min(p.startArmor, p.maxArmor);
    this.grenades = p.grenades; this.maxGrenades = p.maxGrenades;
    this.pos = new THREE.Vector3();
    this.vel = new THREE.Vector3();
    this.facing = 0;
    this.onGround = true;
    this.state = 'alive';
    this.crouch = false; this.crouchT = 0;
    this.rollT = -1; this.rollCd = 0; this.rollDir = new THREE.Vector3();
    this.landT = 0; this.airT = 0;
    this.hurtT = 0; this.invuln = 0;
    this.shieldT = 0; this.speedT = 0; this.overT = 0;
    this.phase = 0; this.stepAcc = 0;
    this.action = null; this.actionT = 0; this.actionDur = 0;
    this.inWater = false;

    // model
    this.inst = instantiate(soldierTemplate());
    this.mesh = this.inst.mesh;
    this.mesh.castShadow = true;
    this.mesh.receiveShadow = true;
    game.scene.add(this.mesh);
    this.anim = new Animator(this.inst, SOLDIER_BASE, SOLDIER_UPPER);
    this.anim.play('idle', 0);
    this.anim.playUpper('ready', 0);
    this.pivot = new THREE.Object3D();
    this.inst.b.chest.add(this.pivot);
    this.recoilZ = 0; this.recoilX = 0;

    // weapons
    this.weapons = [];
    for (const id of cfg.loadout) {
      if (!WEAPONS[id]) continue;
      const def = { ...WEAPONS[id], ...(cfg.weapons[id] || {}) };
      if (def.reserve === null || def.reserve === 'inf') def.reserve = Infinity;
      if (def.maxReserve === null || def.maxReserve === 'inf') def.maxReserve = Infinity;
      const model = weaponModel(id);
      model.group.visible = false;
      this.pivot.add(model.group);
      this.weapons.push({ def, mag: def.mag, reserve: def.reserve, model, spin: 0, spinVel: 0 });
    }
    if (!this.weapons.length) throw new Error('empty loadout');
    this.cur = 0;
    this.weapons[0].model.group.visible = true;
    this.fireCd = 0;
    this.reloadT = -1;
    this.switchT = -1; this.switchTo = -1;
    this.throwT = -1;
    this.grenadeMesh = grenadeModel();
    this.grenadeMesh.visible = false;
    this.inst.b.handR.add(this.grenadeMesh);
    this.grenadeMesh.position.set(0, -0.1, 0.04);

    // shield bubble
    this.shieldMesh = new THREE.Mesh(
      new THREE.SphereGeometry(1.15, 24, 16),
      new THREE.MeshBasicMaterial({ color: 0x6fd8ff, transparent: true, opacity: 0.18, blending: THREE.AdditiveBlending, depthWrite: false, toneMapped: false }),
    );
    this.shieldMesh.visible = false;
    game.scene.add(this.shieldMesh);
    this.aiming = false;
    this.wantFire = false;
  }

  get weapon() { return this.weapons[this.cur]; }
  get alive() { return this.state !== 'dead'; }
  get speedMul() { return this.speedT > 0 ? 1.4 : 1; }
  get damageMul() { return this.overT > 0 ? 1.4 : 1; }

  spawn(x, z) {
    this.pos.set(x, this.game.world.groundHeight(x, z) + 0.05, z);
    this.vel.set(0, 0, 0);
    this.mesh.position.copy(this.pos);
  }

  // ------------------------------------------------------------- actions --
  startAction(name, dur) {
    this.action = name; this.actionT = 0; this.actionDur = dur;
  }

  canAct() {
    return this.alive && this.rollT < 0 && this.reloadT < 0 && this.switchT < 0 && this.throwT < 0 && !this.action;
  }

  reload() {
    const w = this.weapon;
    if (!this.alive || this.reloadT >= 0 || this.switchT >= 0 || this.throwT >= 0) return false;
    if (w.mag >= w.def.mag || w.reserve <= 0) { if (w.reserve <= 0 && w.mag === 0) this.game.sfx('empty_click'); return false; }
    this.reloadT = 0;
    this.action = null;
    this.game.sfx(w.def.reloadSound);
    return true;
  }

  switchWeapon(dir = 1) {
    if (!this.alive || this.weapons.length < 2 || this.switchT >= 0 || this.throwT >= 0) return;
    this.reloadT = -1;
    this.switchT = 0;
    this.switchTo = (this.cur + dir + this.weapons.length) % this.weapons.length;
    this.game.sfx('weapon_switch');
  }

  throwGrenade() {
    if (!this.alive || this.grenades <= 0 || this.throwT >= 0 || this.rollT >= 0 || this.switchT >= 0) return;
    this.reloadT = -1;
    this.throwT = 0;
    this.grenades--;
    this.grenadeMesh.visible = true;
    this.game.sfx('grenade_pin');
  }

  jump() {
    if (!this.alive || !this.onGround || this.rollT >= 0) return;
    if (this.crouch) { this.crouch = false; return; }
    this.vel.y = 7.2;
    this.onGround = false;
    this.anim.play('jump', 0.1);
    this.game.sfx('jump', this.pos);
  }

  toggleCrouch() {
    if (!this.alive || this.rollT >= 0) return;
    this.crouch = !this.crouch;
  }

  roll(moveDir) {
    if (!this.alive || !this.onGround || this.rollT >= 0 || this.rollCd > 0) return;
    this.rollT = 0;
    this.rollCd = 1.0;
    this.crouch = false;
    if (moveDir.lengthSq() > 0.01) this.rollDir.copy(moveDir).normalize();
    else this.rollDir.set(Math.sin(this.facing), 0, Math.cos(this.facing));
    this.facing = Math.atan2(this.rollDir.x, this.rollDir.z);
    this.anim.play('roll', 0.08, true);
    this.invuln = 0.35;
    this.game.sfx('roll', this.pos);
  }

  // -------------------------------------------------------------- damage --
  takeDamage(amount, from, kind = 'melee') {
    if (!this.alive || this.game.cfg.debug.god) return 0;
    if (this.invuln > 0 && kind !== 'trap') return 0;
    if (this.shieldT > 0) {
      this.game.fx.sparkle(this.pos.clone().setY(this.pos.y + 1), 0x6fd8ff);
      return 0;
    }
    let dmg = amount;
    if (this.armor > 0) {
      const absorbed = Math.min(this.armor, dmg * 0.6);
      this.armor -= absorbed;
      dmg -= absorbed;
      if (this.armor <= 0) this.game.sfx('armor_break');
    }
    this.health -= dmg;
    this.game.stats.damageTaken += amount;
    this.hurtT = 0.3;
    this.anim.impulse('hit', 0.9, 4);
    this.game.camRig.shake(Math.min(0.6, 0.15 + amount / 60));
    this.game.hud.damage(from, this.pos, this.game.camRig.yaw, amount);
    this.game.sfx(Math.random() < 0.5 ? 'player_hurt_1' : 'player_hurt_2', null, 0.9);
    this.game.haptic(amount > 25 ? 'heavy' : 'light');
    if (this.health <= 0) this.die();
    return dmg;
  }

  heal(amount) {
    this.health = Math.min(this.maxHealth, this.health + amount);
  }

  die() {
    this.health = 0;
    this.state = 'dead';
    this.reloadT = this.switchT = this.throwT = -1;
    this.anim.playUpper(null, 0.2);
    this.anim.play('death', 0.15);
    this.weapon.model.group.visible = false;
    this.game.sfx('player_death');
    this.game.onPlayerDeath();
  }

  // ---------------------------------------------------------------- update --
  update(dt, input) {
    const g = this.game;
    const world = g.world;
    const rig = g.camRig;
    this.invuln = Math.max(0, this.invuln - dt);
    this.rollCd = Math.max(0, this.rollCd - dt);
    this.hurtT = Math.max(0, this.hurtT - dt);
    if (this.shieldT > 0) this.shieldT -= dt;
    if (this.speedT > 0) this.speedT -= dt;
    if (this.overT > 0) this.overT -= dt;

    const alive = this.alive;
    // desired movement in camera space
    rig.flatForward(_f); rig.flatRight(_r);
    const mv = _v.set(0, 0, 0);
    if (alive) mv.addScaledVector(_f, input.moveY).addScaledVector(_r, input.moveX);
    const mag = Math.min(1, mv.length());
    const w = this.weapon;
    const busy = this.reloadT >= 0 || this.switchT >= 0 || this.throwT >= 0;
    const sprinting = alive && input.sprint && mag > 0.5 && !this.aiming && !this.crouch && !input.fire && this.rollT < 0 && !busy;
    this.sprinting = sprinting;
    this.aiming = alive && input.aim && this.rollT < 0 && !sprinting;

    // speeds
    let speed = this.crouch ? 2.0 : sprinting ? 7.6 : 4.6;
    if (this.aiming) speed = Math.min(speed, 3.0);
    speed *= w.def.moveMul * this.speedMul;
    if (this.inWater) speed *= 0.6;

    if (this.rollT >= 0) {
      this.rollT += dt;
      const k = this.rollT / 0.7;
      const rs = 8.5 * (1 - k * 0.6);
      this.vel.x = this.rollDir.x * rs; this.vel.z = this.rollDir.z * rs;
      if (this.rollT >= 0.7) { this.rollT = -1; }
    } else if (alive) {
      const tx = mv.x * speed, tz = mv.z * speed;
      const accel = this.onGround ? 14 : 3;
      this.vel.x += (tx - this.vel.x) * damp(accel, dt);
      this.vel.z += (tz - this.vel.z) * damp(accel, dt);
    } else {
      this.vel.x *= 0.9; this.vel.z *= 0.9;
    }

    // facing: toward camera while aiming/shooting, otherwise movement direction
    const shooting = alive && (this.aiming || input.fire || this.fireHold > 0);
    this.fireHold = Math.max(0, (this.fireHold || 0) - dt);
    if (this.rollT < 0 && alive) {
      if (shooting) this.facing = dampAngle(this.facing, rig.yaw + Math.PI, 25, dt);
      else if (mag > 0.1) this.facing = dampAngle(this.facing, Math.atan2(mv.x, mv.z), 12, dt);
    }

    // gravity & integration
    this.vel.y -= 20 * dt;
    this.pos.addScaledVector(this.vel, dt);
    // slope: discourage climbing very steep terrain
    world.colliders.resolve(this.pos, 0.38, 1.7);
    const ground = world.groundHeight(this.pos.x, this.pos.z, this.pos.y);
    const wasGround = this.onGround;
    if (this.pos.y <= ground + 0.02 || (this.onGround && this.pos.y - ground < 0.35 && this.vel.y <= 0)) {
      if (!wasGround && this.airT > 0.25) {
        this.landT = 0.22;
        g.sfx('land', this.pos);
        g.fx.dust(this.pos, 2);
        if (this.vel.y < -16) this.takeDamage((-this.vel.y - 16) * 4, null, 'trap');
      }
      this.pos.y = ground;
      this.vel.y = Math.max(0, this.vel.y);
      this.onGround = true;
      this.airT = 0;
    } else {
      this.onGround = false;
      this.airT += dt;
    }
    this.inWater = ground < WATER_Y - 0.25;

    // crouch blend
    this.crouchT += ((this.crouch && this.rollT < 0 ? 1 : 0) - this.crouchT) * damp(10, dt);

    // footsteps
    const hspeed = Math.hypot(this.vel.x, this.vel.z);
    this.phase += hspeed * dt * (sprinting ? 1.05 : 1.45) * (this.crouch ? 1.6 : 1);
    this.stepAcc += hspeed * dt;
    const stride = sprinting ? 1.7 : this.crouch ? 0.9 : 1.25;
    if (this.onGround && this.stepAcc > stride && alive && this.rollT < 0) {
      this.stepAcc = 0;
      const surf = this.inWater ? 'step_water' : world.colliders.deckHeight(this.pos.x, this.pos.z, this.pos.y) > -Infinity ? 'step_wood'
        : world.field.pathMask(this.pos.x, this.pos.z) > 0.4 ? (Math.random() < 0.5 ? 'step_dirt_1' : 'step_dirt_2') : `step_grass_${1 + Math.floor(Math.random() * 3)}`;
      g.sfx(surf, null, this.crouch ? 0.4 : sprinting ? 1 : 0.75);
      if (this.inWater) g.fx.splash(this.pos.clone().setY(WATER_Y));
      else if (sprinting) g.fx.dust(this.pos, 0.6);
    }

    this._updateWeapons(dt, input);
    this._updateAnimation(dt, hspeed, mv);

    this.mesh.position.copy(this.pos);
    this.mesh.rotation.y = this.facing;
    if (this.shieldT > 0) {
      this.shieldMesh.visible = true;
      this.shieldMesh.position.set(this.pos.x, this.pos.y + 0.95, this.pos.z);
      this.shieldMesh.material.opacity = 0.14 + Math.sin(g.time * 8) * 0.05 + (this.shieldT < 2 ? (Math.sin(g.time * 30) > 0 ? 0.08 : -0.08) : 0);
    } else this.shieldMesh.visible = false;
  }

  _updateWeapons(dt, input) {
    const g = this.game;
    const w = this.weapon;
    this.fireCd -= dt;
    if (!this.alive) return;

    // minigun spin-up
    if (w.def.spinUp > 0) {
      const want = input.fire && this.reloadT < 0 && this.switchT < 0 && this.rollT < 0 ? 1 : 0;
      w.spin += (want - w.spin) * damp(want ? 1 / w.def.spinUp * 2.2 : 2.5, dt);
      w.spinVel = w.spin * 60;
      if (w.model.spinner) w.model.spinner.rotation.z += w.spinVel * dt;
      if (w.spin > 0.05) g.audio.loop('minigun', 'minigun_spin', w.spin, 'sfx'); else g.audio.stopLoop('minigun', 0.3);
    }

    // reload
    if (this.reloadT >= 0) {
      this.reloadT += dt / w.def.reload;
      if (this.reloadT >= 1) {
        const need = w.def.mag - w.mag;
        const take = Math.min(need, w.reserve);
        w.mag += take;
        if (w.reserve !== Infinity) w.reserve -= take;
        this.reloadT = -1;
      }
    }
    // weapon switch (model swaps at the bottom of the motion)
    if (this.switchT >= 0) {
      const prev = this.switchT;
      this.switchT += dt / 0.55;
      if (prev < 0.5 && this.switchT >= 0.5) {
        this.weapon.model.group.visible = false;
        this.cur = this.switchTo;
        this.weapon.model.group.visible = true;
        g.hud.weaponChanged();
      }
      if (this.switchT >= 1) this.switchT = -1;
    }
    // grenade throw
    if (this.throwT >= 0) {
      const prev = this.throwT;
      this.throwT += dt / 0.75;
      if (prev < 0.55 && this.throwT >= 0.55) {
        this.grenadeMesh.visible = false;
        const from = new THREE.Vector3();
        this.inst.b.handR.getWorldPosition(from);
        const dir = g.camRig.forward(new THREE.Vector3());
        dir.y += 0.28;
        dir.normalize();
        g.projectiles.grenade(from, dir.multiplyScalar(GRENADE.throwSpeed), this);
      }
      if (this.throwT >= 1) this.throwT = -1;
    }
    // auto reload when empty
    if (w.mag === 0 && this.reloadT < 0 && w.reserve > 0 && this.switchT < 0 && this.throwT < 0) this.reload();

    // fire
    const canFire = this.reloadT < 0 && this.switchT < 0 && this.throwT < 0 && this.rollT < 0 && !this.sprinting && (w.def.spinUp === 0 || w.spin > 0.85);
    if (input.fire) this.fireHold = 0.6;
    if (input.fire && canFire && this.fireCd <= 0) {
      if (!w.def.auto && this._triggerHeld) return;
      if (w.mag <= 0) {
        if (!this._triggerHeld) g.sfx('empty_click');
        this._triggerHeld = true;
        return;
      }
      this._triggerHeld = true;
      w.mag--;
      const rate = this.overT > 0 ? 1.25 : 1;
      this.fireCd = w.def.fireInterval / rate;
      g.combat.fire(this, w);
      this.recoilZ = -0.05 * Math.min(2, w.def.recoil);
      this.recoilX = -0.06 * Math.min(2.5, w.def.recoil);
      this.anim.impulse('recoil', Math.min(1, w.def.recoil * 0.3), 8);
      if (this.action) this.action = null;
    }
    if (!input.fire) this._triggerHeld = false;
  }

  muzzleWorld(out) {
    const w = this.weapon;
    return out.copy(w.model.sockets.muzzle).applyMatrix4(w.model.group.matrixWorld);
  }

  _updateAnimation(dt, hspeed, mv) {
    const an = this.anim;
    const c = an.ctx;
    c.weapon = this.weapon.def.id;
    c.phase = this.phase;
    c.reloadT = this.reloadT;
    c.switchT = this.switchT;
    c.throwT = this.throwT;
    c.rollTime = 0.7;
    if (this.alive) {
      // base layer
      let base;
      if (this.rollT >= 0) base = 'roll';
      else if (this.action === 'pickup') base = 'pickup';
      else if (!this.onGround && this.airT > 0.12) base = this.vel.y > 0 ? 'jump' : 'fall';
      else if (this.landT > 0) base = 'land';
      else if (this.crouch) base = hspeed > 0.4 ? 'crouchWalk' : 'crouch';
      else base = hspeed > 0.4 ? 'locomotion' : 'idle';
      this.landT -= dt;
      c.gait = this.sprinting ? 2 : clamp((hspeed - 1.5) / 3.5, 0, 1);
      // walking backwards plays the cycle in reverse
      const moveAng = hspeed > 0.4 ? wrapAngle(Math.atan2(this.vel.x, this.vel.z) - this.facing) : 0;
      if (Math.abs(moveAng) > 1.9) c.phase = -this.phase;
      an.play(base, base === 'land' ? 0.06 : 0.18);
      // upper layer
      let up;
      if (this.reloadT >= 0) up = 'reload';
      else if (this.switchT >= 0) up = 'switch';
      else if (this.throwT >= 0) up = 'throw';
      else if (this.action === 'heal') up = 'heal';
      else if (this.action === 'interact') up = 'interact';
      else if (this.action === 'pickup') up = 'pickup';
      else if (this.aiming || this.fireHold > 0) up = 'aim';
      else if (this.sprinting) up = 'sprint';
      else up = 'ready';
      an.playUpper(up, up === 'aim' ? 0.1 : 0.2);
      if (this.action) {
        this.actionT += dt;
        if (this.actionT >= this.actionDur) this.action = null;
      }
      // hips follow the strafe direction; upper body keeps facing the aim
      const strafe = Math.abs(moveAng) < 1.9 ? clamp(moveAng, -0.9, 0.9) : clamp(wrapAngle(moveAng + Math.PI), -0.9, 0.9);
      this.strafe = (this.strafe || 0) + ((hspeed > 0.4 && this.rollT < 0 ? strafe : 0) - (this.strafe || 0)) * damp(8, dt);
      const pitch = this.game.camRig.pitch;
      c.post = (P) => {
        if (!this.alive || this.rollT >= 0) return;
        P.add('hips', 0, this.strafe, 0);
        P.add('spine', 0, -this.strafe * 0.6, 0);
        P.add('chest', 0, -this.strafe * 0.4, 0);
        const aimW = this.anim.upper === 'aim' ? 1 : 0.35;
        P.add('spine', -pitch * 0.5 * aimW, 0, 0);
        P.add('chest', -pitch * 0.5 * aimW, 0, 0);
        P.add('head', -pitch * 0.25 * (1 - aimW), 0, 0);
      };
    }
    an.update(dt);
    // gun pivot from the upper layer + recoil
    this.recoilZ += (0 - this.recoilZ) * damp(14, dt);
    this.recoilX += (0 - this.recoilX) * damp(12, dt);
    const P = an.pose;
    this.pivot.position.set(P.g[0], P.g[1], P.g[2] + this.recoilZ);
    this.pivot.rotation.set(P.g[3] + this.recoilX, P.g[4], P.g[5]);
    this.pivot.updateMatrix();
    if (this.alive) {
      // two-bone IK: hands to the grip sockets (or animated override targets)
      const s = this.weapon.model.sockets;
      const hq = _q.copy(this.pivot.quaternion).multiply(HAND_ALIGN);
      const up = _u.set(0, 1, 0).applyQuaternion(hq).multiplyScalar(0.075);
      const gR = _gr.copy(s.grip).applyMatrix4(this.pivot.matrix).add(up);
      const gL = _gl.copy(s.fore).applyMatrix4(this.pivot.matrix).add(up);
      if (P.lh[3] > 0.001) gL.lerp(_t.set(P.lh[0], P.lh[1], P.lh[2]), P.lh[3]);
      if (P.rh[3] > 0.001) gR.lerp(_t.set(P.rh[0], P.rh[1], P.rh[2]), P.rh[3]);
      const b = this.inst.b;
      solveArmIK(b.armR, b.foreR, b.handR, gR, POLE_R, hq);
      solveArmIK(b.armL, b.foreL, b.handL, gL, POLE_L, P.lh[3] > 0.5 ? null : hq);
    }
  }
}

const _q = new THREE.Quaternion(), _u = new THREE.Vector3(), _gr = new THREE.Vector3(), _gl = new THREE.Vector3(), _t = new THREE.Vector3();
export { _m };
