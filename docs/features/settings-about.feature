Feature: Settings About section
  So that people can tell us which build they are on when they report a problem,
  the About section of Settings shows the installed app version.

  Scenario: Settings shows the installed app version
    Given the user opens Settings
    When they look at the About section
    Then they see "App version" with the installed version and build number, e.g. "1.9.1 (build 13)"
    And the version matches the version in pubspec.yaml for that build

  # ---------------------------------------------------------------------------
  # Where our questions come from (credit for PROMIS-informed inputs)
  # ---------------------------------------------------------------------------

  # The symptom inputs that separate intensity from interference and ask for
  # impact in the person's own words come from Dr Cat Hicks's Informed Patient
  # work (https://github.com/DrCatHicks/informed-patient,
  # https://informed-patient.ai). Credit her in the app, on the website, and in
  # the repo. The app is offline-first, so citations are shown as text; links
  # open only on tap via healthflare.org (see .url-scan-ignore).

  Scenario: Settings credits Informed Patient and Dr Cat Hicks
    Given the user opens Settings
    When they open "Where our questions come from"
    Then they see that the symptom questions are adapted from Informed Patient by Dr Cat Hicks
    And they see a plain explanation: intensity and how much a symptom gets in the way are recorded separately, and a short note of what it stopped you doing helps a clinician understand it

  Scenario: Each source is cited in full
    When the user opens "Where our questions come from"
    Then they see these sources with authors, title, journal, year, and PMID:
      | Source                                                                                     | PMID     |
      | Cella et al. 2010, The PROMIS developed and tested its first wave of adult item banks       | 20685078 |
      | Farrar et al. 2001, Clinical importance of changes in chronic pain intensity (11-point NRS) | 11690728 |
      | Paterson 1996, MYMOP compared with the SF-36                                                | 8616351  |
      | Patrick et al. 2011, Content validity of new PRO instruments, part 2                        | 22152166 |
    And they see Informed Patient credited with its licence, CC BY 4.0

  Scenario: The app does not claim to administer PROMIS
    When the user opens "Where our questions come from"
    Then the text says these questions are informed by PROMIS research
    And it does not say the app uses, scores, or is endorsed by PROMIS

  Scenario: Sources link out only when tapped
    When the user taps "Read more on healthflare.org"
    Then the sources page opens in the system browser
    And no network request is made before the tap
