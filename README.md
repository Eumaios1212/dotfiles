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

## Maintainer

Created by [@Eumaios1212](https://github.com/Eumaios1212)
MIT License
