import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;
  int? activeProfileId;
  int schemaVersion = 1;
}
