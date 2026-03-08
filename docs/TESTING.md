# Testing Guide

This document describes the test harness for Health Flare, including how to run tests, write new tests, and understand the testing architecture.

## Quick Start

```bash
# Run all tests
./scripts/test.sh

# Run specific test suites
./scripts/test.sh unit         # Unit tests only
./scripts/test.sh widget       # Widget tests only
./scripts/test.sh bdd          # BDD feature tests
./scripts/test.sh integration  # Integration tests (requires emulator)

# With coverage
./scripts/test.sh --coverage

# Watch mode (re-runs on file changes)
./scripts/test.sh unit --watch
```

## Test Structure

```
test/
├── unit/                    # Unit tests for business logic
│   └── providers/           # Riverpod provider tests
├── widget/                  # Widget tests for UI components
├── bdd/                     # BDD feature tests (Gherkin-style)
│   ├── steps/              # Step definitions
│   └── *.feature           # Feature files
├── helpers/                 # Test utilities
│   ├── test_app.dart       # Test app builder
│   ├── test_database.dart  # In-memory test database
│   └── pump_app.dart       # Widget tester extensions
└── fixtures/               # Test data fixtures
    ├── profile_fixtures.dart
    ├── journal_fixtures.dart
    └── condition_fixtures.dart

integration_test/           # End-to-end integration tests
├── app_test.dart          # Standard Flutter integration tests
└── patrol_test.dart       # Patrol tests (native interactions)
```

## Test Types

### Unit Tests (`test/unit/`)

Test business logic in isolation, including:
- Riverpod providers and notifiers
- Data transformations
- Utility functions

```dart
// Example: Testing a provider
test('add creates a new profile and makes it active', () async {
  await container.read(profileListProvider.notifier).add(
    name: 'Test User',
  );

  final profiles = container.read(profileListProvider);
  expect(profiles, hasLength(1));
  expect(profiles.first.name, equals('Test User'));
});
```

### Widget Tests (`test/widget/`)

Test UI components and their interactions:

```dart
testWidgets('CTA button enables when name is entered', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: const MaterialApp(home: OnboardingScreen()),
    ),
  );
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).first, 'Sarah');
  await tester.pump();

  final button = tester.widget<ElevatedButton>(ctaButton);
  expect(button.onPressed, isNotNull);
});
```

### BDD Tests (`test/bdd/`)

Behavior-driven tests that map to feature specifications:

```gherkin
# onboarding.feature
Scenario: Complete onboarding with a name only
  Given the app has been installed and launched for the first time
  And no profiles exist on this device
  When the app loads
  And I enter "Sarah" in the name field
  And I tap the primary action button
  Then a profile named "Sarah" is created
  And I am taken into the main app
```

### Integration Tests (`integration_test/`)

Full end-to-end tests running on a real device/emulator:

```bash
# Run on connected device
flutter test integration_test/

# Run with Patrol (for native interactions)
patrol test
```

## Writing Tests

### Using Test Fixtures

```dart
import '../fixtures/profile_fixtures.dart';

// Use pre-defined fixtures
final profile = ProfileFixtures.simple;
final profiles = ProfileFixtures.multipleProfiles;

// Seed the database
await isar.seedProfiles([ProfileFixtures.simpleIsar]);
```

### Using Test Database

```dart
import '../helpers/test_database.dart';

late Isar isar;

setUpAll(() async {
  isar = await TestDatabase.open();
});

tearDownAll(() async {
  await TestDatabase.closeAll();
});

setUp(() async {
  await TestDatabase.clear(isar); // Fresh state for each test
});
```

### Using Test App Builder

```dart
import '../helpers/test_app.dart';

// Fluent API for test app configuration
final app = TestAppBuilder()
  .withIsar(isar)
  .withProfiles([ProfileFixtures.simple])
  .withActiveProfileId(1)
  .build();

await tester.pumpWidget(app);
```

### Using Widget Tester Extensions

```dart
import '../helpers/pump_app.dart';

// Extended tester methods
await tester.tapAndSettle(find.text('Submit'));
await tester.enterTextAndSettle(nameField, 'Sarah');
await tester.scrollUntilVisible(find.text('Done'));

// Common finders
AppFinders.elevatedButton('Submit');
AppFinders.textFormField('Name');
AppFinders.chip('Arthritis');
```

## BDD Step Definitions

Step definitions are reusable functions that implement Gherkin steps:

```dart
// test/bdd/steps/onboarding_steps.dart

Future<void> whenIEnterName(WidgetTester tester, String name) async {
  final nameField = find.byType(TextFormField).first;
  await tester.enterText(nameField, name);
  await tester.pump();
}

Future<void> thenThePrimaryButtonIsEnabled(WidgetTester tester) async {
  final button = tester.widget<ElevatedButton>(ctaButton);
  expect(button.onPressed, isNotNull);
}
```

## CI/CD Integration

Tests run automatically on:
- Push to `main` or `develop`
- Pull requests

### GitHub Actions Workflows

- **test.yml**: Full test suite with coverage
- **pr-check.yml**: Quick checks for PRs with coverage comments

### Local Pre-commit

Run tests before committing:

```bash
# Quick check
./scripts/test.sh

# Full check with coverage
./scripts/test.sh --coverage
```

## Coverage

Generate and view coverage reports:

```bash
# Generate coverage
./scripts/test.sh --coverage

# View HTML report
open coverage/html/index.html
```

Coverage thresholds are tracked in CI - aim for >70% coverage on new code.

## Best Practices

1. **Test behavior, not implementation** - Focus on what the user experiences
2. **Use fixtures** - Don't repeat test data definitions
3. **Keep tests independent** - Each test should run in isolation
4. **Name tests clearly** - Describe the expected behavior
5. **Test edge cases** - Empty states, error conditions, boundaries
6. **Match BDD to specs** - Keep test/bdd/ aligned with docs/features/

## Mapping Features to Tests

| Feature File | Test Location |
|--------------|---------------|
| docs/features/onboarding.feature | test/bdd/onboarding_test.dart |
| docs/features/journal.feature | test/bdd/journal_test.dart |
| docs/features/profiles.feature | test/bdd/profile_test.dart |
| docs/features/illness.feature | test/bdd/illness_test.dart |
| docs/features/navigation.feature | test/bdd/navigation_test.dart |

## Troubleshooting

### Tests hang on database operations

Ensure you're using `TestDatabase.open()` for isolated test databases.

### Widget tests fail to find elements

- Use `pumpAndSettle()` after async operations
- Check that the widget tree is correctly set up with providers
- Use `debugDumpApp()` to inspect the widget tree

### Integration tests fail

- Ensure an emulator/simulator is running
- Clear app data between test runs
- Check for timing issues with `await tester.pumpAndSettle()`

### Coverage report not generating

Install lcov: `brew install lcov` (macOS)
