# Releasing features

How a user-facing change gets from merged to in someone's hands without
surprising them. Applies to every release from the Track and Care layout
onward. Specs: `docs/features/whats-new.feature`; the layout specs
(`navigation-customization.feature`) are on the `feature/navigation-track-care`
branch (#135) until they're ready.

## Sort the change first

Every user-facing change is one of three kinds. The kind decides what has
to ship with it.

| Kind | Example | Ships with |
|---|---|---|
| Fix | A missed dose no longer exports as taken | Changelog fragment only |
| Addition | You can now log naps from Quick Log | Fragment, plus a highlight if it's worth knowing about |
| Move | Meds moved into Care | Fragment, highlight, **and a guide**. Behind a build flag until all three are ready |

A **move** is anything that changes where an existing screen, control or
default is, or what it does when tapped. If someone who used the app
yesterday would look for it in the old place, it's a move.

The kind is the last part of the changelog fragment's file name, after
its section: `141-track-and-care.changed.move.md`. See
`changes/README.md`.

## Rules

1. **No move ships without a guide.** The guide says what moved, where it
   went, and how to find the guide again. If the guide isn't ready, the
   move stays behind its flag.
2. **Nothing blocks logging.** No launch modals, no overlays on log forms,
   no badges or unread counts. Release content waits on the dashboard.
3. **Dismissed means dismissed.** One gesture, no confirmation, never shown
   again for that release. Everything stays in Settings > What's new.
4. **Customizations survive updates.** An update never rearranges a bar
   the user changed, and never turns a feature back on that they turned
   off. It tells them the default changed and theirs was kept.
5. **Off means off.** Anything a user can turn off (a feature, update
   highlights, a guide) stays off. Turning a feature off never touches its
   data.
6. **Settings travel with backups.** Layout, features in use and update
   preferences restore with "Replace everything". "Add missing data" never
   overwrites a choice made on this device.
7. **Ids are forever.** Sections and tabs are referenced by stable id. A
   retired id gets an entry in the replacement map, in the same PR that
   retires it, with a test.
8. **Offline.** Highlights and guides are bundled. Nothing is fetched,
   nothing reports whether it was read.

## Writing What's new

Release content lives in `assets/whats_new/releases.json`, bundled with
the app. One entry per version, newest first:

```json
{
  "version": "1.10.0",
  "date": "2026-10-20",
  "highlights": [{ "title": "Naps in Quick Log", "body": "You can log a nap from Quick Log." }],
  "changes": ["One line per change, from the changelog fragments."],
  "guideId": null
}
```

- `highlights`: 0 to 4. Leave empty for a fix-only release: it's listed
  in history and never gets a card. A release only gets a dashboard card
  when it has highlights.
- `changes`: the full list, shown collapsed under "All changes".
- `date`: `null` while the release is being written. The app only lists
  versions up to the one installed, so an entry for the next version can
  sit on main before release.
- `guideId`: the release guide for a move (#145). Null otherwise.

You don't start the entry by hand. At release time
`dart run tool/rollup_changes.dart --write` drafts it: dated today, "All
changes" filled from `CHANGELOG.md`'s Unreleased section, and a `TODO`
highlight for a person to write. A fix-only release (only `fix`
fragments, and nothing in Unreleased outside Fixed and Security) gets no
highlights. A release with a `move` fragment gets `"guideId": "TODO"`.
Anything already written in the entry is kept. The full sequence is the
release checklist in `docs/release-kit.md`.

CI (through `test/unit/rollup_changes_test.dart`) fails when:

- `pubspec.yaml`'s version has no entry. An entry with no highlights is
  fine for a fix-only release.
- The `pubspec.yaml` version's entry, or any dated entry, still has a
  `TODO`.
- A `move` fragment is in `changes/` and the release being written (the
  newest entry, with `"date": null`) names no guide.

`scripts/release.sh` runs the same check for the new version before it
bumps anything, since the tag goes out before CI runs on it.

How the card behaves (all in `lib/features/whats_new/whats_new_rules.dart`):

- A fresh install never sees a card. Someone updating sees one card for
  every release with highlights since the last one they saw.
- Dismissing, opening What's new, or ignoring the card for 5 opens ends it
  for every release up to the installed one.
- With "Show update highlights" off, updates count as seen, so turning it
  back on never brings back an old card.

To see your entry in the app before release, and to test or screenshot
the card: `bash scripts/whats_new.sh` (guide: `docs/testing/whats-new.md`).

## Release checklist additions

- [ ] Each fragment in `changes/` is tagged fix, addition or move (the tool refuses one that isn't)
- [ ] Every move has a guide entry and its build flag is on (CI checks the guide is named, not that it's right)
- [ ] Highlights written for the release (2 to 4, plain language, grade 6 to 8, no dashes)
- [ ] Any retired section, tab or feature id is in the replacement map
- [ ] Backup round trip checked with a customized bar and a feature turned off
- [ ] `bash scripts/whats_new.sh check` passes and `shots` looks right
- [ ] Guide checked with a screen reader, Reduce Motion and 200% text
- [ ] No `TODO` left in the release's What's new entry (CI and `scripts/release.sh` check this, and that the `pubspec.yaml` version has an entry)

## Ordering for Track and Care

These merge to main separately, behind one flag, and ship together:

1. Stable ids for sections, tabs and features, old-route redirects (no visible change)
2. What's new history and release card (#75), usable on its own
3. Track and Care layout, flagged off
4. Your layout: features in use and bottom bar, with backup support, flagged off
5. The Track and Care guide, then the flag comes on in the release that ships it

Steps 3 and 4 are built in that order, but they ship together. The
guide's "Keep it like before" choice is a bottom bar preset, so the layout
can't ship without it.

Accessibility work comes next and will use the same path: its settings
changes are moves, so they get a guide.
