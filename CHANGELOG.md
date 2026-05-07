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
   numbers in the entry text — link to PRs/issues at the bottom of the file
   or inline only when it adds context for users.

3. When cutting a release:
     - Bump `version:` in `pubspec.yaml`.
     - Rename `## [Unreleased]` to `## [X.Y.Z] - YYYY-MM-DD`.
     - Add a fresh, empty `## [Unreleased]` block above it.
     - Update the comparison links at the bottom of the file.
     - Commit the change, then tag `vX.Y.Z` and push the tag — the release
       workflow takes it from there (see `.github/workflows/release.yaml`
       and `.gitea/workflows/release.yaml`).

Subsection meanings (from Keep a Changelog):
  Added       — for new features.
  Changed     — for changes in existing functionality.
  Deprecated  — for soon-to-be-removed features.
  Removed     — for now-removed features.
  Fixed       — for any bug fixes.
  Security    — for vulnerabilities.
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

## [1.2.0] - 2026-05-07

### Added
- **Weather tracking** (opt-in) — when enabled for a profile, the current conditions at log time are automatically captured on symptom, meal, activity, and daily check-in entries. Conditions are displayed read-only on entry detail screens. Fails silently if location permission is denied or unavailable; entries always save normally.
- Database schema upgraded to v14 (adds an embedded `WeatherSnapshot` to symptom, meal, activity, and daily check-in entries; existing entries read back with no weather data — no migration required).

### Fixed
- Profile avatar overlay no longer appears on top of action buttons on entry detail and form screens.
- Tracked conditions and symptoms now reload correctly when switching between profiles, preventing data from one profile showing for another.

## [1.1.0] - 2026-05-04

### Added
- Unified **Tracking** tab in bottom navigation, combining Symptoms and Illnesses into a single tabbed view.
- Condition status tracking — each illness can now be marked **Active** or **In Recovery**.
- Recovery and relapse timeline — record status change events against any condition and view the full history.
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

[Unreleased]: https://git.ahosking.com/HealthFlare/app/compare/v1.2.0...HEAD
[1.2.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.1.0...v1.2.0
[1.1.0]: https://git.ahosking.com/HealthFlare/app/compare/v1.0.0...v1.1.0
[1.0.0]: https://git.ahosking.com/HealthFlare/app/releases/tag/v1.0.0
