// Renders the Flutter UI art (menu backdrop, alien / soldier / weapon images)
// from the real 3D models via the engine's showcase mode.
// usage: node dev/render_ui_assets.mjs   (expects the dev http server on :8765)
import { createRequire } from 'module';
import fs from 'fs';
const { chromium } = createRequire('/opt/node22/lib/node_modules/')('playwright');
const OUT = new URL('../../assets/images/', import.meta.url).pathname;
fs.mkdirSync(OUT, { recursive: true });
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const save = (name, dataUrl) => { fs.writeFileSync(OUT + name, Buffer.from(dataUrl.split(',')[1], 'base64')); console.log('wrote', name); };
async function open(w, h, seed) {
  const page = await browser.newPage({ viewport: { width: w, height: h } });
  page.on('pageerror', (e) => console.log('pageerror', e.message));
  await page.goto(`http://127.0.0.1:8765/assets/game/index.html?quality=HIGH&mode=showcase&seed=${seed}`);
  await page.waitForFunction(() => window.__bridgeLog && window.__bridgeLog.some((m) => m.includes('"ready"')), null, { timeout: 180000 });
  await page.waitForTimeout(3000);
  return page;
}
const page = await open(1600, 720, 77);
save('menu_bg.jpg', await page.evaluate(() => window.game.showcase('menu')));
for (const id of ['grunt', 'runner', 'tank', 'crawler', 'spitter', 'exploder', 'flyer', 'elite', 'boss']) save(`alien_${id}.png`, await page.evaluate((id) => window.game.showcase('alien', id), id));
for (const id of ['rifle', 'shotgun', 'sniper', 'smg', 'pistol', 'minigun']) save(`weapon_${id}.png`, await page.evaluate((id) => window.game.showcase('weapon', id), id));
save('soldier.png', await page.evaluate(() => window.game.showcase('soldier', 'rifle')));
await browser.close();
