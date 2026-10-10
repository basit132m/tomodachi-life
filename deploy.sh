#!/bin/bash
# =============================================================================
#  Deploy the site to the web root.
#
#  Run it on the Hostinger server over SSH:    ~/deploy.sh
#
#  It pulls the newest files from GitHub and copies them into the web root.
#  Everything else on the server is left alone.
#
#  If it picks the wrong folder, force it:
#      WEB_DIR=/full/path/to/public_html ~/deploy.sh
# =============================================================================
set -euo pipefail

REPO_DIR="$HOME/tomodachi-site"
BRANCH="claude/relaxed-ramanujan-e42lga"
DOMAIN="tomodachilife-rom.com"

[ -d "$REPO_DIR" ] || { echo "ERROR: $REPO_DIR not found. Run the one-time setup first."; exit 1; }

# --- Find the web root -------------------------------------------------------
find_web_dir() {
  # 1. Explicitly set by the caller.
  if [ -n "${WEB_DIR:-}" ]; then printf '%s' "$WEB_DIR"; return 0; fi

  # 2. Single-domain layout.
  if [ -d "$HOME/public_html" ]; then printf '%s' "$HOME/public_html"; return 0; fi

  # 3. Multi-domain layout, our domain.
  if [ -d "$HOME/domains/$DOMAIN/public_html" ]; then
    printf '%s' "$HOME/domains/$DOMAIN/public_html"; return 0
  fi

  # 4. Multi-domain layout, exactly one domain present.
  local found=()
  local d
  for d in "$HOME"/domains/*/public_html; do
    [ -d "$d" ] && found+=("$d")
  done
  if [ "${#found[@]}" -eq 1 ]; then printf '%s' "${found[0]}"; return 0; fi

  # Could not decide - report what exists so the user can pick.
  echo "ERROR: could not find the web root automatically." >&2
  if [ "${#found[@]}" -gt 1 ]; then
    echo "" >&2
    echo "Several domains found. Re-run naming the right one, for example:" >&2
    echo "" >&2
    for d in "${found[@]}"; do echo "    WEB_DIR=$d ~/deploy.sh" >&2; done
  else
    echo "Looked in:" >&2
    echo "    $HOME/public_html" >&2
    echo "    $HOME/domains/$DOMAIN/public_html" >&2
    echo "    $HOME/domains/*/public_html" >&2
    echo "" >&2
    echo "Find it with:  ls ~ ; ls ~/domains" >&2
  fi
  return 1
}

WEB_DIR="$(find_web_dir)"
echo "==> Web root: $WEB_DIR"

# Sanity check: a live web root should hold a homepage already.
if [ -f "$WEB_DIR/index.php" ] || [ -f "$WEB_DIR/index.html" ] || [ -f "$WEB_DIR/wp-config.php" ]; then
  echo "    Looks right (found an existing homepage there)."
else
  echo "    WARNING: no index.php/index.html/wp-config.php there. Double-check the path."
fi

# --- Get the newest files ----------------------------------------------------
echo "==> Fetching latest changes..."
cd "$REPO_DIR"
git fetch origin "$BRANCH" --quiet
git checkout "$BRANCH" --quiet
git reset --hard "origin/$BRANCH" --quiet
echo "    Now at: $(git log --oneline -1)"

# --- Copy the website files --------------------------------------------------
echo "==> Copying files..."
mkdir -p "$WEB_DIR/assets"

for f in index.html 404.html robots.txt sitemap.xml; do
  if [ -f "$REPO_DIR/$f" ]; then
    cp "$REPO_DIR/$f" "$WEB_DIR/$f"
    echo "    $f"
  fi
done

# Copy assets, but NEVER overwrite the real logo or favicon with a placeholder.
for f in "$REPO_DIR"/assets/*; do
  name="$(basename "$f")"
  case "$name" in
    logo.webp|favicon.webp)
      if [ -f "$WEB_DIR/assets/$name" ]; then
        echo "    assets/$name  (skipped - keeping the one already on the server)"
        continue
      fi
      ;;
  esac
  cp "$f" "$WEB_DIR/assets/$name"
  echo "    assets/$name"
done

# NOTE: .htaccess is deliberately never touched. It holds the hand-edited
# DirectoryIndex line and the WordPress block. Edit it by hand if needed.

echo ""
echo "==> Done. Open https://$DOMAIN and hard-refresh (Ctrl+Shift+R)."
