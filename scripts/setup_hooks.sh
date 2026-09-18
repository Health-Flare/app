#!/usr/bin/env bash
# scripts/setup_hooks.sh
#
# Points git at the repo-tracked hooks in .githooks/ so formatting, the
# offline integrity scan, static analysis, and tests all run before a commit
# lands — the same checks CI enforces in .github/workflows/ci.yml.
#
# Run once per clone:
#   bash scripts/setup_hooks.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

chmod +x .githooks/*

git config core.hooksPath .githooks

echo "✅ git hooks installed (core.hooksPath = .githooks)."
echo "   Skip a one-off commit with: git commit --no-verify"
