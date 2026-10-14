// Hit detection and damage: camera-aligned hitscan rays with spread, aim
// assist, damage falloff and penetration; terrain/obstacle/alien ray casts;
// explosions with radial falloff and chain reactions.
import * as THREE from 'three';
import { DEG } from '../core/math.js';

const _o = new THREE.Vector3(), _d = new THREE.Vector3(), _dir = new THREE.Vector3(), _muz = new THREE.Vector3();
const _hit = new THREE.Vector3(), _n = new THREE.Vector3(), _tmp = new THREE.Vector3(), _q = new THREE.Quaternion();
const _right = new THREE.Vector3(), _up = new THREE.Vector3();

export class Combat {
  constructor(game) {
    this.game = game;
  }

  // Ray against terrain, static colliders and aliens. Returns
  // { t, point, kind: 'terrain'|'collider'|'none', collider, enemies: [{enemy, t, part}] }
  raycast(o, d, maxDist, maxEnemies = 1, ignoreEnemies = false) {
    const g = this.game;
    let blockT = maxDist, kind = 'none', collider = null;
    const tt = g.world.raycastTerrain(o, d, maxDist);
    if (tt >= 0 && tt < blockT) { blockT = tt; kind = 'terrain'; }
    const ch = g.world.colliders.raycast(o.x, o.y, o.z, d.x, d.y, d.z, blockT, (c) => c.kind !== 'rail');
    if (ch && ch.t < blockT) { blockT = ch.t; kind = 'collider'; collider = ch.collider; }
    const hits = [];
    if (!ignoreEnemies) {
      for (const e of g.enemies.active) {
        if (!e.alive) continue;
        const t = e.rayHit(o, d, blockT);
        if (t) hits.push(t);
      }
      hits.sort((a, b) => a.t - b.t);
      if (hits.length > maxEnemies) hits.length = maxEnemies;
    }
    return { t: blockT, kind, collider, enemies: hits };
  }

  fire(player, w) {
    const g = this.game;
    const def = w.def;
    const cam = g.camera;
    const st = g.stats;
    cam.getWorldDirection(_dir);
    _o.copy(cam.position);
    // start the ray level with the player so nothing behind them is hit
    const ahead = _tmp.copy(player.pos).setY(player.pos.y + 1.4).sub(_o).dot(_dir);
    _o.addScaledVector(_dir, Math.max(0, ahead));
    player.muzzleWorld(_muz);

    let spread = player.aiming ? def.spreadAim : def.spreadHip;
    if (player.crouch) spread *= 0.7;
    const hsp = Math.hypot(player.vel.x, player.vel.z);
    if (hsp > 1) spread *= 1.25;
    if (!player.onGround) spread *= 1.8;
    spread *= DEG;

    _right.set(1, 0, 0).applyQuaternion(cam.quaternion);
    _up.set(0, 1, 0).applyQuaternion(cam.quaternion);

    // Aim assist: bend the centre ray toward a nearby alien.
    if (g.cfg.settings.aimAssist && def.pellets === 1 && !g.camRig.scoped) {
      const best = g.enemies.assistTarget(_o, _dir, 3.2 * DEG, def.range);
      if (best) _dir.lerp(best.sub(_o).normalize(), 0.65).normalize();
    }

    let anyHit = false;
    const dmgMul = player.damageMul;
    for (let p = 0; p < def.pellets; p++) {
      const a = Math.random() * Math.PI * 2, r = Math.sqrt(Math.random()) * spread;
      _d.copy(_dir).addScaledVector(_right, Math.cos(a) * Math.tan(r)).addScaledVector(_up, Math.sin(a) * Math.tan(r)).normalize();
      const res = this.raycast(_o, _d, def.range, def.penetration);
      let endT = res.t;
      for (const h of res.enemies) {
        const dist = h.t + Math.max(0, ahead);
        let dmg = def.damage * dmgMul;
        if (dist > def.falloff) dmg *= Math.max(0.35, 1 - ((dist - def.falloff) / Math.max(1, def.range - def.falloff)) * 0.65);
        _hit.copy(_o).addScaledVector(_d, h.t);
        const killed = h.enemy.damage(dmg, _hit, _d, h.part, { armorPiercing: def.armorPiercing, weapon: def.id });
        anyHit = true;
        if (h.part === 'head') st.headshots++;
        g.hud.hitMarker(h.part === 'head', killed);
        endT = h.t;
      }
      if (res.enemies.length < def.penetration || res.enemies.length === 0) {
        endT = res.t;
        if (res.kind !== 'none') {
          _hit.copy(_o).addScaledVector(_d, res.t);
          if (res.kind === 'terrain') {
            g.world.field.normal(_hit.x, _hit.z, _n);
            const water = g.world.isWater(_hit.x, _hit.z);
            g.fx.impact(_hit, _n, water ? 'water' : g.world.field.pathMask(_hit.x, _hit.z) > 0.3 ? 'dirt' : 'dirt');
            if (p === 0) g.sfx('impact_dirt', _hit, 0.8);
          } else {
            const c = res.collider;
            _n.set(_hit.x - c.x, 0, _hit.z - c.z).normalize();
            const surf = c.kind === 'rock' ? 'rock' : c.kind === 'barrel' ? 'metal' : 'wood';
            g.fx.impact(_hit, _n, surf);
            if (p === 0) g.sfx(surf === 'rock' ? 'impact_rock' : 'impact_wood', _hit, 0.8);
            if (c.prop) g.props.damage(c.prop, def.damage * dmgMul, _hit);
          }
        }
      }
      // tracers: every bullet for single shots, a subset of pellets
      if (def.pellets === 1 || p % 3 === 0) {
        _hit.copy(_o).addScaledVector(_d, Math.min(endT, def.range));
        g.fx.tracer(_muz, _hit, def.id === 'sniper' ? 500 : 300);
      }
    }
    st.shotsFired++;
    if (anyHit) st.shotsHit++;

    // muzzle flash, shells, sound, recoil
    w.model.group.getWorldQuaternion(_q);
    g.fx.muzzleFlash(_muz, _q, def.id === 'shotgun' || def.id === 'sniper' ? 1.5 : def.id === 'pistol' ? 0.7 : 1);
    const ej = _tmp.copy(w.model.sockets.eject).applyMatrix4(w.model.group.matrixWorld);
    g.fx.shell(ej, _right.clone().negate(), def.shellScale);
    g.sfx(def.sound, null, 1);
    const kick = def.recoil * (player.aiming ? 0.55 : 1) * (player.crouch ? 0.75 : 1);
    g.camRig.kick(kick * 0.006 * (0.8 + Math.random() * 0.4), (Math.random() - 0.5) * kick * 0.004);
    g.camRig.shake(Math.min(0.25, def.recoil * 0.035));
    g.director.noise(player.pos, def.id === 'sniper' || def.id === 'shotgun' ? 60 : 40);
  }

  // Radial damage. source: 'player' | 'enemy' | 'world'
  explode(pos, radius, damage, source = 'world', opts = {}) {
    const g = this.game;
    const ground = g.world.groundHeight(pos.x, pos.z);
    g.fx.explosion(pos, radius * 0.6, pos.y - ground < 1.5 ? ground : null);
    g.sfx(Math.random() < 0.5 ? 'explosion_1' : 'explosion_2', pos, 1, 8);
    const pd = pos.distanceTo(g.player.pos);
    g.camRig.shake(Math.max(0, 0.9 - pd / (radius * 4)));
    if (pd < radius * 2.5) g.haptic('heavy');
    for (const e of g.enemies.active) {
      if (!e.alive || e === opts.ignore) continue;
      const d = _tmp.copy(e.pos).setY(e.pos.y + e.def.height * 0.5 * e.scale).distanceTo(pos);
      if (d < radius + e.def.radius * e.scale) {
        const k = 1 - Math.max(0, d - e.def.radius * e.scale) / radius;
        _d.copy(e.pos).sub(pos).normalize();
        e.damage(damage * (0.35 + 0.65 * k), e.pos.clone().setY(e.pos.y + 1), _d, 'body', { explosive: true, weapon: 'explosion' });
        e.knockback(_d, 6 * k);
      }
    }
    if (source !== 'enemy' || opts.hurtsPlayer !== false) {
      const p = g.player;
      const d = pd;
      if (d < radius) {
        const k = 1 - d / radius;
        const mul = source === 'player' ? 0.5 : 1;
        p.takeDamage(damage * 0.45 * (0.3 + 0.7 * k) * mul, pos, 'explosion');
        _d.copy(p.pos).sub(pos).setY(0).normalize();
        p.vel.addScaledVector(_d, 7 * k);
        p.vel.y += 3 * k;
      }
    }
    g.props.explosion(pos, radius, damage);
    g.director.noise(pos, 80);
  }
}
