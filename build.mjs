/**
 * Build: src/index.html  ->  index.html
 *
 * Minifies the inline CSS (clean-css) and JS (terser), compacts the JSON-LD,
 * drops HTML comments and collapses whitespace runs.
 *
 * Collapsing a run of whitespace to a single space is exactly what a browser
 * already does for normal-flow text, so it cannot change rendering. There is
 * no <pre> or <textarea> on the page, which are the cases where it would.
 *
 * Run:  node build.mjs
 */
import { readFileSync, writeFileSync } from 'node:fs';
import CleanCSS from 'clean-css';
import { minify as terser } from 'terser';

const SRC = 'src/index.html';
const OUT = 'index.html';

let html = readFileSync(SRC, 'utf8');
const before = Buffer.byteLength(html);

// ---- CSS -------------------------------------------------------------------
let cssBefore = 0, cssAfter = 0;
html = html.replace(/<style>([\s\S]*?)<\/style>/g, (_m, css) => {
  cssBefore += css.length;
  const out = new CleanCSS({ level: 2 }).minify(css);
  if (out.errors.length) throw new Error('CSS: ' + out.errors.join('; '));
  if (out.warnings.length) console.log('  css warnings:', out.warnings.length);
  cssAfter += out.styles.length;
  return `<style>${out.styles}</style>`;
});

// ---- JSON-LD (compact, must stay valid JSON) -------------------------------
html = html.replace(
  /<script type="application\/ld\+json">([\s\S]*?)<\/script>/g,
  (_m, json) => `<script type="application/ld+json">${JSON.stringify(JSON.parse(json))}</script>`
);

// ---- JS --------------------------------------------------------------------
let jsBefore = 0, jsAfter = 0;
const scripts = [...html.matchAll(/<script>([\s\S]*?)<\/script>/g)];
for (const m of scripts) {
  jsBefore += m[1].length;
  const res = await terser(m[1], {
    compress: { passes: 2 },
    mangle: true,
    format: { comments: false },
  });
  if (res.error) throw res.error;
  jsAfter += res.code.length;
  html = html.replace(m[0], `<script>${res.code}</script>`);
}

// ---- HTML ------------------------------------------------------------------
html = html
  .replace(/<!--(?!\[if)[\s\S]*?-->/g, '')   // comments, keeping conditional ones
  .replace(/\s+/g, ' ')                      // whitespace runs -> single space
  .replace(/>\s+</g, '><')                   // and none at all between tags
  .trim();

// Guard: anything that must survive the squeeze.
for (const needle of [
  'google-site-verification', 'island-blob', 'lazy-video',
  'data-src="/assets/mii-scratch.webm"', '@media', 'IntersectionObserver',
]) {
  if (!html.includes(needle)) throw new Error('lost during build: ' + needle);
}

writeFileSync(OUT, html);
const after = Buffer.byteLength(html);
const pct = (a, b) => ((1 - b / a) * 100).toFixed(1) + '%';
console.log(`  CSS   ${cssBefore} -> ${cssAfter} B  (-${pct(cssBefore, cssAfter)})`);
console.log(`  JS    ${jsBefore} -> ${jsAfter} B  (-${pct(jsBefore, jsAfter)})`);
console.log(`  HTML  ${before} -> ${after} B  (-${pct(before, after)})`);
