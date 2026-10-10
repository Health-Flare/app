#!/usr/bin/env bash
# whats_new.sh: test, preview and screenshot the What's new cards.
#
#   bash scripts/whats_new.sh                  # show this help
#   bash scripts/whats_new.sh test             # fast checks, no simulator (~30 s)
#   bash scripts/whats_new.sh shots            # end-to-end on a simulator + screenshots
#   bash scripts/whats_new.sh e2e              # end-to-end on a simulator, no screenshots kept
#   bash scripts/whats_new.sh run <scenario>   # open the app in a card state to poke at
#   bash scripts/whats_new.sh scenarios        # list scenarios
#   bash scripts/whats_new.sh check            # validate changes/ and releases.json, like CI
#   bash scripts/whats_new.sh goldens          # re-render golden images on Linux CI, copy them in
#
# Options (put before the command):
#   -d "<device>"   simulator/device name or id (default: a booted iPhone,
#                   else "iPhone 17", else the first available iPhone)
#
# Guide: docs/testing/whats-new.md

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SHOTS_DIR="screenshots/whats_new"
DEVICE=""

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

usage() { sed -n '2,18p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# Worktrees: the pre-commit/flutter tooling misreads GIT_DIR (see CLAUDE.md).
unset GIT_DIR GIT_WORK_TREE

need() { command -v "$1" >/dev/null 2>&1 || fail "$1 not found. $2"; }

scenarios() {
  # Single source: the enum in lib/features/whats_new/debug/whats_new_preview.dart
  awk '
    /^enum WhatsNewScenario/ { on = 1; next }
    on && /^  const WhatsNewScenario/ { exit }
    on && /^  [a-z]+\($/ { name = $1; sub(/\(/, "", name); desc = ""; grab = 1; next }
    grab && /installed:/ {
      gsub(/\\\047/, "\047", desc)
      printf "  %-9s %s\n", name, desc; grab = 0; next }
    grab { line = $0; sub(/^ +/, "", line); sub(/,$/, "", line)
      gsub(/^\047|\047$/, "", line); desc = desc line }
  ' lib/features/whats_new/debug/whats_new_preview.dart
}

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

boot() {
  local id="$1"
  local state
  state=$(xcrun simctl list devices -j | jq -r --arg u "$id" '[.devices[][] | select(.udid == $u)] | first | .state')
  if [[ "$state" != "Booted" ]]; then
    echo "Booting simulator…"
    xcrun simctl boot "$id"
    sleep 5
  fi
  open -a Simulator --args -CurrentDeviceUDID "$id" 2>/dev/null || true
}

pick_device() {
  local id
  if [[ "$(uname)" == "Darwin" ]]; then
    id=$(ios_device)
    [[ -n "$id" ]] || fail "No iPhone simulator found${DEVICE:+ named \"$DEVICE\"}. List them: xcrun simctl list devices available"
    boot "$id"
    echo "$id"
  else
    [[ -n "$DEVICE" ]] || fail "On Linux, pass an Android device: -d emulator-5554 (see: flutter devices)"
    echo "$DEVICE"
  fi
}

cmd_test() {
  bold "What's new: unit and widget tests"
  flutter test \
    test/unit/whats_new_rules_test.dart \
    test/unit/whats_new_store_test.dart \
    test/unit/whats_new_preview_test.dart \
    test/widget/whats_new_test.dart \
    test/golden/whats_new_golden_test.dart
  ok "All What's new tests passed."
  echo "  On macOS, the golden test compares against Linux-rendered images and"
  echo "  is skipped here; CI runs it. See docs/testing/whats-new.md."
}

cmd_e2e() {
  local keep="$1"
  local id; id=$(pick_device | tail -1)
  local out="$SHOTS_DIR"
  [[ "$keep" == "yes" ]] || out="$(mktemp -d)"
  rm -rf "$out"; mkdir -p "$out"
  bold "What's new: end to end on $id"
  SCREENSHOT_DIR="$out" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/whats_new_test.dart \
    --device-id="$id"
  if [[ "$keep" == "yes" ]]; then
    # Half size: plenty to review a card, and a quarter of the repo weight.
    if command -v sips >/dev/null; then
      for f in "$out"/*.png; do sips -Z 1311 "$f" >/dev/null; done
    fi
    write_index "$out"
    ok "Screenshots in $out/"
    ls -1 "$out"/*.png | sed 's/^/  /'
    echo "  Contact sheet: $out/index.html"
    [[ "$(uname)" == "Darwin" ]] && open "$out/index.html" || true
  else
    rm -rf "$out"
    ok "End-to-end passed."
  fi
}

write_index() {
  local dir="$1"
  {
    echo '<!doctype html><meta charset="utf-8"><title>What'"'"'s new screenshots</title>'
    echo '<style>body{font:14px system-ui;margin:24px}div{display:flex;flex-wrap:wrap;gap:20px}'
    echo 'figure{margin:0;width:260px}img{width:100%;border:1px solid #ccc;border-radius:12px}</style>'
    echo "<h1>What's new</h1><p>$(date '+%Y-%m-%d %H:%M'), $(git rev-parse --short HEAD)</p><div>"
    for f in "$dir"/*.png; do
      local n; n=$(basename "$f" .png)
      echo "<figure><a href=\"$n.png\"><img src=\"$n.png\"></a><figcaption>${n#whats_new_}</figcaption></figure>"
    done
    echo '</div>'
  } >"$dir/index.html"
}

cmd_run() {
  local s="${1:-}"
  if [[ -z "$s" ]]; then
    echo "Which scenario?"; scenarios; exit 1
  fi
  scenarios | awk '{print $1}' | grep -qx "$s" || { echo "Unknown scenario: $s"; scenarios; exit 1; }
  local id; id=$(pick_device | tail -1)
  bold "Opening the app in scenario: $s"
  scenarios | grep -E "^  $s " | sed 's/^ *[a-z]* *//; s/^/  /'
  echo "  No profile on this simulator? A demo profile, Sam, is added."
  [[ "$s" == "reset" ]] || echo "  When done: bash scripts/whats_new.sh run reset"
  flutter run --device-id="$id" --dart-define=WHATS_NEW_PREVIEW="$s"
}

cmd_goldens() {
  need gh "brew install gh, then gh auth login"
  local branch; branch=$(git rev-parse --abbrev-ref HEAD)
  local pushed
  pushed=$(git ls-remote https://github.com/Health-Flare/app.git "refs/heads/$branch" | cut -f1)
  if [[ "$pushed" != "$(git rev-parse HEAD)" || -n "$(git status --porcelain -- lib test)" ]]; then
    echo "Note: CI renders what's pushed to $branch. Push your changes first,"
    echo "or the images will be of the pushed code, not your working copy."
  fi
  bold "Rendering goldens on Linux CI for $branch"
  gh workflow run regen-goldens.yaml -R Health-Flare/app --ref "$branch"
  sleep 5
  local run
  run=$(gh run list -R Health-Flare/app --workflow regen-goldens.yaml --branch "$branch" --limit 1 --json databaseId -q '.[0].databaseId')
  gh run watch "$run" -R Health-Flare/app --exit-status
  local tmp; tmp=$(mktemp -d)
  gh run download "$run" -R Health-Flare/app -n goldens -D "$tmp"
  cp "$tmp"/whats_new_*.png test/goldens/
  rm -rf "$tmp"
  ok "Copied into test/goldens/:"
  git status --short -- test/goldens | sed 's/^/  /'
  echo "  Review them, then commit."
}

cmd_check() {
  # Same checks as CI: fragment kinds, releases.json, and the pubspec
  # version ready to ship. Then that the app itself can load the file.
  dart run tool/rollup_changes.dart --check
  flutter test test/unit/whats_new_store_test.dart --plain-name "Release content is bundled" >/dev/null
  ok "changes/ and assets/whats_new/releases.json are valid."
}

while getopts ":d:h" opt; do
  case "$opt" in
    d) DEVICE="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

need flutter "Install Flutter: https://docs.flutter.dev/get-started"

case "${1:-help}" in
  test) cmd_test ;;
  shots) cmd_e2e yes ;;
  e2e) cmd_e2e no ;;
  run) cmd_run "${2:-}" ;;
  scenarios) echo "Scenarios (bash scripts/whats_new.sh run <name>):"; scenarios ;;
  check) cmd_check ;;
  goldens) cmd_goldens ;;
  help|-h|--help) usage ;;
  *) echo "Unknown command: $1"; echo; usage; exit 1 ;;
esac
