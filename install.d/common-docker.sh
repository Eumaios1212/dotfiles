#!/usr/bin/env bash
set -euo pipefail

echo "🐳 Installing Docker..."

if command -v docker &>/dev/null; then
  echo "✅ Docker is already installed. Skipping."
  exit 0
fi

if command -v apt &>/dev/null; then
  echo "📦 Installing Docker on APT-based system..."

  # Remove old versions if they exist
  sudo apt remove -y docker docker-engine docker.io containerd runc || true

  # Install dependencies
  sudo apt update
  sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

  # Add Docker's official GPG key
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
    sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Set up the stable repository
  echo \
    "deb [arch=$(dpkg --print-architecture) \
    signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  # Install Docker Engine
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

elif command -v pacman &>/dev/null; then
  echo "📦 Installing Docker on pacman-based system..."
  sudo pacman -Syu --noconfirm docker docker-compose

else
  echo "❌ Unsupported system: neither apt nor pacman found"
  exit 1
fi

# Enable and start Docker daemon
echo "🔧 Enabling and starting Docker..."
sudo systemctl enable --now docker || echo "⚠️ systemctl failed — check if systemd is available"

# Add user to docker group
if ! groups "$USER" | grep -qw docker; then
  echo "👤 Adding $USER to docker group..."
  sudo usermod -aG docker "$USER"
  echo "⚠️ You must log out and back in for group change to take effect."
fi

echo "✅ Docker installation complete."
