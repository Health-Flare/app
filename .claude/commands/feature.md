# Feature Workflow

You are implementing a feature for Health Flare, a chronic illness tracking Flutter app. Follow this workflow strictly:

## Input

The user will describe a feature they want to implement. The feature may be:
- A new capability described in plain language
- A reference to existing scenarios in `docs/features/*.feature`
- A bug fix or enhancement to existing functionality

## Workflow

### Phase 1: Feature Specification

1. **Find or create the feature file**: Check `docs/features/` for an existing `.feature` file that matches this capability
2. **Read existing scenarios**: If a feature file exists, read it to understand already-specified behavior
3. **Write new scenarios**: Add Gherkin scenarios for the new functionality using this format:

```gherkin
Scenario: <Short description of behavior>
  Given <precondition>
  When <action>
  Then <expected outcome>
```

4. **Get approval**: Present the scenarios to the user before proceeding

### Phase 2: Test Implementation

1. **Create test file**: Add tests in the appropriate location:
   - Widget tests: `test/widget/<feature>_test.dart`
   - Unit tests: `test/unit/providers/<provider>_test.dart`
   - BDD tests: `test/bdd/<feature>_test.dart`

2. **Write failing tests**: Tests should fail because the feature doesn't exist yet

3. **Use test helpers**: Import from:
   - `test/helpers/test_database.dart` for Isar setup
   - `test/helpers/test_app.dart` for app builder
   - `test/fixtures/` for test data

### Phase 3: Implementation

1. **Create/modify files** following the project structure:
   - Screen: `lib/features/<feature>/screens/<name>_screen.dart`
   - Widgets: `lib/features/<feature>/widgets/<name>.dart`
   - Provider: `lib/core/providers/<name>_provider.dart`
   - Route: Update `lib/core/router/app_router.dart`

2. **Follow patterns**: Match existing code style and architecture

3. **Run code generation** if needed:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

### Phase 4: Validation

1. **Run tests**: `flutter test test/widget/<feature>_test.dart`
2. **Analyze code**: `flutter analyze`
3. **Format code**: `dart format .`

## Output

Provide a summary of:
- Scenarios added to the feature file
- Tests created
- Code implemented
- Validation results

## User Input

$ARGUMENTS
