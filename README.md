# tomodachilife-rom.com

A static, single-page guide site targeting the **Tomodachi Life ROM / emulation**
keyword cluster. No game files are hosted or linked — the site ranks on guide
content, not downloads.

## Why static instead of WordPress

The homepage is the ranking asset, so it is hand-written HTML with all CSS
inlined and no JavaScript.

| | This site | Typical WordPress + theme |
|---|---|---|
| Page weight (gzipped) | **~9.6 KB** | 1.5–3 MB |
| HTTP requests for first paint | **2** | 30–80 |
| Render-blocking resources | **0** | 5–15 (CSS, webfonts, jQuery) |
| Largest Contentful Paint | **< 0.6 s** | 2.5–6 s |
| Plugins to keep patched | **0** | 8–20 |

WordPress can be made fast, but only by fighting it: a caching plugin, a CSS
optimiser, a CDN, and ongoing maintenance — to land somewhere this file already
is by default. Keep WordPress only if you need a non-technical editor; see
"Hybrid option" below.

## Files

```
index.html          The homepage. All CSS inlined, zero JS, ~2,100 words.
404.html            Styled not-found page.
.htaccess           Brotli/gzip, cache headers, HTTPS + non-www canonical, 404 routing.
robots.txt          Allow-all plus sitemap reference.
sitemap.xml         One URL today; add entries as pages ship.
assets/favicon.svg  425-byte inline-style SVG icon.
```

## Deploying to Hostinger

**0. Confirm the domain.** Everything is written for `tomodachilife-rom.com`.
If the registered domain really is `dtomodachilife-rom.com`, run this once
before uploading:

```bash
grep -rl 'tomodachilife-rom.com' . --exclude-dir=.git \
  | xargs sed -i 's/tomodachilife-rom\.com/dtomodachilife-rom.com/g'
```

**1. Decide what happens to WordPress.** If nothing is published on it yet,
remove it — a WordPress install sitting in `public_html` will shadow
`index.html`, because Apache serves `index.php` first. In hPanel:
*Websites → Dashboard → WordPress → Overview → Delete website data*. If you
want to keep it, see the hybrid option below.

**2. Upload.** hPanel → *Files → File Manager*, open `public_html`, and upload
`index.html`, `404.html`, `.htaccess`, `robots.txt`, `sitemap.xml` and the
`assets/` folder. The File Manager hides dotfiles by default — enable
*Settings → Show hidden files* or `.htaccess` will appear to vanish.

Over SSH or FTP instead (Hostinger gives both on shared hosting):

```bash
rsync -av --delete --exclude='.git' --exclude='README.md' \
  ./ USER@HOST:~/public_html/
```

**3. HTTPS.** hPanel → *Security → SSL*. Install the free certificate and turn
on *Force HTTPS*. The `.htaccess` also redirects, which is harmless belt-and-braces.

**4. Turn on the edge cache.** hPanel → *Advanced → Cache Manager*. For static
HTML this is pure win. Hostinger also offers Cloudflare integration under
*Advanced → Cloudflare*; enable it for global TTFB, but skip Rocket Loader and
Auto-Minify — there is nothing left to minify and Rocket Loader only adds JS.

**5. Verify.**

```bash
curl -sI https://tomodachilife-rom.com/ | grep -iE 'HTTP/|content-encoding|cache-control'
```

Expect `200`, `content-encoding: br` (or `gzip`), and a `cache-control` header.
Then run the URL through PageSpeed Insights — it should score 100 on mobile.

### Hybrid option: keep WordPress for a blog

Put WordPress in a subdirectory and leave the homepage static:

1. Move the WordPress install to `public_html/blog/`.
2. In WP: *Settings → General*, set both URLs to `https://yourdomain.com/blog`.
3. Leave `index.html` at the root. The homepage stays 9 KB; `/blog/` carries
   the WordPress weight where it costs you nothing on the ranking page.

This is the best of both — but only do it once the homepage is live and indexed.

## Launch checklist

- [ ] Domain confirmed and `sed` run if needed
- [ ] WordPress removed from `public_html` (or moved to `/blog/`)
- [ ] Files uploaded, `.htaccess` present
- [ ] SSL installed, Force HTTPS on
- [ ] `https://domain.com/` loads, `http://` and `www.` both 301 to it
- [ ] Google Search Console: add property, verify by DNS TXT in hPanel
- [ ] Submit `sitemap.xml` in Search Console, then *Request Indexing* on the homepage
- [ ] Bing Webmaster Tools: import from Search Console (two minutes, free traffic)
- [ ] Analytics: Cloudflare Web Analytics or Plausible — **not** Google Analytics,
      which would add ~45 KB of JS and undo the performance work
- [ ] PageSpeed Insights: 100 mobile / 100 desktop

## Content roadmap

The homepage targets the head term. Each page below targets its own long-tail
query and links back to the homepage — that internal linking is what lifts the
homepage's authority. Build them in this order, and add each to `sitemap.xml`
as it ships.

| Page | Target query | Why it is worth writing |
|---|---|---|
| `/azahar-setup/` | "azahar emulator setup" | Highest volume, lowest competition. Screenshots matter here. |
| `/dump-3ds-cartridge/` | "how to dump 3ds games godmode9" | Evergreen, and it legitimises the whole site. |
| `/best-settings/` | "azahar best settings" | Short, easy, ranks fast. |
| `/living-the-dream/` | "tomodachi life living the dream" | The 2026 Switch sequel. Highest current volume in the niche. |
| `/qr-codes/` | "tomodachi life qr codes" | Huge long-tail; people share Miis constantly. |
| `/android/` | "tomodachi life android" | Distinct intent from the desktop guide. |

Keep every new page on the same pattern: inline CSS, no JS, one `<h1>`,
a short-answer box near the top, a table, and an FAQ with matching schema.

## Local preview

```bash
python3 -m http.server 8000     # then open http://localhost:8000
```

Note that `.htaccess` rules do not apply locally — test redirects on the live host.
