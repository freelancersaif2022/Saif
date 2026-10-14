// Bundles the engine into a single classic script that the Flutter app serves
// to its WebView from assets/game/. Run: npm run build
import * as esbuild from 'esbuild';

const watch = process.argv.includes('--watch');
const options = {
  entryPoints: ['src/main.js'],
  bundle: true,
  format: 'iife',
  target: ['es2020', 'chrome90'],
  minify: !watch,
  sourcemap: watch ? 'inline' : false,
  legalComments: 'eof',
  outfile: '../assets/game/game.js',
  logLevel: 'info',
};

if (watch) {
  const ctx = await esbuild.context(options);
  await ctx.watch();
} else {
  await esbuild.build(options);
}
