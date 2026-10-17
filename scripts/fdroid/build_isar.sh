#!/usr/bin/env bash
# Builds libisar.so from source for F-Droid and swaps it in for the prebuilt
# copies that isar_community_flutter_libs ships in the pub cache. F-Droid's
# scanner rejects prebuilt native libraries, so the recipe deletes them
# (scandelete: .pub-cache) and this puts source-built ones back.
#
# Source: the third_party/isar-community submodule, pinned to the same
# version as isar_community_flutter_libs in pubspec.lock. Crate versions:
# scripts/fdroid/isar-Cargo.lock (upstream doesn't commit one; this is the
# lock LocalMaterialNotes builds 3.3.2 with on F-Droid).
#
# Usage (repo root, PUB_CACHE set): scripts/fdroid/build_isar.sh [abi...]
#   abi: armv7 arm64 x64 (default: all three; Flutter has no 32-bit x86)
set -euo pipefail

root=$(cd "$(dirname "$0")/../.." && pwd)
src=$root/third_party/isar-community
: "${PUB_CACHE:?set PUB_CACHE to the pub cache the build uses}"

locked=$(awk '/^  isar_community_flutter_libs:/{f=1} f && /version:/{gsub(/"/,"",$2); print $2; exit}' "$root/pubspec.lock")
pinned=$(git -C "$src" describe --tags --exact-match 2>/dev/null || echo "none")
if [[ "$locked" != "$pinned" ]]; then
  echo "third_party/isar-community is at $pinned but pubspec.lock has isar_community_flutter_libs $locked." >&2
  echo "Move the submodule to the $locked tag (and refresh scripts/fdroid/isar-Cargo.lock)." >&2
  exit 1
fi

# mdbx-sys runs bindgen, which otherwise parses the build host's glibc
# headers for an Android target and fails on the 32-bit ABI. Point it at the
# NDK sysroot, found the same way upstream's tool/build_android.sh finds it.
ndk=${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}/ndk}}
[[ -d "$ndk/toolchains" ]] || ndk=$(ls -d "$ndk"/* 2>/dev/null | sort -V | tail -n1)
sysroot=$ndk/toolchains/llvm/prebuilt/linux-x86_64/sysroot
[[ "$(uname -s)" == Darwin ]] && sysroot=$ndk/toolchains/llvm/prebuilt/darwin-x86_64/sysroot
test -d "$sysroot" || { echo "No NDK sysroot at $sysroot" >&2; exit 1; }
export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=$sysroot"

libs=$(ls -d "$PUB_CACHE"/hosted/pub.dev/isar_community_flutter_libs-"$locked"/android/src/main/jniLibs)
cp "$root/scripts/fdroid/isar-Cargo.lock" "$src/Cargo.lock"

abis=("$@")
[[ ${#abis[@]} -gt 0 ]] || abis=(armv7 arm64 x64)
cd "$src"
for abi in "${abis[@]}"; do
  case $abi in
    armv7) dir=armeabi-v7a ;;
    arm64) dir=arm64-v8a ;;
    x64) dir=x86_64 ;;
    *) echo "Unknown abi: $abi" >&2; exit 1 ;;
  esac
  bash tool/build_android.sh "$abi"
  mkdir -p "$libs/$dir"
  mv "libisar_android_$abi.so" "$libs/$dir/libisar.so"
done
# The 32-bit x86 copy is never rebuilt: drop it rather than ship a prebuilt.
rm -rf "$libs/x86"
find "$libs" -name '*.so' -exec ls -l {} +
