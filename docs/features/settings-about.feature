Feature: Settings About section
  So that people can tell us which build they are on when they report a problem,
  the About section of Settings shows the installed app version.

  Scenario: Settings shows the installed app version
    Given the user opens Settings
    When they look at the About section
    Then they see "App version" with the installed version and build number, e.g. "1.9.1 (build 13)"
    And the version matches the version in pubspec.yaml for that build
