#!/usr/bin/env bash
# Install git hooks for this project.
# Run once after cloning: bash scripts/install_hooks.sh

set -euo pipefail

HOOKS_DIR="$(git rev-parse --git-dir)/hooks"

install_hook() {
  local name="$1"
  local src="scripts/hooks/$name"
  local dest="$HOOKS_DIR/$name"

  if [ ! -f "$src" ]; then
    echo "❌  Source hook not found: $src"
    exit 1
  fi

  cp "$src" "$dest"
  chmod +x "$dest"
  echo "✅  Installed $name"
}

install_hook pre-commit

echo ""
echo "Done. Git hooks are installed."
