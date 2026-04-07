import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

/// Singleton settings document stored in Isar.
///
/// There is always exactly one document with [id] = 1.
/// Holds persisted app-level state that doesn't belong to a specific profile.
@collection
class AppSettings {
  /// Fixed id — always 1. There is exactly one AppSettings document.
  Id id = 1;

  /// The id of the currently active profile, or null if none is selected.
  int? activeProfileId;

  /// Schema version used by [MigrationRunner] for data migrations.
  /// v1 = initial Isar schema (this release).
  int schemaVersion = 1;
}
