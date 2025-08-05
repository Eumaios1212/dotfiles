k#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# bootstrap.sh - Dotfiles installer and stow-based manager
#
# This script:
#   - Detects system package manager (apt or pacman)
#   - Installs apps listed in `apps/<profile>.apt.txt` or `.pacman.txt`
#   - Ensures GNU Stow is available
#   - Runs install hooks from `install.d/<profile>-*.sh`
#   - Stows all top-level dotfiles into $HOME or /root
#
# USAGE:
#   ./bootstrap.sh [profile]
#   # Default profile is "common" if not provided
#
#   Example (Ubuntu):
#     ./bootstrap.sh common
#
#   Example (custom dev profile):
#     ./bootstrap.sh dev
# -----------------------------------------------------------------------------

set -euo pipefail

# ----- Ensure we run from the script’s own directory -----
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
command -v sudo >/dev/null || { echo "❌ sudo not found"; exit 1; }

# ===== CONFIG =====
PROFILE="${1:-common}"
APPS_DIR="apps"
HOOKS_DIR="install.d"
PKG_LIST_APT="$APPS_DIR/${PROFILE}.apt.txt"
PKG_LIST_PACMAN="$APPS_DIR/${PROFILE}.pacman.txt"

# ===== FUNCTIONS =====

# Detect which package manager is available (apt or pacman)
detect_package_manager() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  else
    echo "❌ No supported package manager found (APT or pacman)." >&2
    exit 1
  fi
}

# Install apps listed in the profile's .apt.txt or .pacman.txt file
install_apps() {
  local manager="$1"
  local file="$APPS_DIR/${PROFILE}.${manager}.txt"

  if [ ! -f "$file" ]; then
    echo "❌ App list not found: $file"
    exit 1
  fi

  echo "📦 Installing packages from $file..."
  case "$manager" in
    apt)
      sudo apt update && sudo apt upgrade -y
      xargs -a "$file" sudo apt install -y
      ;;
    pacman)
      sudo pacman -Syu --noconfirm
      xargs -a "$file" sudo pacman -S --needed --noconfirm
      ;;
  esac
}

# Ensure GNU Stow is installed
ensure_stow() {
  if ! command -v stow &>/dev/null; then
    echo "🧰 Installing GNU Stow..."
    case "$1" in
      apt) sudo apt install -y stow ;;
      pacman) sudo pacman -S --needed --noconfirm stow ;;
    esac
  fi
}

# Run all executable install hooks matching the profile, e.g., install.d/common-*.sh
run_profile_hooks() {
  local pattern="${HOOKS_DIR}/${PROFILE}-*.sh"
  echo "🚀 Running hooks for profile '$PROFILE'..."
  for hook in "$pattern"; do
    [[ -x "$hook" ]] && echo "➡️  Executing $hook" && "$hook"
  done
}

# Backup any dotfiles in $1 (home or /root) that would block stow from linking
cleanup_conflicts() {
  local target_dir="$1"
  echo "🧹 Checking for conflicting dotfiles in $target_dir..."

  find . -type l -prune -o -type f -print | while read -r file; do
    file_name=$(basename "$file")
    dest="$target_dir/$file_name"

    if [[ -e "$dest" && ! -L "$dest" ]]; then
      echo "⚠️  Backing up $dest → $dest.backup"
      sudo mv "$dest" "$dest.backup"
    fi
  done
}

# Stow each top-level folder (excluding ignored ones) into $HOME or /root
bootstrap_stow() {
  echo "🔗 Stowing dotfiles..."

  for dir in */; do
    [[ "$dir" == "apps/" || "$dir" == "install.d/" || ! -d "$dir" ]] && continue

    if [[ "$dir" == "bash-root/" ]]; then
      cleanup_conflicts "/root"
      echo "➡️  Stowing bash-root into /root"
      sudo stow --target=/root bash-root
    else
      cleanup_conflicts "$HOME"
      echo "➡️  Stowing ${dir%/}"
      stow --target="$HOME" "${dir%/}"
    fi
  done
}

# ===== MAIN =====

sudo -v

PKG_MANAGER=$(detect_package_manager)
install_apps "$PKG_MANAGER"
ensure_stow "$PKG_MANAGER"
run_profile_hooks
bootstrap_stow

echo "✅ Bootstrap complete for profile: $PROFILE ($PKG_MANAGER)"

