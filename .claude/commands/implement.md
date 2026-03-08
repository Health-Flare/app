# Implement

You are implementing code for Health Flare based on existing BDD scenarios. This skill assumes scenarios already exist in feature files.

## Input

The user will provide:
- A reference to specific scenarios in a feature file
- The scenario text directly
- A description of what to implement

## Process

### 1. Read the Scenarios

Find and read the relevant scenarios from `docs/features/*.feature`.

### 2. Identify Required Components

For each scenario, determine what needs to be created:

| Scenario involves... | Create/modify... |
|---------------------|------------------|
| New screen | `lib/features/<feature>/screens/<name>_screen.dart` |
| UI components | `lib/features/<feature>/widgets/<name>.dart` |
| Data storage | `lib/data/models/<name>_isar.dart` + domain model |
| Business logic | `lib/core/providers/<name>_provider.dart` |
| Navigation | `lib/core/router/app_router.dart` |

### 3. Follow Existing Patterns

Before writing new code:
1. Read similar existing implementations
2. Match the coding style
3. Use existing utilities and patterns

**Key patterns:**
- Screens use `ConsumerWidget` or `ConsumerStatefulWidget`
- Providers use `@riverpod` annotation
- Navigation uses go_router
- Database uses Isar collections

### 4. Implementation Order

1. **Domain models** (`lib/models/`) - if new data types needed
2. **Isar collections** (`lib/data/models/`) - if persistence needed
3. **Providers** (`lib/core/providers/`) - business logic
4. **Widgets** (`lib/features/<feature>/widgets/`) - UI components
5. **Screens** (`lib/features/<feature>/screens/`) - full screens
6. **Routes** (`lib/core/router/app_router.dart`) - navigation

### 5. Code Generation

If you created/modified `@riverpod` providers:
```bash
dart run build_runner build --delete-conflicting-outputs
```

If you created/modified Isar collections:
```bash
./scripts/generate_isar.sh
```

### 6. Basic Validation

After implementing:
```bash
flutter analyze
dart format .
```

## Output

Provide:
1. List of files created/modified
2. Summary of implementation
3. Any manual steps needed (e.g., running code generation)
4. Suggestion to run tests

## User Input

$ARGUMENTS
