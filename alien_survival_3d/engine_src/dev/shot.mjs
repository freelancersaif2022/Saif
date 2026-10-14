// usage: node shot.mjs <html-relative-url> <out.png> [w h]
import { createRequire } from 'module';
const { chromium } = createRequire('/opt/node22/lib/node_modules/')('playwright');
const [,, url, out, w = '1280', h = '720'] = process.argv;
const browser = await chromium.launch({ executablePath: '/opt/pw-browsers/chromium', args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
const page = await browser.newPage({ viewport: { width: +w, height: +h } });
const logs = [];
page.on('console', (m) => logs.push(m.type() + ': ' + m.text()));
page.on('pageerror', (e) => logs.push('pageerror: ' + e.message));
await page.goto(url);
await page.waitForFunction(() => window.__done === true, null, { timeout: 60000 }).catch(() => logs.push('timeout'));
await page.screenshot({ path: out });
console.log(logs.join('\n'));
await browser.close();
