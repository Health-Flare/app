#!/usr/bin/env bash
# Checks that the Isar source the F-Droid build compiles libisar from
# (third_party/isar-community) is the same version the app locks, without
# checking out the submodule or building anything. Runs in CI on every PR, so
# an Isar bump that forgets the submodule fails there and not weeks later in
# the F-Droid job (#202 -> #193).
#
#   1. pubspec.lock: isar_community == isar_community_flutter_libs
#   2. .gitmodules `branch` (the tag Renovate tracks) == that version
#   3. the committed submodule commit == that tag's commit upstream
#
# Usage (repo root): scripts/fdroid/check_isar_pin.sh
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
cd "$root"
path=third_party/isar-community

lock_version() {
  awk -v pkg="  $1:" '$0 == pkg {f=1} f && /version:/ {gsub(/"/, "", $2); print $2; exit}' pubspec.lock
}

fail=0
err() { echo "::error::$*" >&2; fail=1; }

runtime=$(lock_version isar_community)
libs=$(lock_version isar_community_flutter_libs)
[[ -n "$runtime" && -n "$libs" ]] || { err "isar_community / isar_community_flutter_libs missing from pubspec.lock"; exit 1; }
[[ "$runtime" == "$libs" ]] || err "pubspec.lock has isar_community $runtime but isar_community_flutter_libs $libs."

tag=$(git config --file .gitmodules "submodule.$path.branch" || true)
[[ "$tag" == "$libs" ]] || err ".gitmodules tracks isar-community tag '${tag:-<none>}' but pubspec.lock has $libs. Set branch = $libs."

pinned=$(git ls-tree HEAD "$path" | awk '{print $3}')
[[ -n "$pinned" ]] || { err "$path is not a submodule at HEAD"; exit 1; }
url=$(git config --file .gitmodules "submodule.$path.url")
# Peeled (^{}) entry first, for annotated tags.
want=$(git ls-remote --tags "$url" "refs/tags/$libs" "refs/tags/$libs^{}" | sort -k2 -r | awk 'NR==1 {print $1}')
if [[ -z "$want" ]]; then
  err "No tag $libs in $url."
elif [[ "$pinned" != "$want" ]]; then
  err "$path is at ${pinned:0:7}, tag $libs is ${want:0:7}. Run: git -C $path fetch --tags && git -C $path checkout $libs && git add $path"
fi

if [[ $fail -ne 0 ]]; then
  echo "Isar source pin is out of step with pubspec.lock; the F-Droid build would fail." >&2
  echo "See docs/deployment/fdroid/README.md (\"When Renovate bumps Isar\")." >&2
  exit 1
fi
echo "Isar $libs: pubspec.lock, .gitmodules and $path (${pinned:0:7}) agree."
