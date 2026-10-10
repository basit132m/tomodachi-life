# tomodachilife-rom.com — Tomodachi Dream Life

Static site. No build step, no framework, no dependencies. Plain HTML + inlined CSS.

## Status

| Piece | State |
|---|---|
| Header | Done |
| Hero banner | Next |
| Rest of homepage | Not started |
| Footer | Not started |

## Files

```
index.html          Homepage. Header + placeholder. All CSS inlined.
assets/logo.webp    Header logo — PLACEHOLDER, must be replaced.
assets/favicon.svg  Browser tab icon.
.htaccess           Compression, cache headers, HTTPS + non-www canonical, 404 routing.
robots.txt          Allow-all + sitemap reference.
sitemap.xml         One URL for now.
404.html            Not-found page (still on the old palette — restyle later).
```

## Header

- Sticky, translucent, blurred backdrop.
- Desktop: logo left, nav centre-right, "Get It Now" pill right.
- Mobile (≤860px): nav collapses to a hamburger that opens a dropdown panel.
- Light and dark mode, following the OS setting.
- Keyboard accessible: skip link, visible focus rings, Escape closes the menu,
  `aria-expanded` reflects state.
- Degrades without JavaScript — the nav stays visible rather than becoming unreachable.

Nav labels and links live in the `<nav id="primary-nav">` block in `index.html`.
The CTA points at `#get-it-now`; change the `href` once there's a real target.

## Local preview

```bash
python3 -m http.server 8000     # http://localhost:8000
```

`.htaccess` rules don't apply locally — test redirects on the live host.
