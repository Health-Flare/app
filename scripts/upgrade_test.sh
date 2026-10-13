#!/usr/bin/env bash
# upgrade_test.sh: the real upgrade, on a simulator or emulator (#181).
#
#   bash scripts/upgrade_test.sh 1.9.1            # iPhone simulator
#   bash scripts/upgrade_test.sh 1.9.1 android    # running Android emulator
#
# 1. Builds the release (its tag) and installs it, replacing any install.
# 2. Puts that release's fixture database (test/fixtures/upgrades/<version>,
#    from scripts/upgrade_fixture.sh) in its documents folder.
# 3. Launches it once and closes it: the old app has opened the data.
# 4. Installs this checkout's build over it, keeping the data, and runs
#    integration_test/upgrade_check_test.dart through the app's real main().
#
# It replaces the app and its data on the device. Guide:
# docs/testing/upgrades.md

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1

VERSION="${1:?usage: bash scripts/upgrade_test.sh <version> [ios|android]}"
VERSION="${VERSION#v}"
PLATFORM="${2:-ios}"
TAG="v$VERSION"
APP_ID="org.healthflare.app.healthflare"
FIXTURE="$ROOT/test/fixtures/upgrades/$VERSION"
OUT="$ROOT/build/upgrade_test/$VERSION-$PLATFORM"

bold() { printf '\033[1m%s\033[0m\n' "$*"; }
ok()   { printf '\033[32m✓\033[0m %s\n' "$*"; }
fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

[[ -f "$FIXTURE/healthflare.isar" ]] \
  || fail "No fixture for $VERSION. Make one: bash scripts/upgrade_fixture.sh $TAG"
git rev-parse -q --verify "refs/tags/$TAG" >/dev/null \
  || git fetch -q https://github.com/Health-Flare/app.git "refs/tags/$TAG:refs/tags/$TAG" \
  || fail "No tag $TAG"
mkdir -p "$OUT"

WT="$(mktemp -d "${TMPDIR:-/tmp}/hf_upgrade_build_${VERSION}_XXXX")"
cleanup() { git worktree remove --force "$WT" >/dev/null 2>&1 || true; }
trap cleanup EXIT
git worktree add -q --detach "$WT" "$TAG"

build_old() {
  bold "Building $TAG ($PLATFORM)"
  (
    cd "$WT" || exit 1
    flutter pub get >/dev/null
    if [[ "$PLATFORM" == ios ]]; then
      flutter build ios --simulator --debug >"$OUT/build_old.log" 2>&1
    else
      flutter build apk --debug >"$OUT/build_old.log" 2>&1
    fi
  ) || fail "Building $TAG failed. See $OUT/build_old.log"
}

run_check() {
  local device="$1"
  bold "Installing this checkout over $TAG and checking"
  SCREENSHOT_DIR="$OUT" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target=integration_test/upgrade_check_test.dart \
    --dart-define=UPGRADE_MANIFEST="$(base64 <"$FIXTURE/manifest.json" | tr -d '\n')" \
    -d "$device" >"$OUT/check.log" 2>&1
  local status=$?
  grep -E "✓ Upgraded|TestFailure|Expected|Actual|reason" "$OUT/check.log" | head -8
  if [[ $status == 0 ]]; then
    ok "Upgrade from $VERSION works on $PLATFORM. Screenshots: $OUT"
  else
    fail "Upgrade from $VERSION failed on $PLATFORM. Log: $OUT/check.log"
  fi
}

ios() {
  command -v jq >/dev/null || fail "jq not found: brew install jq"
  local udid
  udid=$(xcrun simctl list devices available -j \
    | jq -r '[.devices[][] | select(.state == "Booted" and (.name | startswith("iPhone")))] | first | .udid // empty')
  [[ -n "$udid" ]] || fail "Boot an iPhone simulator first: open -a Simulator"
  build_old
  bold "Installing $TAG with its $VERSION data"
  xcrun simctl terminate "$udid" "$APP_ID" >/dev/null 2>&1
  xcrun simctl uninstall "$udid" "$APP_ID" >/dev/null 2>&1
  xcrun simctl install "$udid" "$WT/build/ios/iphonesimulator/Runner.app" \
    || fail "Couldn't install $TAG"
  local data
  data=$(xcrun simctl get_app_container "$udid" "$APP_ID" data) \
    || fail "No data folder for $APP_ID"
  mkdir -p "$data/Documents"
  cp "$FIXTURE/healthflare.isar" "$data/Documents/healthflare.isar"
  xcrun simctl launch "$udid" "$APP_ID" >/dev/null || fail "$TAG didn't launch"
  sleep 15
  xcrun simctl terminate "$udid" "$APP_ID" >/dev/null 2>&1
  ok "$TAG opened its data"
  run_check "$udid"
}

android() {
  local serial
  serial=$(adb devices | awk '/^emulator-/{print $1; exit}')
  [[ -n "$serial" ]] || fail "Start an emulator first: emulator -avd <id> -memory 4096"
  build_old
  bold "Installing $TAG with its $VERSION data"
  adb -s "$serial" uninstall "$APP_ID" >/dev/null 2>&1
  adb -s "$serial" install "$WT/build/app/outputs/flutter-apk/app-debug.apk" >/dev/null \
    || fail "Couldn't install $TAG"
  # Launch once so the app's folders exist, then put the data in place.
  adb -s "$serial" shell monkey -p "$APP_ID" 1 >/dev/null 2>&1
  sleep 10
  adb -s "$serial" shell am force-stop "$APP_ID"
  adb -s "$serial" push "$FIXTURE/healthflare.isar" /data/local/tmp/healthflare.isar >/dev/null
  adb -s "$serial" shell run-as "$APP_ID" sh -c "'rm -f app_flutter/healthflare.isar*; cp /data/local/tmp/healthflare.isar app_flutter/healthflare.isar'" \
    || fail "Couldn't copy the data into the app (run-as needs a debug build)"
  adb -s "$serial" shell monkey -p "$APP_ID" 1 >/dev/null 2>&1
  sleep 15
  adb -s "$serial" shell am force-stop "$APP_ID"
  ok "$TAG opened its data"
  run_check "$serial"
}

case "$PLATFORM" in
  ios) ios ;;
  android) android ;;
  *) fail "Platform is ios or android" ;;
esac
