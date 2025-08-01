#!/usr/bin/env bash
set -euo pipefail

echo "💫 Installing Starship prompt..."

curl -fsSL https://starship.rs/install.sh | bash -s -- -y
