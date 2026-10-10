import 'package:isar_community/isar.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';

class BarLayoutStore {
  BarLayoutStore._();

  static Future<BarRecord> read(Isar isar) => throw UnimplementedError('#137');

  static Future<void> write(Isar isar, BarRecord record) =>
      throw UnimplementedError('#137');

  static Future<BarRecord> settle(Isar isar, {required int current}) =>
      throw UnimplementedError('#137');
}
