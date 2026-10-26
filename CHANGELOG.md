# Changelog

All notable changes to **Health Flare** are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

Dates use ISO-8601 (`YYYY-MM-DD`) in UTC.

<!--
How to use this file
====================

1. Don't edit Unreleased in a PR. Add a file under `changes/` instead (see
   `changes/README.md`): one file per PR can't conflict with other PRs,
   one shared list did on every merge.

2. Use the past tense and a user-facing voice. Avoid commit hashes and PR
   numbers in the entry text.

3. When cutting a release (full steps: docs/feature-releases.md):
     - `dart run tool/rollup_changes.dart --write --version X.Y.Z` moves
       every fragment into Unreleased below, deletes the fragment files,
       and drafts the What's new entry for X.Y.Z. Read the result.
     - Write the What's new highlights for X.Y.Z in
       `assets/whats_new/releases.json`, delete its "draft" line, commit.
     - `bash scripts/release.sh X.Y.Z` bumps `pubspec.yaml`, promotes
       Unreleased, dates What's new, commits, tags and pushes. It refuses
       if What's new isn't ready.

4. Writing notes for a range that spans several past releases?
   `scripts/release/generate_release_notes.sh` drafts the same shape from
   PR history. See `docs/release-kit.md`.

Subsection meanings (from Keep a Changelog):
  Added: for new features.
  Changed: for changes in existing functionality.
  Deprecated: for soon-to-be-removed features.
  Removed: for now-removed features.
  Fixed: for any bug fixes.
  Security: for vulnerabilities.
-->

## [Unreleased]

### Added
- _Nothing yet._

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- _Nothing yet._

### Security
- _Nothing yet._

## [1.11.0] - 2026-10-26

### Added
- Entry forms say when an entry is part of a flare, for example "Part of
  the Fibromyalgia flare". Remove takes it out; Add back puts it back.

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- "Add missing data" now says what a backup would add for each profile
  before adding anything, with Add and Cancel. A backup with nothing new
  says so and changes nothing.
- "Replace everything" now lists what's in the backup and the profiles it
  will replace before it's set up, with Replace and Cancel.
- Meal photos and profile pictures are kept in the app's own folder, so the
  phone can't clear them and they no longer go missing after an update.
  Photos saved earlier are moved there; ones the phone had already cleared
  are removed instead of showing as broken. New photos are saved at most
  1600 pixels across.
- Removing a photo, or deleting its meal or profile, now deletes the photo
  file too. Before, it stayed on the phone. The app says so first: removing
  a saved photo asks before it goes, and deleting a meal with a photo or a
  profile says its photos are deleted with it and are lost if they aren't
  saved anywhere else.
- A backup file can no longer make the app show another file on the phone
  as a profile picture or meal photo.
- Entries logged during a flare are now part of it. Each flare lists the
  symptoms, vitals, meals, doses and activity from its dates, including
  ones logged before this update and ones logged later for a past day.
  Changing a flare's dates updates the list.

### Security
- _Nothing yet._

## [1.10.0] - 2026-10-14

### Added
- Settings > About shows the installed app version, e.g. "1.9.1 (build 13)".
- Pressure and humidity now show alongside the weather on single-entry views: meal and journal details, and the symptom, meal, activity and check-in forms when editing a saved entry.
- Insights has a Vitals card. It charts every vital type with readings in the selected window, plots each reading at its logged time, draws blood pressure as systolic and diastolic lines, and shades flare periods behind the chart.
- Each profile has a temperature unit setting (°C, °F, or As logged). It changes how temperatures are shown; readings are stored as entered, and edit forms and exports show them as logged.
- Medication doses and appointments can be moved to another profile. If the other profile doesn't have the medication yet, it is added for them as part of the move.
- Before an app update changes how your data is stored, Health Flare saves a safety copy of your data on the phone first. The newest three copies are kept, and they are left out of your phone's iCloud or Google backup so they don't crowd it. If the copy can't be saved, the update waits and your data is left as it is.
- If updating your data fails, Health Flare tries again the next two times
  it opens, then stops and opens normally on your data as it is. A card on
  the dashboard says so, and Settings > Data & backup has "Copy details"
  to send us, "Export a backup", and a way to restore the copy saved
  before the update (a backup of your current data is saved first). The
  next version of the app tries the update again.
- Settings > Your layout > Features in use turns off what a profile
  doesn't track: its tab and dashboard card go, and nothing logged is
  deleted. Quick Log still saves it, and says so.
- Settings > Your layout > Bottom bar chooses the bar: pin any screen,
  three to five items, with More for the rest. "Like before" puts it
  close to the old six-item bar.
- Backups keep the bottom bar and each profile's features in use.
- A profile with no appointments sees "Got an appointment coming up? Tap to
  add it." on the dashboard. Tapping it opens a new appointment.
- After an appointment, the dashboard asks "How did it go?" for up to a
  week. Tapping it opens the appointment at its outcome notes, so what the
  doctor said can be written down while it's fresh. Saving an outcome, or
  marking the appointment completed, missed or cancelled, clears it.
- Settings > What's new lists every version of Health Flare, newest first, with the highlights up top and the full list under "All changes".
- After an update with something worth knowing, a short card waits at the top of the dashboard. It never covers a screen or a log form, has no badge or count, holds off during an active flare, and goes away for good when dismissed, opened, or ignored for five app opens.
- "Show update highlights" in Settings turns the card off. What's new stays in Settings either way.

### Changed
- Moving any entry to another profile now asks first, and names anything that won't carry over, such as a flare link.
- Unsaved edits are saved before an entry is moved. An edit that fails validation stops the move.
- Privacy copy says plainly where data goes: your records are in your phone's own iCloud or Google backup, and weather capture sends an approximate location to Open-Meteo. This replaces "Everything stays on this device" and "never shared" wording, which wasn't accurate.
- Weather capture rounds your location to about 1 km before sending it.
- The bottom bar is now Dashboard, Track, Care and Journal. Track holds
  Symptoms, Vitals, Meals, Sleep and Activity; Care holds Medications,
  Appointments, Conditions and Flares; Journal holds Entries and
  Check-ins. Each opens on the tab you last used there. Nothing was
  removed: Meds, Meals and Sleep are tabs now.
- After updating, a card on the dashboard explains what moved and walks
  through it ("Show me"). It can keep the bar like before, and can be
  replayed from Settings > What's new.
- The dashboard's Upcoming card is now an Appointments card. It always has
  an "All appointments" link once a profile has an appointment, where before
  the list could only be opened with three or more coming up. It shows up to
  three appointments instead of two.
- With only past appointments, the card says "No appointments coming up."
  and offers "Add appointment".

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- Adding a profile from the profile switcher no longer leaves the New profile sheet stuck on a spinning button. The profile was saved, but the sheet closed the welcome steps for the new profile instead of itself.
- A new profile no longer picks up entries from a profile you deleted before. After a deleted profile and an app restart, the next new profile could be given the deleted one's place and show symptoms or other entries you never logged for it. Entries a profile already picked up this way stay with it; the app can't tell them apart from your own.
- Vitals, including temperature, now appear on Insights. A profile with only vitals in the window no longer shows "Not enough data yet".
- Moving an entry from an edit screen no longer discards changes you hadn't saved yet.
- If updating your data fails, the app still opens and tells you, and the safety copy from before the update stays on the phone. It tries again next time. Before, a failed update stopped the app from opening at all.
- When an update to your data failed partway and was tried again, the
  copy saved before the update could be replaced by a copy of the
  half-updated data. The copy from before the update is now kept.
- A new profile can no longer be given the number of a deleted profile
  whose entries are still stored, even if an update didn't finish.
- CSV exports now say whether each dose was taken, skipped or missed, with
  the reason and how well it worked when you recorded them, e.g. "500 mg ·
  Missed · Forgot". Before, every dose looked taken, so a missed dose was
  counted as taken by anyone reading the file. Amounts no longer show a
  stray ".0" ("500 mg", not "500.0 mg").
- Appointments whose time had passed were still listed as upcoming. They
  now show as "Outcome not recorded" in the appointments list, on the
  appointment screen, and in PDF and CSV reports, until an outcome is saved
  or the appointment is marked completed, missed or cancelled. Nothing is
  changed in the stored appointment.
- An empty Appointments list now has an "Add appointment" button, and an
  empty Check-in history says "Tap + to add today's check-in". Before,
  both only said nothing was recorded.
- Adding a backup with "Add missing data" now keeps a condition's
  recovery status and its history. Before, a condition in recovery came
  back as active with no history.
- Changing a profile setting, such as the temperature unit, shows
  straight away on open screens instead of after leaving and coming back.
- Chip labels are readable again: the body areas on the symptom form,
  the "in 2 days" label on upcoming appointments and the entry type in
  Quick Log were showing in near-white.
- With very large text, "Skip" at the top of the setup steps no longer
  breaks into one letter per line.
- On the Conditions screen, "Add as a custom illness" is now offered
  for anything you type that isn't exactly a condition already in the list.
  Before, it disappeared as soon as any condition name contained your text,
  so "Colitis" (only "Ulcerative colitis" and others in the list) could not
  be saved at all. The matching conditions are still listed below it.

### Security
- Deleting a profile now removes all of its health data. Before, only its journal entries were removed; symptoms, vitals, medications, doses, meals, sleep, activity, fluids, bowel entries, flares, check-ins, appointments, tracked conditions and tracked symptoms stayed in the database and in backups. A one-time cleanup on upgrade removes data left behind by profiles deleted on 1.9.1 and earlier.
- The Android APK on GitHub Releases is now checked against Health Flare's signing key before it's published, and a release can no longer be built with Android's public debug key by mistake. The README lists the key's fingerprint so you can check a downloaded APK yourself. Every APK published so far was signed with the right key.
- Notes and other text in a CSV export can no longer run as spreadsheet formulas. Text starting with =, +, -, @ now opens in Excel, Sheets or LibreOffice exactly as you typed it, instead of being run, so whoever opens your export is safe from formulas hidden in the data.
- Backups, reports and decrypted backup copies are no longer left in the phone's or computer's temporary folder. On phones, a shared file is deleted as soon as the share sheet closes. Anything left behind, for example if the app was closed during an import, is deleted the next time Health Flare opens.
- Import and restore refuse a file over 256 MB with "This file is too big to be a Health Flare backup." before reading any of it. A very large file could crash the app before. Real backups are far smaller.
- You can now lock Health Flare with your face, fingerprint or phone
  passcode (Settings > Privacy, or when you set up the app). It locks when
  the app opens and again after it has been in the background for a time
  you choose (immediately, 1, 5 or 15 minutes). The lock is a screen in
  front of the app; it doesn't encrypt the records stored on your phone.
  iPhone and Android only.
- New "Hide in app switcher" setting (Settings > Privacy) shows a plain
  screen in the app switcher instead of your last health screen. On Android
  it also blocks screenshots and screen recording of Health Flare.

## [1.9.1] - 2026-09-24

### Added
- Quick Log reads what you type far more accurately. It weighs the whole entry instead of grabbing the first keyword, so a named medication dose is no longer mistaken for a condition mention, and it only offers a quick save when the values can actually be stored.
- Quick Log can record a flare start or end, a mood or cycle note on today's check-in, fluid intake, and (only after you turn it on) bowel or bladder events.
- Symptom entries can store body locations, and the symptom form has a location picker.
- Profile edit can turn cycle tracking and bowel tracking on or off. Both stay off until you choose them.
- Peak flow and step count can be saved as vitals.

### Changed
- Short notes stay short. A one-word entry such as "Tired" is kept as a plain note instead of being guessed into a record, and opening Quick Log with an empty field no longer touches your data.
- The Dashboard + button opens Quick Log. Tracking, Meds, Meals, and Journal keep an add button for that screen, so a symptom log is saved as a symptom and not a journal note. The Sleep tab + button opens Quick Log.
- The Quick Log button says "Add to Journal" when the detected type cannot actually be saved, so the button matches what is stored.
- Daily check-in wellbeing can be left unset. A mood note never invents a score, and an existing score is not replaced by a guess.

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- A peak-flow reading such as "420 L/min" is no longer also read as hundreds of litres of fluid.
- A file that isn't a database is rejected before restore or import tries to open it.

### Security
- _Nothing yet._

## [1.9.0] - 2026-09-24

### Added
- Backups can now be locked with a password. Turn on "Encrypt with a password" when exporting to get an encrypted `.hfbackup` file that only opens with that password. Importing asks for the password automatically, in all three restore modes. Plain backups work exactly as before.
- The export screen now says plainly who can read an exported file and what Health Flare does (and doesn't) do with it.

### Changed
- The Settings button now appears in the top bar on every screen, just left of the profile icon, instead of only on the Dashboard.
- Renamed "Illness(es)" to "Condition(s)" throughout the app (Tracking tab, illness screen, onboarding, first-log prompt) to match the terminology used everywhere else. Shortened the "Medications" nav label to "Meds" so it no longer wraps on narrow screens.

### Deprecated
- _Nothing yet._

### Removed
- The "Data & backup" shortcuts in the profile switcher. Export and import now live only in Settings, which offers password-locked backups and all three restore modes.

### Fixed
- Restoring from a backup file now checks that the file is actually a Health Flare backup before touching anything. Picking the wrong file (a PDF, a CSV, a corrupted download) used to be silently accepted: "Replace everything" would wipe all data on the next launch with no warning, and merge/selective import would just report "0 new records." All three restore modes now show a clear error instead.
- Quick Log's smart detection is more reliable: respiratory rate readings no longer fail to save, mentioning a condition (new or already-tracked) is detected correctly, and symptom matching now considers the wording actually entered instead of only a static list.
- Quick Log now resolves a symptom to its existing tracked/catalogue name (so "brain fog again" matches "Brain fog") instead of creating a new entry for every variation, matching how conditions and medications already work. Severity ("8/10", "mild", "excruciating") and a condition's diagnosis date are now inferred more carefully instead of guessing on every mention.
- Quick Log sleep entries with a time range ("8pm to 4am", "20:00 to 4:00") now create a Sleep entry instead of a Journal entry.

### Security
- _Nothing yet._

## [1.8.0] - 2026-09-18

### Added
- Release kit: `scripts/release/generate_release_notes.sh` drafts release
  notes and store "what's new" blurbs from actual PR/issue history for any
  date/tag range, `scripts/take_video.sh` and `scripts/take_video_android.sh`
  capture an App Store/Play Store preview video from a new guided-tour
  integration test, and `scripts/release/build_release_kit.sh` runs all
  three (plus the existing screenshot sweep) together. See
  `docs/release-kit.md`.
- Sleep tracking is now reachable from the app: a nav bar destination and
  quick-create FAB for logging a sleep entry, and a way to delete one.
  Tapping a sleep entry on the dashboard now opens it for editing instead
  of a blank create form.
- A manual Nap toggle on the sleep entry form, so a nap can be tagged or
  untagged directly instead of relying only on the same-day auto-detect
  heuristic.

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- Quick Log no longer drops the pulse reading from a combined entry like
  "BP 118/76, pulse 68bpm": both vitals are now saved. Pulse/heart-rate
  phrasing without an explicit "bpm" unit ("Pulse 72", "HR 72", "72 beats
  per minute") is now recognised too, and unrelated text with a slash
  (like "Ate 3/4 of a sandwich") no longer mistakenly suggests a blood
  pressure entry.
- Editing a sleep entry's bedtime or wake time past the other now shifts
  the whole sleep window by the same offset, instead of leaving the entry
  in an invalid state.

### Security
- _Nothing yet._

## [1.7.1] - 2026-09-15

### Added
- Android screenshot capture script (`scripts/take_screenshots_android.sh`), mirroring the existing iOS App Store sweep for Play Store listings. Covers the phone device class; the tablet AVD is left to adhoc/manual capture pending a fix for its boot flakiness.
- Onboarding screenshot coverage now walks the full 4-step guided flow (Welcome, What you can track, Your privacy, Create profile) instead of stopping at the first step.

### Changed
- App Store and Play Store screenshot sets regenerated to reflect the guided onboarding redesign and the chip-contrast fix shipped in 1.7.0.

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- _Nothing yet._

### Security
- _Nothing yet._

## [1.7.0] - 2026-09-13

### Added
- **Guided onboarding redesign**: replaces the single long-scroll onboarding
  screen with a 4-step flow (Welcome, What you can track, Your privacy,
  Create profile) sharing one minimal progress-dot header. The first three
  steps can be skipped straight to the mandatory Create profile step. The
  weather opt-in and first-log prompts are now full-screen steps in the same
  style, instead of one-off modal bottom sheets.

### Changed
- Quick log now recognises short vital readings (e.g. "74kg", "144cm",
  "4'8"") as a Vital entry without needing extra words of context.

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- Quick log now detects height (in cm, or feet and inches) as a vital
  measurement: previously it wasn't recognised at all.
- Onboarding: fixed overflow and off-screen tap targets on the redesigned
  first-log and feature-highlight steps, and fixed low-contrast chip labels
  on the "what you can track" step.

### Security
- _Nothing yet._

## [1.6.0] - 2026-09-12

### Added
- Height as a loggable vital type, alongside the existing measurements.

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- _Nothing yet._

### Security
- _Nothing yet._

## [1.5.2] - 2026-09-08

### Added
- _Nothing yet._

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- **iOS App Store Connect warnings:** raised the minimum iOS version to 15.0 (Apple requires 15.0+ for new uploads starting Spring 2027) and added the `NSLocationAlwaysAndWhenInUseUsageDescription` purpose string alongside the existing when-in-use string, since the `geolocator` plugin's compiled binary references the always-authorization API even though the app only ever requests when-in-use access.

### Security
- _Nothing yet._

## [1.5.1] - 2026-09-08

### Added
- _Nothing yet._

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- **Dark mode: onboarding readability:** the privacy and profile-creation zones and the weather opt-in sheet used hardcoded light background colours (`AppColors.surfaceVariant`, `AppColors.surface`, `AppColors.paleSky`) while their text used theme-adaptive colours, so in dark mode the text rendered in a near-white shade against a background that stayed light: in the privacy zone this was the *same* colour as the background, making it fully invisible. Onboarding now uses `ColorScheme` tokens throughout so backgrounds track the active theme.

### Security
- _Nothing yet._

## [1.5.0] - 2026-08-21

### Added
- _Nothing yet._

### Changed
- _Nothing yet._

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- _Nothing yet._

### Security
- _Nothing yet._

## [1.3.0] - 2026-05-26

### Added
- **Profile icon button**: persistent `ProfileIconButton` in every app bar replaces the floating overlay. Tap opens the profile switcher; swipe up cycles to the previous profile (wrapping from first to last), swipe down cycles to the next (wrapping from last to first). No-op when only one profile exists.
- `HFAppBar`: shared `PreferredSizeWidget` app bar component that always appends `ProfileIconButton` as the rightmost action. All screens now use this single component, so the profile icon behaviour is defined once and applied everywhere.
- `docs/features/profile-icon.feature`: full Gherkin spec for profile icon placement, tap, swipe gesture, and single-profile guard behaviour.
- Code-reuse scenarios added to `docs/features/developer-experience.feature` (shared widget extraction, single-source-of-truth for behaviour, no duplicated constants, theme tokens, `AppRoutes`, layout workarounds in the shared component only).

### Changed
- `AppShell` simplified from `ConsumerWidget` to `StatelessWidget`: the profile avatar overlay and `_isRootRoute` heuristic are removed. The profile icon is now layout-participating (inside each screen's app bar) rather than floating above all content.
- All 32 screens migrated from bare `AppBar` to `HFAppBar`.
- Removed `SizedBox(width: 56)` spacer hacks from dashboard, journal list, journal detail, and journal composer screens.

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- Profile avatar no longer obscures app bar action buttons (edit, delete, etc.) on detail and form screens. Closes #83.
- **macOS: weather capture:** outbound network requests and location access were silently blocked by the app sandbox. Added the required entitlements (`network.client`, `personal-information.location`) and `NSLocationWhenInUseUsageDescription` so weather snapshots are captured correctly.
- **macOS: profile picture:** tapping the avatar crashed or did nothing because `image_picker` has no macOS implementation. The profile sheet and onboarding zone now use the system file picker on macOS instead.

### Security
- _Nothing yet._

## [1.2.0] - 2026-05-07

### Added
- **Weather tracking** (opt-in), when enabled for a profile, the current conditions at log time are automatically captured on symptom, meal, activity, and daily check-in entries. Conditions are displayed read-only on entry detail screens. Fails silently if location permission is denied or unavailable; entries always save normally.
- Database schema upgraded to v14 (adds an embedded `WeatherSnapshot` to symptom, meal, activity, and daily check-in entries; existing entries read back with no weather data: no migration required).

### Fixed
- Profile avatar overlay no longer appears on top of action buttons on entry detail and form screens.
- Tracked conditions and symptoms now reload correctly when switching between profiles, preventing data from one profile showing for another.

## [1.1.0] - 2026-05-04

### Added
- Unified **Tracking** tab in bottom navigation, combining Symptoms and Illnesses into a single tabbed view.
- Condition status tracking: each illness can now be marked **Active** or **In Recovery**.
- Recovery and relapse timeline: record status change events against any condition and view the full history.
- Diagnosis date field on tracked conditions, shown alongside the tracking start date.
- New **Condition Detail** screen with status, dates, history, and quick actions.
- New `Chronic Fatigue Syndrome` and `Brain fog` entries in the demo dataset.
- App screenshots archived under `screenshots/v1/` (historical) and `screenshots/v2/` (current).

### Changed
- Bottom navigation replaces separate Illnesses and Symptoms tabs with a single Tracking tab.
- Illnesses list now groups conditions by Active and In Recovery status.
- Database schema upgraded to v13 (adds `status` and `statusHistory` to conditions).
- Screenshot test updated with 11 captures covering the new tracking flow.
- Gherkin specs updated for illness and navigation features.

### Fixed
- Migration tests updated to expect schema v13.

## [1.0.0] - 2026-04-28

### Added
- Initial public release of Health Flare.
- On-device tracking for symptoms, vitals, medications, meals, and journal entries.
- Multi-profile support with fully isolated per-profile data.
- PDF and CSV export for sharing data with clinicians.
- Local backup and restore via the platform share/file-picker sheet.
- Android and iOS support.

### Security
- Offline-first guarantee: zero outbound network requests at runtime, enforced
  by the `url-scan` CI check.

[Unreleased]: https://github.com/Health-Flare/app/compare/v1.11.0...HEAD
[1.11.0]: https://github.com/Health-Flare/app/compare/v1.10.0...v1.11.0
[1.10.0]: https://github.com/Health-Flare/app/compare/v1.9.1...v1.10.0
[1.9.1]: https://github.com/Health-Flare/app/compare/v1.9.0...v1.9.1
[1.9.0]: https://github.com/Health-Flare/app/compare/v1.8.0...v1.9.0
[1.8.0]: https://github.com/Health-Flare/app/compare/v1.7.1...v1.8.0
[1.7.1]: https://github.com/Health-Flare/app/compare/v1.7.0...v1.7.1
[1.7.0]: https://github.com/Health-Flare/app/compare/v1.6.0...v1.7.0
[1.6.0]: https://github.com/Health-Flare/app/compare/v1.5.2...v1.6.0
[1.5.2]: https://git.ahosking.com/HealthFlare/app/compare/v1.5.1...v1.5.2
[1.5.1]: https://git.ahosking.com/HealthFlare/app/compare/v1.5.0...v1.5.1
[1.5.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.3.0...v1.5.0
[1.3.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.2.0...v1.3.0
[1.2.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.1.0...v1.2.0
[1.1.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.0.0...v1.1.0
[1.0.0]: https://git.ahosking.com/HealthFlare/app/releases/tag/v1.0.0
