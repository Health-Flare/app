#!/usr/bin/env bash
# scripts/release/build_release_kit.sh
#
# One command that assembles everything a release announcement, App Store
# Connect submission, or Play Console listing update needs: release notes
# (drafted from actual PR/issue history: see generate_release_notes.sh),
# a fresh screenshot sweep, and a fresh preview-video capture. Works over
# any range (a single release, several skipped releases, a whole quarter)
# because it's a thin wrapper around tools that already take a range.
#
# It does not require every tool to be runnable on this machine: screenshot
# and video capture need Xcode (iOS) and/or the Android SDK (Android) and
# only make sense on a real dev machine with simulators/emulators: this
# script detects what's available and skips the rest with a clear note,
# rather than failing outright. Release notes generation has no such
# dependency and always runs.
#
# Usage:
#   scripts/release/build_release_kit.sh --since v1.7.1
#   scripts/release/build_release_kit.sh --since v1.5.0 --until v1.7.1 --version 1.7.1
#   scripts/release/build_release_kit.sh --since v1.7.1 --notes-only
#   scripts/release/build_release_kit.sh --since v1.7.1 --skip-videos
#
# Options:
#   --since REF       Passed through to generate_release_notes.sh (required).
#   --until REF       Passed through to generate_release_notes.sh (default HEAD).
#   --version X.Y.Z   Labels the kit folder and the release notes heading.
#   --out DIR         Output directory (default: release-kit/<version-or-range>).
#   --notes-only      Skip screenshot and video capture entirely.
#   --skip-screenshots
#   --skip-videos
#   --ios-device NAME    Passed through to take_video.sh / take_screenshots.sh.
#   --android-avd NAME   Passed through to take_video_android.sh / take_screenshots_android.sh.
#
# Output layout:
#   <out>/release-notes.md      Keep-a-Changelog-style draft
#   <out>/store-blurb.md        Condensed "what's new" draft for both stores
#   <out>/screenshots/          Snapshot of screenshots/{appstore,playstore} at build time
#   <out>/videos/                Snapshot of videos/{appstore,playstore} at build time

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

SINCE=""
UNTIL="HEAD"
VERSION=""
OUT_DIR=""
NOTES_ONLY=false
SKIP_SCREENSHOTS=false
SKIP_VIDEOS=false
IOS_DEVICE=""
ANDROID_AVD=""

usage() {
  sed -n '2,40p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    --until) UNTIL="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --out) OUT_DIR="$2"; shift 2 ;;
    --notes-only) NOTES_ONLY=true; shift ;;
    --skip-screenshots) SKIP_SCREENSHOTS=true; shift ;;
    --skip-videos) SKIP_VIDEOS=true; shift ;;
    --ios-device) IOS_DEVICE="$2"; shift 2 ;;
    --android-avd) ANDROID_AVD="$2"; shift 2 ;;
    -h|--help) usage 0 ;;
    *) echo "error: unknown argument '$1'" >&2; usage 1 ;;
  esac
done

if [[ -z "$SINCE" ]]; then
  echo "error: --since is required" >&2
  usage 1
fi

if [[ -z "$OUT_DIR" ]]; then
  OUT_DIR="release-kit/${VERSION:-${SINCE}-to-${UNTIL}}"
fi
mkdir -p "$OUT_DIR"

echo "══════════════════════════════════════════════════════════"
echo "  Health Flare: Release Kit"
echo "  Range: ${SINCE} → ${UNTIL}${VERSION:+  (v${VERSION})}"
echo "  Output: ${OUT_DIR}"
echo "══════════════════════════════════════════════════════════"
echo

# ── 1. Release notes (always runs: no device dependency) ───────────────
echo "── Release notes ──────────────────────────────────────────"
NOTES_ARGS=(--since "$SINCE" --until "$UNTIL")
[[ -n "$VERSION" ]] && NOTES_ARGS+=(--version "$VERSION")

if bash "${REPO_ROOT}/scripts/release/generate_release_notes.sh" "${NOTES_ARGS[@]}" \
    > "${OUT_DIR}/release-notes.md"; then
  echo "  wrote ${OUT_DIR}/release-notes.md"
else
  echo "  ⚠️  generate_release_notes.sh failed: see output above (likely gh auth)." >&2
  rm -f "${OUT_DIR}/release-notes.md"
fi

BLURB_STDERR="$(mktemp)"
if bash "${REPO_ROOT}/scripts/release/generate_release_notes.sh" "${NOTES_ARGS[@]}" --store-blurb \
    > "${OUT_DIR}/store-blurb.md" 2>"$BLURB_STDERR"; then
  echo "  wrote ${OUT_DIR}/store-blurb.md"
  cat "$BLURB_STDERR" >&2
else
  echo "  ⚠️  store-blurb generation failed: see output above." >&2
  cat "$BLURB_STDERR" >&2
  rm -f "${OUT_DIR}/store-blurb.md"
fi
rm -f "$BLURB_STDERR"
echo

if [[ "$NOTES_ONLY" == true ]]; then
  echo "── --notes-only set: skipping screenshot and video capture ─"
  echo
  echo "✅  Release kit ready: ${OUT_DIR}"
  exit 0
fi

# ── 2. Screenshots ────────────────────────────────────────────────────────
echo "── Screenshots ─────────────────────────────────────────────"
if [[ "$SKIP_SCREENSHOTS" == true ]]; then
  echo "  skipped (--skip-screenshots)"
elif command -v xcrun >/dev/null 2>&1 && xcrun simctl list devices >/dev/null 2>&1; then
  echo "  running iOS App Store sweep..."
  if bash "${REPO_ROOT}/scripts/take_screenshots.sh" ${IOS_DEVICE:+"$IOS_DEVICE"}; then
    echo "  ✅ iOS screenshots captured"
  else
    echo "  ⚠️  iOS screenshot sweep reported failures: check screenshots/appstore/" >&2
  fi
else
  echo "  skipped: no Xcode/simctl on this machine (this step needs a Mac)."
fi

if [[ "$SKIP_SCREENSHOTS" == true ]]; then
  :
elif [[ -n "${ANDROID_HOME:-}${ANDROID_SDK_ROOT:-}" ]] || [[ -d "$HOME/Library/Android/sdk" ]]; then
  echo "  running Android Play Store sweep..."
  if bash "${REPO_ROOT}/scripts/take_screenshots_android.sh" ${ANDROID_AVD:+"$ANDROID_AVD"}; then
    echo "  ✅ Android screenshots captured"
  else
    echo "  ⚠️  Android screenshot sweep reported failures: check screenshots/playstore/" >&2
  fi
else
  echo "  skipped: no Android SDK detected on this machine."
fi

if [[ "$SKIP_SCREENSHOTS" != true ]]; then
  mkdir -p "${OUT_DIR}/screenshots"
  [[ -d screenshots/appstore ]] && cp -R screenshots/appstore "${OUT_DIR}/screenshots/"
  [[ -d screenshots/playstore ]] && cp -R screenshots/playstore "${OUT_DIR}/screenshots/"
fi
echo

# ── 3. Videos ──────────────────────────────────────────────────────────────
echo "── Videos ───────────────────────────────────────────────────"
if [[ "$SKIP_VIDEOS" == true ]]; then
  echo "  skipped (--skip-videos)"
elif command -v xcrun >/dev/null 2>&1 && xcrun simctl list devices >/dev/null 2>&1; then
  echo "  recording iOS app preview..."
  if bash "${REPO_ROOT}/scripts/take_video.sh" ${IOS_DEVICE:+"$IOS_DEVICE"}; then
    echo "  ✅ iOS video captured"
  else
    echo "  ⚠️  iOS video capture reported failures: check videos/appstore/" >&2
  fi
else
  echo "  skipped iOS video: no Xcode/simctl on this machine."
fi

if [[ "$SKIP_VIDEOS" == true ]]; then
  :
elif [[ -n "${ANDROID_HOME:-}${ANDROID_SDK_ROOT:-}" ]] || [[ -d "$HOME/Library/Android/sdk" ]]; then
  echo "  recording Android walkthrough..."
  if bash "${REPO_ROOT}/scripts/take_video_android.sh" ${ANDROID_AVD:+"$ANDROID_AVD"}; then
    echo "  ✅ Android video captured"
  else
    echo "  ⚠️  Android video capture reported failures: check videos/playstore/" >&2
  fi
else
  echo "  skipped Android video: no Android SDK detected on this machine."
fi

if [[ "$SKIP_VIDEOS" != true ]]; then
  mkdir -p "${OUT_DIR}/videos"
  [[ -d videos/appstore ]] && cp -R videos/appstore "${OUT_DIR}/videos/"
  [[ -d videos/playstore ]] && cp -R videos/playstore "${OUT_DIR}/videos/"
  [[ -d videos/adhoc ]] && cp -R videos/adhoc "${OUT_DIR}/videos/"
fi
echo

echo "══════════════════════════════════════════════════════════"
echo "✅  Release kit ready: ${OUT_DIR}"
find "$OUT_DIR" -type f | sed 's/^/   /'
echo "══════════════════════════════════════════════════════════"
