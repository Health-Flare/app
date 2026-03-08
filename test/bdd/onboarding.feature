# Generated from docs/features/onboarding.feature
# Run with: flutter test test/bdd/

Feature: Onboarding
  As a first-time user
  I want a clear, warm, and trustworthy introduction to Health Flare
  So that I understand what the app does, trust it with my health data,
  and feel genuinely set up for success from my very first session

  Background:
    Given the test database is initialized

  Scenario: Onboarding is shown on first launch when no profiles exist
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    Then I am shown the top of the onboarding screen
    And I am not shown any log screens, dashboard, or navigation

  Scenario: CTA button is disabled when name field is empty
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    Then the primary action button is disabled

  Scenario: CTA button enables once a name is entered
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    And I enter "Sarah" in the name field
    Then the primary action button is enabled

  Scenario: Complete onboarding with a name only
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    And I enter "Sarah" in the name field
    And I tap the primary action button
    Then a profile named "Sarah" is created
    And I am taken into the main app
    And the first-log prompt is shown

  Scenario: Cannot complete onboarding without entering a profile name
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    And I leave the name field empty
    And I tap the primary action button
    Then I see a validation message indicating a name is required
    And I remain on the onboarding screen
    And no profile is created
