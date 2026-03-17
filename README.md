# Slay the Spire 2 Mods Sync

This repo helps you keep **Slay the Spire 2** mods in sync. You store mods here (in the `mods/` folder), and the scripts copy them into the game’s mod folder. You can update mods manually or set up **auto-update on every game launch**.

**Platform:** macOS only (Steam install path is hard-coded).

---

## Features

| Feature                     | Description                                                                                                                                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Sync mods to game**       | Pull latest from git and copy everything in `mods/` into the game’s mod folder. Creates the mod folder if it doesn’t exist.                                                                                  |
| **Manual update**           | Run `./update-mods.sh` whenever you want to refresh mods (e.g. after `git pull`).                                                                                                                            |
| **Auto-update on launch**   | After a one-time install, every time you start Slay the Spire 2 (Steam, Dock, etc.) the script runs the updater first, then starts the game.                                                                 |
| **Game-update detection**   | If the game binary was replaced (e.g. by a Steam update), the game won’t start until you fix the wrapper. A dialog appears with a **Re-install now** button to re-run the installer and then start the game. |
| **Background check**        | A small helper runs at login and can notify you if the wrapper was removed (e.g. after a game update).                                                                                                       |
| **Uninstall**               | Restore the original game executable and remove the auto-update wrapper and background check. You can still run `./update-mods.sh` manually.                                                                 |
| **Installer is idempotent** | Running `./install-mod-wrapper.sh` again (e.g. after pulling repo changes) first removes the old wrapper, then installs the new one. No need to uninstall first.                                             |

---

## Quick start

### Auto-update mods on game launch

**If you want mods to update every time you launch the game:**

1. In Terminal, go to this repo and run:
   ```bash
   chmod +x install-mod-wrapper.sh
   ./install-mod-wrapper.sh
   ```
2. From now on, start Slay the Spire 2 as you normally do (Steam, Dock, Spotlight). The first thing that runs is the updater; then the game starts.

### Sync mods to game (no auto-update)

**If you only want to copy mods once (no auto-update):**

1. In Terminal, go to this repo and run:
   ```bash
   chmod +x update-mods.sh
   ./update-mods.sh
   ```
2. Mods are now in the game’s mod folder. Start the game as usual.

### Sharing mods with others

To share your mods with others:

1. Copy your mods into the `mods/` folder in this repo.
2. Make a git commit and push (e.g. `git add mods/ && git commit -m "Add or update mods" && git push`).

Others who use this repo and have the auto-update wrapper installed will get your mods the next time they start the game (the wrapper runs the updater, which does `git pull` and then syncs `mods/` to the game folder).

---

## Where mods go (macOS)

The game’s mod folder is:

```
~/Library/Application Support/Steam/steamapps/common/Slay the Spire 2/SlayTheSpire2.app/Contents/MacOS/mods/
```

The scripts create this folder if it doesn’t exist. The contents of this repo’s `mods/` folder are synced there (existing files are overwritten; files that no longer exist in `mods/` are removed from the game folder).

---

## Manual update (no auto-update)

When you want to refresh mods:

```bash
./update-mods.sh
```

This will:

1. Run `git pull` on the current branch (so you get the latest mods from the repo).
2. Create the game mod folder if it’s missing.
3. Sync `./mods/` into the game mod folder (like a one-way copy with cleanup).

You can run this from any directory; the script finds the repo and the game path itself.

---

## Auto-update on game launch

### Install (one-time)

From this repo:

```bash
chmod +x install-mod-wrapper.sh
./install-mod-wrapper.sh
```

This will:

- Install a small **wrapper** inside the Slay the Spire 2 app so that when you “open” the game, the updater runs first, then the real game.
- Install a **background check** that runs at login (and can notify you if the wrapper was removed).

After that, just start the game as usual; mods are updated on every launch.

### If the game was updated (e.g. by Steam)

If Steam (or something else) replaces the game executable, the wrapper may stop working. When you try to start the game:

1. A dialog appears: *"Game was updated. Click Re-install now to fix and start the game, or OK to close."*
2. Click **Re-install now** to run the installer again, sync mods, and start the game. Click **OK** to close without starting; you can run `./install-mod-wrapper.sh` yourself later and then start the game.

### Updating the wrapper (e.g. after you pull this repo)

Run the installer again:

```bash
./install-mod-wrapper.sh
```

It will remove the old wrapper and install the new one. You don’t need to uninstall first.

### Uninstall auto-update

To go back to the original game executable and stop auto-update:

```bash
chmod +x uninstall-mod-wrapper.sh
./uninstall-mod-wrapper.sh
```

This restores the game binary, removes the LaunchAgent and helper script, and deletes the support files. You can still run `./update-mods.sh` manually whenever you want.


---

## Requirements

- **macOS** (paths are for the Steam Slay the Spire 2 app on Mac).
- **Git** – used to pull the latest mods from the repo.
- **rsync** – used to sync files; included with macOS.

---

## Repo layout

| Path                       | Purpose                                                                                             |
| -------------------------- | --------------------------------------------------------------------------------------------------- |
| `mods/`                    | Your mod folders. Each mod lives in its own directory here. This is what gets copied into the game. |
| `update-mods.sh`           | Syncs mods to the game (git pull + rsync). Run this for a one-off update.                           |
| `install-mod-wrapper.sh`   | Installs the in-app wrapper and background check so mods update on every game launch.               |
| `uninstall-mod-wrapper.sh` | Removes the wrapper and restores the original game executable.                                      |
