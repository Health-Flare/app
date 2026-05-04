#!/usr/bin/env bash
# scripts/release.sh
#
# Cut a new Health Flare release.
#
# Automates every step described in CHANGELOG.md's release checklist:
#   1. Bump `version:` in pubspec.yaml (versionName + versionCode).
#   2. Promote the ## [Unreleased] section in CHANGELOG.md.
#   3. Commit the changes and create an annotated git tag.
#   4. Push the commit and tag — triggering the Gitea release workflow.
#
# Usage:
#   bash scripts/release.sh patch                # 1.0.0 → 1.0.1
#   bash scripts/release.sh minor                # 1.0.0 → 1.1.0
#   bash scripts/release.sh major                # 1.0.0 → 2.0.0
#   bash scripts/release.sh 2.5.0                # explicit version
#   bash scripts/release.sh minor --dry-run      # preview without changes
#   bash scripts/release.sh patch --no-push      # commit + tag, skip push
#
# Prerequisites:
#   - Clean working tree (no uncommitted changes).
#   - On the main branch (override with --allow-branch).

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PUBSPEC="${REPO_ROOT}/pubspec.yaml"
CHANGELOG="${REPO_ROOT}/CHANGELOG.md"
GITEA_BASE="https://git.ahosking.com/HealthFlare/app"

# ── Defaults ────────────────────────────────────────────────────────────
DRY_RUN=false
NO_PUSH=false
ALLOW_BRANCH=false

# ── Usage ───────────────────────────────────────────────────────────────
usage() {
  cat <<EOF
usage: $(basename "$0") <major|minor|patch|X.Y.Z> [options]

Positional:
  major            Bump the major version   (1.2.3 → 2.0.0)
  minor            Bump the minor version   (1.2.3 → 1.3.0)
  patch            Bump the patch version   (1.2.3 → 1.2.4)
  X.Y.Z            Set an explicit version  (must be valid semver)

Options:
  --dry-run        Show what would happen without making changes.
  --no-push        Commit and tag locally, but do not push to origin.
  --allow-branch   Allow releasing from a branch other than main.
  -h, --help       Show this help message.
EOF
  exit "${1:-0}"
}

# ── Argument parsing ────────────────────────────────────────────────────
BUMP=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    major|minor|patch) BUMP="$1" ;;
    --dry-run)         DRY_RUN=true ;;
    --no-push)         NO_PUSH=true ;;
    --allow-branch)    ALLOW_BRANCH=true ;;
    -h|--help)         usage 0 ;;
    *)
      if [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        BUMP="$1"
      else
        echo "error: unknown argument '$1'" >&2
        usage 1
      fi
      ;;
  esac
  shift
done

if [[ -z "$BUMP" ]]; then
  echo "error: version bump argument required" >&2
  usage 1
fi

# ── Preflight checks ───────────────────────────────────────────────────
cd "$REPO_ROOT"

if [[ ! -f "$PUBSPEC" ]]; then
  echo "error: $PUBSPEC not found" >&2
  exit 66
fi
if [[ ! -f "$CHANGELOG" ]]; then
  echo "error: $CHANGELOG not found" >&2
  exit 66
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [[ "$DRY_RUN" != true ]]; then
  # Clean working tree?
  if ! git diff --quiet HEAD 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
    echo "error: working tree has uncommitted changes — commit or stash first." >&2
    exit 1
  fi

  # On main?
  if [[ "$BRANCH" != "main" ]] && [[ "$ALLOW_BRANCH" != true ]]; then
    echo "error: releases should be cut from main (currently on '$BRANCH')." >&2
    echo "       Use --allow-branch to override." >&2
    exit 1
  fi
fi

# ── Read current version from pubspec.yaml ──────────────────────────────
CURRENT_LINE=$(grep -E '^version:\s+[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+' "$PUBSPEC" || true)
if [[ -z "$CURRENT_LINE" ]]; then
  echo "error: could not parse version from $PUBSPEC" >&2
  echo "       Expected format: version: X.Y.Z+BUILD" >&2
  exit 1
fi

CURRENT_VERSION=$(echo "$CURRENT_LINE" | sed -E 's/^version:[[:space:]]+([0-9]+\.[0-9]+\.[0-9]+)\+.*/\1/')
CURRENT_BUILD=$(echo "$CURRENT_LINE" | sed -E 's/^version:[[:space:]]+[0-9]+\.[0-9]+\.[0-9]+\+([0-9]+)/\1/')

IFS='.' read -r CUR_MAJOR CUR_MINOR CUR_PATCH <<< "$CURRENT_VERSION"

# ── Compute new version ────────────────────────────────────────────────
case "$BUMP" in
  major) NEW_VERSION="$((CUR_MAJOR + 1)).0.0" ;;
  minor) NEW_VERSION="${CUR_MAJOR}.$((CUR_MINOR + 1)).0" ;;
  patch) NEW_VERSION="${CUR_MAJOR}.${CUR_MINOR}.$((CUR_PATCH + 1))" ;;
  *)     NEW_VERSION="$BUMP" ;;
esac

NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_TAG="v${NEW_VERSION}"
PREV_TAG="v${CURRENT_VERSION}"
TODAY=$(date -u '+%Y-%m-%d')

if [[ "$NEW_VERSION" == "$CURRENT_VERSION" ]]; then
  echo "error: new version ($NEW_VERSION) is the same as current ($CURRENT_VERSION)." >&2
  exit 1
fi

if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
  echo "error: tag $NEW_TAG already exists." >&2
  exit 1
fi

# ── Check Unreleased content ───────────────────────────────────────────
UNRELEASED=$(bash "${REPO_ROOT}/scripts/extract_changelog.sh" Unreleased 2>/dev/null || true)
REAL_ENTRIES=$(echo "$UNRELEASED" | grep -v '^\s*$\|^###\|_Nothing yet\._' || true)

if [[ -z "$REAL_ENTRIES" ]]; then
  echo "warning: the Unreleased section in CHANGELOG.md has no real entries."
  if [[ "$DRY_RUN" != true ]]; then
    read -rp "  Continue anyway? [y/N] " confirm
    if [[ "$confirm" != [yY] ]]; then
      echo "Aborted."
      exit 0
    fi
  fi
fi

# ── Summary ─────────────────────────────────────────────────────────────
echo "──────────────────────────────────────────────"
echo "  Health Flare — Release"
echo "  ${CURRENT_VERSION}+${CURRENT_BUILD}  →  ${NEW_VERSION}+${NEW_BUILD}"
echo "  Tag: ${NEW_TAG}    Date: ${TODAY}"
if [[ "$NO_PUSH" == true ]]; then
  echo "  Push: skipped (--no-push)"
fi
echo "──────────────────────────────────────────────"

if [[ "$DRY_RUN" == true ]]; then
  echo ""
  echo "[dry-run] Would update pubspec.yaml and CHANGELOG.md, commit, and tag."
  echo "[dry-run] No changes made."
  exit 0
fi

# ── 1. Update pubspec.yaml ─────────────────────────────────────────────
TMP=$(mktemp)
sed "s/^version: ${CURRENT_VERSION}+${CURRENT_BUILD}/version: ${NEW_VERSION}+${NEW_BUILD}/" \
  "$PUBSPEC" > "$TMP" && mv "$TMP" "$PUBSPEC"
echo "  Updated pubspec.yaml → ${NEW_VERSION}+${NEW_BUILD}"

# ── 2. Update CHANGELOG.md ─────────────────────────────────────────────
# 2a. Replace the ## [Unreleased] heading with a fresh Unreleased block
#     followed by the new version heading.
TMP=$(mktemp)
awk -v new_ver="$NEW_VERSION" -v today="$TODAY" '
  /^## \[Unreleased\]/ {
    print "## [Unreleased]"
    print ""
    print "### Added"
    print "- _Nothing yet._"
    print ""
    print "### Changed"
    print "- _Nothing yet._"
    print ""
    print "### Deprecated"
    print "- _Nothing yet._"
    print ""
    print "### Removed"
    print "- _Nothing yet._"
    print ""
    print "### Fixed"
    print "- _Nothing yet._"
    print ""
    print "### Security"
    print "- _Nothing yet._"
    print ""
    print "## [" new_ver "] - " today
    next
  }
  { print }
' "$CHANGELOG" > "$TMP" && mv "$TMP" "$CHANGELOG"

# 2b. Update comparison links at the bottom of the file.
TMP=$(mktemp)
awk -v new_ver="$NEW_VERSION" -v new_tag="$NEW_TAG" -v prev_tag="$PREV_TAG" -v base="$GITEA_BASE" '
  /^\[Unreleased\]:/ {
    print "[Unreleased]: " base "/compare/" new_tag "...HEAD"
    print "[" new_ver "]: " base "/compare/" prev_tag "..." new_tag
    next
  }
  { print }
' "$CHANGELOG" > "$TMP" && mv "$TMP" "$CHANGELOG"

echo "  Updated CHANGELOG.md"

# ── 3. Commit ──────────────────────────────────────────────────────────
git add "$PUBSPEC" "$CHANGELOG"
git commit -m "release: ${NEW_TAG}

Bump version to ${NEW_VERSION}+${NEW_BUILD} and promote changelog."

echo "  Committed release changes"

# ── 4. Tag ─────────────────────────────────────────────────────────────
git tag -a "$NEW_TAG" -m "Health Flare ${NEW_TAG}"
echo "  Created tag ${NEW_TAG}"

# ── 5. Push ────────────────────────────────────────────────────────────
if [[ "$NO_PUSH" == true ]]; then
  echo ""
  echo "  Tag created locally. Push when ready:"
  echo "    git push origin ${BRANCH} ${NEW_TAG}"
  exit 0
fi

git push origin "$BRANCH"
git push origin "$NEW_TAG"
echo ""
echo "  Pushed to origin. Release workflow should start shortly."
echo "  ${GITEA_BASE}/releases/tag/${NEW_TAG}"
