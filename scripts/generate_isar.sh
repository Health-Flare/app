#!/usr/bin/env bash
# Generate Isar .g.dart files for the healthflare project.
#
# isar_community_generator conflicts with riverpod_generator due to incompatible
# analyzer version constraints, so code generation is run from a separate
# minimal Dart project (scripts/isar_codegen/).
#
# Run this script from the repo root whenever an Isar-annotated class changes:
#   bash scripts/generate_isar.sh
#
# The generated *.g.dart files are committed to the repository so that
# normal `flutter pub get` and `dart run build_runner build` (for Riverpod)
# continue to work without needing isar_community_generator installed.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEGEN_DIR="$REPO_ROOT/scripts/isar_codegen"

echo "→ Installing codegen project dependencies..."
(cd "$CODEGEN_DIR" && dart pub get)

echo "→ Running isar_community_generator..."
(cd "$CODEGEN_DIR" && dart run build_runner build --delete-conflicting-outputs)

echo "→ Copying generated files to main project..."
cp "$CODEGEN_DIR/lib/app_settings.g.dart"      "$REPO_ROOT/lib/data/database/app_settings.g.dart"
cp "$CODEGEN_DIR/lib/profile_isar.g.dart"      "$REPO_ROOT/lib/data/models/profile_isar.g.dart"
cp "$CODEGEN_DIR/lib/journal_entry_isar.g.dart" "$REPO_ROOT/lib/data/models/journal_entry_isar.g.dart"

echo "✓ Done. Generated files written to lib/data/."
