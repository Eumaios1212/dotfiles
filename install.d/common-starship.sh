#!/usr/bin/env bash
set -euo pipefail

echo "💫 Installing Starship prompt..."

if command -v starship &>/dev/null; then
  echo "✅ Starship already installed: $(starship --version)"
else
  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
  echo "✅ Starship installed successfully"
fi
