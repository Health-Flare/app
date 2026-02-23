import 'package:isar_community/isar.dart';

part 'profile_isar.g.dart';

@collection
class ProfileIsar {
  Id id = Isar.autoIncrement;
  late String name;
  DateTime? dateOfBirth;
  String? avatarPath;
}
