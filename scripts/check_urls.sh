#!/usr/bin/env bash
# scripts/check_urls.sh
#
# Offline integrity scanner for Health Flare.
#
# Health Flare is a fully offline application. No Dart source file in lib/ or
# test/ should contain a hardcoded http:// or https:// URL outside of a comment,
# and no banned network-dependent package should be imported.
#
# Exits 0 if clean, 1 if violations are found.
#
# Whitelist:
#   Add patterns to .url-scan-ignore (one per line, grep -E format) to suppress
#   specific false positives. Each entry must have a documented justification
#   in that file.
#
# Usage:
#   bash scripts/check_urls.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

IGNORE_FILE="$REPO_ROOT/.url-scan-ignore"
VIOLATIONS=0

echo "──────────────────────────────────────────────"
echo "  Health Flare — Offline Integrity Scan"
echo "──────────────────────────────────────────────"

# ── 1. Scan for hardcoded URLs in non-comment Dart lines ──────────────────────
echo ""
echo "=== Scanning lib/ and test/ for hardcoded URLs ==="

# Match http(s):// that are NOT on a pure comment line (line starting with //).
# This allows URLs in doc comments and inline comments while catching live code.
URL_PATTERN='https?://'
COMMENT_PATTERN='^\s*//'

FINDINGS=$(grep -rn --include="*.dart" -E "$URL_PATTERN" lib/ test/ 2>/dev/null \
  | grep -vE "$COMMENT_PATTERN" \
  | grep -vF "// ignore: url-scan" \
  || true)

# Apply whitelist if present.
if [ -f "$IGNORE_FILE" ] && [ -n "$FINDINGS" ]; then
  while IFS= read -r pattern || [ -n "$pattern" ]; do
    # Skip blank lines and comment lines in the ignore file.
    [[ -z "$pattern" || "$pattern" == \#* ]] && continue
    FINDINGS=$(echo "$FINDINGS" | grep -vE "$pattern" || true)
  done < "$IGNORE_FILE"
fi

if [ -n "$FINDINGS" ]; then
  echo "❌  Hardcoded URLs found in Dart source (non-comment lines):"
  echo "$FINDINGS" | sed 's/^/    /'
  echo ""
  echo "    If this URL is intentional (e.g. a spec reference in a comment),"
  echo "    add it to .url-scan-ignore with a justification comment."
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅  No hardcoded URLs found."
fi

# ── 2. Check for banned network-dependent package imports ─────────────────────
echo ""
echo "=== Checking for banned network-dependent package imports ==="

BANNED_PACKAGES=(
  "google_fonts"
  "firebase_core"
  "firebase_auth"
  "firebase_database"
  "firebase_firestore"
  "cloud_firestore"
  "supabase"
  "supabase_flutter"
  "http"
  "dio"
  "retrofit"
  "chopper"
)

IMPORT_VIOLATIONS=()
for pkg in "${BANNED_PACKAGES[@]}"; do
  MATCHES=$(grep -rln --include="*.dart" "package:$pkg" lib/ test/ 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    IMPORT_VIOLATIONS+=("$pkg: $MATCHES")
  fi
done

if [ ${#IMPORT_VIOLATIONS[@]} -gt 0 ]; then
  echo "❌  Banned network-dependent package imports found:"
  for v in "${IMPORT_VIOLATIONS[@]}"; do
    echo "    $v"
  done
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅  No banned package imports found."
fi

# ── 3. Verify google_fonts is absent from pubspec.yaml ────────────────────────
echo ""
echo "=== Verifying google_fonts is not in pubspec.yaml ==="

if grep -q "google_fonts" pubspec.yaml; then
  echo "❌  google_fonts found in pubspec.yaml — all fonts must be bundled as assets."
  VIOLATIONS=$((VIOLATIONS + 1))
else
  echo "✅  google_fonts not present in pubspec.yaml."
fi

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "──────────────────────────────────────────────"
if [ "$VIOLATIONS" -gt 0 ]; then
  echo "❌  Scan failed with $VIOLATIONS violation(s)."
  exit 1
else
  echo "✅  Offline integrity scan passed."
fi
