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
}
