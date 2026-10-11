// Release guides (#145): step-by-step help when something people already
// use moves. Content is bundled; one guide per release at most, named by
// "guideId" in assets/whats_new/releases.json.
// Spec: docs/features/release-guides.feature.

/// One row on "Where things moved": what it was, where it is now.
class GuideRow {
  const GuideRow({
    required this.was,
    required this.now,
    required this.tabId,
    this.pinnable = false,
  });

  /// The old name ("Meds"), or the screen's name for one that now has a
  /// place of its own.
  final String was;

  /// Where it is now ("Care > Medications").
  final String now;

  /// The section or tab "Show me" opens, and "Pin" adds.
  final String tabId;

  /// Was in the old bar, so it can be pinned back (Meds, Meals, Sleep).
  final bool pinnable;
}

class ReleaseGuide {
  const ReleaseGuide({
    required this.id,
    required this.cardTitle,
    required this.cardBody,
    required this.steps,
    required this.sectionLines,
    required this.moved,
    required this.ownPlace,
  });

  final String id;
  final String cardTitle;
  final String cardBody;

  /// Step titles, in order.
  final List<String> steps;

  /// Section id -> one line, for "Four sections now".
  final Map<String, String> sectionLines;

  /// Old bar destinations and where they went.
  final List<GuideRow> moved;

  /// Screens that now have a place of their own.
  final List<GuideRow> ownPlace;
}

// TODO(#145): content.
const trackAndCareGuide = ReleaseGuide(
  id: 'track-and-care',
  cardTitle: '',
  cardBody: '',
  steps: [],
  sectionLines: {},
  moved: [],
  ownPlace: [],
);

/// Every guide, by id. tool/known_guide_ids.txt lists the same ids, for the
/// release checks (a test keeps them in step).
const releaseGuides = <String, ReleaseGuide>{
  'track-and-care': trackAndCareGuide,
};
