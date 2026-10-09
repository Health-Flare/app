# Releasing features

How a user-facing change gets from merged to in someone's hands without
surprising them. Applies to every release from the Track and Care layout
onward. Specs: `docs/features/whats-new.feature`,
`docs/features/navigation-customization.feature`.

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

## Rules

1. **No move ships without a guide.** The guide says what moved, where it
   went, and how to find the guide again. If the guide isn't ready, the
   move stays behind its flag.
2. **Nothing blocks logging.** No launch modals, no overlays on log forms,
   no badges or unread counts. Release content waits on the dashboard.
3. **Dismissed means dismissed.** One gesture, no confirmation, never shown
   again for that release. Everything stays in Settings > What's new.
4. **Customizations survive updates.** An update never rearranges a bar
   the user changed. It tells them the default changed and theirs was kept.
5. **Ids are forever.** Sections and tabs are referenced by stable id. A
   retired id gets an entry in the replacement map, in the same PR that
   retires it, with a test.
6. **Offline.** Highlights and guides are bundled. Nothing is fetched,
   nothing reports whether it was read.

## Release checklist additions

- [ ] Each fragment in `changes/` is tagged fix, addition or move
- [ ] Every move has a guide entry and its build flag is on
- [ ] Highlights written for the release (2 to 4, plain language, grade 6 to 8, no dashes)
- [ ] Any retired section or tab id is in the replacement map
- [ ] Guide checked with a screen reader, Reduce Motion and 200% text
- [ ] CI check: the `pubspec.yaml` version has a What's new entry (may be empty for fix-only releases)

## Ordering for Track and Care

These merge to main separately, behind one flag, and ship together:

1. Stable ids for sections and tabs, old-route redirects (no visible change)
2. What's new history and release card (#75), usable on its own
3. Track and Care layout, flagged off
4. Bar customization, flagged off
5. The Track and Care guide, then the flag comes on in the release that ships it

Accessibility work comes next and will use the same path: its settings
changes are moves, so they get a guide.
