// Third-person over-the-shoulder camera: orbit yaw/pitch from drag input,
// smooth follow, aim zoom (sniper scope), shoulder swap, collision against
// terrain and obstacles, and trauma-based shake.
import * as THREE from 'three';
import { clamp, damp, DEG, makeNoise2D } from '../core/math.js';

const noise = makeNoise2D(99);
const _pivot = new THREE.Vector3();
const _dir = new THREE.Vector3();
const _right = new THREE.Vector3();
const _want = new THREE.Vector3();

export class CameraRig {
  constructor(camera, world, settings) {
    this.camera = camera;
    this.world = world;
    this.settings = settings;
    this.yaw = 0;
    this.pitch = -0.12;
    this.dist = 3.4;
    this.curDist = 3.4;
    this.shoulder = settings.shoulder ?? 1;
    this.curShoulder = this.shoulder;
    this.aimT = 0;
    this.trauma = 0;
    this.time = 0;
    this.pivot = new THREE.Vector3();
    this.fovBase = settings.fov ?? 70;
    this.zoomFov = 50;
    this.scoped = false;
    this.recoilPitch = 0;
    this.recoilYaw = 0;
  }

  addLook(dx, dy, aiming) {
    const s = this.settings;
    const sens = 0.0042 * (s.sensitivity ?? 1) * (aiming ? (s.aimSensitivity ?? 0.6) * (this.scoped ? 0.35 : 1) : 1);
    this.yaw -= dx * sens;
    this.pitch -= dy * sens * (s.invertY ? -1 : 1);
    this.pitch = clamp(this.pitch, -1.15, 0.85);
  }

  kick(pitch, yaw) {
    this.recoilPitch += pitch;
    this.recoilYaw += yaw;
  }

  shake(amount) {
    this.trauma = Math.min(1, this.trauma + amount * (this.settings.cameraShake ?? 1));
  }

  forward(out) {
    return out.set(-Math.sin(this.yaw) * Math.cos(this.pitch), Math.sin(this.pitch), -Math.cos(this.yaw) * Math.cos(this.pitch));
  }

  // Flat camera-relative basis used for movement.
  flatForward(out) { return out.set(-Math.sin(this.yaw), 0, -Math.cos(this.yaw)); }
  flatRight(out) { return out.set(Math.cos(this.yaw), 0, -Math.sin(this.yaw)); }

  update(dt, player, aiming, zoomFov, scoped) {
    this.time += dt;
    // recoil recovers smoothly
    const rp = this.recoilPitch * damp(10, dt), ry = this.recoilYaw * damp(10, dt);
    this.pitch = clamp(this.pitch + rp, -1.15, 0.85); this.yaw += ry;
    this.recoilPitch -= rp; this.recoilYaw -= ry;

    this.aimT += ((aiming ? 1 : 0) - this.aimT) * damp(12, dt);
    this.scoped = scoped && this.aimT > 0.6;
    this.curShoulder += (this.shoulder - this.curShoulder) * damp(8, dt);
    const crouch = player.crouchT;
    const pivotH = 1.62 - 0.45 * crouch + (player.state === 'dead' ? -0.9 : 0);
    _pivot.set(player.pos.x, player.pos.y + pivotH, player.pos.z);
    this.pivot.lerp(_pivot, this.pivot.lengthSq() === 0 ? 1 : damp(18, dt));

    const dist = THREE.MathUtils.lerp(3.3, this.scoped ? 0.2 : 1.55, this.aimT) + (player.state === 'dead' ? 2.5 : 0);
    const side = THREE.MathUtils.lerp(0.62, this.scoped ? 0.12 : 0.5, this.aimT) * this.curShoulder;
    this.forward(_dir);
    this.flatRight(_right);
    // Desired camera position: behind the pivot along the view direction, offset to the shoulder.
    const origin = _want.copy(this.pivot).addScaledVector(_right, side);
    origin.y += 0.08;
    // collision: march from the shoulder point back to the desired distance
    let allowed = dist;
    const back = _dir.clone().negate();
    const hitT = this.world.raycastTerrain(origin, back, dist + 0.3);
    if (hitT >= 0) allowed = Math.min(allowed, Math.max(0.3, hitT - 0.35));
    const hitC = this.world.colliders.raycast(origin.x, origin.y, origin.z, back.x, back.y, back.z, dist + 0.3, (c) => c.kind !== 'rail' && c.r > 0.2);
    if (hitC) allowed = Math.min(allowed, Math.max(0.3, hitC.t - 0.3));
    // Shrink immediately on collision, extend smoothly.
    this.curDist = allowed < this.curDist ? allowed : this.curDist + (allowed - this.curDist) * damp(4, dt);
    const cam = this.camera;
    cam.position.copy(origin).addScaledVector(back, this.curDist);
    // never under the terrain
    const gy = this.world.height(cam.position.x, cam.position.z) + 0.25;
    if (cam.position.y < gy) cam.position.y = gy;

    // shake
    this.trauma = Math.max(0, this.trauma - dt * 1.6);
    const sh = this.trauma * this.trauma;
    const t = this.time * 22;
    const sx = noise(t, 1.7) * 0.06 * sh, sy = noise(t, 9.1) * 0.06 * sh, sr = noise(t, 4.4) * 0.05 * sh;
    cam.position.x += sx; cam.position.y += sy;
    _want.copy(cam.position).add(_dir);
    cam.lookAt(_want);
    cam.rotateZ(sr);

    const fov = THREE.MathUtils.lerp(this.settings.fov ?? 70, zoomFov, this.aimT);
    if (Math.abs(cam.fov - fov) > 0.05) { cam.fov = fov; cam.updateProjectionMatrix(); }
    cam.updateMatrixWorld();
  }
}

export { DEG };
