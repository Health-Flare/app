#!/usr/bin/env bash
# scripts/check_deps.sh
#
# Dependency health audit for Health Flare.
# Reports outdated direct dependencies and fails if any are discontinued.
#
# Usage:
#   bash scripts/check_deps.sh          # exits 0 if healthy, 1 if problems found
#
# Run automatically by the CI weekly schedule job.
# Can also be run locally before opening a PR.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

echo "──────────────────────────────────────────────"
echo "  Health Flare — Dependency Audit"
echo "  $(date -u '+%Y-%m-%d %H:%M UTC')"
echo "──────────────────────────────────────────────"

OUTDATED=$(flutter pub outdated 2>&1)

echo ""
echo "=== flutter pub outdated ==="
echo "$OUTDATED"

# Fail if any dependency is discontinued.
if echo "$OUTDATED" | grep -q "(discontinued)"; then
  echo ""
  echo "❌  One or more dependencies are discontinued."
  echo "    Review the output above and replace them."
  exit 1
fi

# Warn about outdated direct dependencies (resolvable upgrades available).
UPGRADABLE=$(echo "$OUTDATED" | awk '/direct dependencies:/{found=1} found && /\*/' | grep -v "^$" || true)
if [ -n "$UPGRADABLE" ]; then
  echo ""
  echo "⚠️   The following direct dependencies have newer resolvable versions:"
  echo "$UPGRADABLE"
  echo ""
  echo "    Consider running 'flutter pub upgrade' and testing before merging."
  # This is a warning only — do not exit 1 here.
fi

echo ""
echo "=== flutter pub audit ==="
flutter pub audit

echo ""
echo "✅  Dependency audit complete."
