# Release Kit: notes, screenshots, and videos

How Health Flare produces the three things every release needs: written
release notes, store screenshots, and a preview video: for one release, a
gap of several skipped releases, or a full quarter's worth of history. This
page ties together tools that already existed (`CHANGELOG.md`,
`scripts/take_screenshots*.sh`) with the two pieces that were missing:
retroactive release-notes generation and preview video capture.

## The three pieces

| Output | Primary source | Tooling |
|---|---|---|
| Release notes | `CHANGELOG.md`'s `[Unreleased]` section, hand-written as you merge: see its own "How to use this file" header | `scripts/release/generate_release_notes.sh` for retroactive/aggregate drafts |
| Screenshots | Fresh capture per release | `scripts/take_screenshots.sh` (iOS), `scripts/take_screenshots_android.sh` (Android) |
| Preview video | Fresh capture per release | `scripts/take_video.sh` (iOS), `scripts/take_video_android.sh` (Android) |

All three can be produced individually, or together via the orchestrator
(`scripts/release/build_release_kit.sh`) described below.

## Release notes

### The normal path: write them as you merge

`CHANGELOG.md`'s `[Unreleased]` section is the source of truth. Add an
entry in the right subsection (`Added`/`Changed`/`Fixed`/etc.) as part of
the PR that makes the change, in past tense, user-facing voice. This
produces better prose than any script: a human who just made the change
knows why it matters to a user in a way a title-parsing tool never will.
`scripts/release.sh` promotes `[Unreleased]` into a dated version section
when you cut a release.

### The gap this fills: retroactive or aggregate notes

Sometimes that doesn't happen: a PR merges without an Unreleased entry, or
you need notes spanning several releases at once (a quarterly summary, a
"what's new since you last updated" blurb, backfilling history). For that,
`scripts/release/generate_release_notes.sh` walks the actual git/PR/issue
history for any range and drafts the same Keep-a-Changelog shape:

```bash
# Draft notes for everything since the last release
scripts/release/generate_release_notes.sh --since v1.7.1

# Draft notes spanning several releases at once
scripts/release/generate_release_notes.sh --since v1.4.0 --until v1.7.1

# Draft notes since a date, not a tag
scripts/release/generate_release_notes.sh --since 2026-01-01

# Condensed prose for App Store / Play Store "what's new" fields, sized
# to those character limits (see docs/store-listing.md)
scripts/release/generate_release_notes.sh --since v1.7.1 --store-blurb
```

**Why it doesn't trust `gh pr list --state merged`:** before the repo moved
fully to GitHub (2026-09-13), PRs merged on Gitea, which push-mirrored to
GitHub. GitHub only ever observed the resulting merge commit (never a
merge performed through its own API), so its `merged` flag read `false` on
PRs that were very much merged (verified against #3–#18: every one showed
`merged:false` despite being in `main`'s history). The script still never
filters on that flag, both for consistency and so retroactive notes spanning
the Gitea era keep working. It finds PR numbers by walking `git log
--first-parent` for merge-commit patterns (the current GitHub-style `Merge
pull request #N from ...`, the pre-migration Gitea-style `Merge pull
request 'title' (#N) from branch into main`, plus GitHub's squash-merge
`(#N)` suffix convention), then uses `gh` only to fetch metadata (title,
labels, body) for PR numbers it already knows shipped. Commits that reach
`main` outside the PR flow entirely (this repo has plenty of those: 
dependency bumps, direct pushes) still show up, in a "Needs triage"
section, so nothing silently drops.

**Categorization** is by conventional-commit prefix on the PR/commit title
(`feat:` → Added, `fix:` → Fixed, `perf:`/`refactor:` → Changed,
`docs:`/`chore:`/`ci:`/`test:`/`build:`/`style:` → Internal, hidden unless
`--include-internal`). Anything without a recognizable prefix: plenty of
this repo's older history: lands in "Needs triage" rather than being
guessed into the wrong bucket. The script also scans each PR body for
`Closes #N` / `Fixes #N` / `Resolves #N` and lists those issues, with
titles, in an "Issues closed" section.

This is a **draft for a human to edit**, not something to paste straight
into `CHANGELOG.md` or App Store Connect unedited: voice and grouping
still follow `CHANGELOG.md`'s own rules. What it saves is the archaeology:
finding which PRs shipped in a range and what they were about.

Requires `gh` (authenticated) and `jq`.

## Screenshots

Unchanged: see `scripts/take_screenshots.sh` and
`scripts/take_screenshots_android.sh`. Both sweep every required App Store /
Play Store device class using the `integration_test/screenshot_test.dart`
fixture (a fake, in-memory Sarah Chen profile with realistic sample data
across every tracked category), writing into `screenshots/appstore/<slug>/`
and `screenshots/playstore/<slug>/`. These are committed to the repo: 
small, final-form PNGs that are literally what ships in the store listing.

## Preview videos

New. `integration_test/video_walkthrough_test.dart` drives the same kind of
populated-data demo as the screenshot suite, but as a continuous flowing
tour (onboarding, dashboard, tracking, illness detail, medications,
journal, a symptom log with the weather chip), holding each scene for a
couple of real seconds instead of taking a screenshot. It's deliberately a
self-contained fixture (not shared with `screenshot_test.dart`) so a
video-specific change can't break the screenshot pipeline that already
feeds App Store Connect, or vice versa.

Two wrapper scripts pair that walkthrough with platform screen recording,
the same way the screenshot scripts pair it with `flutter drive`:

```bash
# iOS: xcrun simctl io recordVideo, wrapping the walkthrough
scripts/take_video.sh                # default device class (iPhone 16 Pro Max)
scripts/take_video.sh "iPhone 16"    # a specific simulator
scripts/take_video.sh --list         # list available simulators

# Android: adb shell screenrecord, wrapping the walkthrough
scripts/take_video_android.sh
scripts/take_video_android.sh "Medium_Phone_API_36.1"
scripts/take_video_android.sh --list
```

Output goes to `videos/appstore/`, `videos/playstore/`, or `videos/adhoc/`: 
**not committed** (`.gitignore`). Unlike screenshots, raw captures are
large, get trimmed/edited before actual use, and are regenerable on demand
from the walkthrough test, so they stay local/CI artifacts. Edit the raw
capture down to 15–30 seconds for an App Store "App Preview" and upload it
directly in App Store Connect; for Play Console's listing "Video" field,
upload the edited cut to YouTube (unlisted is fine) and paste that URL: 
Play doesn't accept an uploaded file directly.

To change what the video shows, edit the scenes in
`integration_test/video_walkthrough_test.dart`: the capture scripts just
start/stop recording around whatever that file drives.

## Putting it together: the orchestrator

`scripts/release/build_release_kit.sh` runs all three for a given range and
assembles the result into one folder:

```bash
scripts/release/build_release_kit.sh --since v1.7.1 --version 1.7.2
scripts/release/build_release_kit.sh --since v1.4.0 --until v1.7.1 --notes-only
```

```
release-kit/<version-or-range>/
├── release-notes.md      Keep-a-Changelog-style draft
├── store-blurb.md         Condensed "what's new" draft for both stores
├── screenshots/            Snapshot of screenshots/{appstore,playstore} at build time
└── videos/                 Snapshot of videos/{appstore,playstore} at build time
```

Screenshot and video capture need a real Xcode/Android SDK dev machine: 
the orchestrator detects what's actually runnable on the current machine
and skips the rest with a clear note rather than failing outright, so
`--since`-only usage (e.g. from a machine with no simulators) still
produces a useful release-notes-only kit. `--notes-only` skips capture
entirely and explicitly. `release-kit/` output directories are scratch: 
not committed; screenshots stay committed under `screenshots/` as before,
and reviewed release notes get copied by hand into `CHANGELOG.md` and
`docs/store-listing.md`.
