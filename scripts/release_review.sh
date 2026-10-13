#!/usr/bin/env bash
# release_review.sh: screenshot every new 1.10.0 notification and screen,
# in the order someone updating from 1.9.1 sees them, for review (#171).
# Light and dark, at 100% and 200% text, on an iPhone simulator and an
# Android emulator. Not the store screenshots (take_screenshots.sh).
#
#   bash scripts/release_review.sh              # iPhone, then Android if one is running
#   bash scripts/release_review.sh ios          # iPhone only
#   bash scripts/release_review.sh android      # Android only
#   bash scripts/release_review.sh sheet        # rebuild index.html from what's there
#
# Options (before the command):
#   -v <variant>   one variant only: light-100, dark-100, light-200, dark-200
#   -o             open the contact sheet when done
#
# Output: screenshots/release_review/<device>/<variant>/NN_step.png and
# screenshots/release_review/index.html. Guide: docs/testing/release-review.md

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

OUT="screenshots/release_review"
VARIANT=""
OPEN=0
# A device that hangs (Android: #176) must not hold up the others.
LIMIT_SECONDS=1200

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[33m!\033[0m %s\n' "$*" >&2; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'; }

ios_device() {
  command -v xcrun >/dev/null || return 0
  command -v jq >/dev/null || fail "jq not found: brew install jq"
  local json id
  json=$(xcrun simctl list devices available -j)
  id=$(jq -r '[.devices[][] | select(.state == "Booted" and (.name | startswith("iPhone")))] | first | .udid // empty' <<<"$json")
  [[ -z "$id" ]] && id=$(jq -r '[.devices[][] | select(.name == "iPhone 17")] | first | .udid // empty' <<<"$json")
  if [[ -n "$id" ]]; then
    local state
    state=$(jq -r --arg u "$id" '[.devices[][] | select(.udid == $u)] | first | .state' <<<"$json")
    if [[ "$state" != "Booted" ]]; then
      echo "Booting simulator…" >&2
      xcrun simctl boot "$id" && sleep 5
    fi
  fi
  echo "$id"
}

android_device() {
  flutter devices --machine 2>/dev/null \
    | jq -r '[.[] | select(.targetPlatform | startswith("android"))] | first | .id // empty'
}

# Runs [cmd...] with a time limit (macOS has no `timeout`). Returns 124 if
# it ran out of time.
with_limit() {
  "$@" &
  local pid=$! waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if (( waited >= LIMIT_SECONDS )); then
      pkill -TERM -P "$pid" 2>/dev/null; kill -TERM "$pid" 2>/dev/null
      sleep 3; pkill -KILL -P "$pid" 2>/dev/null; kill -KILL "$pid" 2>/dev/null
      wait "$pid" 2>/dev/null
      return 124
    fi
    sleep 5; waited=$((waited + 5))
  done
  wait "$pid"
}

# run_device <folder> <device id>
run_device() {
  local folder="$1" id="$2" log
  log="$OUT/$folder.log"
  rm -rf "${OUT:?}/$folder"
  mkdir -p "$OUT/$folder/raw"
  bold "Release review on $folder ($id)${VARIANT:+, $VARIANT only}"
  echo "  log: $log"
  local defines=()
  [[ -n "$VARIANT" ]] && defines+=(--dart-define=REVIEW_VARIANT="$VARIANT")
  SCREENSHOT_DIR="$OUT/$folder/raw" with_limit flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/release_review_test.dart \
    "${defines[@]+"${defines[@]}"}" \
    -d "$id" >"$log" 2>&1
  local status=$?
  local n; n=$(find "$OUT/$folder/raw" -name '*.png' | wc -l | tr -d ' ')
  case $status in
    0)   ok "$folder: $n screenshots" ;;
    124) warn "$folder: stopped after ${LIMIT_SECONDS}s with $n screenshots. On Android this is #176." ;;
    *)   warn "$folder: failed with $n screenshots. See $log" ;;
  esac
  return 0
}

cmd_sheet() {
  dart run tool/release_review_sheet.dart "$OUT" "Health Flare 1.10.0 review" 2>&1 \
    | sed 's/Running build hooks\.\.\.//g' || true
  [[ $OPEN == 1 ]] && open "$OUT/index.html" 2>/dev/null
  ok "Contact sheet: $OUT/index.html"
}

cmd_ios() {
  local id; id=$(ios_device)
  [[ -n "$id" ]] || { warn "No iPhone simulator. List them: xcrun simctl list devices available"; return; }
  run_device iphone "$id"
}

cmd_android() {
  local id; id=$(android_device)
  if [[ -z "$id" ]]; then
    warn "No Android emulator running. Start one, then run: bash scripts/release_review.sh android"
    warn "  flutter emulators                      # list them"
    warn "  emulator -avd <id> -memory 4096        # start one; 2 GB hangs (#176)"
    return
  fi
  run_device android "$id"
}

while getopts "v:oh" opt; do
  case $opt in
    v) VARIANT="$OPTARG" ;;
    o) OPEN=1 ;;
    *) usage; exit 0 ;;
  esac
done
shift $((OPTIND - 1))
mkdir -p "$OUT"

case "${1:-all}" in
  all)     cmd_ios; cmd_android; cmd_sheet ;;
  ios)     cmd_ios; cmd_sheet ;;
  android) cmd_android; cmd_sheet ;;
  sheet)   cmd_sheet ;;
  help|-h) usage ;;
  *)       usage; exit 1 ;;
esac
