#!/usr/bin/env bash
set -euo pipefail

echo "💫 Installing Starship prompt..."

if command -v starship &>/dev/null; then
  echo "✅ Starship already installed at $(command -v starship)"
else
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
fi
