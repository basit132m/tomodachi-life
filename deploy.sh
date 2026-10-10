#!/bin/bash
# =============================================================================
#  Deploy the site to public_html.
#
#  Run it on the Hostinger server over SSH:    ~/deploy.sh
#
#  It pulls the newest files from GitHub and copies them into public_html.
#  Everything else on the server is left alone.
# =============================================================================
set -euo pipefail

REPO_DIR="$HOME/tomodachi-site"
WEB_DIR="$HOME/public_html"
BRANCH="claude/relaxed-ramanujan-e42lga"

# --- Safety checks -----------------------------------------------------------
[ -d "$REPO_DIR" ] || { echo "ERROR: $REPO_DIR not found. Run the one-time setup first."; exit 1; }
[ -d "$WEB_DIR" ]  || { echo "ERROR: $WEB_DIR not found."; exit 1; }

# --- Get the newest files ----------------------------------------------------
echo "==> Fetching latest changes..."
cd "$REPO_DIR"
git fetch origin "$BRANCH"
git checkout "$BRANCH" --quiet
git reset --hard "origin/$BRANCH" --quiet
echo "    Now at: $(git log --oneline -1)"

# --- Copy the website files --------------------------------------------------
echo "==> Copying files to public_html..."
mkdir -p "$WEB_DIR/assets"

for f in index.html 404.html robots.txt sitemap.xml; do
  if [ -f "$REPO_DIR/$f" ]; then
    cp "$REPO_DIR/$f" "$WEB_DIR/$f"
    echo "    $f"
  fi
done

# Copy assets, but NEVER overwrite the real logo with the repo's placeholder.
for f in "$REPO_DIR"/assets/*; do
  name="$(basename "$f")"
  if [ "$name" = "logo.webp" ] && [ -f "$WEB_DIR/assets/logo.webp" ]; then
    echo "    assets/logo.webp  (skipped - keeping the one already on the server)"
    continue
  fi
  cp "$f" "$WEB_DIR/assets/$name"
  echo "    assets/$name"
done

# NOTE: .htaccess is deliberately never touched. It holds the hand-edited
# DirectoryIndex line and the WordPress block. Edit it by hand if needed.

echo ""
echo "==> Done. Open https://tomodachilife-rom.com and hard-refresh (Ctrl+Shift+R)."
