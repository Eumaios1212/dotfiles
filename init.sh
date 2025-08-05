#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# init.sh - First-time setup script for new Linux servers
#
# HOW TO USE:
#   Run this on a fresh server to:
#     - Install git, curl, stow
#     - Prompt for which branch to use (or read DOTFILES_BRANCH)
#     - Clone the repo and run bootstrap.sh with a selected profile
# -----------------------------------------------------------------------------

set -euo pipefail

REPO_URL="git@github.com:Eumaios1212/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
PROFILE="${1:-common}"
BRANCH="master"

# ----- Prompt for branch if not supplied via env -----
prompt_for_branch() {
  if [ -z "${DOTFILES_BRANCH:-}" ]; then
    read -rp "🌿 Enter branch to clone (default: master): " input_branch
    BRANCH="${input_branch:-master}"
  else
    BRANCH="$DOTFILES_BRANCH"
  fi
}

# ----- Detect package manager -----
detect_pkgmgr() {
  if command -v apt &>/dev/null; then
    echo "apt"
  elif command -v pacman &>/dev/null; then
    echo "pacman"
  else
    echo "❌ Unsupported package manager." >&2
    exit 1
  fi
}

# ----- Install git, curl, stow -----
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

# ----- Verify the branch exists on the remote -----
verify_remote_branch() {
  if ! git ls-remote --heads "$REPO_URL" "$BRANCH" | grep -q "$BRANCH"; then
    echo "❌ Branch '$BRANCH' does not exist on remote."
    exit 1
  fi
}

# ----- Clone dotfiles repo -----
clone_repo() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles into $DOTFILES_DIR (branch: $BRANCH)..."
    git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
  else
    echo "📁 Dotfiles repo already exists. Skipping clone."
  fi
}

# ----- Run the bootstrap process -----
run_bootstrap() {
  echo "🚀 Running bootstrap.sh with profile '$PROFILE'..."
  if [ ! -x "$DOTFILES_DIR/bootstrap.sh" ]; then
    echo "❌ bootstrap.sh not found or not executable at $DOTFILES_DIR"
    exit 1
  fi
  "$DOTFILES_DIR/bootstrap.sh" "$PROFILE"
}

# ----- MAIN -----
sudo -v
prompt_for_branch
PKGMGR=$(detect_pkgmgr)
install_minimum_tools "$PKGMGR"
verify_remote_branch
clone_repo
run_bootstrap

