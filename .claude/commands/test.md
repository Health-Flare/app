# Test Writer

You are writing tests for Health Flare, a chronic illness tracking Flutter app. Your job is to implement tests that verify feature file scenarios.

## Input

The user will provide:
- A reference to scenarios in a feature file, OR
- A specific behavior to test, OR
- A screen/widget/provider to test

## Process

### 1. Understand What to Test

If given a feature reference, read the relevant `docs/features/*.feature` file first.

### 2. Choose Test Type

| Scenario Type | Test Location |
|--------------|---------------|
| UI interactions | `test/widget/<feature>_test.dart` |
| Provider logic | `test/unit/providers/<name>_test.dart` |
| Full user flows | `test/bdd/<feature>_test.dart` |

### 3. Write Tests

**Widget Test Template:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_flare/main.dart';
import 'package:health_flare/core/providers/database_provider.dart';

import '../helpers/test_database.dart';

void main() {
  setUpAll(() async {
    await TestDatabase.initializeIsar();
  });

  tearDown(() async {
    await TestDatabase.clear();
  });

  group('<Feature Name>', () {
    testWidgets('<scenario description>', (tester) async {
      final isar = await TestDatabase.open();
      // Seed data if needed
      // await TestDatabase.seedProfiles(isar, [ProfileFixtures.sarah]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [isarProvider.overrideWithValue(isar)],
          child: const HealthFlareApp(),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      // Test assertions
      expect(find.text('Expected text'), findsOneWidget);
    });
  });
}
```

**Provider Test Template:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_flare/core/providers/<name>_provider.dart';

import '../../helpers/test_database.dart';
import '../../fixtures/<name>_fixtures.dart';

void main() {
  setUpAll(() async {
    await TestDatabase.initializeIsar();
  });

  tearDown(() async {
    await TestDatabase.clear();
  });

  group('<Provider>Notifier', () {
    test('<behavior description>', () async {
      final isar = await TestDatabase.open();
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);

      // Test the provider
      final notifier = container.read(<provider>.notifier);
      // ...assertions
    });
  });
}
```

### 4. Use Existing Fixtures

Import from `test/fixtures/`:
- `ProfileFixtures` - Test profiles (sarah, dad)
- `JournalFixtures` - Journal entries
- `ConditionFixtures` - Conditions and symptoms

### 5. Run and Verify

```bash
flutter test <path_to_test_file>
```

## Output

The test file with:
- Clear group organization
- Descriptive test names matching scenarios
- Proper setup/teardown
- Working assertions

## User Input

$ARGUMENTS
