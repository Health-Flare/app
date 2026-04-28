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

[Unreleased]: https://git.ahosking.com/HealthFlare/app/compare/v1.0.0...HEAD
[1.0.0]: https://git.ahosking.com/HealthFlare/app/releases/tag/v1.0.0
