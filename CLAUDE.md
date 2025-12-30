# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **modular, idempotent dotfiles bootstrap system** for Linux servers (Ubuntu/Debian and Arch-based). It uses GNU Stow for symlink management, profile-based package installation, and optional install hooks.

## Core Architecture

### Bootstrap Flow
1. **init.sh** → First-time setup (curl-able entry point)
   - Detects package manager (APT or pacman)
   - Installs minimal dependencies (git, curl, stow)
   - Prompts for branch selection (or reads `DOTFILES_BRANCH` env var)
   - Clones repo to `~/.dotfiles`
   - Delegates to bootstrap.sh

2. **bootstrap.sh** → Main installer (runs locally)
   - Installs packages from `apps/<profile>.<apt|pacman>.txt`
   - Runs profile hooks from `install.d/<profile>-*.sh`
   - Backs up conflicting dotfiles (`.filename.backup`)
   - Stows all top-level directories into `$HOME` (except `apps/`, `install.d/`)
   - Special case: `bash-root/` is stowed into `/root` with sudo

### Directory Structure
```text
.dotfiles/
├── apps/             # Package lists by profile (e.g., common.apt.txt, dev.pacman.txt)
├── install.d/        # Optional install hooks (e.g., common-docker.sh, common-starship.sh)
├── bash/             # User bash dotfiles (stowed to $HOME)
├── bash-root/        # Root bash config (stowed to /root)
├── starship/         # Starship prompt config
├── alacritty/        # Terminal emulator config
├── ble/              # ble.sh (bash line editor) library
├── git/              # Git config
├── tmux/             # Tmux config
├── shell/            # Shell profile
├── bootstrap.sh      # Local bootstrap script
└── init.sh           # First-time curl entry point
```

## Key Concepts

### Profiles
- Default: `common`
- Each profile has:
  - `apps/<profile>.apt.txt` (Debian/Ubuntu packages)
  - `apps/<profile>.pacman.txt` (Arch packages)
  - Optional hooks: `install.d/<profile>-*.sh`
- Example: `./bootstrap.sh dev` uses dev profile

### Install Hooks
- Executable bash scripts in `install.d/`
- Naming: `<profile>-<name>.sh` (e.g., `common-docker.sh`)
- Run after package installation, before stowing
- Must be idempotent (safe to rerun)
- Use `set -euo pipefail` for safety

### Stowing Mechanism
- All top-level directories (except `apps/`, `install.d/`) are stowed
- Target: `$HOME` (except `bash-root/` → `/root`)
- Conflicts (non-symlink files) are backed up before stowing
- Stow creates symlinks: `~/.bashrc` → `~/.dotfiles/bash/.bashrc`

## Common Development Tasks

### Testing the Bootstrap Process
```bash
# Test on a fresh server or VM (recommended)
bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/master/init.sh)

# Test a specific profile
bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/master/init.sh) dev

# Test a feature branch
DOTFILES_BRANCH=my-feature bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/my-feature/init.sh)
```

### Local Testing
```bash
cd ~/.dotfiles
./bootstrap.sh common  # or 'dev'
```

### Adding a New Package
1. Add to `apps/common.apt.txt` (Debian/Ubuntu) or `apps/common.pacman.txt` (Arch)
2. Rerun `./bootstrap.sh common`

### Adding a New Install Hook
1. Create `install.d/<profile>-<name>.sh`
2. Make executable: `chmod +x install.d/<profile>-<name>.sh`
3. Follow pattern from existing hooks (idempotent, `set -euo pipefail`)

### Managing Dotfiles
```bash
# Add new dotfile directory
mkdir -p mynewconfig/.config/mynewconfig
# Add config files to mynewconfig/.config/mynewconfig/
# Stow it
cd ~/.dotfiles
stow mynewconfig

# Remove a stow group
stow -D bash
```

## Important Files

### Shell Configuration
- `bash/.bashrc` - Main bash config (sources functions/aliases, initializes Starship, ble.sh)
- `bash/.bash_functions` - Reusable functions (update, extract, whatsmyip, gcom, lazyg)
- `bash/.bash_aliases` - Command aliases (git shortcuts, ls variations, tmux help)
- `bash-root/.bashrc` - Root user bash config

### Prompt Configuration
- `starship/.config/starship.toml` - Starship prompt config
  - Custom multi-line format with user, system, network, path, git info
  - Custom modules: remote git tracking, root indicator
  - Language/tool detection (Python, Node.js, Docker, Kubernetes, Terraform)
  - Global command timeout: 1000ms (increased from default 500ms)

### Package Manager Detection
Both init.sh and bootstrap.sh use `detect_package_manager()`:
- Checks for `apt` command → APT
- Checks for `pacman` command → pacman
- Exits with error if neither found

## Critical Constraints

### Idempotency
- All scripts must be safe to rerun
- Package installs use `--needed` (pacman) or are naturally idempotent (apt)
- Install hooks check if tool already installed before proceeding
- Stow conflict backups prevent data loss

### Package Manager Support
- Only APT (Debian/Ubuntu) and pacman (Arch) are supported
- Each profile requires both `.apt.txt` and `.pacman.txt` files

### Stow Conventions
- Top-level directories mirror target structure (e.g., `bash/.bashrc` → `~/.bashrc`)
- Special case: `bash-root/` uses `sudo stow --target=/root`
- Never stow `apps/` or `install.d/` directories

## Testing Strategy

### Always Test On Fresh Systems
- Use VMs, containers, or snapshots for testing
- Feature branches can be bootstrapped via `DOTFILES_BRANCH` env var
- Verify idempotency by running bootstrap twice

### Validation Checklist
- [ ] Does init.sh successfully clone and run bootstrap.sh?
- [ ] Do all packages install without errors?
- [ ] Do install hooks complete successfully?
- [ ] Are dotfiles stowed without conflicts (or conflicts backed up)?
- [ ] Can the process be rerun without errors?
- [ ] Does the branch detection work correctly?

## Shell Customizations

### ble.sh Integration
- Loaded in bash/.bashrc with `--noattach` flag
- Attached at end of .bashrc after Starship initialization
- Provides advanced bash line editing and completion

### Starship Prompt Features
- Shows username (always, even non-SSH)
- Shows hostname and OS symbol
- Shows local IP address
- Custom Git remote tracking module
- Language/tool version detection (Python, Node.js, Go, etc.)
- Docker context detection
- Kubernetes context detection
- Custom root indicator (⚡) when running as root
- Command duration tracking (shows if > 1200ms)

### Useful Bash Functions (in .bash_functions)
- `update` - Updates system packages and pipx packages
- `extract <file>` - Auto-detects and extracts archives (.tar.gz, .zip, .7z, etc.)
- `ftext <pattern>` - Recursive grep with color, piped to less
- `whatsmyip` - Shows internal and external IP addresses
- `gcom "msg"` - Quick git add + commit
- `lazyg "msg"` - Quick git add + commit + push

### Key Aliases (in .bash_aliases)
- `l` - ls with all files, human-readable sizes, long format
- `g` - git shortcut
- `gc`, `ga`, `gst`, `gl`, `gd` - git commit, add, status, log, diff
- `tmuxhelp` - Shows tmux keybindings reference
