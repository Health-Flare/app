#!/usr/bin/env bash
# take_screenshots.sh — capture app screenshots on an iOS simulator.
#
# Usage:
#   ./scripts/take_screenshots.sh                   # default: iPhone 16 Pro
#   ./scripts/take_screenshots.sh "iPhone 16"
#   ./scripts/take_screenshots.sh "iPad Pro 13-inch (M4)"
#
# Output:
#   screenshots/<name>.png   (one file per testWidgets call)
#
# Requirements:
#   • Xcode + iOS Simulator
#   • flutter in $PATH
#   • jq  (brew install jq)

set -euo pipefail

DEVICE_NAME="${1:-iPhone 16 Pro}"
OUT_DIR="screenshots"

# ── Find the simulator UDID ────────────────────────────────────────────────

echo "Looking for simulator: $DEVICE_NAME"

DEVICE_ID=$(xcrun simctl list devices available -j \
  | jq -r --arg name "$DEVICE_NAME" \
    '[.devices | to_entries[] | .value[] | select(.name == $name and .isAvailable == true)] | first | .udid // empty')

if [[ -z "$DEVICE_ID" ]]; then
  echo "❌  Could not find an available simulator named \"$DEVICE_NAME\"."
  echo ""
  echo "Available iOS simulators:"
  xcrun simctl list devices available -j \
    | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.isAvailable) | "  \(.name)  (\(.udid))"'
  exit 1
fi

echo "Found: $DEVICE_NAME  ($DEVICE_ID)"

# ── Boot the simulator if needed ───────────────────────────────────────────

CURRENT_STATE=$(xcrun simctl list devices -j \
  | jq -r --arg udid "$DEVICE_ID" \
    '[.devices | to_entries[] | .value[] | select(.udid == $udid)] | first | .state // "Unknown"')

if [[ "$CURRENT_STATE" != "Booted" ]]; then
  echo "Booting simulator..."
  xcrun simctl boot "$DEVICE_ID"
  # Give the SpringBoard time to fully load before running tests.
  sleep 5
fi

open -a Simulator --args -CurrentDeviceUDID "$DEVICE_ID" 2>/dev/null || true

# ── Run the tests ─────────────────────────────────────────────────────────

mkdir -p "$OUT_DIR"

echo ""
echo "Running screenshot tests..."
echo ""

flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/screenshot_test.dart \
  --device-id="$DEVICE_ID"

# ── Summary ───────────────────────────────────────────────────────────────

echo ""
echo "✅  Done. Screenshots written to $OUT_DIR/"
ls -1 "$OUT_DIR"/*.png 2>/dev/null | while read -r f; do
  echo "   $f"
done
