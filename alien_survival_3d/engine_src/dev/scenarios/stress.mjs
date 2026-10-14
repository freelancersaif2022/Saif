// Fills the alien cap and reports renderer load (draw calls, triangles,
// geometries, textures, JS heap) to check pooling keeps memory flat.
export default async ({ page, sleep }) => {
  const ev = (f, ...a) => page.evaluate(f, ...a);
  await ev(() => { window.game.debug.god(true); window.game.debug.director(false); window.game.debug.setTimeScale(4); });
  const types = ['grunt', 'runner', 'tank', 'crawler', 'spitter', 'exploder', 'flyer', 'elite'];
  const report = async (label) => {
    const r = await ev(() => { const i = window.game.renderer.info; return { calls: i.render.calls, tris: i.render.triangles, geos: i.memory.geometries, tex: i.memory.textures, heap: performance.memory ? Math.round(performance.memory.usedJSHeapSize / 1e6) : -1, enemies: window.game.enemies.aliveCount }; });
    console.log(label, JSON.stringify(r));
    return r;
  };
  await report('baseline');
  for (let round = 0; round < 3; round++) {
    for (let i = 0; i < 26; i++) await ev(([t, i]) => window.game.debug.spawn(t, 8 + (i % 5) * 4, (i / 26) * Math.PI * 2), [types[i % types.length], i]);
    await sleep(2500);
    await report(`round ${round} full`);
    await ev(() => window.game.debug.killAll());
    await page.waitForFunction(() => window.game.enemies.active.length === 0, null, { timeout: 120000 });
  }
  const pools = await ev(() => [...window.game.enemies.pools.values()].reduce((n, p) => n + p.length, 0));
  console.log('pooled alien instances after 78 spawns:', pools);
  await report('after');
};
