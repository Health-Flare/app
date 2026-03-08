import 'package:isar_community/isar.dart';

part 'user_symptom_isar.g.dart';

@collection
class UserSymptomIsar {
  Id id = Isar.autoIncrement;

  @Index()
  late int profileId;

  @Index()
  late int symptomId;

  late String symptomName;

  late DateTime trackedSince;
}
