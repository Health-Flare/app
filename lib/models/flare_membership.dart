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
  Flare? best;
  for (final f in flares) {
    if (f.profileId != profileId) continue;
    if (at.isBefore(f.startedAt)) continue;
    final end = f.endedAt;
    if (end != null && at.isAfter(end)) continue;
    if (best == null || f.startedAt.isAfter(best.startedAt)) best = f;
  }
  return best;
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
  if (detached) return null;
  if (pinnedFlareId != null &&
      flares.any((f) => f.id == pinnedFlareId && f.profileId == profileId)) {
    return pinnedFlareId;
  }
  return flareCovering(at, profileId: profileId, flares: flares)?.id;
}
