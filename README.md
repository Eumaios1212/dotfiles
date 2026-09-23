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

`desktop-550/.local/bin/550-session` provides the host-550-only tmux workspace.
Install just this package with `stow --dir="$HOME/.dotfiles" --target="$HOME" desktop-550`,
then run `550-session` in Kitty. It creates session `550` or attaches to the existing
session; from inside tmux it switches the client. `550-session --detached` creates
it without attaching. Other hosts refuse to launch this layout.

| Window | Directory | Startup |
|---|---|---|
| Agent VM | Home | `ssh -t ceilo tmux attach`, pre-typed; press Enter |
| hbot | Home | `ssh -t hbot tmux attach -t ceilo`, pre-typed; press Enter |
| AI Usage | `/mnt/md0/repos/eumaios1212/ai-usage-indicator` | Claude |
| Codex | `/mnt/md0/repos/homeric-freedom` | Codex |
| Claude | `/mnt/md0/repos/homeric-freedom` | Claude |
| Pr-Rev: ceilo | `/mnt/md0/repos/homeric-freedom/ceilo` | Claude |
| Shell | Home | Plain terminal |

The remote windows only attach to sessions already running on those hosts. If the
Agent VM has several sessions, append `-t SESSION_NAME` to its pre-typed command.
Window names are pinned against automatic/application renaming. To adjust the
layout, edit the launcher's window declarations; an existing session is left intact.

Local agent windows start fresh conversations; use the agent's own resume command
when needed. Detach with Ctrl+A, then D. Closing Kitty leaves local tmux running;
rebooting 550 requires recreating the layout and resuming conversations separately.
The shared tmux prefix also applies remotely: Ctrl+A, Ctrl+A sends a prefix to the
inner session. No existing Kitty terminals are moved or closed by the launcher.

---

## Maintainer

Created by [@Eumaios1212](https://github.com/Eumaios1212)
MIT License
