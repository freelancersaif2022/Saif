export default async ({ page }) => {
  const r = await page.evaluate(() => [...document.querySelectorAll('.btn, .joy')].map((b) => { const r = b.getBoundingClientRect(); const s = b.querySelector('svg')?.getBoundingClientRect(); return `${b.className} ${Math.round(r.left)},${Math.round(r.top)} ${Math.round(r.width)}x${Math.round(r.height)} svg:${s ? Math.round(s.width) + 'x' + Math.round(s.height) : '-'}`; }));
  console.log(r.join('\n'));
};
