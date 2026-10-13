// Which flare an entry is part of (#173). Worked out from the entry's time
// every time it's read, so it never goes stale when a flare's dates change
// and entries from before 1.10.0 join their flares with no migration. The
// person has the final say: an entry can be taken out of its flare
// ([detached]) or, kept from older versions, pinned to one ([pinnedFlareId]).
// Spec: docs/features/flare.feature, "Which flare an entry is part of".

import 'package:health_flare/models/flare.dart';

/// The flare of [profileId] whose dates cover [at], or null. Start and end
/// are both included; an active flare covers everything after its start.
/// If two cover it, the one that started last.
Flare? flareCovering(
  DateTime at, {
  required int profileId,
  required Iterable<Flare> flares,
}) {
  return null; // TODO(#173): red stub
}

/// The id of the flare an entry is part of, or null.
///
/// [detached] (taken out by hand) wins. Then [pinnedFlareId], when that
/// flare still exists for the same profile. Otherwise the flare covering
/// [at].
int? flareFor({
  required DateTime at,
  required int profileId,
  required Iterable<Flare> flares,
  int? pinnedFlareId,
  bool detached = false,
}) {
  return null; // TODO(#173): red stub
}
