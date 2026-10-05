/// Where Health Flare's symptom questions come from.
///
/// One list, used by Settings > "Where our questions come from" and by any
/// store-review answer, so the two never drift apart. Every PMID here was
/// checked on Europe PMC.
///
/// Credit: Dr Cat Hicks pointed us to PROMIS and the measurement research
/// behind it. Her Informed Patient skill, and its symptom-inventory
/// methodology, are where the three ideas below come from:
///   1. How intense a symptom is and how much it gets in the way are
///      different things, so we record them separately.
///   2. A number alone is a weak record; pair it with what the symptom
///      stopped you doing.
///   3. Describe first, rate second, then ask what was missed.
/// Informed Patient (github.com/DrCatHicks/informed-patient) is licensed
/// CC BY 4.0. Our questions are adapted from its ideas and written in our own
/// words. They are informed by PROMIS research; they are not PROMIS
/// instruments, are not scored as such, and are not endorsed by the PROMIS
/// Health Organization.
library;

/// A published source behind a symptom question.
class SymptomSource {
  const SymptomSource({
    required this.citation,
    required this.usedFor,
    this.pmid,
  });

  /// Authors, title, journal, year.
  final String citation;

  /// Plain-language note of which question it supports.
  final String usedFor;

  /// PubMed id, shown as text (the app makes no network calls).
  final String? pmid;
}

abstract final class SymptomSources {
  /// Credit line shown at the top of the sources screen.
  static const credit =
      'Dr Cat Hicks pointed us to PROMIS and the research behind it. '
      'These questions are adapted from her Informed Patient skill and its '
      'symptom-inventory methodology, used under CC BY 4.0. Thank you, Cat.';

  static const informedPatient =
      'Informed Patient, by Dr Cat Hicks. '
      'github.com/DrCatHicks/informed-patient. Licensed CC BY 4.0. '
      'Adapted: ideas rewritten as app questions in our own words.';

  /// What PROMIS is, and what we do not claim.
  static const promisNote =
      'PROMIS is a set of health questionnaires funded by the US National '
      'Institutes of Health. Our questions are informed by PROMIS research. '
      'They are not PROMIS questionnaires, they do not give a PROMIS score, '
      'and PROMIS has not reviewed or endorsed Health Flare.';

  static const List<SymptomSource> all = [
    SymptomSource(
      citation:
          'Cella D, Riley W, Stone A, et al. The Patient-Reported Outcomes '
          'Measurement Information System (PROMIS) developed and tested its '
          'first wave of adult self-reported health outcome item banks: '
          '2005-2008. J Clin Epidemiol. 2010;63(11):1179-94.',
      usedFor: 'Recording intensity and interference separately.',
      pmid: '20685078',
    ),
    SymptomSource(
      citation:
          'Farrar JT, Young JP, LaMoreaux L, Werth JL, Poole RM. Clinical '
          'importance of changes in chronic pain intensity measured on an '
          '11-point numerical pain rating scale. Pain. 2001;94(2):149-58.',
      usedFor: 'Why a number alone is a weak record.',
      pmid: '11690728',
    ),
    SymptomSource(
      citation:
          'Paterson C. Measuring outcomes in primary care: a patient '
          'generated measure, MYMOP, compared with the SF-36 health survey. '
          'BMJ. 1996;312(7037):1016-20.',
      usedFor: 'Saying what a symptom stopped you doing, in your own words.',
      pmid: '8616351',
    ),
    SymptomSource(
      citation:
          'Patrick DL, Burke LB, Gwaltney CJ, et al. Content validity, '
          'establishing and reporting the evidence in newly developed '
          'patient-reported outcomes (PRO) instruments for medical product '
          'evaluation: ISPOR PRO Good Research Practices Task Force report: '
          'part 2, assessing respondent understanding. Value Health. '
          '2011;14(8):978-88.',
      usedFor: 'Asking "anything else?" so we learn what our questions miss.',
      pmid: '22152166',
    ),
  ];
}
