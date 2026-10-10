import 'package:isar_community/isar.dart';

part 'app_settings.g.dart';

@collection
class AppSettings {
  Id id = 1;
  int? activeProfileId;
  int schemaVersion = 1;
  int lastProfileId = 0;
  bool appLockEnabled = false;
  int? appLockRelockSeconds;
  bool hideInAppSwitcher = false;
  String? lastSeenWhatsNewVersion;
  bool updateHighlightsOff = false;
  String? whatsNewCardVersion;
  int? whatsNewCardShownCount;
  List<String>? bottomBarIds;
  int? bottomBarLayoutVersion;
}
