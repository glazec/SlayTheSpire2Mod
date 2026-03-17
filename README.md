# Slay the Spire 2 Mods

Sync mods from this repo into your Slay the Spire 2 game directory.

## Mods path (macOS)

```
~/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/MacOS/mods/
```

## Updating mods

**First time:** grant execute permission to the script (only needed once per clone):

```bash
chmod +x update-mods.sh
```

Then run the script from this repo (you can run from any directory):

```bash
./update-mods.sh
```

It will:

1. **Git pull** — Fetch and merge the latest mods from the repo.
2. **Ensure mods path exists** — Create the game mods directory if it doesn’t exist.
3. **Copy mods** — Sync everything in `./mods/` to the mods path (overwrites existing, removes files no longer in `./mods/`).

## Auto-update mods when you launch the game

You can have mods update **once per day** on the first time you open Slay the Spire 2, without running any script yourself.

1. **One-time setup:** From this repo, run:
   ```bash
   chmod +x install-mod-wrapper.sh
   ./install-mod-wrapper.sh
   ```
   This installs a small wrapper inside the game app and a background check that runs at login.

2. **After that:** Open Slay the Spire 2 as usual (Steam, Dock, Spotlight). The first launch each day will run the mod updater, then start the game.

3. **If Steam updates the game:** Steam may overwrite the wrapper. You’ll get a notification: *"Slay the Spire 2 mod auto-update was removed (e.g. by a Steam update). Re-run install-mod-wrapper.sh from the SlayTheSpire2Mod repo to restore."* Run `./install-mod-wrapper.sh` again to restore it.

## Requirements

- **Git** — For pulling updates.
- **rsync** — For syncing; pre-installed on macOS.

## Layout

- `mods/` — Mod folders (each mod in its own directory). These are what get copied into the game.
- `update-mods.sh` — Script that pulls and syncs mods to the game path.
- `install-mod-wrapper.sh` — One-time installer for the in-app wrapper (auto-update on first launch each day).
