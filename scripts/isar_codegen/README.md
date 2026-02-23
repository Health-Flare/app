# Isar Code Generation

`isar_community_generator` requires `analyzer >=7.4.5 <8.3.0`, which conflicts
with `riverpod_generator ^2.x` used in the main project. To work around this,
Isar code generation is run from this isolated Dart project.

## How to regenerate Isar `.g.dart` files

Run this from the repo root:

```bash
bash scripts/generate_isar.sh
```

Or manually:

```bash
cd scripts/isar_codegen
dart pub get
dart run build_runner build --delete-conflicting-outputs
```

The generated files are written to `lib/data/` in the main project (via the
`build.yaml` source path configuration) and must be committed to the repository.
