# Dotfiles Bootstrap Setup

This repo contains a modular, idempotent setup system for bootstrapping new Linux servers using:

* Package manager detection (APT or pacman)
* Profile-based app install lists
* Optional install hooks (e.g., install Docker, Starship, Alacritty)
* Stow-based dotfile symlinking
* Safe conflict resolution (auto-backups of existing files)

---

## Quick Start

Run this on a new server:

```bash
bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/master/init.sh)
```

To use a specific profile:

```bash
bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/master/init.sh) dev
```

To test a different branch (e.g., a feature branch):

```bash
DOTFILES_BRANCH=my-feature-branch bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/my-feature-branch/init.sh)
```

---

## Directory Structure

```
.dotfiles/
├── apps/             # Package lists by profile (APT/pacman)
├── bash/             # User bash dotfiles
├── bash-root/        # Root-only bash config (stowed into /root)
├── install.d/        # Optional hook scripts (profile-scoped)
├── bootstrap.sh      # Local bootstrap script
└── init.sh           # First-time curl entrypoint
```

---

## Profiles

The system supports profiles like:

* `common` (default) — safe base config
* `dev` — developer setup (VSCode, Docker, etc.)

Each profile includes:

* APT list: `apps/common.apt.txt`
* Pacman list: `apps/common.pacman.txt`
* Optional hooks: `install.d/common-*.sh`

---

## Stowing Dotfiles

Top-level folders (except `apps/`, `install.d/`) are symlinked into `$HOME` using `stow`.

Special case:
`bash-root/` is stowed into `/root` with `sudo`.

---

## Conflict Handling

Before stowing:

* Checks for conflicts (files, not symlinks)
* Backs up as `.filename.backup`
* Supports both user (`$HOME`) and `/root`

---

## Cleanup

To safely remove an old stow group:

```bash
cd ~/.dotfiles
stow -D bash
```

---

## Tips

* Always test changes on a **fresh server** or snapshot
* Feature branches can be bootstrapped using the `DOTFILES_BRANCH` environment variable
* Scripts are idempotent and safe to rerun

---

## Requirements

* `bash`, `curl`, `git`, `stow`
* Works on Ubuntu/Debian and Arch-based distros

---

## 550 Desktop Workspace

`desktop-550/.local/bin/550-session` is the everyday entrypoint on host 550: it opens
Herdr, which shows 550's own workspaces plus its saved SSH machines.
Herdr restores its workspaces and reopens each agent's last conversation itself.
Other hosts refuse to launch it.

Install just this package with `stow --dir="$HOME/.dotfiles" --target="$HOME" desktop-550`
(`bootstrap.sh` deliberately skips `desktop-550/`), then run `550-session` in Kitty.

The script only does what Herdr cannot restore on its own:

- checks the SSH key is loaded (Herdr connects to machines without prompting);
- makes sure hbot's Herdr runs from its capped service (`herdr-hbot.service`), so the
  saved-machine connection never starts an uncapped one;
- re-runs the view commands in panes that Herdr restores as empty shells, by pane label
  and only when the pane is at an idle prompt: `agent-vm` (550), `stack` (hbot, attach to
  `tmux ceilo` only), `zano` (8056, attach only), `paseo-log`, `monerod-log` (monero),
  `bsx-log` (bsx), and `bsx-ui` (the SSH tunnel to BasicSwap's web UI, which must run on 550).

`550-session --detached`, or running it from inside a Herdr pane, skips opening Herdr and
only reattaches those views to a server that is already running.

## Maintainer

Created by [@Eumaios1212](https://github.com/Eumaios1212)
MIT License
