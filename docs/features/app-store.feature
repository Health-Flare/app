Feature: App Store Submission Readiness
  As a Health Flare developer preparing for public distribution
  I want all store metadata, assets, and compliance documents to be complete and accurate
  So that submissions to the Apple App Store and Google Play Store are approved without rejection

  Background:
    Given Health Flare targets both iOS (Apple App Store) and Android (Google Play Store)
    And the app is offline-first with all data stored on-device and no account required

  # ---------------------------------------------------------------------------
  # Shared metadata
  # ---------------------------------------------------------------------------

  Scenario: Core metadata is defined for both stores
    Given the submission checklist
    Then the following fields are completed and consistent across both stores:
      | Field               | Constraint                                             |
      | App name            | "Health Flare" — ≤ 30 chars Apple, ≤ 50 chars Play    |
      | Primary category    | Health & Fitness                                       |
      | Support URL         | Points to a reachable healthflare.org support page     |
      | Privacy policy URL  | Points to a reachable healthflare.org privacy policy   |
      | Copyright           | "© 2026 Health Flare"                                  |

  Scenario: Version and build numbers are consistent and monotonic
    Given the app is ready for submission
    Then the version string (e.g. "1.0.0") matches across pubspec.yaml, the Apple submission, and the Play submission
    And the build number has never been reused across any previous submission to either store

  Scenario: The privacy policy is published at a stable, reachable URL
    Given the healthflare.org domain
    Then a privacy policy page is publicly accessible before any store submission is made
    And it states that all health data is stored on-device only
    And it states that no data is shared with or sold to third parties
    And it states that no account or login is required to use the app
    And the URL is stable and will not change between app versions

  Scenario: The app does not contain health advice or medical claims
    Given all in-app copy, the store description, and the store listing text
    Then no language implies the app can diagnose, treat, or cure any medical condition
    And the description makes clear this is a personal tracking tool, not a medical device
    And no language triggers medical device classification under FDA, CE, or TGA frameworks

  # ---------------------------------------------------------------------------
  # Apple App Store
  # ---------------------------------------------------------------------------

  Scenario: Apple App Store Connect listing is fully populated
    Given the App Store Connect submission record
    Then all required fields are completed:
      | Field               | Constraint                                     |
      | App name            | ≤ 30 characters                                |
      | Subtitle            | ≤ 30 characters                                |
      | Description         | ≤ 4000 characters, no HTML                     |
      | Keywords            | ≤ 100 characters total                         |
      | Promotional text    | ≤ 170 characters (optional but present)        |
      | Support URL         | Valid and reachable                            |
      | Privacy policy URL  | Valid and reachable                            |
      | Age rating          | Questionnaire completed — expected result: 4+  |
      | Primary category    | Health & Fitness                               |

  Scenario: Apple privacy nutrition label accurately reflects the app's data practices
    Given the App Store Connect privacy questionnaire
    Then the following data-use declarations are made:
      | Data type             | Collected | Linked to user | Used for tracking |
      | Health & Fitness data | Yes       | No             | No                |
      | Usage data            | No        | No             | No                |
      | Diagnostics           | No        | No             | No                |
    And the label states that no data is shared with or sold to third parties
    And the label notes that all data is stored on-device only
    And the label is consistent with the app's actual runtime behaviour

  Scenario: Apple review notes explain the offline-first and no-account approach
    Given the App Store review notes field
    Then it explains that no account, login, or network connection is required
    And it explains that all data remains on-device
    And it provides at least one complete test flow a reviewer can follow to evaluate the app

  Scenario: Info.plist declares only permissions the app actually uses
    Given the app's ios/Runner/Info.plist
    Then it does not declare usage description strings for:
      | Permission      |
      | NSCameraUsageDescription (unless camera feature is added)        |
      | NSContactsUsageDescription                                       |
      | NSMicrophoneUsageDescription                                     |
      | NSLocationWhenInUseUsageDescription (unless location is added)   |
    And every permission that is declared has a clear, user-facing purpose string

  Scenario: Screenshots are provided for all required Apple device classes
    Given the App Store Connect media assets
    Then screenshots are provided for at minimum:
      | Device class             | Minimum count |
      | iPhone 6.9" (Pro Max)    | 3             |
      | iPhone 6.5" (Plus)       | 3             |
    And each screenshot shows real app content using realistic chronic-illness tracking data
    And no screenshot contains lorem ipsum, placeholder text, or the default Flutter icon

  # ---------------------------------------------------------------------------
  # Google Play Store
  # ---------------------------------------------------------------------------

  Scenario: Google Play Console listing is fully populated
    Given the Google Play Console submission record
    Then all required fields are completed:
      | Field               | Constraint                              |
      | App name            | ≤ 50 characters                         |
      | Short description   | ≤ 80 characters                         |
      | Full description    | ≤ 4000 characters                       |
      | App icon            | 512 × 512 px PNG, no transparency       |
      | Feature graphic     | 1024 × 500 px PNG or JPEG               |
      | Category            | Health & Fitness                        |
      | Content rating      | IARC questionnaire completed            |
      | Privacy policy URL  | Valid and reachable                     |
      | Data safety form    | Completed accurately (see below)        |

  Scenario: Google Play data safety section accurately reflects data practices
    Given the Play Console data safety form
    Then it declares that no data is shared with third parties
    And it declares that no data is sold to third parties
    And it declares that health and fitness data is collected and stored on-device only
    And it declares that no data is transmitted off the device by the app
    And the form is consistent with the AndroidManifest.xml permissions and actual runtime behaviour

  Scenario: AndroidManifest.xml declares only the permissions the app uses
    Given android/app/src/main/AndroidManifest.xml
    Then it does not declare:
      | Permission                                              |
      | INTERNET (unless weather feature is enabled)            |
      | READ_CONTACTS                                           |
      | CAMERA (unless camera feature is added)                 |
      | RECORD_AUDIO                                            |
    And every declared permission has a documented rationale in the Play submission notes

  Scenario: Screenshots are provided for phone and tablet on Play
    Given the Play Console media assets
    Then at least 4 phone screenshots are provided (minimum 320 px wide, maximum 3840 px)
    And screenshots show the app's key features: dashboard, sleep log, journal, and a report
    And a feature graphic (1024 × 500 px) is present
    And no screenshot contains placeholder or lorem ipsum content

  # ---------------------------------------------------------------------------
  # Screenshots — process
  # ---------------------------------------------------------------------------

  Scenario: Screenshots are generated by the automated screenshot system
    Given the screenshot generation pipeline exists
    Then all store screenshots are produced by running the same repeatable command
    And no screenshot is produced manually or stored as a one-off export
    And generated screenshots are committed to a version-controlled directory
    And the command to regenerate them is documented in CLAUDE.md or the project README

  Scenario: Screenshots use the "Sarah" persona with realistic tracking data
    Given the screenshot fixture data
    Then the active profile is named "Sarah"
    And the dashboard shows at least 7 days of logged sleep, symptoms, and journal entries
    And all dates in the screenshots fall within a recent, plausible range
    And no entry contains lorem ipsum, test data labels, or developer identifiers
