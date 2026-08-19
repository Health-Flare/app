#!/usr/bin/env bash
# take_screenshots.sh — capture App Store screenshots on iOS simulators.
#
# Usage:
#   ./scripts/take_screenshots.sh                    # sweep every required App Store device class
#   ./scripts/take_screenshots.sh "iPhone 16"         # capture one named simulator only
#   ./scripts/take_screenshots.sh --list              # list available simulators and exit
#
# Output:
#   screenshots/appstore/<slug>/<NAME>.png   one subdir per device class, sweep mode
#   screenshots/adhoc/<NAME>.png             single-device mode (explicit device name given)
#
# Requirements:
#   • Xcode + the iOS Simulator runtime downloaded — Xcode → Settings → Platforms,
#     or `xcodebuild -downloadPlatform iOS`. `xcrun simctl list devices available`
#     must show at least one iOS runtime before this script can do anything.
#   • flutter in $PATH
#   • jq  (brew install jq)
#
# App Store Connect screenshot requirements (docs/apple-app-store-checklist.md, Phase 3):
#   6.9" iPhone (Pro Max class) — required
#   6.5" iPhone (Plus class)    — required
#   13"  iPad   (Pro class)     — required because TARGETED_DEVICE_FAMILY = "1,2" in
#                                  ios/Runner.xcodeproj (the app is built as universal)
#
# The simulator names below match Xcode's current device-class naming. Apple
# renames simulators every hardware generation, so if `xcrun simctl list`
# doesn't have an exact match, this script prints the closest available
# devices instead of guessing — update DEVICE_CLASS_NAMES below to match
# whatever's actually installed.

set -euo pipefail

OUT_ROOT="screenshots"

# Parallel arrays (bash 3.2 on macOS has no associative arrays).
DEVICE_CLASS_SLUGS=("iphone-6.9" "iphone-6.5" "ipad-13")
DEVICE_CLASS_NAMES=("iPhone 16 Pro Max" "iPhone 11 Pro Max" "iPad Pro 13-inch (M4)")

# ── Helpers ──────────────────────────────────────────────────────────────

list_available_simulators() {
  echo "Available iOS simulators:"
  xcrun simctl list devices available -j \
    | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.isAvailable) | "  \(.name)  (\(.udid))"'
}

find_device_id() {
  local device_name="$1"
  xcrun simctl list devices available -j \
    | jq -r --arg name "$device_name" \
      '[.devices | to_entries[] | .value[] | select(.name == $name and .isAvailable == true)] | first | .udid // empty'
}

boot_device() {
  local device_id="$1"
  local current_state
  current_state=$(xcrun simctl list devices -j \
    | jq -r --arg udid "$device_id" \
      '[.devices | to_entries[] | .value[] | select(.udid == $udid)] | first | .state // "Unknown"')

  if [[ "$current_state" != "Booted" ]]; then
    echo "Booting simulator..."
    xcrun simctl boot "$device_id"
    # Give the SpringBoard time to fully load before running tests.
    sleep 5
  fi
  open -a Simulator --args -CurrentDeviceUDID "$device_id" 2>/dev/null || true
}

# Runs the screenshot integration test against $1 (device id), writing
# output to $2 (directory).
run_screenshot_suite() {
  local device_id="$1"
  local out_dir="$2"

  mkdir -p "$out_dir"
  SCREENSHOT_DIR="$out_dir" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshot_test.dart \
    --device-id="$device_id"
}

# ── --list ───────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--list" ]]; then
  list_available_simulators
  exit 0
fi

# ── Single-device mode (explicit device name passed) ───────────────────────

if [[ $# -ge 1 ]]; then
  DEVICE_NAME="$1"
  echo "Looking for simulator: $DEVICE_NAME"
  DEVICE_ID=$(find_device_id "$DEVICE_NAME")

  if [[ -z "$DEVICE_ID" ]]; then
    echo "❌  Could not find an available simulator named \"$DEVICE_NAME\"."
    echo ""
    list_available_simulators
    exit 1
  fi

  echo "Found: $DEVICE_NAME  ($DEVICE_ID)"
  boot_device "$DEVICE_ID"

  OUT_DIR="$OUT_ROOT/adhoc"
  echo ""
  echo "Running screenshot tests..."
  echo ""
  run_screenshot_suite "$DEVICE_ID" "$OUT_DIR"

  echo ""
  echo "✅  Done. Screenshots written to $OUT_DIR/"
  ls -1 "$OUT_DIR"/*.png 2>/dev/null | while read -r f; do
    echo "   $f"
  done
  exit 0
fi

# ── Sweep mode (default — every required App Store device class) ──────────

echo "No device given — sweeping all required App Store device classes."
echo "(Pass a device name, e.g. \"iPhone 16\", to capture just one.)"
echo ""

SKIPPED_CLASSES=()   # simulator not installed — never attempted
CAPTURED_CLASSES=()  # ran cleanly, every screenshot test passed
PARTIAL_CLASSES=()   # ran, but one or more screenshot tests failed —
                      # screenshots up to and including the failure are
                      # still written (integration_test saves on failure),
                      # but the set may be incomplete.

for i in "${!DEVICE_CLASS_SLUGS[@]}"; do
  SLUG="${DEVICE_CLASS_SLUGS[$i]}"
  DEVICE_NAME="${DEVICE_CLASS_NAMES[$i]}"

  echo "── ${SLUG}  (${DEVICE_NAME}) ──────────────────────────────"

  DEVICE_ID=$(find_device_id "$DEVICE_NAME")
  if [[ -z "$DEVICE_ID" ]]; then
    echo "⚠️   Simulator \"$DEVICE_NAME\" not installed — skipping ${SLUG}."
    echo "     Install it via Xcode → Settings → Platforms, or update"
    echo "     DEVICE_CLASS_NAMES in this script if Xcode renamed it."
    SKIPPED_CLASSES+=("$SLUG")
    echo ""
    continue
  fi

  echo "Found: $DEVICE_NAME  ($DEVICE_ID)"
  boot_device "$DEVICE_ID"

  OUT_DIR="$OUT_ROOT/appstore/$SLUG"
  # A failed screenshot test (e.g. a widget-finder issue on this specific
  # device) shouldn't abort the whole sweep — move on to the next device
  # class and report the partial result in the summary below.
  if run_screenshot_suite "$DEVICE_ID" "$OUT_DIR"; then
    CAPTURED_CLASSES+=("$SLUG")
  else
    echo "⚠️   One or more screenshot tests failed on ${SLUG} — see log above."
    PARTIAL_CLASSES+=("$SLUG")
  fi
  echo ""
done

# ── Summary ──────────────────────────────────────────────────────────────

echo "──────────────────────────────────────────────"
if [[ ${#CAPTURED_CLASSES[@]} -gt 0 ]]; then
  echo "✅  Captured cleanly: ${CAPTURED_CLASSES[*]}"
  for slug in "${CAPTURED_CLASSES[@]}"; do
    echo "   $OUT_ROOT/appstore/$slug/"
  done
fi
if [[ ${#PARTIAL_CLASSES[@]} -gt 0 ]]; then
  echo "⚠️   Ran with test failures (screenshots may be incomplete): ${PARTIAL_CLASSES[*]}"
  for slug in "${PARTIAL_CLASSES[@]}"; do
    echo "   $OUT_ROOT/appstore/$slug/"
  done
fi
if [[ ${#SKIPPED_CLASSES[@]} -gt 0 ]]; then
  echo "⚠️   Skipped (simulator not installed): ${SKIPPED_CLASSES[*]}"
  echo ""
  list_available_simulators
fi
if [[ ${#PARTIAL_CLASSES[@]} -gt 0 || ${#SKIPPED_CLASSES[@]} -gt 0 ]]; then
  exit 1
fi
