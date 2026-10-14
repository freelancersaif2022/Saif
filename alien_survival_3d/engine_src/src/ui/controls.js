// Multi-touch controls (virtual joystick, action buttons, camera drag) plus
// keyboard/mouse for desktop testing. Button size, opacity and placement are
// configurable; a layout editor lets players drag every control.
import { ICONS } from './icons.js';

export const DEFAULT_LAYOUT = {
  joystick: { x: 0.12, y: 0.74 },
  sprint: { x: 0.27, y: 0.52 },
  fire: { x: 0.885, y: 0.66 },
  aim: { x: 0.765, y: 0.83 },
  reload: { x: 0.745, y: 0.585 },
  jump: { x: 0.955, y: 0.4 },
  crouch: { x: 0.84, y: 0.4 },
  roll: { x: 0.955, y: 0.9 },
  grenade: { x: 0.64, y: 0.86 },
  switch: { x: 0.64, y: 0.66 },
  interact: { x: 0.55, y: 0.52 },
};

const BUTTONS = {
  fire: { size: 96, icon: 'fire', label: '' },
  aim: { size: 60, icon: 'aim' },
  reload: { size: 56, icon: 'reload' },
  jump: { size: 56, icon: 'jump' },
  crouch: { size: 56, icon: 'crouch' },
  roll: { size: 52, icon: 'roll' },
  grenade: { size: 56, icon: 'grenade' },
  switch: { size: 52, icon: 'switch' },
  sprint: { size: 52, icon: 'sprint' },
  interact: { size: 64, icon: 'interact' },
};

export class Controls {
  constructor(root, settings, onLayoutSaved) {
    this.root = root;
    this.settings = settings;
    this.onLayoutSaved = onLayoutSaved;
    this.layout = { ...DEFAULT_LAYOUT, ...(settings.layout || {}) };
    this.state = {
      moveX: 0, moveY: 0, sprint: false, fire: false, aim: false, lookDX: 0, lookDY: 0,
      pressed: new Set(), crouch: false,
    };
    this.touches = new Map(); // touch id -> role
    this.editing = false;
    this.enabled = true;
    this.keys = new Set();
    this.el = document.createElement('div');
    this.el.className = 'controls';
    root.appendChild(this.el);
    this._buildJoystick();
    this.buttons = {};
    this.extra = []; // HUD elements that act as buttons (pause, weapon panel)
    for (const [id, def] of Object.entries(BUTTONS)) this._buildButton(id, def);
    this.applyLayout();
    this._bindTouch();
    this._bindKeyboard();
    window.addEventListener('resize', () => this.applyLayout());
  }

  _buildJoystick() {
    const j = document.createElement('div');
    j.className = 'joy';
    j.innerHTML = '<div class="joy-ring"><span class="joy-arrow up"></span><span class="joy-arrow down"></span><span class="joy-arrow left"></span><span class="joy-arrow right"></span></div><div class="joy-knob"></div>';
    this.el.appendChild(j);
    this.joy = j;
    this.knob = j.querySelector('.joy-knob');
    j.dataset.ctl = 'joystick';
  }

  _buildButton(id, def) {
    const b = document.createElement('div');
    b.className = `btn btn-${id}`;
    b.dataset.ctl = id;
    b.innerHTML = ICONS[def.icon] + (id === 'grenade' ? '<span class="btn-badge" data-badge="grenade">3</span>' : '');
    this.el.appendChild(b);
    this.buttons[id] = b;
  }

  scale() {
    const base = Math.min(window.innerWidth, window.innerHeight) / 400;
    return Math.max(0.6, Math.min(1.6, base)) * (this.settings.controlScale || 1);
  }

  applyLayout() {
    const sc = this.scale();
    const W = window.innerWidth, H = window.innerHeight;
    const place = (el, id, size) => {
      const p = this.layout[id] || DEFAULT_LAYOUT[id];
      el.style.width = el.style.height = `${size}px`;
      el.style.left = `${Math.round(p.x * W - size / 2)}px`;
      el.style.top = `${Math.round(p.y * H - size / 2)}px`;
    };
    this.joySize = 150 * sc;
    place(this.joy, 'joystick', this.joySize);
    for (const [id, def] of Object.entries(BUTTONS)) place(this.buttons[id], id, def.size * sc);
    this.el.style.opacity = this.settings.controlOpacity ?? 0.85;
  }

  registerExtra(id, el) { this.extra.push({ id, el }); }

  setInteractVisible(v) { this.buttons.interact.classList.toggle('hidden', !v && !this.editing); }
  setActive(id, on) { this.buttons[id] && this.buttons[id].classList.toggle('on', !!on); }
  setBadge(name, value) { const e = this.el.querySelector(`[data-badge="${name}"]`); if (e) e.textContent = value; }

  consume(name) {
    if (this.state.pressed.has(name)) { this.state.pressed.delete(name); return true; }
    return false;
  }

  takeLook() {
    const dx = this.state.lookDX, dy = this.state.lookDY;
    this.state.lookDX = 0; this.state.lookDY = 0;
    return [dx, dy];
  }

  // ---------------------------------------------------------------- touch --
  _bindTouch() {
    const opts = { passive: false };
    const target = this.root;
    target.addEventListener('touchstart', (e) => this._onTouchStart(e), opts);
    target.addEventListener('touchmove', (e) => this._onTouchMove(e), opts);
    target.addEventListener('touchend', (e) => this._onTouchEnd(e), opts);
    target.addEventListener('touchcancel', (e) => this._onTouchEnd(e), opts);
    // Pointer (mouse) fallback for desktop: buttons are clickable and the
    // canvas drag rotates the camera.
    target.addEventListener('mousedown', (e) => this._onMouseDown(e));
    window.addEventListener('mousemove', (e) => this._onMouseMove(e));
    window.addEventListener('mouseup', (e) => this._onMouseUp(e));
    target.addEventListener('contextmenu', (e) => e.preventDefault());
  }

  _ctlAt(x, y) {
    const sc = this.scale();
    // Joystick capture zone is generous: the whole lower-left region.
    const jp = this.layout.joystick;
    const jx = jp.x * window.innerWidth, jy = jp.y * window.innerHeight;
    if (!this.editing) {
      for (const { id, el } of this.extra) {
        const r = el.getBoundingClientRect();
        if (r.width && x >= r.left && x <= r.right && y >= r.top && y <= r.bottom) return id;
      }
    }
    for (const [id, b] of Object.entries(this.buttons)) {
      if (b.classList.contains('hidden')) continue;
      const r = b.getBoundingClientRect();
      const pad = 6 * sc;
      if (x >= r.left - pad && x <= r.right + pad && y >= r.top - pad && y <= r.bottom + pad) return id;
    }
    if (Math.hypot(x - jx, y - jy) < this.joySize * 0.95 || (this.editing ? false : x < window.innerWidth * 0.36 && y > window.innerHeight * 0.38)) return 'joystick';
    return 'look';
  }

  _press(id, down) {
    const s = this.state;
    switch (id) {
      case 'fire': s.fire = down; break;
      case 'sprint': if (down) s.sprint = !s.sprint; break;
      case 'crouch': if (down) s.pressed.add('crouch'); break;
      case 'aim': if (down) s.aim = !s.aim; break;
      default: if (down) s.pressed.add(id);
    }
    if (this.buttons[id] && id !== 'sprint' && id !== 'aim') this.buttons[id].classList.toggle('down', down);
    if (down && this.onButton) this.onButton(id);
  }

  _onTouchStart(e) {
    if (!this.enabled) return;
    e.preventDefault();
    if (this.onFirstInput) this.onFirstInput();
    for (const t of e.changedTouches) {
      const role = this._ctlAt(t.clientX, t.clientY);
      if (this.editing) {
        if (role !== 'look') this.touches.set(t.identifier, { role: 'drag', id: role, x: t.clientX, y: t.clientY });
        continue;
      }
      const info = { role, x: t.clientX, y: t.clientY, sx: t.clientX, sy: t.clientY };
      this.touches.set(t.identifier, info);
      if (role === 'joystick') this._joyMove(t.clientX, t.clientY);
      else if (role !== 'look') this._press(role, true);
    }
  }

  _onTouchMove(e) {
    if (!this.enabled) return;
    e.preventDefault();
    for (const t of e.changedTouches) {
      const info = this.touches.get(t.identifier);
      if (!info) continue;
      if (info.role === 'drag') { this._dragTo(info.id, t.clientX, t.clientY); continue; }
      if (info.role === 'joystick') this._joyMove(t.clientX, t.clientY);
      else if (info.role === 'look' || info.role === 'fire') {
        // Fire button doubles as a look pad so players can aim while shooting.
        this.state.lookDX += t.clientX - info.x;
        this.state.lookDY += t.clientY - info.y;
      }
      info.x = t.clientX; info.y = t.clientY;
    }
  }

  _onTouchEnd(e) {
    e.preventDefault();
    for (const t of e.changedTouches) {
      const info = this.touches.get(t.identifier);
      if (!info) continue;
      this.touches.delete(t.identifier);
      if (info.role === 'drag') { this._saveLayout(); continue; }
      if (info.role === 'joystick') this._joyRelease();
      else if (info.role !== 'look') this._press(info.role, false);
    }
  }

  _joyMove(x, y) {
    const p = this.layout.joystick;
    const cx = p.x * window.innerWidth, cy = p.y * window.innerHeight;
    const R = this.joySize * 0.42;
    let dx = (x - cx) / R, dy = (y - cy) / R;
    const len = Math.hypot(dx, dy);
    const dead = 0.12;
    if (len > 1) { dx /= len; dy /= len; }
    const mag = Math.min(1, len);
    const k = mag < dead ? 0 : (mag - dead) / (1 - dead) / Math.max(mag, 1e-6);
    this.state.moveX = dx * k * Math.min(1, len);
    this.state.moveY = -dy * k * Math.min(1, len);
    // Pushing the stick past its rim triggers sprint.
    this.state.stickSprint = len > 1.25;
    this.knob.style.transform = `translate(${dx * R}px, ${dy * R}px)`;
    this.joy.classList.add('active');
  }

  _joyRelease() {
    this.state.moveX = 0; this.state.moveY = 0; this.state.stickSprint = false;
    this.knob.style.transform = 'translate(0px, 0px)';
    this.joy.classList.remove('active');
  }

  _dragTo(id, x, y) {
    this.layout[id] = { x: Math.min(0.97, Math.max(0.03, x / window.innerWidth)), y: Math.min(0.97, Math.max(0.05, y / window.innerHeight)) };
    this.applyLayout();
  }

  _saveLayout() {
    if (this.onLayoutSaved) this.onLayoutSaved({ ...this.layout });
  }

  setEditing(on) {
    this.editing = on;
    this.el.classList.toggle('editing', on);
    this.setInteractVisible(on);
    this._joyRelease();
  }

  resetLayout() {
    this.layout = { ...DEFAULT_LAYOUT };
    this.applyLayout();
    this._saveLayout();
  }

  // --------------------------------------------------------------- mouse --
  _onMouseDown(e) {
    if (!this.enabled) return;
    if (this.onFirstInput) this.onFirstInput();
    const role = this._ctlAt(e.clientX, e.clientY);
    if (this.editing) {
      if (role !== 'look') this.mouse = { role: 'drag', id: role };
      return;
    }
    if (role !== 'look' && role !== 'joystick') { this.mouse = { role }; this._press(role, true); return; }
    if (role === 'joystick') { this.mouse = { role }; this._joyMove(e.clientX, e.clientY); return; }
    this.mouse = { role: 'look', x: e.clientX, y: e.clientY };
    if (e.button === 0 && this.pointerLocked) this.state.fire = true;
    if (e.button === 2) this.state.aim = !this.state.aim;
  }

  _onMouseMove(e) {
    if (this.pointerLocked) {
      this.state.lookDX += e.movementX; this.state.lookDY += e.movementY;
      return;
    }
    if (!this.mouse) return;
    if (this.mouse.role === 'drag') { this._dragTo(this.mouse.id, e.clientX, e.clientY); return; }
    if (this.mouse.role === 'joystick') { this._joyMove(e.clientX, e.clientY); return; }
    if (this.mouse.role === 'look' || this.mouse.role === 'fire') {
      this.state.lookDX += e.clientX - (this.mouse.x ?? e.clientX);
      this.state.lookDY += e.clientY - (this.mouse.y ?? e.clientY);
      this.mouse.x = e.clientX; this.mouse.y = e.clientY;
    }
  }

  _onMouseUp(e) {
    if (this.pointerLocked && e.button === 0) this.state.fire = false;
    if (!this.mouse) return;
    if (this.mouse.role === 'drag') this._saveLayout();
    else if (this.mouse.role === 'joystick') this._joyRelease();
    else if (this.mouse.role !== 'look') this._press(this.mouse.role, false);
    this.mouse = null;
  }

  // ------------------------------------------------------------ keyboard --
  _bindKeyboard() {
    const map = { KeyR: 'reload', Space: 'jump', KeyC: 'crouch', KeyG: 'grenade', KeyQ: 'switch', KeyE: 'interact', KeyV: 'roll', Escape: 'pause', KeyP: 'pause' };
    window.addEventListener('keydown', (e) => {
      if (!this.enabled || e.repeat) return;
      if (this.onFirstInput) this.onFirstInput();
      this.keys.add(e.code);
      if (map[e.code]) this._press(map[e.code], true);
      if (e.code === 'ShiftLeft') this.state.keySprint = true;
      if (e.code === 'KeyF') this.state.fire = true;
      if (e.code === 'KeyZ') this.state.aim = !this.state.aim;
      if (e.code === 'KeyL' && document.pointerLockElement == null && this.root.requestPointerLock) this.root.requestPointerLock();
      this._keyMove();
    });
    window.addEventListener('keyup', (e) => {
      this.keys.delete(e.code);
      if (map[e.code]) this._press(map[e.code], false);
      if (e.code === 'ShiftLeft') this.state.keySprint = false;
      if (e.code === 'KeyF') this.state.fire = false;
      this._keyMove();
    });
    document.addEventListener('pointerlockchange', () => { this.pointerLocked = document.pointerLockElement === this.root; });
  }

  _keyMove() {
    const k = this.keys;
    const x = (k.has('KeyD') || k.has('ArrowRight') ? 1 : 0) - (k.has('KeyA') || k.has('ArrowLeft') ? 1 : 0);
    const y = (k.has('KeyW') || k.has('ArrowUp') ? 1 : 0) - (k.has('KeyS') || k.has('ArrowDown') ? 1 : 0);
    if (x || y || this.state.keyMoving) {
      const l = Math.hypot(x, y) || 1;
      this.state.moveX = x / l; this.state.moveY = y / l;
      this.state.keyMoving = !!(x || y);
    }
  }

  wantsSprint() { return this.state.sprint || this.state.stickSprint || this.state.keySprint; }

  reset() {
    this.state.fire = false; this.state.aim = false; this.state.sprint = false;
    this.state.pressed.clear();
    this.touches.clear();
    this._joyRelease();
    for (const b of Object.values(this.buttons)) b.classList.remove('down', 'on');
  }
}
