#!/usr/bin/env bash
# upgrade_fixture.sh: write an upgrade fixture with a released version's own
# code (#181). Checks out the tag in a temporary worktree, runs
# tool/upgrade/seed_release_test.dart there, and saves the database and its
# manifest to test/fixtures/upgrades/<version>/.
#
#   bash scripts/upgrade_fixture.sh v1.9.1
#
# Run it once per release, when the release is cut, and commit the result.
# Guide: docs/testing/upgrades.md

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

TAG="${1:?usage: bash scripts/upgrade_fixture.sh vX.Y.Z}"
VERSION="${TAG#v}"
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null \
  || git fetch -q https://github.com/Health-Flare/app.git "refs/tags/$TAG:refs/tags/$TAG" \
  || { echo "✗ No tag $TAG" >&2; exit 1; }

SEED="tool/upgrade/seed_${VERSION}_test.dart"
[[ -f "$SEED" ]] || SEED="tool/upgrade/seed_release_test.dart"
OUT="$ROOT/test/fixtures/upgrades/$VERSION"
WT="$(mktemp -d "${TMPDIR:-/tmp}/hf_upgrade_${VERSION}_XXXX")"

cleanup() { git worktree remove --force "$WT" >/dev/null 2>&1 || true; }
trap cleanup EXIT

echo "Writing the $TAG fixture with $TAG's own code"
git worktree add -q --detach "$WT" "$TAG"
# Isar's native library for flutter test on this machine.
[[ -f "$ROOT/libisar.dylib" ]] && cp "$ROOT/libisar.dylib" "$WT/"
cp "$SEED" "$WT/test/zz_upgrade_seed_test.dart"
(
  cd "$WT"
  flutter pub get >/dev/null
  FIXTURE_OUT="$OUT" FIXTURE_RELEASE="$VERSION" \
    flutter test test/zz_upgrade_seed_test.dart --reporter=compact
)
echo "✓ $OUT"
ls -la "$OUT"
