#!/usr/bin/env bash
# unverified_specs.sh: list spec scenarios no person has checked yet.
#
# Agent-written scenarios are tagged @unverified in docs/features/*.feature
# until someone reads them and either fixes or agrees them. Then delete the
# tag (and the file's UNVERIFIED note once none are left).
#
#   bash scripts/unverified_specs.sh            # every unverified scenario
#   bash scripts/unverified_specs.sh --count    # totals per file
#
# Build work (tests and code) should start from verified scenarios.

set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

if [[ "${1:-}" == "--count" ]]; then
  grep -c '^[[:space:]]*@unverified' docs/features/*.feature | grep -v ':0$' || echo "None: every scenario has been checked."
  exit 0
fi

awk '
  /^[[:space:]]*@unverified/ { pending = 1; next }
  pending && /^[[:space:]]*Scenario/ {
    sub(/^[[:space:]]*Scenario( Outline)?:[[:space:]]*/, "")
    printf "%s:%d  %s\n", FILENAME, FNR, $0
    n++
  }
  { pending = 0 }
  END { if (n) printf "\n%d unverified scenario(s)\n", n; else print "None: every scenario has been checked." }
' docs/features/*.feature
