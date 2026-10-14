// Pickups, traps, every alien type's pursuit/attack, game over and restart.
export default async ({ page, sleep, st, out }) => {
  const ev = (f, ...a) => page.evaluate(f, ...a);
  const ok = (name, cond, extra = '') => console.log(`${cond ? 'PASS' : 'FAIL'} ${name} ${extra}`);
  await ev(() => { window.game.debug.setTimeScale(3); window.game.debug.director(false); window.game.debug.god(true); });
  await sleep(500);
  // ---- pickups
  await ev(() => { const g = window.game; g.player.health = 40; g.player.armor = 0; g.player.grenades = 1; g.player.weapons[0].reserve = 10; });
  const types = ['health', 'armor', 'ammo', 'grenade', 'coin', 'gem', 'hpboost', 'speed', 'shield'];
  const before = await st();
  for (const t of types) { await ev((t) => window.game.debug.dropAt(t, 0, 0), t); await sleep(1200); }
  const after = await st();
  ok('health pack heals', after.health > before.health, `${before.health}->${after.health}`);
  ok('armor pickup', after.armor > 0, `${after.armor}`);
  ok('ammo pickup', after.reserve > 10, `reserve ${after.reserve}`);
  ok('grenade pickup', after.grenades === 3, `${after.grenades}`);
  ok('coin pickup', after.stats.coins >= 1, `${after.stats.coins}`);
  ok('gem pickup', after.stats.gems === 1);
  ok('shield pickup', after.shield > 0, `${after.shield.toFixed(1)}s`);
  ok('speed pickup', after.speed > 0, `${after.speed.toFixed(1)}s`);
  ok('hp boost raises max hp', await ev(() => window.game.player.maxHealth) === 125);
  // gun upgrade case requires the interact button
  await ev(() => window.game.debug.dropAt('upgrade', 1, 0));
  await sleep(800);
  const interactVisible = await ev(() => !document.querySelector('.btn-interact').classList.contains('hidden'));
  ok('interact button appears near upgrade case', interactVisible);
  await ev(() => { window.game.debug.press('interact'); window.game.debug.press('interact', false); });
  await sleep(800);
  ok('interact collects gun upgrade (overcharge)', await ev(() => window.game.player.overT > 0));
  await page.screenshot({ path: `${out}-pickups.png` });
  // ---- traps (god mode off so damage registers; shield removed)
  await ev(() => { const g = window.game; g.debug.god(false); g.player.shieldT = 0; g.player.health = g.player.maxHealth; g.player.armor = 0; });
  const mines = await ev(() => window.game.debug.props('mine'));
  if (mines.length) {
    const m = mines[0];
    const h0 = (await st()).health;
    await ev((m) => window.game.debug.teleport(m.x + 0.3, m.z), m);
    await sleep(2500);
    const s = await st();
    ok('landmine triggers and damages player', s.health < h0 && s.stats.mines === 1, `hp ${h0}->${s.health}`);
  } else ok('landmine present in streamed world', false);
  await ev(() => { const g = window.game; g.player.health = g.player.maxHealth; });
  const spikes = await ev(() => window.game.debug.props('spikes'));
  if (spikes.length) {
    const p = spikes[0];
    const h0 = (await st()).health;
    await ev((p) => window.game.debug.teleport(p.x, p.z), p);
    await sleep(1500);
    ok('spike trap damages player', (await st()).health < h0);
  } else ok('spike trap present', false);
  await ev(() => { const g = window.game; g.player.health = g.player.maxHealth; });
  const barrels = await ev(() => window.game.debug.props('barrel'));
  if (barrels.length) {
    const b = barrels[0];
    await ev((b) => { const g = window.game; g.debug.teleport(b.x + 12, b.z); const p = g.world.props.find((x) => x.id === b.id); g.props.damage(p, 100, null); }, b);
    await sleep(1500);
    ok('explosive barrel detonates when shot', (await st()).stats.barrels >= 1);
  } else ok('barrel present', false);
  const crates = await ev(() => window.game.debug.props('crate'));
  if (crates.length) {
    const c = crates[0];
    const n0 = (await st()).stats.cratesBroken;
    await ev((c) => window.game.debug.teleport(c.x + 1.6, c.z), c);
    await sleep(600);
    await ev(() => { window.game.debug.press('interact'); window.game.debug.press('interact', false); });
    await sleep(1500);
    ok('crate can be kicked open (interact)', (await st()).stats.cratesBroken > n0);
  }
  // ---- every alien type pursues and attacks
  await ev(() => { const g = window.game; g.debug.god(false); g.player.health = 5000; g.player.maxHealth = 5000; g.player.armor = 0; });
  for (const type of ['grunt', 'runner', 'tank', 'crawler', 'spitter', 'exploder', 'flyer', 'elite', 'boss']) {
    await ev(() => window.game.debug.killAll());
    await sleep(300);
    await ev(() => { const g = window.game; g.player.health = 5000; g.player.shieldT = 0; });
    await ev((t) => window.game.debug.spawn(t, 16, 0.5), type);
    await sleep(400);
    const e0 = (await ev(() => window.game.debug.enemies()))[0];
    const h0 = (await st()).health;
    let minDist = e0 ? e0.dist : 99, hurt = false;
    for (let i = 0; i < 14 && !hurt; i++) {
      await sleep(700);
      const es = await ev(() => window.game.debug.enemies());
      if (es[0]) minDist = Math.min(minDist, es[0].dist);
      hurt = (await st()).health < h0;
    }
    if (type === 'boss') await page.screenshot({ path: `${out}-boss.png` });
    ok(`${type} approaches and damages player`, hurt, `start=${e0 && e0.dist} closest=${minDist.toFixed(1)} hp ${h0}->${(await st()).health}`);
  }
  await ev(() => window.game.debug.killAll());
  // ---- game over -> bridge message -> restart
  await ev(() => window.game.debug.setHealth(0));
  await sleep(4000);
  const log = await ev(() => window.game.debug.bridge());
  const go = log.find((m) => m.includes('"gameOver"'));
  ok('gameOver sent to host with stats', !!go, go ? go.slice(0, 160) : '');
  await page.screenshot({ path: `${out}-dead.png` });
  await ev(() => { document.querySelector('.standalone-over')?.remove(); window.game.restart(); });
  await sleep(1500);
  const r = await st();
  ok('restart resets the run', r.alive && r.stats.kills === 0 && r.health === 100 && r.wave === 0, JSON.stringify({ alive: r.alive, kills: r.stats.kills, hp: r.health }));
};
