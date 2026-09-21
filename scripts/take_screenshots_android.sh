#!/usr/bin/env bash
# take_screenshots_android.sh: capture Play Store screenshots on Android emulators.
#
# Usage:
#   ./scripts/take_screenshots_android.sh                 # sweep every required device class
#   ./scripts/take_screenshots_android.sh "Medium_Phone_API_36.1"   # capture one named AVD only
#   ./scripts/take_screenshots_android.sh --list           # list available AVDs and exit
#
# Output:
#   screenshots/playstore/<slug>/<NAME>.png   one subdir per device class, sweep mode
#   screenshots/playstore/adhoc/<NAME>.png    single-device mode (explicit AVD name given)
#
# Requirements:
#   • Android SDK with emulator + platform-tools (ANDROID_HOME or ANDROID_SDK_ROOT set,
#     or the SDK installed at the default ~/Library/Android/sdk)
#   • At least one AVD created per device class below (Android Studio → Device Manager)
#   • flutter in $PATH
#
# Google Play screenshot requirements (docs/store-listing.md):
#   Phone screenshots: required
#   7-inch / 10-inch tablet: optional but recommended; skipped here. The
#                              Pixel Tablet AVD has been unreliable (boot
#                              hangs / driver flakiness): re-add it to
#                              DEVICE_CLASS_SLUGS/DEVICE_CLASS_AVDS once
#                              that's sorted out, or capture it manually via
#                              adhoc mode: ./take_screenshots_android.sh "Pixel_Tablet_API_36"
#
# AVD names are whatever you created locally: Android Studio doesn't standardize them
# the way Apple names simulators, so update DEVICE_CLASS_AVDS below to match what
# `emulator -list-avds` actually prints if it differs from the defaults.

set -euo pipefail

OUT_ROOT="screenshots"

# Parallel arrays (bash 3.2 on macOS has no associative arrays).
DEVICE_CLASS_SLUGS=("phone")
DEVICE_CLASS_AVDS=("Medium_Phone_API_36.1")

# ── SDK discovery ───────────────────────────────────────────────────────────

SDK_ROOT="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
EMULATOR_BIN="$SDK_ROOT/emulator/emulator"
ADB_BIN="$SDK_ROOT/platform-tools/adb"

if [[ ! -x "$EMULATOR_BIN" || ! -x "$ADB_BIN" ]]; then
  echo "❌  Could not find emulator/adb under \$ANDROID_HOME ($SDK_ROOT)."
  echo "    Set ANDROID_HOME or ANDROID_SDK_ROOT to your Android SDK path."
  exit 1
fi

# ── Helpers ──────────────────────────────────────────────────────────────

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
  "$EMULATOR_BIN" -avd "$avd_name" -no-snapshot-save -no-audio > /tmp/android_emulator_boot.log 2>&1 &

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
  # SpringBoard-equivalent settle time (launcher animation, etc).
  sleep 3
  echo "$serial"
}

kill_emulator() {
  local serial="$1"
  "$ADB_BIN" -s "$serial" emu kill > /dev/null 2>&1 || true
  sleep 2
}

# Runs the screenshot integration test against $1 (adb serial), writing
# output to $2 (directory).
run_screenshot_suite() {
  local serial="$1"
  local out_dir="$2"

  mkdir -p "$out_dir"
  SCREENSHOT_DIR="$out_dir" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/screenshot_test.dart \
    --device-id="$serial"
}

# ── --list ───────────────────────────────────────────────────────────────

if [[ "${1:-}" == "--list" ]]; then
  list_available_avds
  exit 0
fi

# ── Single-device mode (explicit AVD name passed) ───────────────────────

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

  OUT_DIR="$OUT_ROOT/playstore/adhoc"
  echo ""
  echo "Running screenshot tests..."
  echo ""
  run_screenshot_suite "$SERIAL" "$OUT_DIR"

  echo ""
  echo "✅  Done. Screenshots written to $OUT_DIR/"
  ls -1 "$OUT_DIR"/*.png 2>/dev/null | while read -r f; do
    echo "   $f"
  done
  exit 0
fi

# ── Sweep mode (default: every required Play Store device class) ────────

echo "No device given: sweeping all Play Store device classes."
echo "(Pass an AVD name, e.g. \"Medium_Phone_API_36.1\", to capture just one.)"
echo ""

SKIPPED_CLASSES=()   # AVD not installed: never attempted
CAPTURED_CLASSES=()  # ran cleanly, every screenshot test passed
PARTIAL_CLASSES=()   # ran, but one or more screenshot tests failed: 
                      # screenshots up to and including the failure are
                      # still written (integration_test saves on failure),
                      # but the set may be incomplete.

for i in "${!DEVICE_CLASS_SLUGS[@]}"; do
  SLUG="${DEVICE_CLASS_SLUGS[$i]}"
  AVD_NAME="${DEVICE_CLASS_AVDS[$i]}"

  echo "── ${SLUG}  (${AVD_NAME}) ──────────────────────────────"

  FOUND=$(find_avd "$AVD_NAME")
  if [[ -z "$FOUND" ]]; then
    echo "⚠️   AVD \"$AVD_NAME\" not installed: skipping ${SLUG}."
    echo "     Create it via Android Studio → Device Manager, or update"
    echo "     DEVICE_CLASS_AVDS in this script if it's named differently."
    SKIPPED_CLASSES+=("$SLUG")
    echo ""
    continue
  fi

  SERIAL=$(boot_avd "$AVD_NAME")
  echo "Booted: $AVD_NAME  ($SERIAL)"

  OUT_DIR="$OUT_ROOT/playstore/$SLUG"
  if run_screenshot_suite "$SERIAL" "$OUT_DIR"; then
    CAPTURED_CLASSES+=("$SLUG")
  else
    echo "⚠️   One or more screenshot tests failed on ${SLUG}: see log above."
    PARTIAL_CLASSES+=("$SLUG")
  fi

  kill_emulator "$SERIAL"
  echo ""
done

# ── Summary ──────────────────────────────────────────────────────────────

echo "──────────────────────────────────────────────"
if [[ ${#CAPTURED_CLASSES[@]} -gt 0 ]]; then
  echo "✅  Captured cleanly: ${CAPTURED_CLASSES[*]}"
  for slug in "${CAPTURED_CLASSES[@]}"; do
    echo "   $OUT_ROOT/playstore/$slug/"
  done
fi
if [[ ${#PARTIAL_CLASSES[@]} -gt 0 ]]; then
  echo "⚠️   Ran with test failures (screenshots may be incomplete): ${PARTIAL_CLASSES[*]}"
  for slug in "${PARTIAL_CLASSES[@]}"; do
    echo "   $OUT_ROOT/playstore/$slug/"
  done
fi
if [[ ${#SKIPPED_CLASSES[@]} -gt 0 ]]; then
  echo "⚠️   Skipped (AVD not installed): ${SKIPPED_CLASSES[*]}"
  echo ""
  list_available_avds
fi
if [[ ${#PARTIAL_CLASSES[@]} -gt 0 || ${#SKIPPED_CLASSES[@]} -gt 0 ]]; then
  exit 1
fi
