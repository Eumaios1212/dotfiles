#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# init.sh - First-time setup script for new Linux servers
#
# HOW TO USE:
#   Run this on a fresh Debian/Ubuntu or Arch Linux server to:
#     - Install Git, curl, and GNU Stow
#     - Clone your dotfiles repository into ~/.dotfiles using SSH
#     - Run bootstrap.sh to install packages and stow config files
#
# BASIC USAGE (default profile: "common"):
#   bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/main/init.sh)
#
# CUSTOM PROFILE (e.g., dev, server):
#   bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/main/init.sh) dev
#
# REQUIREMENTS:
#   - SSH key access to: git@github.com:Eumaios1212/dotfiles.git
#   - Must run as a regular user (not root)
#   - sudo must be available and configured for the user
#
# NOTES:
#   - This script auto-detects the package manager (APT or pacman)
#   - Dotfiles will be installed using GNU Stow
# -----------------------------------------------------------------------------

set -euo pipefail

REPO_URL="git@github.com:Eumaios1212/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
PROFILE="${1:-common}"

# Detect package manager
detect_pkgmgr() {
  if command -v apt &>/dev/null; then echo "apt"
  elif command -v pacman &>/dev/null; then echo "pacman"
  else
    echo "❌ Unsupported package manager." >&2
    exit 1
  fi
}

install_minimum_tools() {
  local mgr="$1"
  echo "🛠 Installing git, curl, and stow..."
  case "$mgr" in
    apt)
      sudo apt update && sudo apt install -y git curl stow
      ;;
    pacman)
      sudo pacman -Sy --noconfirm git curl stow
      ;;
  esac
}

clone_repo() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles into $DOTFILES_DIR..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
  else
    echo "📁 Dotfiles repo already exists. Skipping clone."
  fi
}

run_bootstrap() {
  echo "🚀 Running bootstrap.sh with profile '$PROFILE'..."
  if [ ! -x "$DOTFILES_DIR/bootstrap.sh" ]; then
    echo "❌ bootstrap.sh not found or not executable at $DOTFILES_DIR"
    exit 1
  fi
  "$DOTFILES_DIR/bootstrap.sh" "$PROFILE"
}

# Main
sudo -v

PKGMGR=$(detect_pkgmgr)
install_minimum_tools "$PKGMGR"
clone_repo
run_bootstrap
