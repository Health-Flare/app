#!/usr/bin/env bash
# track_and_care.sh: test, try and screenshot Track and Care (#135).
# It's behind the TRACK_AND_CARE build flag until it ships (#145).
#
#   bash scripts/track_and_care.sh          # show this help
#   bash scripts/track_and_care.sh test     # unit and widget tests, no simulator (~20 s)
#   bash scripts/track_and_care.sh run      # open the app with Track and Care on
#   bash scripts/track_and_care.sh shots    # end to end on a simulator + screenshots
#   bash scripts/track_and_care.sh e2e      # end to end, no screenshots kept
#
# Options (before the command):
#   -d "<device>"   simulator/device name or id (default: a booted iPhone,
#                   else "iPhone 17", else the first available iPhone)
#
# Guide: docs/testing/track-and-care.md

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SHOTS_DIR="screenshots/track_and_care"
DEVICE=""

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null || fail "$1 not found. $2"; }

usage() { sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'; }

ios_device() {
  need xcrun "Install Xcode."
  need jq "brew install jq"
  local json; json=$(xcrun simctl list devices available -j)
  if [[ -n "$DEVICE" ]]; then
    jq -r --arg n "$DEVICE" '[.devices[][] | select(.name == $n or .udid == $n)] | first | .udid // empty' <<<"$json"
    return
  fi
  local id
  id=$(jq -r '[.devices[][] | select(.state == "Booted" and (.name | startswith("iPhone")))] | first | .udid // empty' <<<"$json")
  [[ -z "$id" ]] && id=$(jq -r '[.devices[][] | select(.name == "iPhone 17")] | first | .udid // empty' <<<"$json")
  [[ -z "$id" ]] && id=$(jq -r '[.devices[][] | select(.name | startswith("iPhone"))] | first | .udid // empty' <<<"$json")
  echo "$id"
}

pick_device() {
  local id
  if [[ "$(uname)" == "Darwin" ]]; then
    id=$(ios_device)
    [[ -n "$id" ]] || fail "No iPhone simulator found${DEVICE:+ named \"$DEVICE\"}. List them: xcrun simctl list devices available"
    local state
    state=$(xcrun simctl list devices -j | jq -r --arg u "$id" '[.devices[][] | select(.udid == $u)] | first | .state')
    if [[ "$state" != "Booted" ]]; then
      echo "Booting simulator…" >&2
      xcrun simctl boot "$id"
      sleep 5
    fi
    open -a Simulator --args -CurrentDeviceUDID "$id" 2>/dev/null || true
    echo "$id"
  else
    [[ -n "$DEVICE" ]] || fail "On Linux, pass an Android device: -d emulator-5554 (see: flutter devices)"
    echo "$DEVICE"
  fi
}

cmd_test() {
  bold "Track and Care: unit and widget tests"
  flutter test \
    test/unit/navigation \
    test/unit/database/features_off_keeps_data_test.dart \
    test/widget/track_and_care_test.dart \
    test/widget/track_and_care_bodies_test.dart \
    test/widget/features_in_use_screen_test.dart \
    test/widget/features_in_use_sections_test.dart \
    test/widget/quick_log_features_off_test.dart \
    test/widget/app_shell_test.dart
  ok "All Track and Care tests passed."
}

cmd_run() {
  local id; id=$(pick_device | tail -1)
  bold "Opening Health Flare with Track and Care on ($id)"
  flutter run --dart-define=TRACK_AND_CARE=true --device-id="$id"
}

cmd_e2e() {
  local keep="$1"
  local id; id=$(pick_device | tail -1)
  local out="$SHOTS_DIR"
  [[ "$keep" == "yes" ]] || out="$(mktemp -d)"
  rm -rf "$out"; mkdir -p "$out"
  bold "Track and Care: end to end on $id"
  SCREENSHOT_DIR="$out" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/track_and_care_test.dart \
    --device-id="$id"
  if [[ "$keep" == "yes" ]]; then
    # Half size: plenty to review a screen, a quarter of the repo weight.
    if command -v sips >/dev/null; then
      for f in "$out"/*.png; do sips -Z 1311 "$f" >/dev/null; done
    fi
    {
      echo '<!doctype html><meta charset="utf-8"><title>Track and Care screenshots</title>'
      echo '<style>body{font:14px system-ui;margin:24px}figure{display:inline-block;margin:0 16px 24px 0;vertical-align:top}img{width:260px;border:1px solid #ccc;border-radius:12px}</style>'
      for f in "$out"/*.png; do
        n=$(basename "$f")
        echo "<figure><img src=\"$n\"><figcaption>${n%.png}</figcaption></figure>"
      done
    } > "$out/index.html"
    ok "Screenshots in $out/"
    echo "  Contact sheet: $out/index.html"
    [[ "$(uname)" == "Darwin" ]] && open "$out/index.html" || true
  else
    rm -rf "$out"
    ok "End to end passed."
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -d) DEVICE="$2"; shift 2 ;;
    *) break ;;
  esac
done

case "${1:-}" in
  test) cmd_test ;;
  run) cmd_run ;;
  shots) cmd_e2e yes ;;
  e2e) cmd_e2e no ;;
  ""|-h|--help|help) usage ;;
  *) usage; fail "Unknown command: $1" ;;
esac
