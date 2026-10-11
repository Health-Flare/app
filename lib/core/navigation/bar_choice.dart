import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:health_flare/core/navigation/bar_layout.dart';

// TODO(#143): stubs.
typedef BarStore = Future<void> Function(BarRecord record);
typedef Announcer = void Function(BuildContext context, String message);

final barStoreProvider = Provider<BarStore>((ref) => (r) async {});
final announcerProvider = Provider<Announcer>((ref) => (c, m) {});

class BarChoiceNotifier extends Notifier<BarRecord> {
  BarRecord? _preloaded;

  void preload(BarRecord record) => _preloaded = record;

  @override
  BarRecord build() => _preloaded ?? const BarRecord();

  List<String> get shownIds => throw UnimplementedError('#143');
  Future<BarRecord> choose(List<String>? ids) =>
      throw UnimplementedError('#143');
  Future<void> restore(BarRecord r) => throw UnimplementedError('#143');
  Future<BarRecord> useDefault() => throw UnimplementedError('#143');
  Future<BarRecord> applyLikeBefore() => throw UnimplementedError('#143');
}

final barChoiceProvider = NotifierProvider<BarChoiceNotifier, BarRecord>(
  BarChoiceNotifier.new,
);

final barIsCustomizedProvider = Provider<bool>(
  (ref) => throw UnimplementedError('#143'),
);
