// Drives the real game page in headless Chromium.
// usage: node dev/run.mjs <scenario> [out-prefix] [w] [h] [quality]
import { createRequire } from 'module';
const { chromium } = createRequire('/opt/node22/lib/node_modules/')('playwright');
const [,, scenario = 'smoke', out = '/tmp/claude-0/run', w = '960', h = '540', q = 'MEDIUM'] = process.argv;
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist', '--autoplay-policy=no-user-gesture-required'] });
const page = await browser.newPage({ viewport: { width: +w, height: +h }, hasTouch: true });
const logs = [];
page.on('console', (m) => { if (m.type() !== 'debug') logs.push(m.type() + ': ' + m.text()); });
page.on('pageerror', (e) => logs.push('PAGEERROR: ' + e.message + '\n' + e.stack));
const extra = process.env.EXTRA || '';
const url = `http://127.0.0.1:8765/assets/game/index.html?quality=${q}&seed=1234&fps=1${extra}`;
await page.goto(url);
await page.waitForFunction(() => window.__bridgeLog && window.__bridgeLog.some((m) => m.includes('"ready"')), null, { timeout: 180000 }).catch(() => logs.push('READY TIMEOUT'));
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const st = () => page.evaluate(() => window.game.debug.state());
const mod = await import(`./scenarios/${scenario}.mjs`);
let failed = false;
try {
  await mod.default({ page, sleep, st, out, logs });
} catch (e) { failed = true; logs.push('SCENARIO ERROR: ' + e.stack); }
console.log(logs.filter((l) => !l.includes('GPU stall') && !l.includes('Automatic fallback') && !l.includes('sound failed')).slice(0, 80).join('\n'));
await browser.close();
process.exit(failed ? 1 : 0);
