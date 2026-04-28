#!/usr/bin/env bash
# Extract a single version's section from CHANGELOG.md and print it to stdout.
#
# Usage:
#   bash scripts/extract_changelog.sh v1.2.3
#   bash scripts/extract_changelog.sh 1.2.3
#   bash scripts/extract_changelog.sh Unreleased
#
# The script accepts an optional leading "v" so it works directly with git
# tag names (`github.ref_name` in CI). It prints everything between the
# matching `## [VERSION]` heading and the next `## [` heading, exclusive.
#
# Exits non-zero if no matching section is found, so CI fails loudly when a
# tag is pushed without a corresponding changelog entry.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <version>" >&2
  echo "       $0 v1.2.3" >&2
  echo "       $0 Unreleased" >&2
  exit 64
fi

raw="$1"
# Strip a leading "v" so callers can pass either "v1.2.3" or "1.2.3".
version="${raw#v}"

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
changelog="${repo_root}/CHANGELOG.md"

if [ ! -f "$changelog" ]; then
  echo "error: $changelog not found" >&2
  exit 66
fi

section="$(
  awk -v target="$version" '
    BEGIN { found = 0; printing = 0 }
    # Stop when we hit the next version heading.
    /^## \[/ {
      if (printing) { exit }
      # Match `## [VERSION]` or `## [VERSION] - DATE`
      if ($0 ~ "^## \\[" target "\\](\\]| - |$)") {
        found = 1
        printing = 1
        next
      }
    }
    # Stop when we hit the link-reference block at the bottom of the file,
    # e.g. `[Unreleased]: https://...`.
    printing && /^\[[^]]+\]:[[:space:]]/ { exit }
    printing { print }
    END { if (!found) exit 1 }
  ' "$changelog"
)"

if [ -z "${section// /}" ]; then
  echo "error: no changelog section found for version '$version'" >&2
  exit 1
fi

# Trim leading/trailing blank lines.
printf '%s\n' "$section" | awk '
  NF { blank = 0; buf = buf $0 ORS; next }
  { if (length(buf)) buf = buf $0 ORS }
  END {
    # Strip trailing blank lines from buf.
    sub(/[[:space:]]+$/, "", buf)
    if (length(buf)) print buf
  }
'
