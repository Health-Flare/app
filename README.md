# Health Flare


[<img src="assets/images/HealthFlare Banner Light.png">](assets/images/HealthFlare Banner Light.png)

**A calm, private health companion for people living with chronic illness.**

Health Flare makes it easy to record and review your own health data — or the health data of someone you care for. Log symptoms, vitals, medications, meals, and journal entries in one place, then walk into your next appointment with a clear, organised picture of how you've really been feeling.

Health Flare is not a medical device. It does not diagnose, prescribe, or give clinical recommendations. It is a personal health journal with structure.

---

## What it tracks

| Area | What you can log |
|---|---|
| **Symptoms** | Name, severity (1–10), date/time, notes |
| **Vitals** | Blood pressure, heart rate, blood glucose, temperature, weight, SpO₂, respiratory rate |
| **Medications** | Name, dose, schedule, dose history, missed/skipped doses |
| **Meals** | Description, optional photo, reactions/trigger flags |
| **Journal** | Freeform entries with optional mood and energy level |

Reports can be exported as PDF or CSV to share with a doctor or specialist.

---

## Privacy — your data stays on your device

- **No account or login required.** Ever.
- **No cloud sync, no remote storage.** All data is written to the local device only.
- **Data only leaves your device when you explicitly export or share it.**
- **No analytics, no telemetry, no third-party SDKs that make network calls.**
- All fonts are bundled as local assets — the app makes zero outbound network requests at runtime.

---

## Multi-profile support

One install can track multiple people. Create a profile for yourself, a child, a parent, or a partner. Switch between profiles at any time. Each profile's data is fully isolated.

---

## Platforms

| Platform | Status |
|---|---|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| macOS | 🚧 Planned |
| Windows | 🚧 Planned |
| Web | 🚧 Planned |

---

## Tech stack

| Layer | Technology |
|---|---|
| UI framework | Flutter |
| State management | Riverpod v2 (code-gen) |
| Routing | go_router |
| Local database | isar_community v3 |
| Image picking | image_picker |

---

---

## Contributing

### Prerequisites

- Flutter SDK `^3.11.0`
- Dart SDK (bundled with Flutter)
- Android Studio or Xcode for device/simulator targets
- Java 17 for Android builds

### Getting started

```bash
git clone https://git.ahosking.com/HealthFlare/app.git
cd app
flutter pub get
flutter run
```

### Branch strategy

| Branch pattern | Purpose |
|---|---|
| `main` | Stable, releasable code. PRs only — no direct commits. |
| `feature/<name>` | New features |
| `fix/<name>` | Bug fixes |
| `ci/<name>` | Pipeline and tooling changes |
| `chore/<name>` | Dependency updates, refactors, housekeeping |

All PRs target `main`. Every PR must pass CI before it can be merged.

### CI pipeline

Pushes and PRs run the following checks automatically via Gitea Actions:

| Check | What it does |
|---|---|
| `flutter-pub-get` | Resolves dependencies; fails on discontinued packages |
| `flutter-pub-audit` | Scans for known security advisories |
| `url-scan` | Ensures no hardcoded URLs or network packages appear in source |
| `dart-format` | Enforces `dart format` on `lib/` and `test/` |
| `flutter-analyze` | Static analysis with `--fatal-infos` |
| `flutter-build-apk` | Builds a debug APK and archives it as an artifact |

Run checks locally before pushing:

```bash
# Static analysis
flutter analyze

# Formatting (exits non-zero if anything needs reformatting)
dart format --output=none --set-exit-if-changed lib/ test/

# Offline integrity scan (no hardcoded URLs, no network packages)
bash scripts/check_urls.sh

# Dependency health
bash scripts/check_deps.sh
```

### Code generation

Riverpod providers use code generation. After modifying any `@riverpod` annotation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Isar database models use a **separate** isolated code-gen project due to an
`analyzer` version conflict with `riverpod_generator`. After modifying any
Isar collection in `lib/data/models/`:

```bash
bash scripts/generate_isar.sh
```

Commit the resulting `.g.dart` files. See `scripts/isar_codegen/README.md` for details.

### Commit messages

This project follows [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>

Types: feat, fix, chore, docs, refactor, test, perf, ci
```

Examples:
```
feat(journal): add keyword search to journal list
fix(onboarding): scroll to top on first frame
chore(deps): upgrade go_router to v17
ci: add weekly dependency audit job
```

### Offline-first rule

Health Flare makes **zero** outbound network requests at runtime. Before opening a PR, ensure:

- No `http://` or `https://` URLs appear in `lib/` or `test/` outside of comments
- No network-dependent packages (`http`, `dio`, `firebase_*`, `google_fonts`, etc.) are imported
- Run `bash scripts/check_urls.sh` to verify — this is also enforced by CI

### Feature specifications

All features are specced as Gherkin `.feature` files in `docs/features/`. Read the relevant spec before implementing or changing behaviour, and update it if the behaviour changes.
