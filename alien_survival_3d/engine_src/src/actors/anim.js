// Skeletal animation: procedural clips evaluated into poses, cross-faded by an
// animation state machine with an upper-body layer and additive reactions,
// plus analytic two-bone IK that keeps the soldier's hands on the weapon.
import * as THREE from 'three';
import { clamp, smoothstep, lerp } from '../core/math.js';

const UPPER = ['spine', 'chest', 'neck', 'head', 'armL', 'foreL', 'handL', 'armR', 'foreR', 'handR', 'wingL', 'wingR'];
const PI = Math.PI;
const ease = (t) => t * t * (3 - 2 * t);
const easeOut = (t) => 1 - (1 - t) * (1 - t);

export class Pose {
  constructor(index) {
    this.index = index;
    this.n = Object.keys(index).length;
    this.r = new Float32Array(this.n * 3);
    this.h = new Float32Array(3); // hips translation offset
    this.g = new Float32Array(6); // gun pivot (chest space): pos xyz, rot xyz
    this.lh = new Float32Array(4); // left hand override target (chest space) + weight
    this.rh = new Float32Array(4); // right hand override target + weight
  }
  zero() { this.r.fill(0); this.h.fill(0); this.g.fill(0); this.lh.fill(0); this.rh.fill(0); return this; }
  set(name, x, y = 0, z = 0) {
    const i = this.index[name];
    if (i === undefined) return this;
    this.r[i * 3] = x; this.r[i * 3 + 1] = y; this.r[i * 3 + 2] = z;
    return this;
  }
  add(name, x, y = 0, z = 0) {
    const i = this.index[name];
    if (i === undefined) return this;
    this.r[i * 3] += x; this.r[i * 3 + 1] += y; this.r[i * 3 + 2] += z;
    return this;
  }
  gun(px, py, pz, rx = 0, ry = 0, rz = 0) { this.g.set([px, py, pz, rx, ry, rz]); return this; }
  left(x, y, z, w) { this.lh.set([x, y, z, w]); return this; }
  right(x, y, z, w) { this.rh.set([x, y, z, w]); return this; }
  copy(o) { this.r.set(o.r); this.h.set(o.h); this.g.set(o.g); this.lh.set(o.lh); this.rh.set(o.rh); return this; }
  blend(o, t) {
    const a = this.r, b = o.r;
    for (let i = 0; i < a.length; i++) a[i] += (b[i] - a[i]) * t;
    for (let i = 0; i < 3; i++) this.h[i] += (o.h[i] - this.h[i]) * t;
    for (let i = 0; i < 6; i++) this.g[i] += (o.g[i] - this.g[i]) * t;
    for (let i = 0; i < 4; i++) { this.lh[i] += (o.lh[i] - this.lh[i]) * t; this.rh[i] += (o.rh[i] - this.rh[i]) * t; }
    return this;
  }
  blendBones(o, t, names) {
    for (const n of names) {
      const i = this.index[n];
      if (i === undefined) continue;
      for (let k = 0; k < 3; k++) this.r[i * 3 + k] += (o.r[i * 3 + k] - this.r[i * 3 + k]) * t;
    }
    for (let i = 0; i < 6; i++) this.g[i] += (o.g[i] - this.g[i]) * t;
    for (let i = 0; i < 4; i++) { this.lh[i] += (o.lh[i] - this.lh[i]) * t; this.rh[i] += (o.rh[i] - this.rh[i]) * t; }
  }
  addScaled(o, s) {
    for (let i = 0; i < this.r.length; i++) this.r[i] += o.r[i] * s;
    for (let i = 0; i < 3; i++) this.h[i] += o.h[i] * s;
  }
}

// ---------------------------------------------------------------- helpers --
function legs(p, phase, A, K, opts = {}) {
  const base = opts.base || 0, knee0 = opts.knee0 || 0.08;
  for (const [side, off] of [['L', 0], ['R', PI]]) {
    const f = phase + off;
    const th = -Math.sin(f) * A + base;
    const kn = knee0 + K * Math.max(0, Math.cos(f)) + (opts.kneeBase || 0);
    p.set('thigh' + side, th, 0, side === 'L' ? 0.03 : -0.03);
    p.set('shin' + side, kn);
    p.set('foot' + side, -(th + kn) * 0.55 + (opts.foot || 0));
  }
}

function armsSwing(p, phase, A, bend, out = 0.12) {
  p.set('armL', Math.sin(phase) * A, 0, out);
  p.set('armR', -Math.sin(phase) * A, 0, -out);
  p.set('foreL', -bend - Math.max(0, -Math.sin(phase)) * 0.3);
  p.set('foreR', -bend - Math.max(0, Math.sin(phase)) * 0.3);
}

function kneel(p) {
  p.h[1] = -0.45;
  p.set('thighL', -1.4, 0, 0.08); p.set('shinL', 1.4); p.set('footL', 0);
  p.set('thighR', 0.08, 0, -0.06); p.set('shinR', 1.5); p.set('footR', 0.6);
  p.set('spine', 0.12);
}

// ------------------------------------------------------------ soldier base --
export const SOLDIER_BASE = {
  idle(p, t) {
    const b = Math.sin(t * 1.7);
    p.h[1] = -0.012 + b * 0.004;
    p.set('thighL', -0.06, 0, 0.05); p.set('shinL', 0.1); p.set('footL', -0.04);
    p.set('thighR', 0.05, 0, -0.06); p.set('shinR', 0.08); p.set('footR', -0.1);
    p.set('spine', 0.02 + b * 0.01); p.set('chest', b * 0.015);
    p.set('armL', 0.05, 0, 0.12); p.set('armR', 0.05, 0, -0.12); p.set('foreL', -0.2); p.set('foreR', -0.2);
  },
  locomotion(p, t, c) {
    const s = c.gait; // 0 walk .. 1 run .. 2 sprint
    const A = s < 1 ? lerp(0.42, 0.68, s) : lerp(0.68, 0.85, s - 1);
    const K = s < 1 ? lerp(0.75, 1.35, s) : lerp(1.35, 1.7, s - 1);
    const ph = c.phase;
    legs(p, ph, A, K);
    p.h[1] = -Math.abs(Math.sin(ph)) * (0.03 + 0.03 * s) - 0.02 * s;
    p.set('hips', 0, Math.sin(ph) * 0.08, 0);
    p.set('spine', 0.05 + 0.08 * s, -Math.sin(ph) * 0.06);
    p.set('chest', 0.02, -Math.sin(ph) * 0.05);
    armsSwing(p, ph, A * 0.8, 0.35 + 0.5 * Math.min(s, 1));
  },
  crouch(p, t) {
    kneel(p);
    p.set('spine', 0.18 + Math.sin(t * 1.6) * 0.01);
  },
  crouchWalk(p, t, c) {
    const ph = c.phase;
    legs(p, ph, 0.38, 0.9, { base: -0.75, knee0: 1.1 });
    p.h[1] = -0.3 - Math.abs(Math.sin(ph)) * 0.02;
    p.set('spine', 0.32);
  },
  jump(p) {
    p.set('thighL', -0.9); p.set('shinL', 1.3); p.set('footL', 0.2);
    p.set('thighR', -0.2); p.set('shinR', 0.7); p.set('footR', 0.3);
    p.set('spine', 0.12);
  },
  fall(p, t) {
    p.set('thighL', -0.4); p.set('shinL', 0.4);
    p.set('thighR', -0.1); p.set('shinR', 0.6);
    p.set('armL', -0.4, 0, 0.5 + Math.sin(t * 9) * 0.05); p.set('armR', -0.4, 0, -0.5);
  },
  land(p) {
    p.h[1] = -0.2;
    p.set('thighL', -0.7); p.set('shinL', 1.2); p.set('footL', -0.5);
    p.set('thighR', -0.6); p.set('shinR', 1.1); p.set('footR', -0.5);
    p.set('spine', 0.3);
  },
  roll(p, t, c) {
    const k = clamp(t / (c.rollTime || 0.7), 0, 1);
    const tuck = Math.sin(PI * k);
    p.h[1] = -0.6 * tuck;
    p.h[2] = 0.15 * tuck;
    p.set('hips', 2 * PI * ease(k));
    p.set('thighL', -1.7 * tuck); p.set('shinL', 2.2 * tuck);
    p.set('thighR', -1.5 * tuck); p.set('shinR', 2.1 * tuck);
    p.set('spine', 0.6 * tuck); p.set('chest', 0.4 * tuck); p.set('head', 0.6 * tuck);
  },
  death(p, t) {
    const k = clamp(t / 1.1, 0, 1);
    const f = easeOut(k);
    if (k < 0.3) {
      const a = k / 0.3;
      p.set('thighL', -0.5 * a); p.set('shinL', 1.4 * a); p.set('thighR', 0.1); p.set('shinR', 1.6 * a);
      p.h[1] = -0.35 * a;
      p.set('spine', -0.2 * a); p.set('head', -0.4 * a);
    } else {
      const a = ease((k - 0.3) / 0.7);
      p.set('hips', -PI / 2 * a);
      p.h[1] = -0.35 - 0.48 * a;
      p.h[2] = -0.3 * a;
      p.set('thighL', -0.5 * (1 - a) - 0.2 * a); p.set('shinL', 1.4 * (1 - a) + 0.3 * a);
      p.set('thighR', 0.1); p.set('shinR', 1.6 * (1 - a) + 0.2 * a);
      p.set('spine', -0.2 * (1 - a)); p.set('head', -0.4 * (1 - a) + 0.3 * a, 0.5 * a);
    }
    p.set('armL', -0.3 * f, 0, 1.3 * f); p.set('foreL', -0.6 * f);
    p.set('armR', -0.6 * f, 0, -1.1 * f); p.set('foreR', -0.4 * f);
  },
  pickup(p, t) {
    kneel(p);
    p.set('spine', 0.45); p.set('chest', 0.25);
  },
};

// Upper-body gun handling (arms solved with IK to the gun sockets).
const GUN_AIM = [-0.135, 0.19, 0.33];
export const SOLDIER_UPPER = {
  aim(p, t, c) {
    const pistol = c.weapon === 'pistol';
    const heavy = c.weapon === 'minigun';
    if (pistol) p.gun(-0.06, 0.2, 0.52, 0, 0.02, 0);
    else if (heavy) p.gun(-0.2, -0.06, 0.32, 0, 0.05, 0);
    else p.gun(GUN_AIM[0], GUN_AIM[1], GUN_AIM[2], 0, 0.03, 0);
    p.set('neck', 0.05, 0.12); p.set('head', 0.08, 0.05, 0.06);
  },
  ready(p, t, c) {
    const b = Math.sin(t * 1.7) * 0.01;
    if (c.weapon === 'pistol') p.gun(-0.12, -0.02, 0.32, 0.6 + b, 0.15, 0);
    else if (c.weapon === 'minigun') p.gun(-0.2, -0.1, 0.3, 0.12 + b, 0.1, 0);
    else p.gun(-0.12, 0.02, 0.28, 0.42 + b, 0.38, 0.1);
  },
  sprint(p, t, c) {
    if (c.weapon === 'pistol') p.gun(-0.15, -0.05, 0.25, 1.0, 0.2, 0);
    else if (c.weapon === 'minigun') p.gun(-0.2, -0.12, 0.28, 0.3, 0.2, 0);
    else p.gun(-0.05, 0.08, 0.26, 0.75, 0.95, 0.35);
  },
  reload(p, t, c) {
    const k = clamp(c.reloadT ?? 0, 0, 1);
    p.gun(-0.08, 0.02, 0.3, 0.35, 0.55, 0.45);
    // left hand: to magazine, down to the belt pouch, back to the magazine, to the foregrip
    const mag = [-0.04, -0.1, 0.36], belt = [0.16, -0.42, 0.06];
    let x, y, z, w;
    if (k < 0.2) { const a = ease(k / 0.2); [x, y, z] = mag; w = a; }
    else if (k < 0.45) { const a = ease((k - 0.2) / 0.25); x = lerp(mag[0], belt[0], a); y = lerp(mag[1], belt[1], a); z = lerp(mag[2], belt[2], a); w = 1; }
    else if (k < 0.7) { const a = ease((k - 0.45) / 0.25); x = lerp(belt[0], mag[0], a); y = lerp(belt[1], mag[1], a); z = lerp(belt[2], mag[2], a); w = 1; }
    else { const a = ease((k - 0.7) / 0.3); [x, y, z] = mag; w = 1 - a; }
    p.left(x, y, z, w);
    p.set('head', 0.35, 0.25); p.set('chest', 0.1);
  },
  switch(p, t, c) {
    const k = clamp(c.switchT ?? 0, 0, 1);
    const d = Math.sin(PI * k);
    p.gun(-0.12, 0.02 - 0.35 * d, 0.28 - 0.1 * d, 0.42 + 0.8 * d, 0.38, 0.1);
    p.set('chest', 0.15 * d);
  },
  throw(p, t, c) {
    const k = clamp(c.throwT ?? 0, 0, 1);
    p.gun(0.02, -0.12, 0.25, 0.9, -0.5, 0.3);
    let x, y, z;
    if (k < 0.45) { const a = ease(k / 0.45); x = lerp(-0.25, -0.32, a); y = lerp(0.0, 0.42, a); z = lerp(0.2, -0.25, a); }
    else { const a = easeOut((k - 0.45) / 0.55); x = lerp(-0.32, -0.1, a); y = lerp(0.42, 0.25, a); z = lerp(-0.25, 0.55, a); }
    p.right(x, y, z, 1);
    p.set('chest', 0, k < 0.45 ? 0.35 * ease(k / 0.45) : 0.35 - 0.7 * easeOut((k - 0.45) / 0.55));
  },
  heal(p, t, c) {
    p.gun(-0.12, -0.04, 0.26, 0.7, 0.3, 0.1);
    p.left(0.02, 0.12 + Math.sin(t * 6) * 0.02, 0.2, 1);
    p.set('head', 0.4);
  },
  interact(p, t) {
    p.gun(-0.12, -0.02, 0.26, 0.6, 0.4, 0.1);
    const k = clamp(t / 0.5, 0, 1);
    p.left(0.12, 0.12, 0.25 + 0.3 * Math.sin(PI * k), 1);
  },
  pickup(p, t) {
    p.gun(-0.12, -0.04, 0.26, 0.8, 0.4, 0.1);
    const k = clamp(t / 0.45, 0, 1);
    p.left(0.14, -0.55 * Math.sin(PI * k), 0.38, 1);
    p.set('head', 0.5 * Math.sin(PI * k));
  },
};

export const ADDITIVE = {
  hit(p) { p.set('spine', -0.22); p.set('chest', -0.12, 0.1); p.set('head', -0.3, 0.2); p.h[2] = -0.04; },
  recoil(p) { p.set('chest', -0.06); p.set('head', -0.02); },
};

// ----------------------------------------------------------- alien clips --
function alienStance(p, t) {
  p.h[1] = -0.06;
  p.set('thighL', -0.28, 0, 0.1); p.set('shinL', 0.55); p.set('footL', -0.27);
  p.set('thighR', -0.28, 0, -0.1); p.set('shinR', 0.55); p.set('footR', -0.27);
}

export const HUMANOID = {
  idle(p, t) {
    alienStance(p, t);
    const b = Math.sin(t * 2.1);
    p.set('spine', 0.18 + b * 0.03); p.set('chest', 0.18 + b * 0.02); p.set('neck', -0.15); p.set('head', -0.2 + Math.sin(t * 0.7) * 0.15, Math.sin(t * 0.5) * 0.4);
    p.set('armL', -0.2, 0, 0.3 + b * 0.04); p.set('armR', -0.2, 0, -0.3 - b * 0.04);
    p.set('foreL', -0.55); p.set('foreR', -0.55);
    p.set('handL', -0.3 + Math.sin(t * 7) * 0.1); p.set('handR', -0.3 + Math.cos(t * 6) * 0.1);
  },
  move(p, t, c) {
    const s = c.gait; const ph = c.phase;
    const A = lerp(0.45, 0.8, s), K = lerp(0.8, 1.5, s);
    legs(p, ph, A, K, { kneeBase: 0.3, base: -0.15 });
    p.h[1] = -0.06 - Math.abs(Math.sin(ph)) * 0.05;
    p.set('hips', 0, Math.sin(ph) * 0.12);
    p.set('spine', 0.25 + 0.2 * s, -Math.sin(ph) * 0.1); p.set('chest', 0.15 + 0.15 * s);
    p.set('neck', -0.2 - 0.2 * s); p.set('head', -0.15);
    if (s > 0.5) {
      p.set('armL', -0.6 + Math.sin(ph) * 0.5, 0, 0.35); p.set('armR', -0.6 - Math.sin(ph) * 0.5, 0, -0.35);
      p.set('foreL', -0.9); p.set('foreR', -0.9);
    } else {
      armsSwing(p, ph, 0.5, 0.5, 0.3);
    }
  },
  attack(p, t, c) {
    alienStance(p, t);
    const k = clamp(c.attackT ?? 0, 0, 1);
    const s = c.side || 1; // 1: right arm, -1: left arm
    const arm = s > 0 ? 'R' : 'L';
    const other = s > 0 ? 'L' : 'R';
    let raise, swing;
    if (k < 0.45) { raise = ease(k / 0.45); swing = 0; } else { raise = 1 - easeOut((k - 0.45) / 0.55); swing = easeOut(clamp((k - 0.45) / 0.25, 0, 1)); }
    p.set('arm' + arm, -2.4 * raise - 0.6 * swing, 0, -s * (0.6 * raise - 0.4 * swing));
    p.set('fore' + arm, -0.8 * raise - 0.2);
    p.set('arm' + other, -0.4, 0, s * 0.4); p.set('fore' + other, -0.7);
    p.set('spine', 0.1 + 0.45 * swing, s * (0.4 * raise - 0.6 * swing));
    p.set('chest', 0.1 + 0.2 * swing, s * (0.3 * raise - 0.4 * swing));
    p.set('head', -0.3 * raise);
  },
  spit(p, t, c) {
    alienStance(p, t);
    const k = clamp(c.attackT ?? 0, 0, 1);
    const back = k < 0.55 ? ease(k / 0.55) : 1 - easeOut((k - 0.55) / 0.45) * 1.6;
    p.set('spine', -0.3 * back + 0.1); p.set('chest', -0.3 * back); p.set('neck', -0.4 * back); p.set('head', -0.3 * back);
    p.set('armL', -0.3, 0, 0.6); p.set('armR', -0.3, 0, -0.6); p.set('foreL', -1); p.set('foreR', -1);
  },
  roar(p, t, c) {
    alienStance(p, t);
    const k = clamp(t / 1.2, 0, 1);
    const a = Math.sin(PI * k);
    p.set('spine', -0.3 * a); p.set('chest', -0.25 * a); p.set('neck', -0.3 * a); p.set('head', -0.4 * a + Math.sin(t * 30) * 0.03 * a);
    p.set('armL', -0.6 * a, 0, 1.0 * a + 0.2); p.set('armR', -0.6 * a, 0, -1.0 * a - 0.2);
    p.set('foreL', -1.2 * a); p.set('foreR', -1.2 * a);
  },
  spawn(p, t) {
    const k = clamp(t / 1.0, 0, 1);
    const a = 1 - ease(k);
    kneel(p);
    for (let i = 0; i < p.r.length; i++) p.r[i] *= a;
    p.h[1] = -0.45 * a - 0.06 * (1 - a);
    p.set('spine', 0.8 * a + 0.2); p.set('head', -0.4 * a);
    p.set('armL', -0.5 * a, 0, 0.4); p.set('armR', -0.5 * a, 0, -0.4);
  },
  death(p, t) {
    const k = clamp(t / 1.2, 0, 1);
    if (k < 0.35) {
      const a = ease(k / 0.35);
      kneel(p);
      for (let i = 0; i < p.r.length; i++) p.r[i] *= a;
      p.h[1] = -0.45 * a;
      p.set('spine', -0.4 * a); p.set('head', -0.6 * a); p.set('armL', -0.5 * a, 0, 0.6 * a); p.set('armR', -0.3 * a, 0, -0.9 * a);
    } else {
      const a = ease((k - 0.35) / 0.65);
      kneel(p);
      p.set('hips', PI / 2 * a);
      p.h[1] = -0.45 - 0.35 * a; p.h[2] = 0.35 * a;
      p.set('spine', -0.4 * (1 - a) + 0.1 * a); p.set('head', -0.6 * (1 - a) - 0.3 * a, 0.6 * a);
      p.set('armL', -0.5 - 1.6 * a, 0, 0.6 + 0.3 * a); p.set('armR', -0.3 - 2.0 * a, 0, -0.9);
      p.set('foreL', -0.3); p.set('foreR', -0.6);
      p.set('thighL', -1.4 * (1 - a)); p.set('shinL', 1.4 * (1 - a) + 0.2); p.set('thighR', 0.3 * a); p.set('shinR', 1.5 * (1 - a));
    }
  },
};

export const BRUTE = {
  idle(p, t) {
    const b = Math.sin(t * 1.4);
    p.h[1] = -0.05 + b * 0.01;
    p.set('thighL', -0.2, 0, 0.15); p.set('shinL', 0.35); p.set('footL', -0.15);
    p.set('thighR', -0.2, 0, -0.15); p.set('shinR', 0.35); p.set('footR', -0.15);
    p.set('spine', 0.25 + b * 0.04); p.set('chest', 0.2 + b * 0.03); p.set('neck', -0.3); p.set('head', -0.15, Math.sin(t * 0.4) * 0.3);
    p.set('armL', -0.15, 0, 0.35); p.set('armR', -0.15, 0, -0.35); p.set('foreL', -0.4); p.set('foreR', -0.4);
  },
  move(p, t, c) {
    const ph = c.phase, s = c.gait;
    legs(p, ph, 0.38 + 0.12 * s, 0.7 + 0.3 * s, { base: -0.12, kneeBase: 0.15 });
    p.set('hips', 0, Math.sin(ph) * 0.1, Math.sin(ph) * 0.08);
    p.h[1] = -0.05 - Math.abs(Math.cos(ph)) * 0.06;
    p.set('spine', 0.3 + 0.1 * s, -Math.sin(ph) * 0.12, -Math.sin(ph) * 0.06); p.set('chest', 0.2);
    p.set('neck', -0.35); p.set('head', -0.1);
    p.set('armL', Math.sin(ph) * 0.45 - 0.1, 0, 0.4); p.set('armR', -Math.sin(ph) * 0.45 - 0.1, 0, -0.4);
    p.set('foreL', -0.5); p.set('foreR', -0.5);
  },
  attack(p, t, c) {
    BRUTE.idle(p, t);
    const k = clamp(c.attackT ?? 0, 0, 1);
    let raise, smash;
    if (k < 0.5) { raise = ease(k / 0.5); smash = 0; } else { raise = 1 - easeOut((k - 0.5) / 0.2 > 1 ? 1 : (k - 0.5) / 0.2); smash = k < 0.8 ? easeOut((k - 0.5) / 0.3) : 1 - ease((k - 0.8) / 0.2); }
    p.set('armL', -2.8 * raise - 0.8 * smash, 0, 0.3); p.set('armR', -2.8 * raise - 0.8 * smash, 0, -0.3);
    p.set('foreL', -0.6 * raise); p.set('foreR', -0.6 * raise);
    p.set('spine', 0.25 - 0.4 * raise + 0.6 * smash); p.set('chest', 0.2 - 0.2 * raise + 0.3 * smash);
    p.h[1] = -0.05 - 0.2 * smash;
  },
  slam(p, t, c) {
    const k = clamp(c.attackT ?? 0, 0, 1);
    BRUTE.idle(p, t);
    const up = k < 0.45 ? Math.sin((k / 0.45) * PI * 0.5) : Math.max(0, 1 - (k - 0.45) / 0.12);
    const land = k > 0.55 ? 1 - ease(clamp((k - 0.55) / 0.45, 0, 1)) : 0;
    p.h[1] = 0.35 * up - 0.3 * land;
    p.set('armL', -2.6 * up - 0.5 * land, 0, 0.5); p.set('armR', -2.6 * up - 0.5 * land, 0, -0.5);
    p.set('thighL', -0.6 * up - 0.7 * land); p.set('shinL', 0.9 * up + 1.2 * land);
    p.set('thighR', -0.6 * up - 0.7 * land); p.set('shinR', 0.9 * up + 1.2 * land);
    p.set('spine', -0.2 * up + 0.6 * land); p.set('neck', -0.3 + 0.2 * up);
  },
  roar(p, t, c) { HUMANOID.roar(p, t, c); p.set('thighL', -0.2, 0, 0.2); p.set('thighR', -0.2, 0, -0.2); p.set('shinL', 0.3); p.set('shinR', 0.3); },
  spawn(p, t) { HUMANOID.spawn(p, t); },
  death(p, t) {
    const k = clamp(t / 1.5, 0, 1);
    const a = ease(k);
    p.set('hips', -PI / 2 * a);
    p.h[1] = -0.62 * a; p.h[2] = -0.4 * a;
    p.set('thighL', -0.5 * a); p.set('shinL', 0.6 * a); p.set('thighR', -0.2 * a); p.set('shinR', 0.4 * a);
    p.set('armL', -0.5 * a, 0, 1.2 * a); p.set('armR', -0.5 * a, 0, -1.2 * a);
    p.set('head', 0.5 * a, 0.5 * a);
  },
};

function crawlStance(p, ph, swing, lift) {
  for (const [side, s] of [['L', 1], ['R', -1]]) {
    for (const [a, b, c, off] of [['arm', 'fore', 'hand', 0], ['thigh', 'shin', 'foot', PI]]) {
      const f = ph + off + (side === 'L' ? 0 : PI);
      const sw = Math.sin(f) * swing;
      const lf = Math.max(0, Math.cos(f)) * lift;
      p.set(a + side, -sw * 0.5, s * sw, s * (0.95 + lf));
      p.set(b + side, 0, 0, -s * (1.45 - lf * 0.4));
      p.set(c + side, 0, 0, s * 0.4);
    }
  }
}

export const CRAWLER = {
  idle(p, t) {
    crawlStance(p, t * 0.5, 0.05, 0);
    p.h[1] = -0.12 + Math.sin(t * 2) * 0.015;
    p.set('spine', 0, Math.sin(t * 1.3) * 0.1); p.set('head', Math.sin(t * 0.8) * 0.15, Math.sin(t * 0.6) * 0.4);
    p.set('tail', 0.3 + Math.sin(t * 1.7) * 0.15, Math.sin(t * 1.1) * 0.4); p.set('tail2', 0.4);
  },
  move(p, t, c) {
    const ph = c.phase;
    crawlStance(p, ph, 0.45 + 0.2 * c.gait, 0.5);
    p.h[1] = -0.1 - Math.abs(Math.sin(ph * 2)) * 0.03;
    p.set('spine', 0, Math.sin(ph) * 0.15); p.set('chest', 0, -Math.sin(ph) * 0.1);
    p.set('head', -0.1, -Math.sin(ph) * 0.1);
    p.set('tail', 0.25, Math.sin(ph) * 0.5); p.set('tail2', 0.3, Math.sin(ph - 1) * 0.4);
  },
  attack(p, t, c) {
    const k = clamp(c.attackT ?? 0, 0, 1);
    CRAWLER.idle(p, t);
    const rear = k < 0.4 ? ease(k / 0.4) : 1 - easeOut((k - 0.4) / 0.6);
    p.set('hips', -0.5 * rear);
    p.set('spine', -0.2 * rear); p.set('head', 0.4 * rear);
    for (const [side, s] of [['L', 1], ['R', -1]]) {
      p.set('arm' + side, -1.6 * rear, 0, s * (0.9 - 0.4 * rear));
      p.set('fore' + side, -0.6 * rear, 0, -s * 1.2 * (1 - rear));
    }
    p.h[1] = -0.1 + 0.25 * rear;
  },
  spawn(p, t) { CRAWLER.idle(p, t); p.h[1] = -0.6 * (1 - ease(clamp(t, 0, 1))); },
  roar(p, t, c) { CRAWLER.attack(p, t, { attackT: 0.4 }); },
  death(p, t) {
    const k = ease(clamp(t / 0.9, 0, 1));
    crawlStance(p, 0, 0, 0);
    for (const n of ['armL', 'foreL', 'thighL', 'shinL', 'armR', 'foreR', 'thighR', 'shinR']) {
      const i = p.index[n] * 3;
      p.r[i + 2] *= 1 - k * 1.5;
    }
    p.set('hips', 0, 0, PI * k);
    p.h[1] = -0.25 * k;
    p.set('tail', 0.6 * k); p.set('head', 0.6 * k);
  },
};

export const BLOATER = {
  idle(p, t) {
    const b = Math.sin(t * 2.5);
    p.set('thighL', -0.1, 0, 0.25); p.set('thighR', -0.1, 0, -0.25); p.set('shinL', 0.2); p.set('shinR', 0.2);
    p.set('spine', 0.1 + b * 0.05, 0, b * 0.05); p.set('head', -0.2, Math.sin(t) * 0.4);
    p.set('armL', 0, 0, 0.6 + b * 0.1); p.set('armR', 0, 0, -0.6 - b * 0.1); p.set('foreL', -0.6); p.set('foreR', -0.6);
  },
  move(p, t, c) {
    const ph = c.phase;
    legs(p, ph, 0.45, 0.8, { base: -0.05 });
    p.set('thighL', p.r[p.index.thighL * 3], 0, 0.22); p.set('thighR', p.r[p.index.thighR * 3], 0, -0.22);
    p.set('hips', 0, 0, Math.sin(ph) * 0.18);
    p.set('spine', 0.25, 0, -Math.sin(ph) * 0.15);
    p.set('armL', -0.8 + Math.sin(ph * 2) * 0.4, 0, 0.7); p.set('armR', -0.8 - Math.sin(ph * 2) * 0.4, 0, -0.7);
    p.set('foreL', -0.8); p.set('foreR', -0.8);
    p.set('head', -0.3, Math.sin(ph * 2) * 0.3);
    p.h[1] = -Math.abs(Math.sin(ph)) * 0.06;
  },
  attack(p, t, c) { BLOATER.idle(p, t * 4); },
  spawn(p, t) { HUMANOID.spawn(p, t); },
  roar(p, t, c) { BLOATER.idle(p, t * 3); },
  death(p, t) { HUMANOID.death(p, t); },
};

export const FLYER = {
  idle(p, t) {
    const f = Math.sin(t * 11);
    p.set('wingL', 0, 0, 0.25 + f * 0.75); p.set('wingR', 0, 0, -0.25 - f * 0.75);
    p.set('hips', 0.25); p.set('thighL', 0.3, 0, 0.1); p.set('thighR', 0.45, 0, -0.1); p.set('shinL', 0.9); p.set('shinR', 0.7);
    p.set('footL', 0.6); p.set('footR', 0.6);
    p.set('spine', 0.1); p.set('chest', 0.1 + f * 0.04); p.set('head', -0.3);
    p.set('armL', -0.6, 0, 0.35); p.set('armR', -0.6, 0, -0.35); p.set('foreL', -0.9); p.set('foreR', -0.9);
    p.h[1] = f * 0.06;
  },
  move(p, t, c) {
    const f = Math.sin(t * 15);
    FLYER.idle(p, t);
    p.set('wingL', 0, 0, 0.15 + f * 0.9); p.set('wingR', 0, 0, -0.15 - f * 0.9);
    p.set('hips', 0.7); p.set('head', -0.8);
    p.set('thighL', 0.7); p.set('thighR', 0.8);
  },
  attack(p, t, c) {
    const k = clamp(c.attackT ?? 0, 0, 1);
    FLYER.move(p, t, c);
    const a = Math.sin(PI * k);
    p.set('armL', -1.6 * a - 0.4, 0, 0.3); p.set('armR', -1.6 * a - 0.4, 0, -0.3);
    p.set('foreL', -0.3); p.set('foreR', -0.3);
    p.set('thighL', -0.6 * a + 0.3); p.set('thighR', -0.6 * a + 0.3);
  },
  spawn(p, t) { FLYER.idle(p, t); },
  roar(p, t) { FLYER.idle(p, t * 1.5); },
  death(p, t) {
    const k = ease(clamp(t / 1.0, 0, 1));
    p.set('wingL', 0, 0, 1.4 * k); p.set('wingR', 0, 0, -1.4 * k);
    p.set('hips', 1.2 * k, 0, t * 4);
    p.set('armL', -1, 0, 0.6); p.set('armR', -1, 0, -0.6);
  },
};

export const CLIPSETS = { humanoid: HUMANOID, brute: BRUTE, crawler: CRAWLER, bloater: BLOATER, flyer: FLYER };

// ---------------------------------------------------------------- Animator --
const _v = new THREE.Vector3();
export class Animator {
  constructor(inst, clips, upperClips = null) {
    this.inst = inst;
    this.clips = clips;
    this.upperClips = upperClips;
    const idx = inst.index;
    this.pose = new Pose(idx);
    this.a = new Pose(idx); this.b = new Pose(idx); this.u = new Pose(idx); this.ub = new Pose(idx); this.tmp = new Pose(idx);
    this.cur = null; this.prev = null; this.t = 0; this.pt = 0; this.fade = 1; this.fadeDur = 0.2;
    this.upper = null; this.upperPrev = null; this.ut = 0; this.upt = 0; this.uFade = 1; this.uFadeDur = 0.2; this.uWeight = 0;
    this.additive = []; // {name, w, decay}
    this.ctx = {};
  }

  play(name, fade = 0.2, restart = false) {
    if (name === this.cur && !restart) return;
    this.prev = this.cur; this.pt = this.t;
    this.cur = name; this.t = 0;
    this.fade = this.prev ? 0 : 1; this.fadeDur = fade;
  }

  playUpper(name, fade = 0.18, restart = false) {
    if (name === this.upper && !restart) return;
    this.upperPrev = this.upper; this.upt = this.ut;
    this.upper = name; this.ut = 0;
    this.uFade = this.upperPrev ? 0 : 1; this.uFadeDur = fade;
  }

  impulse(name, strength = 1, decay = 6) {
    for (const a of this.additive) if (a.name === name) { a.w = Math.min(1.5, a.w + strength); return; }
    this.additive.push({ name, w: strength, decay });
  }

  update(dt) {
    const ctx = this.ctx;
    this.t += dt; this.pt += dt;
    this.fade = Math.min(1, this.fade + dt / Math.max(0.001, this.fadeDur));
    const P = this.pose;
    P.zero();
    if (this.cur) this.clips[this.cur](P, this.t, ctx);
    if (this.prev && this.fade < 1) {
      this.b.zero();
      this.clips[this.prev](this.b, this.pt, ctx);
      // pose = lerp(prev, cur, fade)
      this.tmp.copy(this.b).blend(P, ease(this.fade));
      P.copy(this.tmp);
    }
    // upper layer
    const target = this.upper ? 1 : 0;
    this.uWeight += (target - this.uWeight) * Math.min(1, dt * 12);
    if (this.upperClips && (this.upper || this.upperPrev) && this.uWeight > 0.001) {
      this.ut += dt; this.upt += dt;
      this.uFade = Math.min(1, this.uFade + dt / Math.max(0.001, this.uFadeDur));
      this.u.zero();
      if (this.upper) this.upperClips[this.upper](this.u, this.ut, ctx);
      if (this.upperPrev && this.uFade < 1) {
        this.ub.zero();
        this.upperClips[this.upperPrev](this.ub, this.upt, ctx);
        this.ub.blend(this.u, ease(this.uFade));
        this.u.copy(this.ub);
      }
      // Upper layer keeps lower-body spine motion partly (adds instead of replacing spine twist).
      P.blendBones(this.u, this.uWeight, UPPER);
    }
    for (let i = this.additive.length - 1; i >= 0; i--) {
      const a = this.additive[i];
      this.tmp.zero();
      ADDITIVE[a.name](this.tmp, 0, ctx);
      P.addScaled(this.tmp, Math.min(1, a.w));
      a.w -= a.decay * dt;
      if (a.w <= 0) this.additive.splice(i, 1);
    }
    if (ctx.post) ctx.post(P);
    this.apply();
  }

  apply() {
    const { bones, rest } = this.inst;
    const r = this.pose.r;
    for (let i = 0; i < bones.length; i++) {
      bones[i].rotation.set(r[i * 3], r[i * 3 + 1], r[i * 3 + 2]);
    }
    const hips = this.inst.b.hips;
    const hr = rest[this.inst.index.hips];
    hips.position.set(hr.x + this.pose.h[0], hr.y + this.pose.h[1], hr.z + this.pose.h[2]);
  }
}

// ---------------------------------------------------------------- IK --------
const _S = new THREE.Vector3(), _D = new THREE.Vector3(), _N = new THREE.Vector3(), _U = new THREE.Vector3();
const _E = new THREE.Vector3(), _W = new THREE.Vector3(), _X = new THREE.Vector3(), _Y = new THREE.Vector3(), _Z = new THREE.Vector3();
const _M = new THREE.Matrix4(), _Q = new THREE.Quaternion(), _Q2 = new THREE.Quaternion();
const _AX = new THREE.Vector3(1, 0, 0);

// Solves arm (upper bone `arm`, child `fore`, grandchild `hand`) so that the
// wrist reaches `target` (expressed in the arm's parent space). `pole` (same
// space) is where the elbow should point. `handQ` is the desired hand
// orientation in parent space (optional).
export function solveArmIK(arm, fore, hand, target, pole, handQ) {
  const L1 = fore.position.length();
  const L2 = hand.position.length();
  _S.copy(arm.position);
  _D.subVectors(target, _S);
  let d = _D.length();
  if (d < 1e-5) return;
  _D.multiplyScalar(1 / d);
  d = clamp(d, Math.abs(L1 - L2) + 0.01, (L1 + L2) * 0.999);
  _N.subVectors(pole, _S).cross(_D).negate(); // n = d x (pole - S)
  if (_N.lengthSq() < 1e-8) _N.set(1, 0, 0);
  _N.normalize();
  const a = Math.acos(clamp((L1 * L1 + d * d - L2 * L2) / (2 * L1 * d), -1, 1));
  _U.copy(_D).applyAxisAngle(_N, a);
  _E.copy(_S).addScaledVector(_U, L1);
  _W.copy(_S).addScaledVector(_D, d).sub(_E).normalize();
  _Y.copy(_U).negate();
  _Z.copy(_W).addScaledVector(_U, -_W.dot(_U));
  if (_Z.lengthSq() < 1e-8) _Z.copy(_N).cross(_Y);
  _Z.normalize();
  _X.crossVectors(_Y, _Z);
  _M.makeBasis(_X, _Y, _Z);
  arm.quaternion.setFromRotationMatrix(_M);
  const c = Math.acos(clamp((L1 * L1 + L2 * L2 - d * d) / (2 * L1 * L2), -1, 1));
  fore.quaternion.setFromAxisAngle(_AX, -(PI - c));
  if (handQ) {
    _Q.copy(arm.quaternion).multiply(fore.quaternion).invert();
    hand.quaternion.copy(_Q.multiply(handQ));
  }
}

export { smoothstep };
