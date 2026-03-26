import 'package:isar_community/isar.dart';

part 'profile_isar.g.dart';

@collection
class ProfileIsar {
  Id id = Isar.autoIncrement;
  late String name;
  DateTime? dateOfBirth;
  String? avatarPath;

  /// Whether the first-log prompt has been shown (and dismissed) for this profile.
  /// Defaults to false — prompt shown automatically on first dashboard visit.
  bool firstLogShown = false;

  /// Whether the user opted in to weather tracking for this profile.
  /// Defaults to false. Set to true after the user taps "Enable" in the
  /// weather opt-in prompt.
  bool weatherTrackingEnabled = false;

  /// Whether the weather opt-in prompt has been shown for this profile.
  /// Defaults to false. Set to true once the prompt is presented, regardless
  /// of whether the user enabled or declined.
  bool weatherOptInShown = false;

  /// Material seed color for this profile's ColorScheme.
  /// Null = use the app default. Auto-assigned from a palette on creation.
  int? colorSeed;

  /// Whether menstrual cycle tracking is enabled for this profile.
  /// Defaults to false. When true, cycle phase field appears in daily check-in.
  bool cycleTrackingEnabled = false;
}
