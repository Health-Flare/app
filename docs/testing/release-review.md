# Release review: 1.10.0

One command screenshots every new notification and screen in 1.10.0, in the order someone updating from 1.9.1 sees them. Every step is shot in light and dark, at 100% and 200% text, on an iPhone and an Android phone. A contact sheet then lays the variants side by side, one row per step.

The App Store and Play screenshots are a separate set; they come from `scripts/take_screenshots.sh`.

```bash
bash scripts/release_review.sh -o     # iPhone, then Android if one is running; opens the sheet
```

## The 30-second version

| I want to… | Run | Needs |
|---|---|---|
| The whole set | `bash scripts/release_review.sh` | Xcode + an iPhone simulator; an Android emulator for the Android half. About 8 min per device |
| iPhone only | `bash scripts/release_review.sh ios` | Xcode |
| Android only | `bash scripts/release_review.sh android` | A running emulator (`flutter emulators --launch <id>`) |
| One variant, quicker | `bash scripts/release_review.sh -v dark-200 ios` | Same. About 2 min |
| Rebuild the contact sheet | `bash scripts/release_review.sh sheet` | Nothing |

Output goes to `screenshots/release_review/<device>/<variant>/NN_step.png`, with `index.html` beside it. Each device's run log is `screenshots/release_review/<device>.log`. The folder isn't committed: one run is about 200 full-size images.

## What it walks

Each variant starts from a fresh database that looks like 1.9.1 after updating: one profile ("Sarah"), the old bar, nothing seen yet, and highlights on.

| # | Step | What to check |
|---|---|---|
| 01 | Guide card | Shows before What's new. The title and body read well at 200% |
| 02–06 | The guide: Four sections now, Where things moved, Pinned, Keep it or change it, Finding this again | Rows and Pin at large text (they stack). The pinned line wording |
| 07 | Show me | Care opens with its bar item outlined |
| 08–09 | What's new card, then Settings > What's new with Replay guide | The card only appears once the guide is done. The highlights are the draft 1.10.0 entry |
| 10–13 | Track, Care, Journal; the pinned Sleep | Tabs fit or scroll at 200% |
| 14–15 | Settings > Your layout; Features in use with Meals off | The "kept" message |
| 16–18 | Bottom bar; full bar; Like before | "The bar holds five items" and the Like before note |
| 19 | More | What's left over after Like before |
| 20 | Quick Log with Meals off | The warning and "Turn Meals on" |
| 21–22 | Someone with their own bar: the card ("Yours has been kept"), then Keep my bar | |
| 23–24 | An update that didn't finish (#112): the card, then its Settings section | The wording is still `@unverified` |

## How it works

- The walk is `integration_test/release_review_test.dart`, with one test per variant. Dark mode and text size are set in the test, not on the device, so one build covers all four.
- The test makes the database look like 1.9.1 directly, and tells the app it's 1.10.0, because `pubspec.yaml` says 1.9.1 until the release is cut. The real `releases.json` entry is used, draft and all.
- The #112 card is fed a made-up failed upgrade. Nothing actually fails.
- The driver saves `<variant>__NN_step.png` files. `tool/release_review_sheet.dart` sorts them and writes the sheet. A step missing on one device or variant shows as "missing" rather than a gap.
- Each device has a 20-minute limit, so a hang on one doesn't hold up the others or the sheet.

## Known problems

- **Android hangs on the first screenshot** (#176), the same as the Play Store screenshots. Until that's fixed, the Android half stops at the time limit with no shots, and the sheet says so.

## Changing it for the next release

Edit the walk in `release_review_test.dart` and the table above. Keep step numbers stable within a release, so two runs of the sheet can be compared side by side.
