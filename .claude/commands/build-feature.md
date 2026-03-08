# Build Feature (Full Workflow)

You are building a complete feature for Health Flare using the full BDD workflow: Specify → Test → Implement → Validate.

## Input

The user will describe what they want to build. This could be:
- A new feature or capability
- An enhancement to existing functionality
- A bug fix with regression prevention

## Full Workflow

### Phase 1: Specification (Feature File)

1. **Identify the feature area** and corresponding file in `docs/features/`
2. **Read existing scenarios** to understand context
3. **Write new Gherkin scenarios** for the requested functionality
4. **Present scenarios for approval** before proceeding

Example output:
```
I'll add these scenarios to docs/features/illness.feature:

Scenario: User can filter conditions by category
  Given the illness entry screen is open
  When I tap the "Autoimmune" category filter
  Then only autoimmune conditions are shown in the list

Should I proceed with these scenarios?
```

### Phase 2: Testing

1. **Create test file** in appropriate location
2. **Write tests** that implement the scenarios
3. **Run tests** to confirm they fail (feature doesn't exist yet)

```bash
flutter test test/widget/<feature>_test.dart
```

### Phase 3: Implementation

1. **Plan the components** needed:
   - Domain models
   - Isar collections
   - Providers
   - Widgets
   - Screens
   - Routes

2. **Implement in order**:
   - Data layer first (models, collections)
   - Logic layer (providers)
   - UI layer (widgets, screens)
   - Navigation (routes)

3. **Run code generation** if needed

### Phase 4: Validation

1. **Run tests** to confirm they now pass
2. **Static analysis**: `flutter analyze`
3. **Formatting**: `dart format .`
4. **Manual check**: No network URLs, no google_fonts

### Phase 5: Summary

Provide a complete summary:
- Scenarios added
- Tests created
- Files implemented
- Validation status

## Checkpoints

At each phase, pause and confirm with the user:
- After writing scenarios: "Ready to proceed to tests?"
- After tests fail: "Ready to implement?"
- After implementation: "Running validation..."

## User Input

$ARGUMENTS
