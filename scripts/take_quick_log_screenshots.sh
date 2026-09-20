#!/usr/bin/env bash
# take_quick_log_screenshots.sh — capture one screenshot of the Quick Log
# sheet per suggested entry type (Meal, Symptom, Vital, Medication, Doctor
# Visit, Sleep, Condition, plus the catalogue/tracked/generic-keyword paths
# for Condition and Symptom detection) — see
# integration_test/quick_log_screenshot_test.dart.
#
# This is a documentation/demo tool, not a CI or App Store artifact — it's
# meant to be run on demand (e.g. to refresh a PR description or a doc after
# a classifier change), not on every commit. Deliberately kept separate from
# scripts/take_screenshots.sh (the App Store sweep), which walks the whole
# app and only needs re-running when a *store listing* screenshot changes.
#
# Usage:
#   ./scripts/take_quick_log_screenshots.sh                  # first available iOS simulator
#   ./scripts/take_quick_log_screenshots.sh "iPhone 16"       # a named simulator
#   ./scripts/take_quick_log_screenshots.sh --list            # list available simulators and exit
#
# Output:
#   screenshots/quick_log/NAME.png
#
# Requirements: same as scripts/take_screenshots.sh (Xcode + an iOS
# simulator runtime, flutter in $PATH, jq).

set -euo pipefail

OUT_DIR="screenshots/quick_log"

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

# First already-booted simulator, if any — lets this reuse whatever's open
# instead of always booting a specific device.
find_booted_device_id() {
  xcrun simctl list devices booted -j \
    | jq -r '[.devices | to_entries[] | .value[]] | first | .udid // empty'
}

# First available iPhone simulator — used when no device is named and none
# is booted. Apple renames simulators every hardware generation, so this
# picks whatever's actually installed instead of hardcoding a model name
# that inevitably goes stale (see scripts/take_screenshots.sh's comments).
find_any_iphone_device_id() {
  xcrun simctl list devices available -j \
    | jq -r '[.devices | to_entries[] | .value[] | select(.name | startswith("iPhone"))] | first | .udid // empty'
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
    sleep 5
  fi
  open -a Simulator --args -CurrentDeviceUDID "$device_id" 2>/dev/null || true
}

# ── --list ───────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--list" ]]; then
  list_available_simulators
  exit 0
fi

# ── Pick a device ────────────────────────────────────────────────────────

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
  boot_device "$DEVICE_ID"
else
  DEVICE_ID=$(find_booted_device_id)
  if [[ -n "$DEVICE_ID" ]]; then
    echo "Using already-booted simulator ($DEVICE_ID)."
  else
    echo "No device given and none booted — picking any available iPhone simulator."
    DEVICE_ID=$(find_any_iphone_device_id)
    if [[ -z "$DEVICE_ID" ]]; then
      echo "❌  No iPhone simulator is installed."
      echo ""
      list_available_simulators
      exit 1
    fi
    boot_device "$DEVICE_ID"
  fi
fi

# ── Run ──────────────────────────────────────────────────────────────────

mkdir -p "$OUT_DIR"
echo ""
echo "Running Quick Log screenshot suite..."
echo ""
SCREENSHOT_DIR="$OUT_DIR" flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/quick_log_screenshot_test.dart \
  --device-id="$DEVICE_ID"

echo ""
echo "✅  Done. Screenshots written to $OUT_DIR/"
ls -1 "$OUT_DIR"/*.png 2>/dev/null | while read -r f; do
  echo "   $f"
done
