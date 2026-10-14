export default async ({ page, sleep, out }) => {
  const ev = (f, ...a) => page.evaluate(f, ...a);
  await ev(() => { window.game.debug.god(true); window.game.debug.setTimeScale(2); window.game.debug.startWaveNow(); });
  await sleep(1500);
  await ev(() => { window.game.debug.spawn('grunt', 9, 0.15); window.game.debug.spawn('tank', 14, -0.2); window.game.debug.spawn('runner', 11, 0.35); });
  await sleep(2500);
  await ev(() => window.game.debug.press('fire'));
  await sleep(600);
  await page.screenshot({ path: `${out}.png` });
  await ev(() => window.game.debug.press('fire', false));
  const s = await ev(() => window.game.debug.state());
  console.log('draws', s.drawCalls, 'tris', s.triangles, 'enemies', s.enemies);
};
