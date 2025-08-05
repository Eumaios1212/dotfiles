#!/usr/bin/env bash
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

ensure_stow() {
  if ! command -v stow &>/dev/null; then
    echo "🧰 Installing GNU Stow..."
    case "$1" in
      apt) sudo apt install -y stow ;;
      pacman) sudo pacman -S --needed --noconfirm stow ;;
    esac
  fi
}

run_profile_hooks() {
  local pattern="${HOOKS_DIR}/${PROFILE}-*.sh"
  echo "🚀 Running hooks for profile '$PROFILE'..."
  for hook in $pattern; do
    [[ -x "$hook" ]] && echo "➡️  Executing $hook" && "$hook"
  done
}

# ----- Backup existing dotfiles that would block stow -----
cleanup_conflicts() {
  local target_dir="$1"
  echo "🧹 Checking for conflicting dotfiles in $target_dir..."
  for file in .bashrc .bash_logout .bash_profile .bash_aliases .bash_functions .profile; do
    local target="$target_dir/$file"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
      echo "⚠️  Backing up $target → ${target}.backup"
      mv "$target" "${target}.backup"
    fi
  done
}

bootstrap_stow() {
  echo "🔗 Stowing dotfiles..."

  # Backup conflicts in user home
  cleanup_conflicts "$HOME"

  # Stow all directories except bash-root
  for dir in */; do
    [[ "$dir" == "apps/" || "$dir" == "install.d/" || "$dir" == "bash-root/" || ! -d "$dir" ]] && continue
    echo "➡️  Stowing ${dir%/}"
    stow --target="$HOME" "${dir%/}"
  done

  # Handle bash-root separately
  echo "🧹 Checking for conflicting dotfiles in /root..."
  sudo bash -c '
    for file in .bashrc .bash_logout .bash_profile .bash_aliases .bash_functions .profile; do
      target="/root/$file"
      if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "⚠️  Backing up $target → ${target}.backup"
        mv "$target" "${target}.backup"
      fi
    done
  '

  echo "➡️  Stowing bash-root into /root"
  if ! sudo stow --target=/root bash-root; then
    echo "❌ Failed to stow bash-root — check for leftover conflicts in /root"
    exit 1
  fi
}

# ===== MAIN =====

sudo -v

PKG_MANAGER=$(detect_package_manager)
install_apps "$PKG_MANAGER"
ensure_stow "$PKG_MANAGER"
run_profile_hooks
bootstrap_stow

echo "✅ Bootstrap complete for profile: $PROFILE ($PKG_MANAGER)"
