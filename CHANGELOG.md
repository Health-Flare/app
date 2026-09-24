# Changelog

All notable changes to **Health Flare** are documented in this file.

The format is based on [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning 2.0.0](https://semver.org/spec/v2.0.0.html).

Dates use ISO-8601 (`YYYY-MM-DD`) in UTC.

<!--
How to use this file
====================

1. While working on `main`, add entries under `## [Unreleased]` in the matching
   subsection (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`).

2. Use the past tense and a user-facing voice. Avoid commit hashes and PR
   numbers in the entry text: link to PRs/issues at the bottom of the file
   or inline only when it adds context for users.

3. When cutting a release:
     - Bump `version:` in `pubspec.yaml`.
     - Rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`.
     - Add a fresh, empty `## [Unreleased]` block above it.
     - Update the comparison links at the bottom of the file.
     - Commit the change, then tag `vX.Y.Z` and push the tag: the release
       workflow takes it from there (see `.github/workflows/release.yaml`).

4. Forgot to keep Unreleased up to date, or writing notes for a range that
   spans several past releases? `scripts/release/generate_release_notes.sh`
   drafts this same Keep-a-Changelog shape (plus store-blurb prose) from
   actual PR/issue history for any `--since`/`--until` range: a starting
   point to edit, not a replacement for writing entries as you go. See
   `docs/release-kit.md` for the full release-notes/screenshots/videos
   workflow.

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
- Quick Log can record a flare start or end, a mood or cycle note on today's check-in, fluid intake, and (only after you turn it on) bowel or bladder events.
- Symptom entries can store body locations, and the symptom form has a location picker.
- Profile edit can turn cycle tracking and bowel tracking on or off. Both stay off until you choose them.
- Peak flow and step count can be saved as vitals.

### Changed
- The + button on Dashboard, Tracking, Meds, Meals, Journal, Sleep, and Reports opens the same Quick Log sheet.
- The Quick Log button says "Add to Journal" when the detected type cannot actually be saved, so the button matches what is stored.
- Daily check-in wellbeing can be left unset. A mood note never invents a score, and an existing score is not replaced by a guess.

### Deprecated
- _Nothing yet._

### Removed
- _Nothing yet._

### Fixed
- A peak-flow reading such as "420 L/min" is no longer also read as hundreds of litres of fluid.

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

[Unreleased]: https://github.com/Health-Flare/app/compare/v1.9.0...HEAD
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
