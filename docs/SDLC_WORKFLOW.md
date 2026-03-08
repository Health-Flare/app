# Health Flare SDLC Workflow

This document describes the Behavior-Driven Development (BDD) workflow used in Health Flare, optimized for working with Claude Code.

## Overview

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Specify   │───►│    Test     │───►│  Implement  │───►│  Validate   │
│  (Feature   │    │  (Write     │    │  (Build     │    │  (Run all   │
│   Files)    │    │   tests)    │    │   code)     │    │   checks)   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## Claude Code Skills

The following custom skills are available to streamline this workflow:

| Skill | Purpose | Usage |
|-------|---------|-------|
| `/scenario` | Write BDD scenarios | `/scenario Add category filters to illness search` |
| `/test` | Write tests for scenarios | `/test illness filtering scenarios` |
| `/implement` | Implement code for scenarios | `/implement illness category filter` |
| `/validate` | Run full validation suite | `/validate` |
| `/feature` | Complete feature workflow | `/feature Add category filtering` |
| `/build-feature` | Full BDD cycle with checkpoints | `/build-feature User can filter by category` |
| `/review-feature` | Review feature file quality | `/review-feature illness` |

## Workflow Steps

### 1. Specify: Write BDD Scenarios

**Input:** A feature idea or requirement in plain language.

**Process:**
1. Identify the appropriate feature file in `docs/features/`
2. Write Gherkin scenarios that describe the expected behavior
3. Review scenarios for completeness

**Output:** Updated `.feature` file with new scenarios.

**Skill:** `/scenario` or `/review-feature`

**Example:**
```
User: /scenario Users should be able to filter conditions by typing

Claude: I'll add these scenarios to docs/features/illness.feature:

Scenario: Typing in the search bar filters the condition list live
  Given the illness entry screen is open
  When I type "arth" in the search bar
  Then the condition list updates immediately to show only conditions that contain "arth"
```

### 2. Test: Write Failing Tests

**Input:** BDD scenarios from feature files.

**Process:**
1. Create test file in appropriate location
2. Write widget/unit tests that implement the scenarios
3. Run tests to confirm they fail

**Output:** Test files that will pass once the feature is implemented.

**Skill:** `/test`

**Example:**
```
User: /test illness filtering scenarios

Claude: I'll create test/widget/illness_screen_test.dart:

testWidgets('filters condition list when typing in search', (tester) async {
  // ... test implementation
});
```

### 3. Implement: Build the Feature

**Input:** Test files and BDD scenarios.

**Process:**
1. Create/modify domain models if needed
2. Create/modify Isar collections if needed
3. Implement providers for business logic
4. Build widgets and screens
5. Add routes if needed
6. Run code generation

**Output:** Working feature code.

**Skill:** `/implement`

### 4. Validate: Verify Everything Works

**Input:** Completed implementation.

**Process:**
1. Run `flutter analyze` (must pass)
2. Run `dart format --set-exit-if-changed .` (must pass)
3. Run `flutter test` (all tests must pass)
4. Verify offline compliance (no network URLs)

**Output:** Validation report.

**Skill:** `/validate`

## Quick Reference

### Start a New Feature
```
/build-feature <description>
```
This runs the full workflow with checkpoints at each phase.

### Just Write Scenarios
```
/scenario <description>
```

### Just Write Tests
```
/test <reference to scenarios>
```

### Just Implement
```
/implement <reference to scenarios>
```

### Validate Before Commit
```
/validate
```

## Project Structure

```
docs/features/           # BDD specifications
├── onboarding.feature
├── illness.feature
├── journal.feature
└── ...

test/                    # Test files
├── widget/              # Widget tests
├── unit/providers/      # Provider tests
├── bdd/                 # BDD step definitions
├── helpers/             # Test utilities
└── fixtures/            # Test data

lib/                     # Implementation
├── features/            # Feature code
├── core/providers/      # Business logic
├── data/models/         # Data layer
└── models/              # Domain models
```

## Tips

### For Humans

1. **Start with scenarios:** Before asking Claude to implement anything, ensure the behavior is specified in feature files
2. **Use `/validate` before commits:** Run the full validation to catch issues early
3. **Review generated tests:** Tests should match your intent, not just the scenario text

### For Claude

1. **Always read feature files first:** Understand the specified behavior before implementing
2. **Match existing patterns:** Read similar code in the codebase before writing new code
3. **Run validation frequently:** Don't wait until the end to check for issues
4. **Use test helpers:** Leverage `TestDatabase`, `TestAppBuilder`, and fixtures

## Common Commands

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget/illness_screen_test.dart

# Static analysis
flutter analyze

# Format code
dart format .

# Generate Riverpod code
dart run build_runner build --delete-conflicting-outputs

# Generate Isar code
./scripts/generate_isar.sh
```
