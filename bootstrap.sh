#!/usr/bin/env bash
set -euo pipefail

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

bootstrap_stow() {
  echo "🔗 Stowing dotfiles..."
  for dir in */; do
    [[ "$dir" == "$APPS_DIR/" || "$dir" == "$HOOKS_DIR/" || ! -d "$dir" ]] && continue
    echo "➡️  Stowing ${dir%/}"
    stow --target="$HOME" "${dir%/}"
  done
}

# ===== MAIN =====

cd "$(dirname "$0")"
sudo -v

PKG_MANAGER=$(detect_package_manager)
install_apps "$PKG_MANAGER"
ensure_stow "$PKG_MANAGER"
run_profile_hooks
bootstrap_stow

echo "✅ Bootstrap complete for profile: $PROFILE ($PKG_MANAGER)"
