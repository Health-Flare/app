#!/usr/bin/env bash
# Runs fdroiddata's "fdroid rewritemeta" merge request check on our recipe:
# fails if `fdroid rewritemeta` would reformat it. Their check wraps long lines
# and wants a trailing newline, and the exact wrapping depends on Debian's
# python3-ruamel.yaml, so this must run where theirs does: debian:trixie-slim
# with the Debian fdroidserver dependencies and fdroidserver from git (see
# .github/workflows/fdroid-build.yml and fdroiddata's .gitlab-ci.yml).
#
# Usage (as root in debian:trixie-slim): scripts/fdroid/rewritemeta_check.sh <app checkout>
set -euo pipefail

app=$(cd "$1" && pwd)
appid=org.healthflare.app.healthflare
recipe=$app/docs/deployment/fdroid/$appid.yml

export DEBIAN_FRONTEND=noninteractive
apt-get -qq --allow-releaseinfo-change update
apt-get install -qy --no-install-recommends fdroidserver git ca-certificates >/dev/null

fdroidserver=/opt/fdroidserver
git clone -q --depth 1 https://gitlab.com/fdroid/fdroidserver.git "$fdroidserver"
export PATH="$fdroidserver:$PATH" PYTHONPATH="$fdroidserver:$fdroidserver/examples"
export serverwebroot=/tmp

work=$(mktemp -d)
mkdir -p "$work/metadata"
printf 'repo_url: https://example.com/fdroid/repo\n' > "$work/config.yml"
chmod 600 "$work/config.yml"
cp "$recipe" "$work/metadata/$appid.yml"
(cd "$work" && fdroid rewritemeta "$appid")

if ! diff -u "$recipe" "$work/metadata/$appid.yml"; then
  echo "::error file=docs/deployment/fdroid/$appid.yml::fdroid rewritemeta would reformat the recipe (diff above). Copy its output over the recipe: fdroiddata's MR check fails otherwise."
  exit 1
fi
echo "Recipe is already in fdroid rewritemeta's format."
