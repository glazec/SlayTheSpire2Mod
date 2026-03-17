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
3. **Copy mods** — Sync everything in `./mods/` to the mods path (overwrites existing, removes files no longer in `./mods/`). A notification is shown when the copy succeeds.

## Auto-update mods when you launch the game

You can have mods update **every time** you open Slay the Spire 2, without running any script yourself.

1. **One-time setup:** From this repo, run:
   ```bash
   chmod +x install-mod-wrapper.sh
   ./install-mod-wrapper.sh
   ```
   This installs a small wrapper inside the game app and a background check that runs at login. If you update this repo and want the latest wrapper behaviour, just run `./install-mod-wrapper.sh` again (it uninstalls the old wrapper first, then installs the new one).

2. **After that:** Open Slay the Spire 2 as usual (Steam, Dock, Spotlight). Each launch will run the mod updater, then start the game.

3. **If Steam updates the game:** Steam may overwrite the wrapper. You’ll get a notification: *"Slay the Spire 2 mod auto-update was removed (e.g. by a Steam update). Re-run install-mod-wrapper.sh from the SlayTheSpire2Mod repo to restore."* Run `./install-mod-wrapper.sh` again to restore it.

4. **Uninstall:** To remove the auto-update feature and restore the original game executable:
   ```bash
   chmod +x uninstall-mod-wrapper.sh
   ./uninstall-mod-wrapper.sh
   ```
   This restores the game binary, removes the LaunchAgent, and deletes the support files. You can still run `./update-mods.sh` manually.

## Requirements

- **Git** — For pulling updates.
- **rsync** — For syncing; pre-installed on macOS.

## Layout

- `mods/` — Mod folders (each mod in its own directory). These are what get copied into the game.
- `update-mods.sh` — Script that pulls and syncs mods to the game path.
- `install-mod-wrapper.sh` — Installs the in-app wrapper (mods update every time you launch the game). Re-run after pulling repo updates to get the latest wrapper.
- `uninstall-mod-wrapper.sh` — Removes the auto-update wrapper and restores the original game executable.
