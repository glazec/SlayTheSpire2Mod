# Slay the Spire 2 Mods

Sync mods from this repo into your Slay the Spire 2 game directory.

## Mods path (macOS)

```
~/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/MacOS/mods/
```

## Updating mods

Run the update script from this repo (any directory):

```bash
./update-mods.sh
```

It will:

1. **Git pull** — Fetch and merge the latest mods from the repo.
2. **Ensure mods path exists** — Create the game mods directory if it doesn’t exist.
3. **Copy mods** — Sync everything in `./mods/` to the mods path (overwrites existing, removes files no longer in `./mods/`).

## Requirements

- **Git** — For pulling updates.
- **rsync** — For syncing; pre-installed on macOS.

## Layout

- `mods/` — Mod folders (each mod in its own directory). These are what get copied into the game.
- `update-mods.sh` — Script that pulls and syncs mods to the game path.
