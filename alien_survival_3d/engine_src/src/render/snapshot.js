// Renders small icons (soldier portrait, weapon and grenade icons) from the
// real 3D models into data URLs for the HUD, using the main renderer and an
// off-screen render target.
import * as THREE from 'three';
import { soldierTemplate, weaponModel, grenadeModel } from '../actors/models.js';
import { instantiate } from '../actors/skeleton.js';

export function capture(renderer, scene, camera, w, h, type = 'image/png') {
  const rt = new THREE.WebGLRenderTarget(w, h, { samples: 0 });
  rt.texture.colorSpace = THREE.SRGBColorSpace;
  const prevRT = renderer.getRenderTarget();
  const prevClear = renderer.getClearAlpha();
  renderer.setClearColor(0x000000, 0);
  renderer.setRenderTarget(rt);
  renderer.clear();
  renderer.render(scene, camera);
  const px = new Uint8Array(w * h * 4);
  renderer.readRenderTargetPixels(rt, 0, 0, w, h, px);
  renderer.setRenderTarget(prevRT);
  renderer.setClearAlpha(prevClear);
  rt.dispose();
  const c = document.createElement('canvas');
  c.width = w; c.height = h;
  const ctx = c.getContext('2d');
  const img = ctx.createImageData(w, h);
  for (let y = 0; y < h; y++) {
    const src = (h - 1 - y) * w * 4;
    img.data.set(px.subarray(src, src + w * 4), y * w * 4);
  }
  ctx.putImageData(img, 0, 0);
  return c.toDataURL(type, 0.9);
}

export function lights(scene) {
  scene.add(new THREE.HemisphereLight(0xdfefff, 0x404030, 1.6));
  const d = new THREE.DirectionalLight(0xffffff, 2.4);
  d.position.set(1.5, 2, 3);
  scene.add(d);
}

export function makeIcons(renderer) {
  const out = { weapons: {} };
  const prevTM = renderer.toneMapping;
  // portrait
  {
    const scene = new THREE.Scene();
    lights(scene);
    const inst = instantiate(soldierTemplate());
    inst.b.head.rotation.y = 0.35;
    inst.b.neck.rotation.x = 0.05;
    scene.add(inst.mesh);
    const cam = new THREE.PerspectiveCamera(24, 1, 0.05, 10);
    cam.position.set(0.32, 1.78, 0.95);
    cam.lookAt(0, 1.72, 0);
    out.portrait = capture(renderer, scene, cam, 128, 128);
  }
  // weapons (side view, barrel to the right)
  for (const id of ['rifle', 'shotgun', 'sniper', 'smg', 'pistol', 'minigun']) {
    const scene = new THREE.Scene();
    lights(scene);
    const m = weaponModel(id);
    m.group.rotation.y = Math.PI / 2;
    scene.add(m.group);
    const box = new THREE.Box3().setFromObject(m.group);
    const c = box.getCenter(new THREE.Vector3());
    const size = box.getSize(new THREE.Vector3());
    const cam = new THREE.OrthographicCamera(-size.x * 0.56, size.x * 0.56, size.x * 0.28, -size.x * 0.28, 0.01, 10);
    cam.position.set(c.x, c.y, c.z + 2);
    cam.lookAt(c);
    out.weapons[id] = capture(renderer, scene, cam, 192, 96);
  }
  {
    const scene = new THREE.Scene();
    lights(scene);
    const gm = grenadeModel();
    gm.rotation.z = -0.3;
    scene.add(gm);
    const cam = new THREE.OrthographicCamera(-0.1, 0.1, 0.1, -0.1, 0.01, 10);
    cam.position.set(0, 0.01, 1);
    cam.lookAt(0, 0.01, 0);
    out.grenade = capture(renderer, scene, cam, 64, 64);
  }
  renderer.toneMapping = prevTM;
  return out;
}
