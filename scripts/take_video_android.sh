#!/usr/bin/env bash
# take_video_android.sh — record a Play Store promo/feature video on an
# Android emulator.
#
# Usage:
#   ./scripts/take_video_android.sh                              # default AVD
#   ./scripts/take_video_android.sh "Medium_Phone_API_36.1"       # named AVD
#   ./scripts/take_video_android.sh --list                        # list AVDs
#
# Output:
#   videos/playstore/<slug>.mp4   default mode
#   videos/playstore/adhoc/<AVD>.mp4   single-device mode (explicit AVD given)
#
# What it does: boots the emulator (or reuses one already running, like
# take_screenshots_android.sh does), starts `adb shell screenrecord` in the
# background, runs the integration_test walkthrough
# (integration_test/video_walkthrough_test.dart) via `flutter drive`, then
# stops the recording and pulls the file off the device. Scene pacing lives
# in that Dart file, not here.
#
# `adb shell screenrecord` hard-stops at 3 minutes; the walkthrough is
# well under a minute, so this isn't a practical limit here, but is worth
# knowing if the walkthrough test grows.
#
# Play Console doesn't accept an uploaded video file directly — the "Video"
# field on a store listing takes a YouTube URL. This script produces the
# raw recording; upload it to YouTube (unlisted is fine) and paste that URL
# into Play Console, per docs/store-listing.md.
#
# Requirements: same as take_screenshots_android.sh — Android SDK with
# emulator + platform-tools, flutter in $PATH.

set -euo pipefail

OUT_ROOT="videos/playstore"
DEFAULT_AVD="Medium_Phone_API_36.1"
DEFAULT_SLUG="phone"
DEVICE_OUT_PATH="/sdcard/health_flare_walkthrough.mp4"

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
EMULATOR_BIN="$SDK_ROOT/emulator/emulator"
ADB_BIN="$SDK_ROOT/platform-tools/adb"

if [[ ! -x "$EMULATOR_BIN" || ! -x "$ADB_BIN" ]]; then
  echo "❌  Could not find emulator/adb under \$ANDROID_HOME ($SDK_ROOT)."
  echo "    Set ANDROID_HOME or ANDROID_SDK_ROOT to your Android SDK path."
  exit 1
fi

list_available_avds() {
  echo "Available AVDs:"
  "$EMULATOR_BIN" -list-avds | sed 's/^/  /'
}

find_avd() {
  local avd_name="$1"
  "$EMULATOR_BIN" -list-avds | grep -Fx "$avd_name" || true
}

# Boots $1 (avd name) if no emulator is already running, and prints the
# resulting adb serial (e.g. emulator-5554) on stdout.
boot_avd() {
  local avd_name="$1"
  local existing
  existing=$("$ADB_BIN" devices | awk '/^emulator-/{print $1; exit}')

  if [[ -n "$existing" ]]; then
    echo "Using already-running emulator: $existing" >&2
    echo "$existing"
    return
  fi

  echo "Booting $avd_name..." >&2
  "$EMULATOR_BIN" -avd "$avd_name" -no-snapshot-save -no-audio > /tmp/android_emulator_video_boot.log 2>&1 &

  "$ADB_BIN" wait-for-device
  local serial
  serial=$("$ADB_BIN" devices | awk '/^emulator-/{print $1; exit}')

  echo "Waiting for boot to complete ($serial)..." >&2
  local booted=""
  for _ in $(seq 1 60); do
    booted=$("$ADB_BIN" -s "$serial" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')
    [[ "$booted" == "1" ]] && break
    sleep 2
  done
  if [[ "$booted" != "1" ]]; then
    echo "❌  $avd_name did not finish booting in time." >&2
    exit 1
  fi
  sleep 3
  echo "$serial"
}

kill_emulator() {
  local serial="$1"
  "$ADB_BIN" -s "$serial" emu kill > /dev/null 2>&1 || true
  sleep 2
}

# Records the walkthrough on $1 (adb serial), pulling the result to $2
# (local output path).
record_walkthrough() {
  local serial="$1"
  local out_file="$2"

  mkdir -p "$(dirname "$out_file")"
  "$ADB_BIN" -s "$serial" shell rm -f "$DEVICE_OUT_PATH" >/dev/null 2>&1 || true

  # A freshly booted (or idle) emulator can come up with its display asleep
  # and not yet assigned a SurfaceFlinger layer stack. screenrecord attaches
  # fine in that state but silently records nothing — it exits immediately
  # with "ERROR: UNASSIGNED_LAYER_STACK" and leaves a 0-byte file, while
  # every step around it still reports success. Waking the display first
  # avoids that.
  "$ADB_BIN" -s "$serial" shell input keyevent KEYCODE_WAKEUP >/dev/null 2>&1 || true
  sleep 1

  echo "Starting recording -> device:$DEVICE_OUT_PATH"
  "$ADB_BIN" -s "$serial" shell screenrecord --bit-rate 8000000 "$DEVICE_OUT_PATH" &
  local record_pid=$!
  sleep 2

  local drive_status=0
  flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/video_walkthrough_test.dart \
    --device-id="$serial" || drive_status=$?

  # screenrecord finalizes the mp4 container on SIGINT; a hard kill leaves
  # an unplayable file. It also self-stops at 3 minutes, well past this
  # walkthrough's length, so this is a courtesy stop, not a race against it.
  #
  # The signal has to be sent to the *remote* screenrecord process via a
  # second `adb shell`, not to $record_pid (the local `adb shell ...`
  # client) — without a pty, adb does not reliably forward a local SIGINT
  # to the remote command, so the mp4's container/moov atom never gets
  # finalized and the pulled file comes back 0 bytes despite every step
  # reporting success.
  "$ADB_BIN" -s "$serial" shell pkill -INT screenrecord 2>/dev/null || true
  wait "$record_pid" 2>/dev/null || true
  sleep 2

  echo "Pulling recording..."
  "$ADB_BIN" -s "$serial" pull "$DEVICE_OUT_PATH" "$out_file"
  "$ADB_BIN" -s "$serial" shell rm -f "$DEVICE_OUT_PATH" >/dev/null 2>&1 || true

  if [[ ! -s "$out_file" ]]; then
    echo "❌  $out_file is empty — the recording never got finalized on-device." >&2
    return 1
  fi

  return "$drive_status"
}

# ── --list ───────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--list" ]]; then
  list_available_avds
  exit 0
fi

# ── Single-device mode (explicit AVD name passed) ────────────────────────

if [[ $# -ge 1 ]]; then
  AVD_NAME="$1"
  echo "Looking for AVD: $AVD_NAME"
  FOUND=$(find_avd "$AVD_NAME")

  if [[ -z "$FOUND" ]]; then
    echo "❌  Could not find an AVD named \"$AVD_NAME\"."
    echo ""
    list_available_avds
    exit 1
  fi

  SERIAL=$(boot_avd "$AVD_NAME")
  echo "Booted: $AVD_NAME  ($SERIAL)"

  OUT_FILE="$OUT_ROOT/adhoc/${AVD_NAME}.mp4"
  if record_walkthrough "$SERIAL" "$OUT_FILE"; then
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

echo "No AVD given — recording on the default device class ($DEFAULT_AVD)."
echo "(Pass an AVD name to record on a specific device.)"
echo ""

FOUND=$(find_avd "$DEFAULT_AVD")
if [[ -z "$FOUND" ]]; then
  echo "❌  AVD \"$DEFAULT_AVD\" not installed."
  echo "     Create it via Android Studio → Device Manager, or pass a"
  echo "     different AVD name explicitly."
  echo ""
  list_available_avds
  exit 1
fi

SERIAL=$(boot_avd "$DEFAULT_AVD")
echo "Booted: $DEFAULT_AVD  ($SERIAL)"

OUT_FILE="$OUT_ROOT/${DEFAULT_SLUG}.mp4"
STATUS=0
record_walkthrough "$SERIAL" "$OUT_FILE" || STATUS=$?
kill_emulator "$SERIAL"

if [[ "$STATUS" -eq 0 ]]; then
  echo ""
  echo "✅  Done. Video written to $OUT_FILE"
else
  echo ""
  echo "⚠️   Walkthrough test failed — video up to that point still saved to $OUT_FILE"
  exit 1
fi
