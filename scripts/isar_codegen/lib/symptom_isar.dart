import 'package:isar_community/isar.dart';

part 'symptom_isar.g.dart';

@collection
class SymptomIsar {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  late bool global;
}
