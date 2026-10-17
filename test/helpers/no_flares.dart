// Forms show which flare an entry is part of (#173), which reads the flare
// list, and the real list opens Isar. Add [noFlares] to a form test's
// overrides when it isn't about flares, or [withFlares] when it is.
import 'package:flutter_riverpod/misc.dart';

import 'package:health_flare/core/providers/condition_provider.dart';
import 'package:health_flare/core/providers/flare_provider.dart';
import 'package:health_flare/models/flare.dart';
import 'package:health_flare/models/user_condition.dart';

class _Flares extends FlareListNotifier {
  _Flares(this.flares);
  final List<Flare> flares;

  @override
  List<Flare> build() => flares;
}

class _Conditions extends UserConditionListNotifier {
  @override
  List<UserCondition> build() => const [];
}

/// [flares], and no tracked conditions (the row names a flare by them).
List<Override> withFlares(List<Flare> flares) => [
  flareListProvider.overrideWith(() => _Flares(flares)),
  userConditionListProvider.overrideWith(_Conditions.new),
];

final Override noFlares = flareListProvider.overrideWith(
  () => _Flares(const []),
);
