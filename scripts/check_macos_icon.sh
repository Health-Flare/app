#!/usr/bin/env bash
# check_macos_icon.sh — validates the macOS app icon set against the asset
# completeness rules in docs/features/macos.feature.
#
# Fails with a descriptive error (non-zero exit) if:
#   - Contents.json is missing
#   - a file it references is missing from the appiconset
#   - a referenced file is a zero-byte placeholder
#   - a referenced file's actual pixel dimensions don't match size × scale
#
# Run standalone:
#   bash scripts/check_macos_icon.sh
#
# Wired into CI in .github/workflows/ci.yml (flutter-build-macos job), run
# before `flutter build macos` so a broken icon set fails fast with a clear
# message instead of silently shipping in the .app bundle.
#
# Requires: jq, sips (both preinstalled on macos-latest GitHub runners and
# any Mac with Xcode).

set -euo pipefail

ICONSET="macos/Runner/Assets.xcassets/AppIcon.appiconset"
CONTENTS="$ICONSET/Contents.json"

if [[ ! -f "$CONTENTS" ]]; then
  echo "❌  $CONTENTS not found." >&2
  exit 1
fi

FAILED=0

while IFS=$'\t' read -r filename size scale; do
  path="$ICONSET/$filename"

  if [[ ! -f "$path" ]]; then
    echo "❌  $filename is referenced in Contents.json but missing from $ICONSET/" >&2
    FAILED=1
    continue
  fi

  bytes=$(stat -f%z "$path")
  if [[ "$bytes" -eq 0 ]]; then
    echo "❌  $filename is a zero-byte placeholder." >&2
    FAILED=1
    continue
  fi

  # Expected pixel size = logical size × scale, e.g. "16x16" @ "2x" -> 32px.
  logical_w="${size%x*}"
  scale_n="${scale%x}"
  expected=$((logical_w * scale_n))

  actual=$(sips -g pixelWidth "$path" | tail -1 | awk '{print $2}')
  if [[ "$actual" != "$expected" ]]; then
    echo "❌  $filename is ${actual}x${actual}px, expected ${expected}x${expected}px (size=$size, scale=$scale)" >&2
    FAILED=1
  fi
done < <(jq -r '.images[] | "\(.filename)\t\(.size)\t\(.scale)"' "$CONTENTS")

if [[ "$FAILED" -eq 1 ]]; then
  echo "" >&2
  echo "macOS app icon validation failed — see docs/features/macos.feature." >&2
  exit 1
fi

echo "✅  macOS app icon set is complete (${ICONSET})."
