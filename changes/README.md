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

## Checking

`dart run tool/rollup_changes.dart --check` validates every fragment, and
the unit tests run the same check, so a malformed file fails CI in the PR
that adds it. `dart run tool/rollup_changes.dart` (no flag) previews the
rolled-up Unreleased section without changing anything.
