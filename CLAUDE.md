# Claude Code Project Guide — Health Flare

Health Flare is a chronic illness tracking companion app for iOS and Android. It's built with Flutter, uses Riverpod for state management, Isar Community for local storage, and follows a feature-first architecture. The app is **fully offline** — no network calls, no cloud sync, all data stays on device.

## Quick Start Commands

```bash
# Run the app
flutter run

# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Analyze code (must pass with zero issues)
flutter analyze

# Format code
dart format .

# Generate Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Generate Isar code (separate project due to analyzer conflict)
./scripts/generate_isar.sh
```

## Project Architecture

```
lib/
├── core/
│   ├── providers/      # Riverpod providers (state management)
│   ├── router/         # go_router configuration
│   └── theme/          # Colors, typography, theming
├── data/
│   ├── database/       # Isar database setup, migrations
│   └── models/         # Isar collection classes (*_isar.dart)
├── features/           # Feature-first organization
│   ├── dashboard/
│   ├── illness/
│   ├── journal/
│   ├── onboarding/
│   ├── profiles/
│   └── shell/
└── models/             # Domain models (immutable, non-Isar)

docs/features/          # BDD feature files (Gherkin scenarios)
test/                   # Unit and widget tests
integration_test/       # E2E tests
```

## Development Workflow

### Feature File → Test → Code → Validation

This project follows BDD-style development. The workflow is:

1. **Specify behavior** in `docs/features/*.feature` (Gherkin format)
2. **Write failing tests** that implement the scenarios
3. **Implement the feature** in `lib/`
4. **Validate** by running tests and ensuring they pass

### Feature Files

Feature files are the source of truth for app behavior. Always check relevant `.feature` files before implementing. Key files:

| Feature | File |
|---------|------|
| Onboarding | `docs/features/onboarding.feature` |
| Illness tracking | `docs/features/illness.feature` |
| Journal entries | `docs/features/journal.feature` |
| Profiles | `docs/features/profiles.feature` |
| Navigation | `docs/features/navigation.feature` |
| Developer experience | `docs/features/developer-experience.feature` |

## Code Patterns

### Domain Models vs Isar Collections

- Domain models in `lib/models/` are immutable and used in business logic
- Isar collections in `lib/data/models/` handle persistence
- Providers convert between the two

Example:
```dart
// Domain model (lib/models/profile.dart)
class Profile {
  final String id;
  final String name;
  // ...
}

// Isar collection (lib/data/models/profile_isar.dart)
@collection
class ProfileIsar {
  Id? isarId;
  @Index(unique: true)
  late String id;
  late String name;
  // ...
}
```

### Riverpod Providers

Use `@riverpod` annotation for code generation:

```dart
@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  Future<List<Profile>> build() async {
    // Load from Isar
  }
}
```

### Isar Code Generation

Isar generator conflicts with Riverpod generator. Use the isolated project:

```bash
# Edit schema in scripts/isar_codegen/lib/
# Then regenerate:
./scripts/generate_isar.sh

# Copy generated files to lib/data/models/
```

## Testing

### Test Structure

```
test/
├── unit/providers/     # Provider unit tests
├── widget/             # Widget tests
├── bdd/                # BDD step definitions
├── helpers/            # Test utilities (TestDatabase, TestAppBuilder)
└── fixtures/           # Test data factories
```

### Writing Tests

```dart
testWidgets('shows onboarding when no profile exists', (tester) async {
  await TestDatabase.initializeIsar();
  final isar = await TestDatabase.open();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const HealthFlareApp(),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));

  expect(find.text('Your health story,\nin your hands.'), findsOneWidget);
});
```

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/widget/onboarding_screen_test.dart
```

## Code Quality Rules

### Must Pass

1. `flutter analyze` — zero warnings/errors
2. `dart format --set-exit-if-changed .` — code is formatted
3. No network URLs in Dart files (offline-only app)
4. No `google_fonts` package (fonts are bundled locally)

### Conventions

- Use `package:health_flare/` imports, not relative imports
- Single quotes for strings
- Trailing commas for better diffs
- Cancel subscriptions and close sinks

## Common Tasks

### Adding a New Feature

1. Check/create scenarios in `docs/features/<feature>.feature`
2. Create screen in `lib/features/<feature>/screens/`
3. Create widgets in `lib/features/<feature>/widgets/`
4. Add provider in `lib/core/providers/<feature>_provider.dart`
5. Add route in `lib/core/router/app_router.dart`
6. Write tests in `test/widget/<feature>_test.dart`

### Adding a New Isar Collection

1. Create domain model in `lib/models/<name>.dart`
2. Create Isar model in `scripts/isar_codegen/lib/<name>_isar.dart`
3. Run `./scripts/generate_isar.sh`
4. Copy generated files to `lib/data/models/`
5. Register collection in `lib/data/database/app_database.dart`
6. Add migration if needed in `lib/data/database/migration_runner.dart`

### Adding a New Provider

1. Create file `lib/core/providers/<name>_provider.dart`
2. Use `@riverpod` annotation
3. Run `dart run build_runner build --delete-conflicting-outputs`
4. Commit the generated `.g.dart` file

## Key Design Decisions

### Offline-First

- No network permissions
- No analytics or telemetry
- All data stored in Isar on device
- Export/share only when user explicitly requests

### Multi-Profile Support

- App supports multiple profiles (e.g., tracking for self and family)
- One profile is "active" at a time
- Profile switcher available from dashboard

### Privacy-Centric

- No login/account required
- No cloud sync
- Clear, specific privacy statements (no vague "we value privacy")

## Troubleshooting

### Isar "Failed to load dynamic library"

Run `Isar.initializeIsarCore(download: true)` before opening the database in tests.

### Riverpod Generator Conflicts

Don't add `isar_community_generator` to main pubspec.yaml. Use the isolated `scripts/isar_codegen/` project.

### Tests Timing Out with pumpAndSettle

Use `pump(Duration(milliseconds: 500))` instead of `pumpAndSettle()` when providers are loading asynchronously.
