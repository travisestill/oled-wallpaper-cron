# OLED Wallpaper Cron

Keeps `~/Pictures/Wallpaper` stocked with fresh, random ultrawide OLED
wallpapers pulled from [ultrawidewallpapers.net](https://ultrawidewallpapers.net/gallery?lang=en&tags=OLED).

Each run:

1. Queries the site's gallery API for every image tagged `OLED`.
2. Picks a random subset.
3. Deletes everything currently in the wallpaper folder.
4. Downloads the new set into it.

Intended to be run on a schedule (cron) so your wallpaper folder rotates
automatically.

## Requirements

- `bash`
- `curl`
- `shuf` (part of GNU coreutils)

## Usage

```bash
./fetch-oled-wallpapers.sh
```

Configuration is via variables at the top of the script:

| Variable         | Default                              | Description                          |
|------------------|---------------------------------------|---------------------------------------|
| `WALLPAPER_DIR`  | `$HOME/Pictures/Wallpaper`           | Folder that gets wiped and refilled   |
| `TAG`            | `OLED`                                | Gallery tag to pull images from       |
| `COUNT`          | `10`                                  | Number of images to download per run  |

## Scheduling with cron

See [crontab.example](crontab.example) for the line used in production —
runs at 6:00 AM every 3rd day of the month:

```
0 6 */3 * * $HOME/.local/bin/fetch-oled-wallpapers.sh >> $HOME/.cache/oled-wallpapers.log 2>&1
```

Install a copy of the script somewhere on your `PATH` (e.g.
`~/.local/bin/`), then add a line like the one above with `crontab -e`.

## Notes

- Downloads use a `Referer` header matching the gallery page, since the
  site requires it to serve full-resolution images directly.
- Downloads are retried automatically (`curl --retry-all-errors`) and
  spaced 2 seconds apart to avoid tripping the site's Cloudflare rate
  limiting (HTTP 429).
