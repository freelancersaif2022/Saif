export default async ({ page, sleep, st, out }) => {
  await sleep(3000);
  console.log('state', JSON.stringify(await st()));
  await page.screenshot({ path: `${out}-1.png` });
};
