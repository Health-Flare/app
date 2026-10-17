#!/usr/bin/env bash
# Removes Google Play Services from geolocator_android in the pub cache, so
# the F-Droid build has no non-free dependency. geolocator then always uses
# Android's own LocationManager, which it already falls back to on phones
# without Play Services. The weather lookup only needs one coarse fix, so
# nothing the app does changes.
#
# Fails loudly if a geolocator_android update moves the code this edits,
# rather than shipping a build that still links Play Services.
#
# Usage (repo root, PUB_CACHE set): scripts/fdroid/strip_gms_location.sh
set -euo pipefail
: "${PUB_CACHE:?set PUB_CACHE to the pub cache the build uses}"

root=$(cd "$(dirname "$0")/../.." && pwd)
version=$(awk '/^  geolocator_android:/{f=1} f && /version:/{gsub(/"/,"",$2); print $2; exit}' "$root/pubspec.lock")
pkg=$PUB_CACHE/hosted/pub.dev/geolocator_android-$version/android
test -d "$pkg" || { echo "geolocator_android $version not in $PUB_CACHE" >&2; exit 1; }

python3 - "$pkg" <<'PY'
import pathlib, re, sys
pkg = pathlib.Path(sys.argv[1])
loc = pkg / 'src/main/java/com/baseflow/geolocator/location'

gradle = pkg / 'build.gradle'
text = gradle.read_text()
text, n = re.subn(r"^\s*implementation\s+'com\.google\.android\.gms:[^']+'\s*\n", '', text, flags=re.M)
assert n == 1, f'expected one gms dependency in {gradle}, found {n}'
gradle.write_text(text)

(loc / 'FusedLocationClient.java').unlink()

mgr = loc / 'GeolocationManager.java'
text = mgr.read_text()
text, n = re.subn(r'^import com\.google\.android\.gms\.[^;]+;\n', '', text, flags=re.M)
assert n == 2, f'expected two gms imports, found {n}'
old = ('    return isGooglePlayServicesAvailable(context)\n'
       '        ? new FusedLocationClient(context, locationOptions)\n'
       '        : new LocationManagerClient(context, locationOptions);\n')
assert old in text, 'createLocationClient changed upstream'
text = text.replace(old, '    return new LocationManagerClient(context, locationOptions);\n')
text, n = re.subn(r'\n  private boolean isGooglePlayServicesAvailable\(Context context\) \{.*?\n  \}\n', '\n', text, flags=re.S)
assert n == 1, 'isGooglePlayServicesAvailable changed upstream'
mgr.write_text(text)

left = [str(p) for p in pkg.rglob('*') if p.is_file() and re.search(r'gms|play-services', p.read_text(errors='ignore'))]
assert not left, f'Play Services references left: {left}'
print(f'Stripped Play Services from {pkg}')
PY
