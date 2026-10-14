import * as THREE from 'three';
import { soldierTemplate, alienTemplate, weaponModel } from '../src/actors/models.js';
import { instantiate } from '../src/actors/skeleton.js';
import { Animator, SOLDIER_BASE, SOLDIER_UPPER, CLIPSETS, solveArmIK } from '../src/actors/anim.js';
import { ENEMIES } from '../src/core/config.js';

const params = new URLSearchParams(location.search);
const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: true });
renderer.setSize(1280, 720);
renderer.outputColorSpace = THREE.SRGBColorSpace;
renderer.toneMapping = THREE.ACESFilmicToneMapping;
document.body.appendChild(renderer.domElement);
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x101418);
const cam = new THREE.PerspectiveCamera(35, 1280 / 720, 0.05, 100);
scene.add(new THREE.HemisphereLight(0xcfe3ff, 0x3a3020, 1.4));
const sun = new THREE.DirectionalLight(0xffffff, 2.2); sun.position.set(3, 6, 4); scene.add(sun);
const ground = new THREE.Mesh(new THREE.PlaneGeometry(40, 40), new THREE.MeshStandardMaterial({ color: 0x3a4a2a }));
ground.rotation.x = -Math.PI / 2; scene.add(ground);

const mode = params.get('m') || 'soldier';
const clip = params.get('clip') || 'idle';
const upper = params.get('upper') || '';
const t = parseFloat(params.get('t') || '0.5');
const ctx = { gait: parseFloat(params.get('gait') || '1'), phase: parseFloat(params.get('phase') || '0.8'), weapon: params.get('w') || 'rifle', attackT: t, reloadT: t, throwT: t, switchT: t };

function soldier(x, rotY, base, up, w) {
  const inst = instantiate(soldierTemplate());
  inst.mesh.position.x = x; inst.mesh.rotation.y = rotY;
  scene.add(inst.mesh);
  const an = new Animator(inst, SOLDIER_BASE, SOLDIER_UPPER);
  Object.assign(an.ctx, ctx, { weapon: w });
  const gun = weaponModel(w);
  const pivot = new THREE.Object3D();
  inst.b.chest.add(pivot);
  pivot.add(gun.group);
  an.play(base, 0); if (up) an.playUpper(up, 0); an.uWeight = up ? 1 : 0;
  an.update(t);
  const P = an.pose;
  pivot.position.set(P.g[0], P.g[1], P.g[2]); pivot.rotation.set(P.g[3], P.g[4], P.g[5]);
  if (up) {
    pivot.updateMatrix();
    const handAlign = new THREE.Quaternion().setFromEuler(new THREE.Euler(-1.25, 0, 0));
    const hq = pivot.quaternion.clone().multiply(handAlign);
    const up1 = new THREE.Vector3(0, 1, 0).applyQuaternion(hq).multiplyScalar(0.07);
    const gR = gun.sockets.grip.clone().applyMatrix4(pivot.matrix).add(up1);
    const gL = gun.sockets.fore.clone().applyMatrix4(pivot.matrix).add(up1);
    if (P.lh[3] > 0) gL.lerp(new THREE.Vector3(P.lh[0], P.lh[1], P.lh[2]), P.lh[3]);
    if (P.rh[3] > 0) gR.lerp(new THREE.Vector3(P.rh[0], P.rh[1], P.rh[2]), P.rh[3]);
    const b = inst.b;
    solveArmIK(b.armR, b.foreR, b.handR, gR, new THREE.Vector3(-0.6, -0.3, -0.4), hq);
    solveArmIK(b.armL, b.foreL, b.handL, gL, new THREE.Vector3(0.5, -0.5, -0.2), hq);
  } else pivot.visible = false;
  return inst;
}

if (mode === 'soldier') {
  const views = [0, Math.PI, Math.PI / 2, -Math.PI / 2];
  views.forEach((r, i) => soldier(-3 + i * 2, r, clip, upper, ctx.weapon));
  cam.position.set(0, 1.4, 9); cam.lookAt(0, 0.95, 0);
} else if (mode === 'close') {
  soldier(0, parseFloat(params.get('ry') || '0.6'), clip, upper, ctx.weapon);
  cam.position.set(0, 1.5, 3.2); cam.lookAt(0, 1.1, 0);
} else if (mode === 'aliens') {
  const ids = Object.keys(ENEMIES);
  ids.forEach((id, i) => {
    const def = ENEMIES[id];
    const inst = instantiate(alienTemplate(def));
    inst.mesh.scale.setScalar(id === 'boss' ? 1.2 : def.scale);
    inst.mesh.position.set(-8 + i * 2, 0, 0);
    inst.mesh.rotation.y = parseFloat(params.get('ry') || '0.3');
    scene.add(inst.mesh);
    const an = new Animator(inst, CLIPSETS[def.rig]);
    Object.assign(an.ctx, ctx);
    an.play(clip in CLIPSETS[def.rig] ? clip : 'idle', 0);
    an.update(t);
  });
  cam.position.set(0, 2.5, 13); cam.lookAt(0, 1, 0);
} else if (mode === 'weapons') {
  ['rifle', 'shotgun', 'sniper', 'smg', 'pistol', 'minigun'].forEach((id, i) => {
    const g = weaponModel(id).group;
    g.position.set(-1.6 + (i % 3) * 1.2, 1.4 - Math.floor(i / 3) * 0.6, 0);
    g.rotation.y = -Math.PI / 2;
    scene.add(g);
  });
  cam.position.set(-0.4, 1.1, 3.0); cam.lookAt(-0.4, 1.1, 0);
}
renderer.render(scene, cam);
window.__done = true;
