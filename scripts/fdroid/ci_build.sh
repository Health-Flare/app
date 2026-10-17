#!/usr/bin/env bash
# Builds this app the way F-Droid's build server will: same container image,
# same fdroidserver, same metadata recipe. Run inside
# registry.gitlab.com/fdroid/fdroidserver:buildserver-trixie as root (see
# .github/workflows/fdroid-build.yml). Mirrors the "fdroid build" job in
# fdroiddata's .gitlab-ci.yml, which is what reviewers look at on the
# merge request.
#
# Usage: scripts/fdroid/ci_build.sh <app checkout> <commit sha>
#
# The recipe comes from docs/deployment/fdroid/<appid>.yml. Its first Builds
# entry is rewritten to point at <commit sha>, with versionName/versionCode
# read from pubspec.yaml at that commit, so every run tests the current tree
# rather than the last tag.
set -euo pipefail

app=$(cd "$1" && pwd)
sha=$2
appid=org.healthflare.app.healthflare
data=${FDROIDDATA:-/fdroiddata}

version=$(sed -n -E 's/^version: *([^ ]+)/\1/p' "$app/pubspec.yaml")
vname=${version%+*}
vcode=${version#*+}
echo "Building $appid $vname ($vcode) at $sha"

test -d "$data" || git clone --depth 1 https://gitlab.com/fdroid/fdroiddata.git "$data"
cd "$data"

python3 - "$app/docs/deployment/fdroid/$appid.yml" "metadata/$appid.yml" "$sha" "$vname" "$vcode" <<'PY'
import sys
from ruamel.yaml import YAML
src, dst, sha, vname, vcode = sys.argv[1:]
yaml = YAML()
yaml.preserve_quotes = True
with open(src) as f:
    m = yaml.load(f)
build = m['Builds'][0]
build['versionName'] = vname
build['versionCode'] = int(vcode)
build['commit'] = sha
m['Builds'] = [build]
m['CurrentVersion'] = vname
m['CurrentVersionCode'] = int(vcode)
with open(dst, 'w') as f:
    yaml.dump(m, f)
PY
cat "metadata/$appid.yml"

# --- from here on, the fdroiddata "fdroid build" job, trimmed to one app ---
CI_PROJECT_DIR=$data
export ANDROID_HOME=${ANDROID_HOME:-/opt/android-sdk}
set +u
test -n "$fdroidserver" || source /etc/profile.d/bsenv.sh
set -u

apt-get -qq update
apt-get -qy install sudo jq >/dev/null
sdkmanager "platform-tools" "build-tools;31.0.0" >/dev/null

rm -rf "$fdroidserver"
git clone --depth 1 https://gitlab.com/fdroid/fdroidserver.git "$fdroidserver"
export PATH="$fdroidserver:$PATH"
export PYTHONPATH="$fdroidserver:$fdroidserver/examples"
export PYTHONUNBUFFERED=true
export serverwebroot=/tmp

git -C "$home_vagrant/gradlew-fdroid" pull -q || true

# Production buildserver git hardening.
bootstrap=/tmp/fdroid-bootstrap-buildserver
test -d $bootstrap || git clone -q https://gitlab.com/fdroid/fdroid-bootstrap-buildserver.git $bootstrap
cp $bootstrap/roles/production_hardening/files/gitconfig "$CI_PROJECT_DIR/../.gitconfig"

mkdir -p build
for d in logs tmp unsigned "$home_vagrant/.android" "$home_vagrant/.gradle" "$home_vagrant/metadata"; do
  mkdir -p "$d"
  chown -R vagrant "$d"
done
ln -sfn "$CI_PROJECT_DIR/tmp" "$home_vagrant/tmp"
ln -sfn "$CI_PROJECT_DIR/srclibs" "$home_vagrant/srclibs"
sysctl fs.inotify.max_user_watches=524288 || true
export GRADLE_USER_HOME=$home_vagrant/.gradle

fdroid() {
  sudo --preserve-env --user vagrant \
    env PATH="$fdroidserver:$PATH" \
    env PYTHONPATH="$fdroidserver:$fdroidserver/examples" \
    env PYTHONUNBUFFERED=true \
    env TERM="${TERM:-dumb}" \
    env HOME="$home_vagrant" \
    fdroid "$@"
}

apt-get -qy install openjdk-21-jdk-headless >/dev/null
update-alternatives --set java /usr/lib/jvm/java-21-openjdk-amd64/bin/java

build="$appid:$vcode"
cp -R "$CI_PROJECT_DIR/build" "$home_vagrant/build"
cp "metadata/$appid.yml" "$home_vagrant/metadata/"
chown -R vagrant "$home_vagrant" "$CI_PROJECT_DIR"
pushd "$home_vagrant" >/dev/null
ln -sfn "$CI_PROJECT_DIR" "$home_vagrant/fdroiddata"
ln -sfn "$CI_PROJECT_DIR/../.gitconfig" "$home_vagrant/.gitconfig"
fdroid fetchsrclibs "$build" --verbose
rm "$home_vagrant/fdroiddata" "$home_vagrant/.gitconfig"
(unset CI; fdroid build --verbose --test --refresh-scanner --on-server --no-tarball "$build")
popd >/dev/null

# fdroid lint is what the merge request's "fdroid lint" job runs.
(cd "$CI_PROJECT_DIR" && fdroid lint "$appid") || echo "::warning::fdroid lint reported problems"

ls -la "$CI_PROJECT_DIR/tmp"
