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
    required this.intro,
    required this.steps,
    required this.sectionLines,
    required this.moved,
    required this.ownPlace,
  });

  final String id;
  final String cardTitle;
  final String cardBody;

  /// The first step's opening line.
  final String intro;

  /// Step titles, in order.
  final List<String> steps;

  /// Section id -> one line, for "Four sections now".
  final Map<String, String> sectionLines;

  /// Old bar destinations and where they went.
  final List<GuideRow> moved;

  /// Screens that now have a place of their own.
  final List<GuideRow> ownPlace;
}

/// Track and Care (#135): the six-item bar becomes four sections.
const trackAndCareGuide = ReleaseGuide(
  id: 'track-and-care',
  cardTitle: 'The bottom bar has changed',
  cardBody: 'Meds, Meals and Sleep have moved. Nothing has been removed.',
  intro: '', // TODO(#145): copy review
  steps: [
    'Four sections now',
    'Where things moved',
    'Keep it or change it',
    'Finding this again',
  ],
  sectionLines: {
    'dashboard': "Today, and what's coming up",
    'track': 'Symptoms, vitals, meals, sleep and activity',
    'care': 'Medications, appointments, conditions, flares',
    'journal': 'Journal entries and daily check-ins',
  },
  moved: [
    GuideRow(was: 'Tracking', now: 'Track', tabId: 'track'),
    GuideRow(
      was: 'Meds',
      now: 'Care > Medications',
      tabId: 'care.medications',
      pinnable: true,
    ),
    GuideRow(
      was: 'Meals',
      now: 'Track > Meals',
      tabId: 'track.meals',
      pinnable: true,
    ),
    GuideRow(
      was: 'Sleep',
      now: 'Track > Sleep',
      tabId: 'track.sleep',
      pinnable: true,
    ),
    GuideRow(
      was: 'Journal',
      now: 'Journal > Entries',
      tabId: 'journal.entries',
    ),
  ],
  ownPlace: [
    GuideRow(
      was: 'Appointments',
      now: 'Care > Appointments',
      tabId: 'care.appointments',
    ),
    GuideRow(was: 'Activity', now: 'Track > Activity', tabId: 'track.activity'),
    GuideRow(
      was: 'Check-ins',
      now: 'Journal > Check-ins',
      tabId: 'journal.checkins',
    ),
    GuideRow(was: 'Flares', now: 'Care > Flares', tabId: 'care.flares'),
  ],
);

/// Every guide, by id. tool/known_guide_ids.txt lists the same ids, for the
/// release checks (a test keeps them in step).
const releaseGuides = <String, ReleaseGuide>{
  'track-and-care': trackAndCareGuide,
};

/// A row as a screen reader says it. TODO(#145): stub.
String spokenRow(GuideRow row) => throw UnimplementedError();
