// Contract test between the Flutter shell and the engine: boots the engine in
// host mode (?host=1) with a mock GameBridge JavaScript channel and the exact
// config produced by GameState.engineConfig() (build/engine_config_*.json).
import { createRequire } from 'module';
import fs from 'fs';
const { chromium } = createRequire('/opt/node22/lib/node_modules/')('playwright');
const root = new URL('../../', import.meta.url).pathname;
const cfg = JSON.parse(fs.readFileSync(root + 'build/engine_config_sample.json', 'utf8'));
const layoutCfg = JSON.parse(fs.readFileSync(root + 'build/engine_config_layout.json', 'utf8'));
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist', '--autoplay-policy=no-user-gesture-required'] });
const ok = (name, cond, extra = '') => console.log(`${cond ? 'PASS' : 'FAIL'} ${name} ${extra}`);
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function boot(config, w = 800, h = 360) {
  const page = await browser.newPage({ viewport: { width: w, height: h }, hasTouch: true });
  page.on('pageerror', (e) => console.log('PAGEERROR', e.message));
  // the mock channel the WebView would inject
  await page.addInitScript(() => {
    window.__hostMsgs = [];
    window.GameBridge = { postMessage: (m) => window.__hostMsgs.push(JSON.parse(m)) };
  });
  await page.goto('http://127.0.0.1:8765/assets/game/index.html?host=1');
  await sleep(500);
  const before = await page.evaluate(() => !!window.game.cfg);
  ok('host mode waits for boot()', before === false);
  await page.evaluate((c) => window.game.boot(c), config);
  await page.waitForFunction(() => window.__hostMsgs.some((m) => m.type === 'ready'), null, { timeout: 180000 });
  return page;
}
const msgs = (page) => page.evaluate(() => window.__hostMsgs);

// ---- play mode
let page = await boot(cfg);
let m = await msgs(page);
ok('loading progress reported', m.filter((x) => x.type === 'loading').length > 3);
ok('ready reported with quality', m.find((x) => x.type === 'ready')?.quality === 'LOW');
const st = await page.evaluate(() => {
  const g = window.game;
  return {
    loadout: g.player.weapons.map((w) => w.def.id), rifleMag: g.player.weapons[0].def.mag, rifleReserve: g.player.weapons[0].reserve,
    shotgunDmg: g.player.weapons[1].def.damage, pistolReserve: g.player.weapons[2].reserve, maxHealth: g.player.maxHealth, grenades: g.player.grenades,
    fireX: g.controls.layout.fire.x, quality: g.qualityName,
  };
});
ok('loadout applied', st.loadout.join() === 'rifle,shotgun,pistol', st.loadout.join());
ok('upgraded magazine applied', st.rifleMag === 39 && st.rifleReserve === 234, `${st.rifleMag}/${st.rifleReserve}`);
ok('upgraded damage applied', Math.abs(st.shotgunDmg - 16.8) < 1e-6);
ok('pistol keeps unlimited reserve', st.pistolReserve === null || st.pistolReserve === Infinity, String(st.pistolReserve));
ok('player upgrades applied', st.maxHealth === 120 && st.grenades === 4);
ok('saved control layout applied', st.fireX === 0.8);
await page.screenshot({ path: '/tmp/claude-0/host-800x360.png' });
await page.evaluate(() => window.game.pause(false));
await sleep(300);
m = await msgs(page);
ok('pause() -> paused message', m.some((x) => x.type === 'paused'));
await page.evaluate(() => window.game.resume());
await sleep(300);
ok('resume() -> resumed message', (await msgs(page)).some((x) => x.type === 'resumed'));
await page.evaluate(() => window.game.setSettings({ musicVolume: 0.1, sensitivity: 2, shoulder: -1, controlScale: 1.3 }));
const s2 = await page.evaluate(() => ({ sens: window.game.cfg.settings.sensitivity, shoulder: window.game.camRig.shoulder, scale: window.game.controls.settings.controlScale }));
ok('setSettings applies live', s2.sens === 2 && s2.shoulder === -1 && s2.scale === 1.3);
await page.evaluate(() => { window.game.debug.setTimeScale(3); window.game.debug.setHealth(0); });
await page.waitForFunction(() => window.__hostMsgs.some((m) => m.type === 'gameOver'), null, { timeout: 60000 }).catch(() => {});
m = await msgs(page);
const go = m.find((x) => x.type === 'gameOver');
ok('gameOver message carries run stats', !!go && 'score' in go.stats && 'accuracy' in go.stats && 'killsByType' in go.stats);
ok('no standalone overlay in host mode', await page.evaluate(() => !document.querySelector('.standalone-over')));
await page.evaluate(() => window.game.restart());
await sleep(500);
ok('restart() -> restarted message', (await msgs(page)).some((x) => x.type === 'restarted'));
await page.evaluate(() => window.game.quit());
await page.close();

// ---- layout editor mode
page = await boot(layoutCfg);
const joy = await page.evaluate(() => { const r = document.querySelector('.btn-jump').getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; });
const cdp = await page.context().newCDPSession(page);
await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: joy[0], y: joy[1], id: 1 }] });
for (let i = 1; i <= 5; i++) await cdp.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x: joy[0] - i * 30, y: joy[1] + i * 10, id: 1 }] });
await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await sleep(300);
m = await msgs(page);
const saved = m.filter((x) => x.type === 'layoutSaved').pop();
ok('dragging a control in layout mode saves its position', saved && Math.abs(saved.layout.jump.x - (joy[0] - 150) / 800) < 0.02, saved ? JSON.stringify(saved.layout.jump) : 'none');
await page.screenshot({ path: '/tmp/claude-0/host-layout.png' });
const done = await page.evaluate(() => { const r = document.querySelector('.layout-bar button[data-a="done"]').getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; });
await cdp.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x: done[0], y: done[1], id: 2 }] });
await cdp.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
await sleep(300);
ok('DONE sends layoutDone', (await msgs(page)).some((x) => x.type === 'layoutDone'));
await browser.close();
