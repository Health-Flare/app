#!/usr/bin/env bash
# scripts/check_deps.sh
#
# Dependency health audit for Health Flare.
# Reports outdated direct dependencies and fails if any direct dependency
# is discontinued. Transitive discontinued packages are warned but do not
# fail the build — they are outside our control.
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

# Extract only the direct + dev dependency sections (stop at transitive).
DIRECT=$(echo "$OUTDATED" \
  | awk '/^direct dependencies:|^dev_dependencies:/{found=1} /^transitive dependencies:|^transitive dev_dependencies:/{found=0} found')

# Fail if any direct dependency is discontinued.
if echo "$DIRECT" | grep -q "(discontinued)"; then
  echo ""
  echo "❌  A direct dependency is discontinued:"
  echo "$DIRECT" | grep "(discontinued)"
  echo "    Replace it before merging."
  exit 1
fi

# Warn (no fail) about discontinued transitive packages.
TRANSITIVE_DISC=$(echo "$OUTDATED" | grep "(discontinued)" || true)
if [ -n "$TRANSITIVE_DISC" ]; then
  echo ""
  echo "⚠️   Discontinued transitive dependencies (tracked upstream, no action required):"
  echo "$TRANSITIVE_DISC"
fi

# Warn about outdated direct dependencies with newer resolvable versions.
UPGRADABLE=$(echo "$DIRECT" | grep "^\*\|[[:space:]]\*[0-9]" | grep -v "^$" || true)
if [ -n "$UPGRADABLE" ]; then
  echo ""
  echo "⚠️   Direct dependencies with newer resolvable versions available:"
  echo "$UPGRADABLE"
  echo ""
  echo "    Consider running 'flutter pub upgrade' and testing before merging."
fi

echo ""
echo "✅  Dependency audit complete."
