#!/usr/bin/env bash
# take_video.sh — record an App Store preview video on an iOS simulator.
#
# Usage:
#   ./scripts/take_video.sh                    # record on the default device class
#   ./scripts/take_video.sh "iPhone 16"         # record on a named simulator
#   ./scripts/take_video.sh --list              # list available simulators and exit
#
# Output:
#   videos/appstore/<slug>.mov   default (device-class) mode
#   videos/adhoc/<NAME>.mov      single-device mode (explicit device name given)
#
# What it does: boots the simulator, starts `xcrun simctl io recordVideo` in
# the background, runs the integration_test walkthrough
# (integration_test/video_walkthrough_test.dart) via `flutter drive`, then
# stops the recording once the walkthrough completes. The walkthrough itself
# defines the scenes and how long each one holds — edit that file to change
# what gets recorded, not this script.
#
# App Store Connect app previews (docs/apple-app-store-checklist.md):
#   15-30 seconds, H.264 or ProRes, matching one of the required screenshot
#   device-class resolutions. This script records at whatever resolution the
#   chosen simulator renders at — re-encode/crop in a video editor to match
#   the exact App Store Connect spec for the device class you're targeting;
#   this script produces the raw source material, not the final upload.
#
# Requirements: same as take_screenshots.sh — Xcode + an iOS Simulator
# runtime, flutter in $PATH, jq.

set -euo pipefail

OUT_ROOT="videos"
DEFAULT_DEVICE_NAME="iPhone 16 Pro Max"
DEFAULT_SLUG="iphone-6.9"

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
    sleep 5
  fi
  open -a Simulator --args -CurrentDeviceUDID "$device_id" 2>/dev/null || true
}

# Records $2 (output .mov path) on $1 (device id) for the duration of the
# integration_test walkthrough, which drives its own pacing/scene holds.
record_walkthrough() {
  local device_id="$1"
  local out_file="$2"

  mkdir -p "$(dirname "$out_file")"

  echo "Starting recording -> $out_file"
  xcrun simctl io "$device_id" recordVideo --codec=h264 --force "$out_file" &
  local record_pid=$!
  # Give recordVideo a moment to attach before the app starts driving.
  sleep 2

  local drive_status=0
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/video_walkthrough_test.dart \
    --device-id="$device_id" || drive_status=$?

  # simctl recordVideo finalizes the file on SIGINT — a hard kill leaves a
  # corrupt/unplayable .mov.
  kill -INT "$record_pid" 2>/dev/null || true
  wait "$record_pid" 2>/dev/null || true

  return "$drive_status"
}

# ── --list ───────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--list" ]]; then
  list_available_simulators
  exit 0
fi

# ── Single-device mode (explicit device name passed) ────────────────────

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

  OUT_FILE="$OUT_ROOT/adhoc/${DEVICE_NAME// /_}.mov"
  if record_walkthrough "$DEVICE_ID" "$OUT_FILE"; then
    echo ""
    echo "✅  Done. Video written to $OUT_FILE"
  else
    echo ""
    echo "⚠️   Walkthrough test failed — video up to that point still saved to $OUT_FILE"
    exit 1
  fi
  exit 0
fi

# ── Default mode ─────────────────────────────────────────────────────────

echo "No device given — recording on the default App Store device class ($DEFAULT_DEVICE_NAME)."
echo "(Pass a device name, e.g. \"iPhone 16\", to record on a specific simulator.)"
echo ""

DEVICE_ID=$(find_device_id "$DEFAULT_DEVICE_NAME")
if [[ -z "$DEVICE_ID" ]]; then
  echo "❌  Simulator \"$DEFAULT_DEVICE_NAME\" not installed."
  echo "     Install it via Xcode → Settings → Platforms, or pass a different"
  echo "     device name explicitly."
  echo ""
  list_available_simulators
  exit 1
fi

echo "Found: $DEFAULT_DEVICE_NAME  ($DEVICE_ID)"
boot_device "$DEVICE_ID"

OUT_FILE="$OUT_ROOT/appstore/${DEFAULT_SLUG}.mov"
if record_walkthrough "$DEVICE_ID" "$OUT_FILE"; then
  echo ""
  echo "✅  Done. Video written to $OUT_FILE"
else
  echo ""
  echo "⚠️   Walkthrough test failed — video up to that point still saved to $OUT_FILE"
  exit 1
fi
