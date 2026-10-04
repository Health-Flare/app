# Development guide

Everything you need to build, test, and ship Health Flare. Read [CONTRIBUTING.md](../CONTRIBUTING.md) first for the ground rules. [CLAUDE.md](../CLAUDE.md) has the deeper architecture and code-pattern reference.

## Prerequisites

- Flutter SDK `^3.11.0` (Dart is bundled)
- Android Studio or Xcode for device/simulator targets
- Java 17 for Android builds

## Getting started

```bash
git clone https://github.com/Health-Flare/app.git
cd app
flutter pub get
bash scripts/setup_hooks.sh   # one-time: pre-commit hook that mirrors CI
flutter run
```

## Running on a device or simulator

```bash
flutter devices              # list available devices
flutter run -d <device-id>   # run on a specific one
xcrun simctl list devices    # list Xcode simulators
```

## Tech stack

- **UI:** Flutter
- **State:** Riverpod (code-gen)
- **Routing:** go_router
- **Storage:** isar_community v3
- **Images:** image_picker

## Code generation

Riverpod providers use code generation. After changing any `@riverpod` annotation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Isar models use a **separate** code-gen project because of an `analyzer` version conflict with `riverpod_generator`. After changing any Isar collection in `lib/data/models/`:

```bash
bash scripts/generate_isar.sh
```

Commit the resulting `.g.dart` files. See `scripts/isar_codegen/README.md` for details.

## Branches

- `main`: stable, releasable. PRs only, no direct commits.
- `feature/<name>`: new features
- `fix/<name>`: bug fixes
- `ci/<name>`: pipeline and tooling
- `chore/<name>`: dependency updates, refactors, housekeeping

All PRs target `main` and must pass CI before merge.

## Commit messages

[Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>

Types: feat, fix, chore, docs, refactor, test, perf, ci
```

```
feat(journal): add keyword search to journal list
fix(onboarding): scroll to top on first frame
chore(deps): upgrade go_router to v17
```

## CI

Every push and PR runs these gates via GitHub Actions (`.github/workflows/ci.yml`):

- `flutter-pub-get`: resolves dependencies, fails on discontinued packages
- `url-scan`: no hardcoded URLs or network packages in source
- `dart-format`: enforces `dart format` on `lib/` and `test/`
- `flutter-analyze`: static analysis with `--fatal-infos`
- `flutter-test`: the full test suite, goldens included

`CI gates` passes when all of them do, and it is the one required check for
merging into main.

Debug builds (APK, macOS, Windows) live in `.github/workflows/build.yml`. They
are not required to merge. They run:

- on every push to main
- on PRs that change `android/`, `ios/`, `macos/`, `windows/`, `linux/`,
  `pubspec.yaml`, `pubspec.lock` or the CI workflows
- by hand, on any ref:

```bash
gh workflow run build.yml -R Health-Flare/app -f ref=my-branch -f platforms=apk
# platforms: all | apk | macos | windows
gh run list -R Health-Flare/app -w "Debug builds" -L 1   # then gh run download <id>
```

Run the same checks locally before pushing:

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib/ test/
bash scripts/check_urls.sh   # offline integrity scan
bash scripts/check_deps.sh   # dependency health
```

## Offline-first rule

Health Flare makes no outbound network requests at runtime, with one opt-in exception: weather capture sends an approximate location (rounded to about 1 km) to the Open-Meteo API (see `.url-scan-ignore` for the allowed domains and why). No accounts, no sync, no analytics. The database is included in the OS's own backup (iCloud, Google); privacy copy must say so rather than claim data never leaves the device. `test/unit/privacy_claims_test.dart` fails on the old wording. Before opening a PR:

- No new `http://` or `https://` URLs in `lib/` or `test/` outside comments, unless added to `.url-scan-ignore` with a justification
- No network-dependent packages (`dio`, `firebase_*`, `google_fonts`, etc.)
- `bash scripts/check_urls.sh` passes (CI enforces this too)

## Feature specifications

Every feature is specified as a Gherkin `.feature` file in [`docs/features/`](features/). Read the relevant spec before changing behaviour, and update it in the same PR if behaviour changes.

## Release notes, screenshots, and videos

[`docs/release-kit.md`](release-kit.md) has the full workflow. In short:

- **Release notes:** add an entry under `## [Unreleased]` in `CHANGELOG.md` with any user-facing PR. To backfill a range: `scripts/release/generate_release_notes.sh --since <tag|date>`.
- **Screenshots:** `scripts/take_screenshots.sh` (iOS) and `scripts/take_screenshots_android.sh` (Android).
- **Videos:** `scripts/take_video.sh` (iOS) and `scripts/take_video_android.sh` (Android).
- **All three:** `scripts/release/build_release_kit.sh --since <tag>` assembles everything into `release-kit/<version>/`.
