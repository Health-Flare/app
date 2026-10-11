# Testing Track and Care

How to check the Track and Care layout (Dashboard, Track, Care, Journal,
each with tabs) by hand, by test and by screenshot. It's behind the
`TRACK_AND_CARE` build flag until the release guide ships (#145). One
script does all of it:

```bash
bash scripts/track_and_care.sh       # help
```

Spec: `docs/features/navigation.feature`. Plan: #135.

## The 30-second version

| I want to… | Run | Needs |
|---|---|---|
| Know nothing is broken | `bash scripts/track_and_care.sh test` | Nothing. ~20 s |
| Use the app with Track and Care on | `bash scripts/track_and_care.sh run` | Xcode + an iPhone simulator |
| See every section and tab, as screenshots | `bash scripts/track_and_care.sh shots` | Same. ~5 min |
| Prove it works on a device, no screenshots | `bash scripts/track_and_care.sh e2e` | Same |

Pick a simulator or device with `-d`, before the command:

```bash
bash scripts/track_and_care.sh -d "iPhone 17 Pro Max" shots
bash scripts/track_and_care.sh -d emulator-5554 run     # Android
```

`run` is `flutter run --dart-define=TRACK_AND_CARE=true`. Without the
define, the app is exactly as before: the six-item bar.

## What to check by hand

1. **Four sections.** The bar reads Dashboard, Track, Care, Journal.
2. **First tab.** Track opens on Symptoms, Care on Medications, Journal on
   Entries.
3. **Remembered tab.** Open Care > Appointments, go to Dashboard, tap
   Care: Appointments is still selected. Close the app fully and reopen:
   Care opens on Medications again.
4. **Add button.** On every tab, + opens that tab's own form, never Quick
   Log. Journal > Check-ins opens today's check-in, to edit if it's done.
5. **Reports.** The Reports button is in the top bar of every section.
6. **Scroll.** Scroll down a long list, switch tab and back: same place.
7. **Old links.** Anything that used to open Meds, Meals, Sleep and so on
   (dashboard cards, "See all", notifications) opens that tab inside its
   section, with the section selected.
8. **Large text.** Settings > Accessibility > Larger Text at the maximum:
   the tab row scrolls sideways; no label is cut off.

### Features in use (#142)

9. **Settings > Your layout > Features in use.** Nine switches, all on;
   Symptoms and Conditions read "Always on". The text names the profile.
10. **Turn Meals off.** A message says the meals are kept (or "Meals is
    off for Sarah" with none logged). Track has no Meals tab.
11. **Journal and Check-ins off.** Journal leaves the bar. Turn one back
    on: it returns, with no tab row if it has one tab.
12. **Quick Log with Meals off.** Type "Toast and eggs for breakfast": the
    Meal chip, a warning, "Turn Meals on", and "Save as a journal note
    too". Save: the meal is in recent activity, not in Track.
13. **Opened directly.** With Meals off, open a meal from recent activity
    and go Back, or follow an old `/meals` link: the list shows, with
    "Meals is turned off for Sarah" and "Turn on" at the top.
14. **Dashboard.** Flares, Check-ins or Appointments off: their card or
    prompt goes; their entries stay in recent activity.
15. **Another profile.** Switch to someone with different switches: the
    tabs and bar follow the active profile.

## The automated tests

| File | Covers |
|---|---|
| `test/unit/navigation/section_routes_test.dart` | Which tab and section every address belongs to, old links, 2-tap reach |
| `test/unit/navigation/tab_content_test.dart` | What each tab's add button opens, including today's check-in |
| `test/widget/track_and_care_test.dart` | The bar, tabs, remembered tab, scroll, Reports, add button, large text, flag off |
| `test/widget/track_and_care_bodies_test.dart` | Every real tab with no data shows how to add the first entry |
| `test/unit/navigation/features_in_use_providers_test.dart` | What's on for the active profile, visible tabs and sections, every message's wording |
| `test/widget/features_in_use_screen_test.dart` | The Features in use screen, the "kept" message, screen reader labels, the Settings entry |
| `test/widget/features_in_use_sections_test.dart` | Tabs and bar with features off, per profile, one tab left, opened directly |
| `test/widget/quick_log_features_off_test.dart` | Quick Log's warning, Turn on, and the journal note too |
| `test/unit/database/features_off_keeps_data_test.dart` | Turning everything off deletes nothing and reports still include it; onboarding never asks |
| `integration_test/track_and_care_test.dart` | The real app on a real database: every section and tab, then Features in use, screenshotted |

Screenshots land in `screenshots/track_and_care/`, with a contact sheet at
`index.html`. They're committed, so a PR shows what changed.

## How it works, briefly

- Every tab has its own address: the list screen's old one
  (`/medications`, `/sleep`, `/tracking?tab=vitals`). With the flag on,
  those routes show `SectionScreen` on the right tab; that's why old links
  keep working. Rules: `lib/core/navigation/section_routes.dart`.
- Tab contents (list, add button, extra top-bar actions) come from
  `tabContentProvider` in `lib/features/sections/tab_content.dart`. The
  list widgets are the same ones the standalone screens use.
- The remembered tab and scroll positions are held in memory only
  (`section_state.dart`), so they reset when the app closes.
