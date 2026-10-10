import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

/// Singleton settings document stored in Isar.
///
/// There is always exactly one document with [id] = 1.
/// Holds persisted app-level state that doesn't belong to a specific profile.
@collection
class AppSettings {
  /// Fixed id: always 1. There is exactly one AppSettings document.
  Id id = 1;

  /// The id of the currently active profile, or null if none is selected.
  int? activeProfileId;

  /// Schema version used by [MigrationRunner] for data migrations.
  /// v1 = initial Isar schema (this release).
  int schemaVersion = 1;

  /// Highest profile id ever handed out on this device. New profiles get
  /// the next one, so a deleted profile's id is never reused (#117).
  int lastProfileId = 0;

  /// App lock (#100): ask for the phone's own security before showing
  /// anything. Belongs to this phone, not to the data: a restore keeps the
  /// phone's value (see BackupService.applyPendingRestoreIfNeeded).
  bool appLockEnabled = false;

  /// How long the app may sit in the background before it locks again.
  /// 0 locks as soon as it leaves the screen. Null means the default (15
  /// minutes): nullable so rows written before this field existed read as
  /// the default, not Isar's missing-long value.
  int? appLockRelockSeconds;

  /// Hide the app in the app switcher (#101). On Android this also blocks
  /// screenshots and screen recording (FLAG_SECURE).
  bool hideInAppSwitcher = false;
}
