# Testing What's new

How to check the What's new card, history and setting by hand, by test,
and by screenshot. One script does all of it:

```bash
bash scripts/whats_new.sh            # help
```

Spec: `docs/features/whats-new.feature`. How to write release content:
`docs/feature-releases.md` ("Writing What's new").

## The 30-second version

| I want to… | Run | Needs |
|---|---|---|
| Know nothing is broken | `bash scripts/whats_new.sh test` | Nothing. ~30 s |
| See every state, as screenshots | `bash scripts/whats_new.sh shots` | Xcode + an iPhone simulator. ~5 min |
| Prove it works on a device, no screenshots | `bash scripts/whats_new.sh e2e` | Same |
| Play with the card myself | `bash scripts/whats_new.sh run card` | Same |
| List the states I can open | `bash scripts/whats_new.sh scenarios` | Nothing |
| Check `changes/` and `releases.json` after editing them | `bash scripts/whats_new.sh check` | Nothing |
| Update the golden images after a visual change | `bash scripts/whats_new.sh goldens` | `gh` logged in, branch pushed |

Pick a simulator or device with `-d`, before the command:

```bash
bash scripts/whats_new.sh -d "iPhone 17 Pro Max" shots
bash scripts/whats_new.sh -d emulator-5554 run card     # Android
```

Without `-d` it uses a booted iPhone, then "iPhone 17", then any iPhone.

## Preview scenarios: open the app in any state

`run <scenario>` starts a debug build already in a What's new state. No
editing `pubspec.yaml`, no fake version bumps, no reinstalling. It uses
fixture releases numbered **99.x**, so they can't be mistaken for real
ones.

| Scenario | What you should see |
|---|---|
| `card` | One card at the top of the dashboard: "What's new in 99.2", two highlight titles, "See what's new", a close button |
| `multi` | One card: "What's new since your last update", with highlights from 99.2 and 99.1 |
| `fixonly` | No card. Settings > What's new lists 99.3.0 at the top with no highlights |
| `seen` | No card. Full history in Settings |
| `off` | No card. Settings shows "Show update highlights" off, with "You won't get a card after updates, even when screens move. Everything stays in What's new." |
| `upgrade` | Like `card`, but nothing is reset between launches. Use it to try dismiss + relaunch, or the 5-open expiry, for real |
| `reset` | Back to the real `releases.json` and real version, What's new state cleared |

Notes:

- **No setup.** On a fresh simulator (no profile yet), the scenario adds
  a demo profile called "Sam" with onboarding done, so you land on the
  dashboard. It never touches existing profiles.
- **Run `reset` when you're done.** Otherwise this install remembers
  having seen version 99, and real cards won't show until 99 ships. The
  script reminds you.
- Every scenario except `upgrade` puts the same state back on each
  launch, so hot restart (`R`) always gets you the same screen.
- Previews only exist in debug builds. In a release build
  `--dart-define=WHATS_NEW_PREVIEW` does nothing.
- The scenario list lives in one place:
  `lib/features/whats_new/debug/whats_new_preview.dart`. The script reads
  it, so adding a scenario there adds it to `scenarios` and `run`.

### Hand-test checklist

Run each line and tick it off. Everything here is also covered by the
automated end-to-end test; this is for eyes on the real thing.

- [ ] `run card`: the card sits below the flare banner. Nothing covers
      the screen. No red dot, no badge, no count.
- [ ] Tap the close button: the card goes, no "Are you sure?".
- [ ] `run upgrade`, dismiss, quit the app, open it again: no card.
- [ ] `run upgrade` on a fresh state (`run reset` first, then `run
      upgrade`): swipe the card sideways, it's gone.
- [ ] `run card`, tap "See what's new": history opens at 99.2. Go back:
      the card is gone.
- [ ] `run card`, tap "I'm flaring" to start a flare, restart (`R`): no
      card. End the flare, restart: the card is back.
- [ ] `run multi`: one card, not two.
- [ ] `run off`: no card, and Settings says what off means.
- [ ] Turn on VoiceOver (Simulator: Settings > Accessibility), `run
      card`: the card is read out once, and focus doesn't jump to it.
- [ ] Settings > Accessibility > Display & Text Size > Larger Text, max
      it out, `run card`: no cut-off text, no overflow stripes.
- [ ] Settings > Accessibility > Motion > Reduce Motion on, `run
      upgrade`, swipe the card: it goes without sliding.
- [ ] `run reset`.

## The automated tests

| File | Covers | Runs |
|---|---|---|
| `test/unit/whats_new_rules_test.dart` | The rules: versions, which releases get a card, fresh install, expiry, downgrades | `test`, CI |
| `test/unit/whats_new_store_test.dart` | Storage on a real database: migration, round trip, dismiss surviving a restart, highlights on/off, `releases.json` parses | `test`, `check`, CI |
| `test/unit/whats_new_preview_test.dart` | Each preview scenario lands in the state this guide says it does | `test`, CI |
| `test/widget/whats_new_test.dart` | Card, swipe, flare hold-off, screen reader announcement, history, Settings switch | `test`, CI |
| `test/golden/whats_new_golden_test.dart` | Pixel snapshots: card (light, dark, two releases), history, setting off | CI only (Linux) |
| `integration_test/whats_new_test.dart` | The real app on a real database, with relaunches, screenshotting every visible state | `shots`, `e2e` |

The end-to-end test checks, in order: a fresh install sees no card; an
update shows one card (also in dark mode and at 200% text); skipping a
version shows one card; dismissing survives a relaunch; swiping
dismisses; an ignored card is gone on the 6th open; a flare holds it
off; a fix-only update shows nothing but is in history; "See what's new"
opens history and counts as seen; turning highlights off sticks after a
relaunch.

## Screenshots

`bash scripts/whats_new.sh shots` writes to `screenshots/whats_new/` and
opens `index.html`, a contact sheet with every image, the date and the
commit:

| File | State |
|---|---|
| `whats_new_00_fresh_install_no_card.png` | Fresh install: dashboard, no card |
| `whats_new_01_card.png` | The card |
| `whats_new_02_card_dark.png` | The card, dark mode |
| `whats_new_03_card_multi.png` | One card covering two releases |
| `whats_new_04_card_200_percent_text.png` | The card at 200% text |
| `whats_new_05_after_dismiss_and_relaunch.png` | Dismissed, app reopened: no card |
| `whats_new_06_flare_no_card.png` | Active flare: no card |
| `whats_new_07_history_fix_only_release.png` | History with a fix-only release at the top |
| `whats_new_08_history.png` | History, opened from the card |
| `whats_new_09_history_all_changes.png` | "All changes" expanded |
| `whats_new_10_settings_highlights_on.png` | Settings, highlights on |
| `whats_new_11_settings_highlights_off.png` | Settings, highlights off, with its explanation |

The set in the repo is the reference for how the cards look today.
Re-run `shots` in any PR that touches the card, commit the changed
images, and the PR diff shows before and after side by side. GitHub
renders PNG diffs.

## Golden images

Golden tests compare against PNGs in `test/goldens/whats_new_*.png`. They
must be rendered on Linux: macOS anti-aliasing is a few pixels off, so
the golden test skips itself on a Mac and CI runs it.

After a change that's meant to look different:

```bash
git push                                   # CI renders what's pushed
bash scripts/whats_new.sh goldens          # runs the workflow, waits, copies the PNGs in
git add test/goldens && git commit -m "test(whats-new): update goldens"
```

If CI fails a golden you didn't mean to change, open the failing job:
the diff images are in its log output. Don't regenerate to make it pass.

## When something goes wrong

| Symptom | Fix |
|---|---|
| No card on a real update after previewing | You previewed and didn't reset. `run reset` |
| `No iPhone simulator found` | `xcrun simctl list devices available`, then pass one with `-d` |
| `shots` fails with "Timed out waiting for…" | The UI copy changed. The strings the test looks for are at the top of `integration_test/whats_new_test.dart` |
| `jq not found` | `brew install jq` |
| Golden test fails locally on macOS | It shouldn't run there; if it does, you're not on macOS. Use `goldens` to re-render on Linux |
| `check` fails | It names the file and the version, and says what to change. Releasing: `docs/feature-releases.md` |
