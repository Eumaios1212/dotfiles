#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# init.sh - First-time setup script for new Linux servers
#
# USAGE:
#   bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/master/init.sh)
#
#   Or to use a specific branch:
#     DOTFILES_BRANCH=<new-feature-branch-here> bash <(curl -s https://raw.githubusercontent.com/Eumaios1212/dotfiles/<new-feature-branch-here>/init.sh)
#
# OVERVIEW:
#   Run this on a fresh server to:
#     - Install git, curl, and stow (if not already installed)
#     - Prompt for which branch to use (or read DOTFILES_BRANCH)
#     - Clone the dotfiles repo into ~/.dotfiles
#     - Run bootstrap.sh with a selected profile (defaults to 'common')
#
# ENVIRONMENT VARIABLES:
#   DOTFILES_BRANCH  Optional. Name of the git branch to clone.
#                    If unset, you will be prompted interactively.
# -----------------------------------------------------------------------------

set -euo pipefail

REPO_URL="git@github.com:Eumaios1212/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
PROFILE="${1:-common}"

# ----- Prompt for branch to clone -----
# If DOTFILES_BRANCH is set, use it directly.
# Otherwise, prompt the user interactively, defaulting to "master".
prompt_for_branch() {
  if [ -z "${DOTFILES_BRANCH:-}" ]; then
    read -rp "🌿 Enter branch to clone (default: master): " input_branch
    BRANCH="${input_branch:-master}"
  else
    BRANCH="$DOTFILES_BRANCH"
  fi

  # Verify that the chosen branch exists on the remote repository
  if ! git ls-remote --heads "$REPO_URL" "$BRANCH" | grep -q "$BRANCH"; then
    echo "❌ Branch '$BRANCH' does not exist on remote."
    exit 1
  fi
}

# ----- Detect available package manager -----
# Checks if the system uses APT (Debian/Ubuntu) or pacman (Arch/Manjaro)
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

# ----- Install required tools: git, curl, stow -----
# Ensures the system has the minimum tools to bootstrap dotfiles
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

# ----- Clone the dotfiles repository -----
# If the dotfiles directory already exists, skips cloning
clone_repo() {
  if [ ! -d "$DOTFILES_DIR" ]; then
    echo "📥 Cloning dotfiles into $DOTFILES_DIR (branch: $BRANCH)..."
    git clone --branch "$BRANCH" "$REPO_URL" "$DOTFILES_DIR"
  else
    echo "📁 Dotfiles repo already exists. Skipping clone."
  fi
}

# ----- Run the dotfiles bootstrap process -----
# Delegates setup to the bootstrap.sh script with the chosen profile
run_bootstrap() {
  echo "🚀 Running bootstrap.sh with profile '$PROFILE'..."
  if [ ! -x "$DOTFILES_DIR/bootstrap.sh" ]; then
    echo "❌ bootstrap.sh not found or not executable at $DOTFILES_DIR"
    exit 1
  fi
  "$DOTFILES_DIR/bootstrap.sh" "$PROFILE"
}

# ----- MAIN EXECUTION -----
# Elevate privileges once up front
sudo -v
prompt_for_branch
PKGMGR=$(detect_pkgmgr)
install_minimum_tools "$PKGMGR"
clone_repo
run_bootstrap
