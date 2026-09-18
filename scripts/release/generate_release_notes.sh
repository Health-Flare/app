#!/usr/bin/env bash
# scripts/release/generate_release_notes.sh
#
# Draft polished, user-facing release notes for ANY range of commits — one
# release, a gap of several skipped releases, or a whole quarter — by
# walking the PRs and issues that actually shipped in that range, not by
# relying on the Unreleased section having been kept up to date.
#
# Why this exists: CHANGELOG.md's [Unreleased] section is the primary,
# hand-curated source (see its own "How to use this file" header) and stays
# that way — a human writing entries as they merge produces better prose
# than any script. This tool is for the cases that workflow doesn't cover:
#   - a retroactive writeup spanning several past tags
#   - a contributor forgot to add an Unreleased entry and it shipped anyway
#   - App Store / Play Store "what's new" copy, which needs the same
#     underlying material condensed into a different shape
#
# It does NOT write to CHANGELOG.md. It prints a draft to stdout for a
# human to read, trim, and paste in.
#
# ── The Gitea/GitHub wrinkle ────────────────────────────────────────────
# This repo merges PRs on Gitea, which push-mirrors to GitHub in near real
# time. `gh pr list --state merged` is unreliable here — GitHub only ever
# sees the resulting merge commit, never a merge performed through its own
# API, so its `merged` flag reads false on PRs that are very much merged
# (confirmed against #3-#18: every one shows merged:false despite being in
# `main`'s history). So this script never filters or trusts that flag — it
# finds PR numbers by walking git history directly, then uses `gh` only to
# fetch metadata (title/labels/body) for numbers it already knows shipped.
#
# Usage:
#   scripts/release/generate_release_notes.sh --since v1.5.0
#   scripts/release/generate_release_notes.sh --since v1.4.0 --until v1.6.0
#   scripts/release/generate_release_notes.sh --since 2026-01-01           # date
#   scripts/release/generate_release_notes.sh --since v1.7.1 --include-internal
#   scripts/release/generate_release_notes.sh --since v1.7.1 --store-blurb
#
# Options:
#   --since REF          Tag, commit, or ISO date to start from (required).
#   --until REF          Tag, commit, or ISO date to end at (default: HEAD).
#   --repo OWNER/NAME    GitHub repo (default: inferred from `git remote`,
#                        falls back to Health-Flare/app).
#   --version X.Y.Z      Label the draft with a version heading instead of
#                        the raw ref range.
#   --include-internal   Also list docs/chore/ci/test/build/style entries
#                        (omitted by default — not user-facing).
#   --store-blurb        Emit condensed prose paragraphs instead of a
#                        Keep-a-Changelog section, sized for App Store /
#                        Play Store "what's new" fields (see character
#                        counts printed to stderr).
#
# Requires: gh (authenticated), jq, git.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_ROOT"

# ── Argument parsing ────────────────────────────────────────────────────
SINCE=""
UNTIL="HEAD"
REPO=""
VERSION=""
INCLUDE_INTERNAL=false
STORE_BLURB=false

usage() {
  sed -n '2,55p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --since) SINCE="$2"; shift 2 ;;
    --until) UNTIL="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --version) VERSION="$2"; shift 2 ;;
    --include-internal) INCLUDE_INTERNAL=true; shift ;;
    --store-blurb) STORE_BLURB=true; shift ;;
    -h|--help) usage 0 ;;
    *) echo "error: unknown argument '$1'" >&2; usage 1 ;;
  esac
done

if [[ -z "$SINCE" ]]; then
  echo "error: --since is required" >&2
  usage 1
fi

for bin in gh jq git; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' is required but not found in PATH" >&2
    exit 1
  fi
done

if [[ -z "$REPO" ]]; then
  ORIGIN_URL="$(git remote get-url origin 2>/dev/null || true)"
  REPO="$(echo "$ORIGIN_URL" | sed -E 's#^(git@|https://)([^:/]+)[:/]##; s#\.git$##' || true)"
  if [[ -z "$REPO" || "$REPO" == "$ORIGIN_URL" ]]; then
    REPO="Health-Flare/app"
  fi
fi

# Resolve --since/--until to real git refs — accepts tags, SHAs, or dates.
resolve_ref() {
  local input="$1"
  if git rev-parse --verify --quiet "${input}^{commit}" >/dev/null; then
    echo "$input"
    return
  fi
  # Fall back to "first commit on the current branch at/after this date".
  local sha
  sha="$(git rev-list -1 --since="$input" --reverse HEAD 2>/dev/null || true)"
  if [[ -z "$sha" ]]; then
    echo "error: could not resolve '$input' as a git ref or date" >&2
    exit 1
  fi
  echo "$sha"
}

SINCE_REF="$(resolve_ref "$SINCE")"
UNTIL_REF="$(resolve_ref "$UNTIL")"

echo "Collecting PRs merged between ${SINCE} (${SINCE_REF:0:12}) and ${UNTIL} (${UNTIL_REF:0:12}) in ${REPO}..." >&2

# ── 1. Find every PR number that landed in this range ──────────────────
# Two merge-commit shapes appear in this repo's history:
#   GitHub-style:  "Merge pull request #18 from Health-Flare/branch-name"
#   Gitea-style:   "Merge pull request 'title' (#123) from branch into main"
# Plus, in case a future PR is squash-merged (GitHub convention appends
# "(#N)" to the squashed commit's own subject line), scan all commits too.
PR_NUMBERS_FILE="$(mktemp)"
COMMIT_FALLBACK_FILE="$(mktemp)"
trap 'rm -f "$PR_NUMBERS_FILE" "$COMMIT_FALLBACK_FILE"' EXIT

git log --first-parent --format='%H%x09%s' "${SINCE_REF}..${UNTIL_REF}" | while IFS=$'\t' read -r sha subject; do
  pr_num=""
  if [[ "$subject" =~ ^Merge\ pull\ request\ \#([0-9]+)\  ]]; then
    pr_num="${BASH_REMATCH[1]}"
  elif [[ "$subject" =~ \(\#([0-9]+)\)[[:space:]]*(from|$) ]]; then
    pr_num="${BASH_REMATCH[1]}"
  fi

  if [[ -n "$pr_num" ]]; then
    echo "$pr_num" >> "$PR_NUMBERS_FILE"
  elif [[ ! "$subject" =~ ^Merge\  && ! "$subject" =~ ^release:\ v[0-9] ]]; then
    # Non-merge commit with no PR reference — keep as a fallback entry so
    # direct-to-main commits (or squash merges without "(#N)") aren't
    # silently dropped from the draft. "release: vX.Y.Z" bump commits are
    # excluded — they're the release mechanism, not a user-facing change.
    printf '%s\t%s\n' "${sha:0:12}" "$subject" >> "$COMMIT_FALLBACK_FILE"
  fi
done

if [[ ! -s "$PR_NUMBERS_FILE" && ! -s "$COMMIT_FALLBACK_FILE" ]]; then
  echo "No commits found in ${SINCE_REF}..${UNTIL_REF}." >&2
  exit 0
fi

PR_NUMBERS="$(sort -un "$PR_NUMBERS_FILE" 2>/dev/null || true)"

# ── 2. Fetch PR metadata + categorize ───────────────────────────────────
DRAFT_JSON="$(mktemp)"
echo "[]" > "$DRAFT_JSON"

CLOSED_ISSUES_FILE="$(mktemp)"
: > "$CLOSED_ISSUES_FILE"
trap 'rm -f "$PR_NUMBERS_FILE" "$COMMIT_FALLBACK_FILE" "$DRAFT_JSON" "$CLOSED_ISSUES_FILE"' EXIT

categorize() {
  # Reads a conventional-commit-style prefix off the PR title and prints
  # one of: Added Changed Fixed Internal Other
  local title="$1"
  local prefix
  prefix="$(echo "$title" | grep -oE '^[a-zA-Z]+(\([^)]*\))?!?:' | grep -oE '^[a-zA-Z]+' | tr '[:upper:]' '[:lower:]' || true)"
  case "$prefix" in
    feat) echo "Added" ;;
    fix) echo "Fixed" ;;
    perf|refactor) echo "Changed" ;;
    docs|chore|ci|test|build|style) echo "Internal" ;;
    "") echo "Other" ;;
    *) echo "Other" ;;
  esac
}

clean_title() {
  # Strips a leading "type(scope): " / "type!: " conventional-commit prefix.
  echo "$1" | sed -E 's/^[a-zA-Z]+(\([^)]*\))?!?:[[:space:]]*//'
}

if [[ -n "$PR_NUMBERS" ]]; then
  while read -r num; do
    [[ -z "$num" ]] && continue
    pr_json="$(gh pr view "$num" --repo "$REPO" \
      --json number,title,url,author,body,labels 2>/dev/null || true)"
    if [[ -z "$pr_json" ]]; then
      echo "  warning: could not fetch PR #$num from $REPO (skipping)" >&2
      continue
    fi

    title="$(echo "$pr_json" | jq -r '.title')"
    category="$(categorize "$title")"
    display_title="$(clean_title "$title")"

    entry="$(jq -n \
      --arg category "$category" \
      --arg text "$display_title" \
      --argjson pr "$pr_json" \
      '{category: $category, text: $text, pr: $pr}')"
    jq --argjson e "$entry" '. += [$e]' "$DRAFT_JSON" > "${DRAFT_JSON}.tmp" && mv "${DRAFT_JSON}.tmp" "$DRAFT_JSON"

    # Collect issues this PR closes (Fixes/Closes/Resolves #N in the body).
    echo "$pr_json" | jq -r '.body // ""' \
      | grep -ioE '(close[sd]?|fix(e[sd])?|resolve[sd]?)[[:space:]]+#[0-9]+' \
      | grep -oE '[0-9]+' >> "$CLOSED_ISSUES_FILE" || true
  done <<< "$PR_NUMBERS"
fi

# Fold in commit-only fallback entries as "Other" so nothing silently drops.
if [[ -s "$COMMIT_FALLBACK_FILE" ]]; then
  while IFS=$'\t' read -r sha subject; do
    entry="$(jq -n \
      --arg category "Other" \
      --arg text "$subject" \
      --arg sha "$sha" \
      '{category: $category, text: $text, pr: {number: null, url: null, sha: $sha}}')"
    jq --argjson e "$entry" '. += [$e]' "$DRAFT_JSON" > "${DRAFT_JSON}.tmp" && mv "${DRAFT_JSON}.tmp" "$DRAFT_JSON"
  done < "$COMMIT_FALLBACK_FILE"
fi

# ── 3. Render ────────────────────────────────────────────────────────────
render_bullets() {
  local category="$1"
  jq -r --arg cat "$category" '
    .[] | select(.category == $cat) |
    if .pr.number then
      "- " + .text + " ([#" + (.pr.number|tostring) + "](" + .pr.url + "))"
    else
      "- " + .text + " (" + .pr.sha + ")"
    end
  ' "$DRAFT_JSON"
}

if [[ "$STORE_BLURB" == true ]]; then
  echo "# Store blurb draft — ${VERSION:-${SINCE}..${UNTIL}}"
  echo
  for cat in Added Changed Fixed; do
    prose="$(jq -r --arg cat "$cat" '.[] | select(.category == $cat) | .text' "$DRAFT_JSON" \
      | sed -E 's/^./\U&/' | sed 's/$/./' | tr '\n' ' ')"
    [[ -z "$prose" ]] && continue
    case "$cat" in
      Added) echo "## New" ;;
      Changed) echo "## Improved" ;;
      Fixed) echo "## Fixed" ;;
    esac
    echo "$prose"
    echo
  done
  FULL_TEXT="$(jq -r '.[] | select(.category=="Added" or .category=="Changed" or .category=="Fixed") | .text' "$DRAFT_JSON" | tr '\n' ' ')"
  echo "── character counts (trim to fit) ──" >&2
  echo "App Store 'What's New' limit: 4000 — draft prose above is a starting point, not a copy-paste." >&2
  echo "Play Store 'Recent changes' limit: 500 — this draft will need real trimming, not just this joined text (${#FULL_TEXT} chars unformatted)." >&2
  exit 0
fi

HEADING="${VERSION:+[$VERSION] - $(date -u '+%Y-%m-%d')}"
HEADING="${HEADING:-${SINCE} → ${UNTIL}}"

echo "## ${HEADING}"
echo
for cat in Added Changed Deprecated Removed Fixed Security; do
  bullets="$(render_bullets "$cat")"
  [[ -z "$bullets" && "$cat" != "Added" && "$cat" != "Changed" && "$cat" != "Fixed" ]] && continue
  echo "### ${cat}"
  if [[ -n "$bullets" ]]; then
    echo "$bullets"
  else
    echo "- _Nothing yet._"
  fi
  echo
done

other_bullets="$(render_bullets "Other")"
if [[ -n "$other_bullets" ]]; then
  echo "### Needs triage (no conventional-commit prefix — categorize by hand)"
  echo "$other_bullets"
  echo
fi

if [[ "$INCLUDE_INTERNAL" == true ]]; then
  internal_bullets="$(render_bullets "Internal")"
  if [[ -n "$internal_bullets" ]]; then
    echo "### Internal (docs/chore/ci/test/build/style — not user-facing)"
    echo "$internal_bullets"
    echo
  fi
fi

if [[ -s "$CLOSED_ISSUES_FILE" ]]; then
  echo "### Issues closed in this range"
  sort -un "$CLOSED_ISSUES_FILE" | while read -r issue_num; do
    [[ -z "$issue_num" ]] && continue
    issue_json="$(gh issue view "$issue_num" --repo "$REPO" --json number,title,url 2>/dev/null || true)"
    if [[ -n "$issue_json" ]]; then
      echo "$issue_json" | jq -r '"- #" + (.number|tostring) + " " + .title + " (" + .url + ")"'
    else
      echo "- #${issue_num} (could not fetch title — check it wasn't a PR self-reference)"
    fi
  done
  echo
fi

pr_count="$(jq '[.[] | select(.pr.number != null)] | length' "$DRAFT_JSON")"
echo "---" >&2
echo "Drafted from ${pr_count} PR(s) in ${REPO} between ${SINCE} and ${UNTIL}." >&2
echo "This is a draft for a human to edit — voice, tense, and grouping per CHANGELOG.md's own rules." >&2
