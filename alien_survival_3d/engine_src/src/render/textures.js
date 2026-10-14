// Procedurally painted textures (canvas). All art in the game is generated at
// startup, so the app ships no third-party image assets.
import * as THREE from 'three';
import { makeNoise2D, fbm, rng } from '../core/math.js';

const cache = new Map();

function canvas(size, h = size) {
  const c = document.createElement('canvas');
  c.width = size; c.height = h;
  return c;
}

function toTexture(c, { repeat = true, srgb = true } = {}) {
  const t = new THREE.CanvasTexture(c);
  if (repeat) t.wrapS = t.wrapT = THREE.RepeatWrapping;
  t.colorSpace = srgb ? THREE.SRGBColorSpace : THREE.NoColorSpace;
  t.anisotropy = 4;
  t.needsUpdate = true;
  return t;
}

// Fill with a per-pixel function returning grey value 0..255 (tileable via
// sampling noise on a torus).
function paintGrey(size, seed, fn) {
  const c = canvas(size);
  const ctx = c.getContext('2d');
  const img = ctx.createImageData(size, size);
  const n = makeNoise2D(seed);
  const TAU = Math.PI * 2;
  // Tileable 2D noise: blend four samples (cheap and good enough for detail maps).
  const tile = (u, v, f) => {
    const a = n(u * f, v * f), b = n((u - 1) * f, v * f);
    const c2 = n(u * f, (v - 1) * f), d = n((u - 1) * f, (v - 1) * f);
    const ix = u * u * (3 - 2 * u), iy = v * v * (3 - 2 * v);
    return (a * (1 - ix) + b * ix) * (1 - iy) + (c2 * (1 - ix) + d * ix) * iy;
  };
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      const v = fn(x / size, y / size, tile, TAU) | 0;
      const i = (y * size + x) * 4;
      const g = v < 0 ? 0 : v > 255 ? 255 : v;
      img.data[i] = img.data[i + 1] = img.data[i + 2] = g;
      img.data[i + 3] = 255;
    }
  }
  ctx.putImageData(img, 0, 0);
  return c;
}

function cached(name, make) {
  if (!cache.has(name)) cache.set(name, make());
  return cache.get(name);
}

export const Textures = {
  ground: () => cached('ground', () => toTexture(paintGrey(256, 11, (u, v, tile) => {
    const base = 190 + 40 * tile(u, v, 8) + 25 * tile(u, v, 32);
    return base;
  }))),

  fabric: () => cached('fabric', () => toTexture(paintGrey(128, 3, (u, v, tile) => {
    const weave = (Math.sin(u * 128 * Math.PI) * Math.sin(v * 128 * Math.PI)) * 14;
    return 205 + weave + 30 * tile(u, v, 6) + 12 * tile(u, v, 24);
  }))),

  skin: () => cached('skin', () => toTexture(paintGrey(128, 5, (u, v, tile) => 225 + 18 * tile(u, v, 10) + 8 * tile(u, v, 40)))),

  bark: () => cached('bark', () => toTexture(paintGrey(128, 7, (u, v, tile) => {
    const ridges = Math.abs(Math.sin(u * Math.PI * 10 + tile(u, v, 4) * 3));
    return 120 + 110 * ridges + 20 * tile(u, v, 24);
  }))),

  rock: () => cached('rock', () => toTexture(paintGrey(256, 13, (u, v, tile) => {
    const cracks = Math.abs(tile(u, v, 6));
    return 150 + 70 * tile(u, v, 3) + 40 * tile(u, v, 16) - (cracks < 0.05 ? 60 : 0);
  }))),

  alien: () => cached('alien', () => toTexture(paintGrey(256, 17, (u, v, tile) => {
    // Chitin plates: cellular-looking ridges plus fine grain.
    const cell = Math.abs(tile(u, v, 10));
    const ridge = cell < 0.07 ? 90 : 0;
    return 215 - ridge + 30 * tile(u, v, 30);
  }))),

  metal: () => cached('metal', () => toTexture(paintGrey(128, 19, (u, v, tile) => 200 + 30 * tile(u * 0.1, v * 4, 20) + 10 * tile(u, v, 40)))),

  wood: () => cached('wood', () => {
    const c = canvas(256);
    const ctx = c.getContext('2d');
    const r = rng(23);
    ctx.fillStyle = '#7a5230';
    ctx.fillRect(0, 0, 256, 256);
    for (let i = 0; i < 4; i++) {
      // planks
      ctx.fillStyle = `hsl(28, ${35 + r() * 15}%, ${26 + r() * 10}%)`;
      ctx.fillRect(0, i * 64 + 2, 256, 60);
      for (let g = 0; g < 40; g++) {
        ctx.strokeStyle = `rgba(40,20,5,${0.15 + r() * 0.25})`;
        ctx.lineWidth = 1 + r();
        ctx.beginPath();
        const y = i * 64 + 4 + r() * 56;
        ctx.moveTo(0, y);
        ctx.bezierCurveTo(80, y + r() * 6 - 3, 170, y + r() * 6 - 3, 256, y + r() * 4 - 2);
        ctx.stroke();
      }
      ctx.fillStyle = 'rgba(20,10,0,0.7)';
      ctx.fillRect(0, i * 64, 256, 2);
    }
    return toTexture(c);
  }),

  crate: () => cached('crate', () => {
    const c = canvas(256);
    const ctx = c.getContext('2d');
    const r = rng(29);
    ctx.fillStyle = '#9a6a3a';
    ctx.fillRect(0, 0, 256, 256);
    for (let i = 0; i < 5; i++) {
      ctx.fillStyle = `hsl(30, 45%, ${32 + r() * 10}%)`;
      ctx.fillRect(0, i * 51 + 2, 256, 48);
      for (let g = 0; g < 18; g++) {
        ctx.strokeStyle = `rgba(50,25,5,${0.2 + r() * 0.2})`;
        ctx.beginPath();
        const y = i * 51 + 4 + r() * 44;
        ctx.moveTo(0, y); ctx.lineTo(256, y + r() * 4 - 2); ctx.stroke();
      }
    }
    ctx.strokeStyle = '#5a3a1a';
    ctx.lineWidth = 22;
    ctx.strokeRect(11, 11, 234, 234);
    ctx.lineWidth = 18;
    ctx.beginPath(); ctx.moveTo(20, 20); ctx.lineTo(236, 236); ctx.stroke();
    ctx.fillStyle = '#2a2a2a';
    for (const [x, y] of [[11, 11], [245, 11], [11, 245], [245, 245]]) {
      ctx.beginPath(); ctx.arc(x, y, 5, 0, Math.PI * 2); ctx.fill();
    }
    return toTexture(c, { repeat: false });
  }),

  barrel: () => cached('barrel', () => {
    const c = canvas(256, 128);
    const ctx = c.getContext('2d');
    const g = ctx.createLinearGradient(0, 0, 256, 0);
    g.addColorStop(0, '#8f1010'); g.addColorStop(0.5, '#d42a1a'); g.addColorStop(1, '#8f1010');
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, 256, 128);
    ctx.fillStyle = 'rgba(0,0,0,0.35)';
    ctx.fillRect(0, 18, 256, 6); ctx.fillRect(0, 104, 256, 6);
    // hazard placard
    ctx.fillStyle = '#f2c21b';
    ctx.beginPath(); ctx.moveTo(64, 38); ctx.lineTo(90, 88); ctx.lineTo(38, 88); ctx.closePath(); ctx.fill();
    ctx.strokeStyle = '#111'; ctx.lineWidth = 3; ctx.stroke();
    ctx.fillStyle = '#111';
    ctx.font = 'bold 30px sans-serif'; ctx.textAlign = 'center';
    ctx.fillText('!', 64, 84);
    ctx.fillStyle = '#f2c21b';
    ctx.beginPath(); ctx.moveTo(192, 38); ctx.lineTo(218, 88); ctx.lineTo(166, 88); ctx.closePath(); ctx.fill();
    ctx.stroke();
    ctx.fillStyle = '#111'; ctx.fillText('!', 192, 84);
    const r = rng(31);
    for (let i = 0; i < 60; i++) {
      ctx.fillStyle = `rgba(60,30,10,${r() * 0.4})`;
      ctx.fillRect(r() * 256, r() * 128, 2 + r() * 8, 1 + r() * 3);
    }
    return toTexture(c, { repeat: false });
  }),

  medkit: () => cached('medkit', () => {
    const c = canvas(128);
    const ctx = c.getContext('2d');
    ctx.fillStyle = '#d61f1f'; ctx.fillRect(0, 0, 128, 128);
    ctx.fillStyle = '#fff';
    ctx.fillRect(48, 22, 32, 84); ctx.fillRect(22, 48, 84, 32);
    return toTexture(c, { repeat: false });
  }),

  ammo: () => cached('ammo', () => {
    const c = canvas(128);
    const ctx = c.getContext('2d');
    ctx.fillStyle = '#3f5a26'; ctx.fillRect(0, 0, 128, 128);
    ctx.fillStyle = '#e8c547';
    ctx.font = 'bold 26px sans-serif'; ctx.textAlign = 'center';
    ctx.fillText('AMMO', 64, 74);
    ctx.strokeStyle = '#2a3d18'; ctx.lineWidth = 8; ctx.strokeRect(4, 4, 120, 120);
    return toTexture(c, { repeat: false });
  }),

  muzzle: () => cached('muzzle', () => {
    const c = canvas(128);
    const ctx = c.getContext('2d');
    const g = ctx.createRadialGradient(64, 64, 2, 64, 64, 64);
    g.addColorStop(0, 'rgba(255,255,230,1)');
    g.addColorStop(0.25, 'rgba(255,200,80,0.95)');
    g.addColorStop(0.6, 'rgba(255,110,20,0.4)');
    g.addColorStop(1, 'rgba(255,60,0,0)');
    ctx.fillStyle = g;
    ctx.save();
    ctx.translate(64, 64);
    for (let i = 0; i < 6; i++) {
      ctx.rotate(Math.PI / 3);
      ctx.beginPath();
      ctx.moveTo(-10, 0); ctx.lineTo(0, -64); ctx.lineTo(10, 0); ctx.closePath();
      ctx.fill();
    }
    ctx.restore();
    ctx.beginPath(); ctx.arc(64, 64, 34, 0, Math.PI * 2); ctx.fill();
    return toTexture(c, { repeat: false });
  }),

  glow: () => cached('glow', () => {
    const c = canvas(64);
    const ctx = c.getContext('2d');
    const g = ctx.createRadialGradient(32, 32, 0, 32, 32, 32);
    g.addColorStop(0, 'rgba(255,255,255,1)');
    g.addColorStop(0.4, 'rgba(255,255,255,0.45)');
    g.addColorStop(1, 'rgba(255,255,255,0)');
    ctx.fillStyle = g; ctx.fillRect(0, 0, 64, 64);
    return toTexture(c, { repeat: false });
  }),

  scorch: () => cached('scorch', () => {
    const c = canvas(128);
    const ctx = c.getContext('2d');
    const r = rng(37);
    for (let i = 0; i < 40; i++) {
      const a = r() * Math.PI * 2, d = r() * 40;
      const g = ctx.createRadialGradient(64 + Math.cos(a) * d, 64 + Math.sin(a) * d, 0, 64 + Math.cos(a) * d, 64 + Math.sin(a) * d, 10 + r() * 22);
      g.addColorStop(0, 'rgba(10,8,6,0.5)');
      g.addColorStop(1, 'rgba(10,8,6,0)');
      ctx.fillStyle = g; ctx.fillRect(0, 0, 128, 128);
    }
    return toTexture(c, { repeat: false });
  }),

  patch: (color) => cached('patch' + color, () => {
    const c = canvas(64);
    const ctx = c.getContext('2d');
    ctx.fillStyle = '#2c3320'; ctx.fillRect(0, 0, 64, 64);
    ctx.fillStyle = color; ctx.fillRect(6, 6, 52, 52);
    ctx.fillStyle = '#2c3320'; ctx.fillRect(14, 28, 36, 8); ctx.fillRect(28, 14, 8, 36);
    return toTexture(c, { repeat: false });
  }),
};

// Grey noise generator reused by the terrain colour pass.
export { fbm };
