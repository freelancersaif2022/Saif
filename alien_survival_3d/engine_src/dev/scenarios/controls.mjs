// Multi-touch input, movement, camera drag, reload, weapon switching,
// grenade, crouch/jump/roll and pause/resume.
export default async ({ page, sleep, st, out }) => {
  const ev = (f, ...a) => page.evaluate(f, ...a);
  const cdp = await page.context().newCDPSession(page);
  const touch = (type, points) => cdp.send('Input.dispatchTouchEvent', { type, touchPoints: points.map((p, i) => ({ x: p[0], y: p[1], id: p[2] ?? i })) });
  const center = async (sel) => ev((s) => { const r = document.querySelector(s).getBoundingClientRect(); return [r.left + r.width / 2, r.top + r.height / 2]; }, sel);
  const ok = (name, cond, extra = '') => console.log(`${cond ? 'PASS' : 'FAIL'} ${name} ${extra}`);
  await ev(() => window.game.debug.god(true));
  await sleep(800);
  const joy = await center('.joy');
  const fire = await center('.btn-fire');
  let s0 = await st();
  // joystick up (forward) + fire simultaneously (two touch points)
  await touch('touchStart', [[joy[0], joy[1], 1]]);
  await touch('touchMove', [[joy[0], joy[1] - 50, 1]]);
  await touch('touchStart', [[joy[0], joy[1] - 50, 1], [fire[0], fire[1], 2]]);
  await sleep(5000);
  let s1 = await st();
  await touch('touchEnd', [[fire[0], fire[1], 2]]);
  await touch('touchEnd', [[joy[0], joy[1] - 50, 1]]);
  const moved = Math.hypot(s1.pos[0] - s0.pos[0], s1.pos[2] - s0.pos[2]);
  // forward = camera flat forward (-sin yaw, -cos yaw)
  const fx = -Math.sin(s0.yaw), fz = -Math.cos(s0.yaw);
  const along = ((s1.pos[0] - s0.pos[0]) * fx + (s1.pos[2] - s0.pos[2]) * fz) / (moved || 1);
  ok('joystick moves player camera-forward', moved > 0.5 && along > 0.8, `moved=${moved.toFixed(2)} along=${along.toFixed(2)}`);
  ok('multi-touch fire while moving', s1.stats.shotsFired > s0.stats.shotsFired, `shots=${s1.stats.shotsFired}`);
  // camera drag on the right side
  const W = page.viewportSize().width, H = page.viewportSize().height;
  const yaw0 = (await st()).yaw;
  await touch('touchStart', [[W * 0.55, H * 0.3, 3]]);
  for (let i = 1; i <= 5; i++) { await touch('touchMove', [[W * 0.55 + i * 20, H * 0.3, 3]]); await sleep(60); }
  await touch('touchEnd', [[W * 0.55 + 100, H * 0.3, 3]]);
  await sleep(400);
  const yaw1 = (await st()).yaw;
  ok('drag rotates camera', Math.abs(yaw1 - yaw0) > 0.1, `dyaw=${(yaw1 - yaw0).toFixed(3)}`);
  // reload
  const sR = await st();
  await ev(() => window.game.debug.press('reload')); await ev(() => window.game.debug.press('reload', false));
  await ev(() => window.game.debug.setTimeScale(3));
  await sleep(3500);
  const sR2 = await st();
  ok('reload refills magazine', sR2.mag === 30 && sR2.reserve < sR.reserve, `mag ${sR.mag}->${sR2.mag} reserve ${sR.reserve}->${sR2.reserve}`);
  // weapon switching through the loadout and firing each
  const seen = [];
  for (let k = 0; k < 3; k++) {
    await ev(() => window.game.debug.press('switch')); await ev(() => window.game.debug.press('switch', false));
    await sleep(2500);
    const s = await st();
    seen.push(s.weapon);
    const before = s.stats.shotsFired;
    await ev(() => window.game.debug.press('fire')); await sleep(1500); await ev(() => window.game.debug.press('fire', false));
    await sleep(800);
    const after = (await st()).stats.shotsFired;
    ok(`fire ${s.weapon}`, after > before, `shots ${before}->${after}`);
  }
  ok('weapon switch cycles loadout', seen.join(',') === 'shotgun,pistol,rifle', seen.join(','));
  await page.screenshot({ path: `${out}-1.png` });
  // grenade
  const g0 = (await st()).grenades;
  await ev(() => window.game.debug.spawn('grunt', 8, 0));
  await ev(() => window.game.debug.press('grenade')); await ev(() => window.game.debug.press('grenade', false));
  await sleep(4500);
  const g1 = await st();
  ok('grenade thrown and exploded', g1.grenades === g0 - 1 && g1.stats.grenadesThrown === 1, `grenades ${g0}->${g1.grenades}`);
  // crouch, jump, roll
  await ev(() => window.game.debug.press('crouch')); await ev(() => window.game.debug.press('crouch', false));
  await sleep(1000);
  ok('crouch toggles', (await st()).crouch === true);
  await page.screenshot({ path: `${out}-crouch.png` });
  await ev(() => window.game.debug.press('jump')); await ev(() => window.game.debug.press('jump', false));
  await sleep(600);
  ok('jump from crouch stands up', (await st()).crouch === false);
  await ev(() => window.game.debug.press('jump')); await ev(() => window.game.debug.press('jump', false));
  await sleep(150);
  const sj = await st();
  ok('jump leaves ground', sj.onGround === false || sj.anim === 'jump', `anim=${sj.anim}`);
  await sleep(1500);
  const p0 = (await st()).pos;
  await ev(() => window.game.debug.press('roll')); await ev(() => window.game.debug.press('roll', false));
  await sleep(250);
  const sr = await st();
  await sleep(1200);
  const p1 = (await st()).pos;
  ok('roll dashes', sr.anim === 'roll' || Math.hypot(p1[0] - p0[0], p1[2] - p0[2]) > 2, `anim=${sr.anim} dist=${Math.hypot(p1[0] - p0[0], p1[2] - p0[2]).toFixed(2)}`);
  // pause / resume through the HUD pause button (touch)
  const pb = await center('.pause-btn');
  await touch('touchStart', [[pb[0], pb[1], 5]]); await touch('touchEnd', [[pb[0], pb[1], 5]]);
  await sleep(500);
  const sp = await st();
  const t0 = sp.stats.time;
  await sleep(1500);
  const sp2 = await st();
  ok('pause button pauses (time frozen)', sp.paused && sp2.stats.time === t0, `paused=${sp.paused}`);
  ok('bridge got paused message', (await ev(() => window.game.debug.bridge())).some((m) => m.includes('"paused"')));
  await ev(() => window.game.resume());
  await sleep(1500);
  ok('resume continues', (await st()).stats.time > t0);
};
