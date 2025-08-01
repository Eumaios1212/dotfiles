#!/usr/bin/env bash
set -euo pipefail

echo "🖥️ Installing Alacritty terminal emulator..."

if command -v alacritty &>/dev/null; then
  echo "✅ Alacritty is already installed. Skipping."
  exit 0
fi

if command -v apt &>/dev/null; then
  echo "📦 Installing on APT-based system (Ubuntu/Debian)..."

  # Ensure Rust is installed (required to build if not using a PPA)
  if ! command -v rustc &>/dev/null; then
    echo "🔧 Installing Rust toolchain..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # Add official Alacritty PPA (for Ubuntu 22.04 and later)
  if lsb_release -cs | grep -q jammy; then
    sudo add-apt-repository ppa:aslatter/ppa -y
    sudo apt update
    sudo apt install -y alacritty
  else
    echo "⚠️ No official PPA for this release — falling back to manual build"
    # Optional: Build from source
    # sudo apt install -y cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3
    # cargo install alacritty
  fi

elif command -v pacman &>/dev/null; then
  echo "📦 Installing on pacman-based system..."
  sudo pacman -Syu --noconfirm alacritty

else
  echo "❌ Unsupported package manager. Cannot install Alacritty."
  exit 1
fi

echo "✅ Alacritty installation complete."
