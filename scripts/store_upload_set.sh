#!/usr/bin/env bash
# store_upload_set.sh: build the exact screenshot set to upload to each store,
# numbered in upload order, from the captures in screenshots/appstore/ and
# screenshots/playstore/. App Store takes up to 10 per device size; Play up to
# 8 phone screenshots. Notes and steps: docs/store-notes/<version>.md
#
#   bash scripts/store_upload_set.sh          # build build/store_upload/ and open it
#   bash scripts/store_upload_set.sh --no-open

set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 1
OUT="$ROOT/build/store_upload"

# Upload order. Change the selection here.
APP_STORE=(01_onboarding 02_dashboard 03_tracking_symptoms 06_medications 12_symptom_form_weather 04_tracking_illnesses 05_condition_detail 07_meals 08_journal 01c_onboarding_privacy)
PLAY_STORE=(01_onboarding 02_dashboard 03_tracking_symptoms 06_medications 12_symptom_form_weather 04_tracking_illnesses 08_journal 01c_onboarding_privacy)

fail() { printf '\033[31m✗\033[0m %s\n' "$*" >&2; exit 1; }

copy_set() {
  local from="$1" to="$2"; shift 2
  local i=0 name
  rm -rf "$to"; mkdir -p "$to"
  for name in "$@"; do
    i=$((i + 1))
    [[ -f "$from/$name.png" ]] || fail "Missing $from/$name.png. Re-take the screenshots."
    # Upload position, then the capture name without its own number:
    # 12_symptom_form_weather -> 05_symptom_form_weather.png
    cp "$from/$name.png" "$to/$(printf '%02d' "$i")_${name#*_}.png"
  done
  printf '\033[32m✓\033[0m %-44s %d screenshots\n' "${to#"$ROOT"/}" "$i"
}

rm -rf "$OUT"
for device in iphone-6.9 iphone-6.5 ipad-13; do
  copy_set "screenshots/appstore/$device" "$OUT/app-store/$device" "${APP_STORE[@]}"
done
copy_set "screenshots/playstore/phone" "$OUT/play-store/phone" "${PLAY_STORE[@]}"

[[ "${1:-}" == "--no-open" ]] || open "$OUT" 2>/dev/null || true
