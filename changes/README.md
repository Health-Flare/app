# Changelog fragments

Every PR with a user-visible change adds **one file here** instead of
editing `CHANGELOG.md`. Each PR adding its own file means PRs no longer
conflict with each other on the changelog. At release time
`dart run tool/rollup_changes.dart --write` moves them all into
`CHANGELOG.md` and deletes them.

Docs, CI, dependency and test-only PRs don't need one.

## File name

`<issue>-<short-slug>.<section>.md`

- `<issue>`: the issue number (or the PR number if there's no issue)
- `<short-slug>`: a few lowercase words, hyphens between
- `<section>`: one of `added`, `changed`, `deprecated`, `removed`,
  `fixed`, `security`

Examples: `115-profile-sheet-spinner.fixed.md`,
`104-backup-size-cap.security.md`.

A PR that belongs in two sections adds two files.

## Content

One or more Markdown bullets, written for the person using the app:

```markdown
- Adding a profile from the profile switcher no longer leaves the New
  profile sheet stuck on a spinning button.
```

- Past tense, plain words, no PR numbers or code names.
- Name the screen and quote the UI text when it helps.
- Lines that don't start with `- ` continue the bullet above.

## Kind: fix, addition or move

Every change is one of three kinds (`docs/feature-releases.md`), and the
kind decides what ships with it:

| Kind | Means | Ships with |
|---|---|---|
| `fix` | Something broken now works | The fragment |
| `addition` | Something new; nothing existing moved | The fragment, and a What's new highlight if it's worth knowing |
| `move` | An existing screen, control or default is somewhere else, or does something else when tapped | The fragment, a highlight, **and a release guide** |

`added` fragments are additions and `fixed`/`security` fragments are fixes
unless they say otherwise. `changed`, `removed` and `deprecated` fragments
**must** say, because that's where moves hide. Put the kind on its own
line; the rollup keeps it out of the changelog:

```markdown
<!-- kind: addition -->
- The appointments card shows up to three appointments instead of two.
```

A move names its guide (lowercase, hyphens):

```markdown
<!-- kind: move; guide: track-and-care -->
- Meds, Meals and Sleep moved into Track and Care.
```

The test: would someone who used the app yesterday look for it in the old
place? Then it's a move. A move with no guide yet stays behind its build
flag with no fragment. The check fails a move fragment with no guide.

## Features that ship over several PRs

A feature built across several PRs before one release (Track and Care,
#135, is the first) gets one set of fragments, not one per PR. The first
PR writes them; later PRs **edit or replace** those files so the release
notes describe what shipped, not each step on the way. Don't add a bullet
that contradicts an earlier one ("The dashboard links to appointments",
then "Appointments moved to Care").

Say so at the top of the fragment with a one-line comment naming the
issues that will change it. Each comment line must start with `<!--`;
the rollup skips those lines and keeps only the bullets:

```markdown
<!-- Track and Care (#141) moves this. Edit this bullet then. -->
- The dashboard has an "All appointments" link.
```

The same goes for any fragment whose feature changes again before
release: fix the fragment in the later PR rather than stacking a
correction under it.

When cutting a release, put the headline changes first in each
subsection of `CHANGELOG.md`. Fragments roll up in file-name order, which
is not the order of importance.

## Checking

`dart run tool/rollup_changes.dart --check` validates every fragment
(including its kind) and `assets/whats_new/releases.json`, and the unit
tests run the same checks, so a bad file fails CI in the PR that adds it. `dart run tool/rollup_changes.dart` (no flag) previews the
rolled-up Unreleased section without changing anything.
