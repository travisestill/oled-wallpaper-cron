#!/usr/bin/env bash
set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpaper}"
BASE_URL="https://ultrawidewallpapers.net"
GALLERY_URL="${BASE_URL}/gallery?lang=en&tags=OLED"
LOAD_URL="${BASE_URL}/gallery_load.php"
TAG="OLED"
COUNT=10
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36"

mkdir -p "$WALLPAPER_DIR"

tmp_list="$(mktemp)"
trap 'rm -f "$tmp_list"' EXIT

curl -sf -A "$UA" "${LOAD_URL}?offset=0&limit=5000&tag=${TAG}" \
  | grep -oE 'href="wallpapers/[^"]+\.jpg"' \
  | sed -E 's/^href="//; s/"$//' \
  | sort -u > "$tmp_list"

total=$(wc -l < "$tmp_list")
if [ "$total" -eq 0 ]; then
  echo "$(date '+%F %T'): no images found for tag ${TAG}, aborting" >&2
  exit 1
fi

selected="$(shuf -n "$COUNT" "$tmp_list")"

# Clear out yesterday's wallpapers before downloading today's set.
rm -f "${WALLPAPER_DIR:?}"/*

count=0
while IFS= read -r path; do
  [ -z "$path" ] && continue
  filename="$(basename "$path")"
  # --retry-all-errors + curl's built-in Retry-After handling absorbs the
  # site's Cloudflare rate limiting (HTTP 429) on back-to-back downloads.
  if curl -sf -A "$UA" -e "$GALLERY_URL" --retry 5 --retry-all-errors \
      -o "${WALLPAPER_DIR}/${filename}" "${BASE_URL}/${path}"; then
    count=$((count + 1))
  else
    echo "$(date '+%F %T'): failed to download ${path}" >&2
  fi
  sleep 2
done <<< "$selected"

echo "$(date '+%F %T'): downloaded ${count}/${COUNT} OLED wallpapers to ${WALLPAPER_DIR}"
