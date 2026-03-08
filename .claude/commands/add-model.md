# Add Data Model

You are adding a new data model to Health Flare. This involves creating both a domain model and an Isar collection.

## Input

The user will describe:
- The data they want to store
- The fields/properties needed
- Relationships to other models

## Process

### 1. Create Domain Model

Create `lib/models/<name>.dart`:

```dart
/// A brief description of what this model represents.
class ModelName {
  final String id;
  final String field1;
  final int? optionalField;

  const ModelName({
    required this.id,
    required this.field1,
    this.optionalField,
  });
}
```

### 2. Create Isar Collection

Create `scripts/isar_codegen/lib/<name>_isar.dart`:

```dart
import 'package:isar/isar.dart';

part '<name>_isar.g.dart';

@collection
class ModelNameIsar {
  Id? isarId;

  @Index(unique: true)
  late String id;

  late String field1;

  int? optionalField;

  // Relationships use @Index if needed
  @Index()
  late String? relatedId;
}
```

### 3. Generate Isar Code

```bash
./scripts/generate_isar.sh
```

### 4. Copy Generated Files

Copy from `scripts/isar_codegen/lib/` to `lib/data/models/`:
- `<name>_isar.dart`
- `<name>_isar.g.dart`

### 5. Register Collection

Update `lib/data/database/app_database.dart`:

```dart
static final List<CollectionSchema<dynamic>> _schemas = [
  ProfileIsarSchema,
  JournalEntryIsarSchema,
  ModelNameIsarSchema,  // Add new schema
];
```

### 6. Add Migration (if needed)

If the app has existing users, add migration in `lib/data/database/migration_runner.dart`.

### 7. Create Provider (optional)

If CRUD operations are needed, create `lib/core/providers/<name>_provider.dart`.

## Output

Provide:
1. Files created
2. Commands to run for code generation
3. Manual steps (copying files, registering schema)

## User Input

$ARGUMENTS
