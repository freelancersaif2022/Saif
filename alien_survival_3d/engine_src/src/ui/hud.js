// In-game HUD (DOM over the WebGL canvas), styled after the reference sheet:
// dark translucent panels, neon lime (#D1FE17) accents, red health and blue
// armor bars, soldier portrait, weapon + ammo, grenades, wave / kills / timer /
// score, coins, radar, crosshair, hit markers, damage direction, boss bar.
import { ICONS } from './icons.js';

const el = (tag, cls, html = '') => {
  const e = document.createElement(tag);
  if (cls) e.className = cls;
  if (html) e.innerHTML = html;
  return e;
};

const fmtTime = (t) => {
  const m = Math.floor(t / 60), s = Math.floor(t % 60);
  return `${m}:${s < 10 ? '0' : ''}${s}`;
};

export class Hud {
  constructor(root, game) {
    this.game = game;
    this.root = el('div', 'hud');
    root.appendChild(this.root);
    const r = this.root;
    this.cache = {};

    // top-left: wave / kills / time / score
    this.stats = el('div', 'panel stats', `
      <div class="stat"><i>${ICONS.wave}</i><span data-k="wave">WAVE 1</span></div>
      <div class="stat"><i>${ICONS.skull}</i><span data-k="kills">0</span></div>
      <div class="stat"><i>${ICONS.clock}</i><span data-k="time">0:00</span></div>
      <div class="stat score"><span data-k="score">0</span><b data-k="combo"></b></div>
      <div class="remaining" data-k="remaining"></div>`);
    r.appendChild(this.stats);

    // top-right: coins, gems, radar, pause
    this.wallet = el('div', 'panel wallet', `
      <div class="stat coin"><i>${ICONS.coin}</i><span data-k="coins">0</span></div>
      <div class="stat gem"><i>${ICONS.gem}</i><span data-k="gems">0</span></div>`);
    r.appendChild(this.wallet);
    this.radarWrap = el('div', 'radar');
    this.radar = el('canvas');
    this.radar.width = this.radar.height = 128;
    this.radarWrap.appendChild(this.radar);
    r.appendChild(this.radarWrap);
    this.pauseBtn = el('div', 'pause-btn', ICONS.pause);
    r.appendChild(this.pauseBtn);
    this.fps = el('div', 'fps');
    r.appendChild(this.fps);

    // bottom: portrait + bars, weapon panel, grenades
    this.vitals = el('div', 'panel vitals', `
      <div class="portrait"><img data-k="portrait" alt=""/></div>
      <div class="bars">
        <div class="bar hp"><i>${ICONS.heart}</i><div class="fill"></div><span data-k="hp">100/100</span></div>
        <div class="bar ar"><i>${ICONS.shield}</i><div class="fill"></div><span data-k="ar">0/100</span></div>
        <div class="buffs" data-k="buffs"></div>
      </div>`);
    r.appendChild(this.vitals);
    this.weaponPanel = el('div', 'panel weapon', `
      <img data-k="wicon" alt=""/>
      <div class="ammo"><i>${ICONS.bullets}</i><span data-k="ammo">30/120</span></div>
      <div class="nades"><img data-k="nicon" alt=""/><span data-k="nades">3</span></div>
      <div class="wname" data-k="wname"></div>`);
    r.appendChild(this.weaponPanel);
    this.nadePanel = this.weaponPanel.querySelector('.nades');

    // centre
    this.cross = el('div', 'crosshair', '<span class="c t"></span><span class="c b"></span><span class="c l"></span><span class="c r"></span><span class="dot"></span>');
    r.appendChild(this.cross);
    this.hit = el('div', 'hitmarker', '<span></span><span></span><span></span><span></span>');
    r.appendChild(this.hit);
    this.dmgRing = el('div', 'dmg-ring');
    r.appendChild(this.dmgRing);
    this.vignette = el('div', 'vignette');
    r.appendChild(this.vignette);
    this.scope = el('div', 'scope', '<div class="scope-lens"><span class="sh"></span><span class="sv"></span></div>');
    r.appendChild(this.scope);
    this.bannerEl = el('div', 'banner', '<div class="b-title"></div><div class="b-sub"></div>');
    r.appendChild(this.bannerEl);
    this.countEl = el('div', 'countdown');
    r.appendChild(this.countEl);
    this.feed = el('div', 'killfeed');
    r.appendChild(this.feed);
    this.toasts = el('div', 'toasts');
    r.appendChild(this.toasts);
    this.boss = el('div', 'bossbar', '<div class="bname">HIVE TITAN</div><div class="btrack"><div class="bfill"></div></div>');
    r.appendChild(this.boss);
    this.prompt = el('div', 'prompt');
    r.appendChild(this.prompt);

    this.q = {};
    for (const e of r.querySelectorAll('[data-k]')) this.q[e.dataset.k] = e;
    this.hpFill = this.vitals.querySelector('.hp .fill');
    this.arFill = this.vitals.querySelector('.ar .fill');
    this.bossFill = this.boss.querySelector('.bfill');
    this.bannerT = 0; this.hitT = 0; this.dmgT = 0; this.radarT = 0; this.fpsT = 0; this.frames = 0;
    this.spread = 0;
    this.show(true);
  }

  show(on) { this.root.style.display = on ? '' : 'none'; }

  setImages(portrait, weaponIcons, grenadeIcon) {
    this.weaponIcons = weaponIcons;
    if (portrait) this.q.portrait.src = portrait;
    if (grenadeIcon) this.q.nicon.src = grenadeIcon;
    this.weaponChanged();
  }

  _set(k, v) {
    if (this.cache[k] === v) return;
    this.cache[k] = v;
    this.q[k].textContent = v;
  }

  weaponChanged() {
    const w = this.game.player?.weapon;
    if (!w) return;
    if (this.weaponIcons && this.weaponIcons[w.def.id]) this.q.wicon.src = this.weaponIcons[w.def.id];
    this._set('wname', w.def.name.toUpperCase());
  }

  banner(title, sub, danger) {
    this.bannerEl.querySelector('.b-title').textContent = title;
    this.bannerEl.querySelector('.b-sub').textContent = sub || '';
    this.bannerEl.classList.toggle('danger', !!danger);
    this.bannerEl.classList.remove('show');
    void this.bannerEl.offsetWidth;
    this.bannerEl.classList.add('show');
    this.bannerT = 3;
  }

  countdown(n) {
    if (n === null) { this.countEl.textContent = ''; return; }
    const txt = `NEXT WAVE IN ${n}`;
    if (this.countEl.textContent !== txt) this.countEl.textContent = txt;
  }

  hitMarker(head, killed) {
    this.hit.classList.toggle('head', head);
    this.hit.classList.toggle('kill', !!killed);
    this.hitT = killed ? 0.3 : 0.15;
    this.hit.style.opacity = 1;
    this.game.sfx('hitmarker', null, killed ? 1 : 0.6);
  }

  damage(from, pos, yaw, amount) {
    this.dmgT = 0.6;
    this.vignette.style.opacity = Math.min(0.85, 0.35 + amount / 50);
    if (from) {
      const ang = Math.atan2(from.x - pos.x, from.z - pos.z);
      // relative to camera forward (camera looks along -Z at yaw 0 => angle yaw+PI)
      const rel = ang - (yaw + Math.PI);
      this.dmgRing.style.transform = `translate(-50%, -50%) rotate(${-rel}rad)`;
      this.dmgRing.style.opacity = 1;
    }
  }

  killFeed(name, pts, combo) {
    const row = el('div', 'kf', `<b>${name.toUpperCase()}</b> +${pts}${combo > 1.01 ? ` <em>x${combo.toFixed(2).replace(/0$/, '')}</em>` : ''}`);
    this.feed.prepend(row);
    while (this.feed.children.length > 4) this.feed.lastChild.remove();
    setTimeout(() => row.classList.add('fade'), 2200);
    setTimeout(() => row.remove(), 2800);
  }

  toast(text, color) {
    const t = el('div', 'toast', text);
    t.style.borderColor = '#' + color.toString(16).padStart(6, '0');
    this.toasts.appendChild(t);
    while (this.toasts.children.length > 3) this.toasts.firstChild.remove();
    setTimeout(() => t.classList.add('fade'), 1600);
    setTimeout(() => t.remove(), 2200);
  }

  bossBar(e) {
    if (!e || !e.alive) { this.boss.classList.remove('show'); return; }
    this.boss.classList.add('show');
    this.bossFill.style.width = `${Math.max(0, (e.hp / e.maxHp) * 100)}%`;
  }

  setPrompt(text) {
    if (this.cache.prompt === text) return;
    this.cache.prompt = text;
    this.prompt.textContent = text || '';
    this.prompt.classList.toggle('show', !!text);
  }

  update(dt) {
    const g = this.game, P = g.player, st = g.stats, d = g.director;
    // FPS from wall-clock time (dt is clamped and may be time-scaled)
    const now = performance.now();
    this.frames++;
    this.fpsStart = this.fpsStart || now;
    this.fpsT = (now - this.fpsStart) / 1000;
    if (this.fpsT >= 0.5) {
      this.fpsValue = this.frames / this.fpsT;
      this.fpsStart = now;
      if (g.cfg.settings.showFps) this.fps.textContent = `${Math.round(this.fpsValue)} FPS`;
      else if (this.fps.textContent) this.fps.textContent = '';
      this.frames = 0; this.fpsT = 0;
    }
    this._set('wave', `WAVE ${Math.max(1, st.wave)}`);
    this._set('kills', String(st.kills));
    this._set('time', fmtTime(st.time));
    this._set('score', st.score.toLocaleString('en-US'));
    this._set('combo', d.combo > 1.01 ? `x${d.combo.toFixed(1)}` : '');
    this._set('remaining', d.state === 'active' ? `${d.remaining()} ALIENS LEFT` : '');
    this._set('coins', String(st.coins));
    this._set('gems', String(st.gems));
    const hp = Math.max(0, Math.ceil(P.health));
    this._set('hp', `${hp}/${P.maxHealth}`);
    this._set('ar', `${Math.ceil(P.armor)}/${P.maxArmor}`);
    const hpw = `${(Math.max(0, P.health) / P.maxHealth) * 100}%`;
    if (this.cache.hpw !== hpw) { this.cache.hpw = hpw; this.hpFill.style.width = hpw; }
    const arw = `${(P.armor / P.maxArmor) * 100}%`;
    if (this.cache.arw !== arw) { this.cache.arw = arw; this.arFill.style.width = arw; }
    const w = P.weapon;
    this._set('ammo', `${w.mag}/${w.reserve === Infinity ? '∞' : w.reserve}`);
    this.weaponPanel.classList.toggle('empty', w.mag === 0);
    this.weaponPanel.classList.toggle('reloading', P.reloadT >= 0);
    this._set('nades', String(P.grenades));
    g.controls.setBadge('grenade', P.grenades);
    const buffs = `${P.shieldT > 0 ? `<b class="sh">SHIELD ${Math.ceil(P.shieldT)}</b>` : ''}${P.speedT > 0 ? `<b class="sp">SPEED ${Math.ceil(P.speedT)}</b>` : ''}${P.overT > 0 ? `<b class="ov">OVERCHARGE ${Math.ceil(P.overT)}</b>` : ''}`;
    if (this.cache.buffs !== buffs) { this.cache.buffs = buffs; this.q.buffs.innerHTML = buffs; }

    // crosshair spread follows weapon spread and movement
    const def = w.def;
    const moving = Math.hypot(P.vel.x, P.vel.z) > 1;
    const target = (P.aiming ? def.spreadAim : def.spreadHip) * (moving ? 1.25 : 1) * (P.crouch ? 0.7 : 1) * (P.onGround ? 1 : 1.8);
    this.spread += (target - this.spread) * Math.min(1, dt * 12);
    const px = 6 + this.spread * 9 + (g.player.fireCd > 0 ? 4 : 0);
    if (Math.abs((this.cache.px || 0) - px) > 0.3) { this.cache.px = px; this.cross.style.setProperty('--gap', `${px}px`); }
    const scoped = g.camRig.scoped;
    this.scope.classList.toggle('show', scoped);
    this.cross.classList.toggle('hide', scoped || !P.alive || P.sprinting);

    if (this.hitT > 0) { this.hitT -= dt; if (this.hitT <= 0) this.hit.style.opacity = 0; }
    if (this.dmgT > 0) {
      this.dmgT -= dt;
      if (this.dmgT <= 0) { this.vignette.style.opacity = 0; this.dmgRing.style.opacity = 0; }
    }
    const low = P.alive && P.health < P.maxHealth * 0.3;
    this.root.classList.toggle('lowhp', low);
    if (low) g.audio.loop('heart', 'low_health', 1, 'sfx'); else g.audio.stopLoop('heart');
    if (this.bannerT > 0) { this.bannerT -= dt; if (this.bannerT <= 0) this.bannerEl.classList.remove('show'); }

    this.radarT -= dt;
    if (this.radarT <= 0) { this.radarT = 0.1; this._drawRadar(); }
  }

  _drawRadar() {
    const g = this.game, P = g.player;
    const c = this.radar.getContext('2d');
    const S = 128, R = 60, range = 45;
    c.clearRect(0, 0, S, S);
    c.save();
    c.translate(S / 2, S / 2);
    c.fillStyle = 'rgba(8,14,10,0.72)';
    c.beginPath(); c.arc(0, 0, R, 0, Math.PI * 2); c.fill();
    c.strokeStyle = 'rgba(209,254,23,0.35)'; c.lineWidth = 1;
    for (const k of [0.33, 0.66]) { c.beginPath(); c.arc(0, 0, R * k, 0, Math.PI * 2); c.stroke(); }
    c.beginPath(); c.moveTo(-R, 0); c.lineTo(R, 0); c.moveTo(0, -R); c.lineTo(0, R); c.stroke();
    // sweep
    const sweep = (g.time * 2) % (Math.PI * 2);
    const grad = c.createConicGradient ? c.createConicGradient(sweep - Math.PI / 2, 0, 0) : null;
    if (grad) {
      grad.addColorStop(0, 'rgba(209,254,23,0.25)'); grad.addColorStop(0.12, 'rgba(209,254,23,0)'); grad.addColorStop(1, 'rgba(209,254,23,0)');
      c.fillStyle = grad; c.beginPath(); c.arc(0, 0, R, 0, Math.PI * 2); c.fill();
    }
    c.strokeStyle = '#D1FE17'; c.lineWidth = 2;
    c.beginPath(); c.arc(0, 0, R, 0, Math.PI * 2); c.stroke();
    // world -> radar: rotate so camera forward is up
    const yaw = g.camRig.yaw;
    const cs = Math.cos(yaw), sn = Math.sin(yaw);
    const plot = (x, z) => {
      const dx = x - P.pos.x, dz = z - P.pos.z;
      const rx = dx * cs - dz * sn, rz = dx * sn + dz * cs;
      return [(rx / range) * R, (rz / range) * R];
    };
    for (const it of g.pickups.items) {
      if (!it.active || it.type === 'coin') continue;
      const [x, y] = plot(it.pos.x, it.pos.z);
      if (x * x + y * y > R * R) continue;
      c.fillStyle = '#ffd23a';
      c.fillRect(x - 2, y - 2, 4, 4);
    }
    for (const e of g.enemies.active) {
      if (!e.alive) continue;
      let [x, y] = plot(e.pos.x, e.pos.z);
      const l = Math.hypot(x, y);
      if (l > R - 3) { x *= (R - 3) / l; y *= (R - 3) / l; }
      const boss = e.def.behavior === 'boss';
      c.fillStyle = boss ? '#ff2ee6' : '#ff3b2f';
      c.beginPath(); c.arc(x, y, boss ? 5 : e.def.rig === 'brute' ? 3.5 : 2.6, 0, Math.PI * 2); c.fill();
    }
    c.fillStyle = '#D1FE17';
    c.beginPath(); c.moveTo(0, -6); c.lineTo(4.5, 5); c.lineTo(0, 2.5); c.lineTo(-4.5, 5); c.closePath(); c.fill();
    c.restore();
  }
}
