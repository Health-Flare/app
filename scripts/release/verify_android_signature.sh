#!/usr/bin/env bash
# Verify that an Android release artifact is signed with the Health Flare
# release key before it is published (#106).
#
#   scripts/release/verify_android_signature.sh <app.apk|app.aab>
#
# The expected SHA-256 certificate fingerprint lives in
# android/release-signing.sha256 (one line, lowercase hex, no colons). It is
# the key every published APK since v1.7.1 is signed with. Changing it means
# the signing key changed: existing installs can't update, so that must be
# a deliberate decision, never a side effect.
#
# APKs are checked with apksigner (they may carry only v2/v3 signatures,
# which keytool can't read). App Bundles are JAR-signed, so keytool works.
set -euo pipefail

artifact="${1:?usage: $0 <app.apk|app.aab>}"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
expected="$(tr -d '[:space:]' < "$repo_root/android/release-signing.sha256")"

[[ -s "$artifact" ]] || { echo "error: $artifact is missing or empty" >&2; exit 1; }

find_apksigner() {
  if command -v apksigner >/dev/null 2>&1; then command -v apksigner; return; fi
  local sdk="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}}"
  find "$sdk/build-tools" -mindepth 2 -maxdepth 2 -name apksigner 2>/dev/null \
    | sort -V | tail -1
}

case "$artifact" in
  *.apk)
    apksigner="$(find_apksigner)"
    [[ -n "$apksigner" ]] || { echo "error: apksigner not found" >&2; exit 1; }
    certs="$("$apksigner" verify --print-certs "$artifact" 2>&1)" || {
      echo "error: $artifact failed signature verification:" >&2
      grep -v '^WARNING' <<<"$certs" >&2
      exit 1
    }
    actual="$(grep -m1 'certificate SHA-256 digest' <<<"$certs" | awk '{print $NF}' || true)"
    signers="$(grep -c 'certificate SHA-256 digest' <<<"$certs" || true)"
    ;;
  *.aab)
    certs="$(keytool -printcert -jarfile "$artifact" 2>&1 || true)"
    actual="$(grep -m1 'SHA256:' <<<"$certs" | awk '{print $NF}' | tr -d ':' | tr 'A-F' 'a-f' || true)"
    signers="$(grep -c 'SHA256:' <<<"$certs" || true)"
    ;;
  *)
    echo "error: expected an .apk or .aab, got $artifact" >&2; exit 1 ;;
esac

if [[ -z "$actual" ]]; then
  echo "error: $artifact is not signed" >&2
  exit 1
fi
if [[ "$signers" -ne 1 ]]; then
  echo "error: expected exactly one signer, found $signers" >&2
  exit 1
fi
if [[ "$actual" != "$expected" ]]; then
  echo "error: $artifact is signed with the wrong key." >&2
  echo "  expected: $expected" >&2
  echo "  actual:   $actual" >&2
  echo "Refusing to publish. Check the signing secrets." >&2
  exit 1
fi
echo "ok: $artifact is signed with the release key ($actual)"
