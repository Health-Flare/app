import 'package:isar_community/isar.dart';

part 'condition_isar.g.dart';

@collection
class ConditionIsar {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String name;

  late bool global;
}
