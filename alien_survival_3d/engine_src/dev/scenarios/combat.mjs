// Spawns aliens, aims at them and fires; verifies damage, kills, drops and HUD.
export default async ({ page, sleep, st, out }) => {
  const ev = (f, ...a) => page.evaluate(f, ...a);
  await sleep(1500);
  const t0 = Date.now();
  let s0 = await st();
  await sleep(4000);
  let s1 = await st();
  console.log('sim seconds per wall second:', ((s1.stats.time - s0.stats.time) / ((Date.now() - t0) / 1000)).toFixed(2), 'fps', s1.fps && s1.fps.toFixed(1), 'draws', s1.drawCalls, 'tris', s1.triangles);
  await ev(() => { window.game.debug.god(true); window.game.debug.startWaveNow(); });
  await sleep(2000);
  console.log('after wave start', JSON.stringify((({ wave, dirState, enemies, queue }) => ({ wave, dirState, enemies, queue }))(await st())));
  await ev(() => window.game.debug.spawn('grunt', 9, 0));
  await sleep(1500);
  await ev(() => window.game.debug.faceNearest());
  await page.screenshot({ path: `${out}-aim.png` });
  // hold fire while tracking the nearest alien
  await ev(() => window.game.debug.press('fire', true));
  for (let i = 0; i < 16; i++) { await ev(() => window.game.debug.faceNearest()); await sleep(250); }
  await page.screenshot({ path: `${out}-firing.png` });
  await ev(() => window.game.debug.press('fire', false));
  const s2 = await st();
  console.log('after firing', JSON.stringify({ mag: s2.mag, reserve: s2.reserve, shots: s2.stats.shotsFired, hits: s2.stats.shotsHit, kills: s2.stats.kills, score: s2.stats.score, pickups: s2.pickups }));
  console.log('enemies', JSON.stringify(await ev(() => window.game.debug.enemies())));
  await sleep(2500);
  await page.screenshot({ path: `${out}-after.png` });
  const s3 = await st();
  console.log('final', JSON.stringify({ hp: s3.health, kills: s3.stats.kills, coins: s3.stats.coins, wave: s3.wave, enemies: s3.enemies, anim: s3.anim, upper: s3.upper }));
};
