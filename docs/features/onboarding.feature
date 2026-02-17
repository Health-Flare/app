Feature: Onboarding
  As a first-time user
  I want a clear, warm, and trustworthy introduction to Health Flare
  So that I understand what the app does, trust it with my health data,
  and feel genuinely set up for success from my very first session

  # ---------------------------------------------------------------------------
  # Trigger: when onboarding is shown
  # ---------------------------------------------------------------------------

  Scenario: Onboarding is shown on first launch when no profiles exist
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    Then I am shown the onboarding screen
    And I am not shown any log screens, dashboard, or navigation

  Scenario: Onboarding is not shown if a profile already exists
    Given at least one profile exists on this device
    When the app launches
    Then I am taken directly to the dashboard for the last active profile
    And the onboarding screen is not shown

  Scenario: Onboarding cannot be skipped or dismissed
    Given I am on the onboarding screen
    When I attempt to navigate away without completing profile creation
    Then I remain on the onboarding screen
    And no navigation to the main app is possible until a profile is saved

  # ---------------------------------------------------------------------------
  # Zone 1: Purpose and welcome message
  # ---------------------------------------------------------------------------

  Scenario: Welcome message is visible on the onboarding screen
    Given I am on the onboarding screen
    Then I see the app name "Health Flare"
    And I see a short welcome headline communicating the app's purpose
    And I see a brief supporting statement that positions the app as a health companion, not a medical device
    And the tone is warm and encouraging, not clinical

  Scenario: Medical disclaimer is present but not alarming
    Given I am on the onboarding screen
    Then I can see a plain-language statement clarifying that Health Flare is not a medical device
    And the statement does not use fear language or warnings
    And the statement is clearly readable without scrolling on a standard screen size

  # ---------------------------------------------------------------------------
  # Zone 2: Privacy and data promise
  # ---------------------------------------------------------------------------

  Scenario: Primary privacy promise is prominently displayed
    Given I am on the onboarding screen
    Then I see a prominent headline stating that all data stays on this device
    And this statement appears before the profile creation form

  Scenario: Supporting privacy facts are visible below the headline
    Given I am on the onboarding screen
    Then I see at least 3 and no more than 4 concise supporting privacy statements
    And one statement confirms no account or login is required
    And one statement confirms no data is uploaded to any cloud or server
    And one statement confirms data only leaves the device when the user explicitly exports or shares it

  Scenario: "Learn more" expands a plain-English privacy detail section
    Given I am on the onboarding screen
    When I tap "Learn more" under the privacy section
    Then an expanded privacy explanation is shown inline without navigating away
    And the expanded content explains in plain English exactly where data is stored, what is collected, and what is never collected
    And the expanded content is written to be understandable by a non-technical user
    And the expanded content contains enough technical detail to satisfy a privacy-conscious technical user

  Scenario: "Learn more" section can be collapsed again
    Given I have expanded the privacy "Learn more" section
    When I tap to collapse it
    Then the expanded content is hidden
    And the onboarding screen returns to its default state

  Scenario: Privacy section uses specific, verifiable language
    Given I am on the onboarding screen
    Then no privacy statement uses vague language such as "we value your privacy" or "we care about your data"
    And every privacy claim is specific and describes a concrete behaviour of the app

  # ---------------------------------------------------------------------------
  # Zone 3: Profile creation (inline, no navigation)
  # ---------------------------------------------------------------------------

  Scenario: Profile creation form is present on the onboarding screen
    Given I am on the onboarding screen
    Then I see a profile creation form below the privacy section
    And the form contains a required name field
    And the form contains an optional date of birth field
    And the form contains an optional avatar or photo field
    And there is a clearly labelled primary action button to complete setup

  Scenario: Complete onboarding with a name only
    Given I am on the onboarding screen
    When I enter "Sarah" in the name field
    And I tap the primary action button
    Then a profile named "Sarah" is created
    And I am taken into the main app
    And the first-log prompt is shown

  Scenario: Complete onboarding with all profile fields filled
    Given I am on the onboarding screen
    When I enter "Dad" in the name field
    And I enter "1952-04-10" in the date of birth field
    And I choose a photo from the library as the avatar
    And I tap the primary action button
    Then a profile named "Dad" is created with the date of birth and avatar saved
    And I am taken into the main app
    And the first-log prompt is shown

  Scenario: Cannot complete onboarding without entering a profile name
    Given I am on the onboarding screen
    When I leave the name field empty
    And I tap the primary action button
    Then I see a validation message indicating a name is required
    And I remain on the onboarding screen
    And no profile is created

  Scenario: Profile name field is focused automatically on load
    Given I am on the onboarding screen
    Then the name input field has focus
    And on devices with a software keyboard the keyboard is visible

  # ---------------------------------------------------------------------------
  # Post-setup: first-log prompt
  # ---------------------------------------------------------------------------

  Scenario: First-log prompt is shown immediately after onboarding is complete
    Given I have just completed onboarding and created my first profile
    When I enter the main app
    Then I am shown the first-log prompt
    And the prompt is warm and encouraging in tone
    And the prompt briefly explains why logging regularly helps identify patterns over time

  Scenario: First-log prompt offers four entry options
    Given the first-log prompt is visible
    Then I can see four options:
      | Option      |
      | A symptom   |
      | A vital     |
      | A meal      |
      | A medication|

  Scenario: Tapping a first-log option opens the relevant entry form
    Given the first-log prompt is visible
    When I tap "A symptom"
    Then the new symptom entry form opens
    And when I save it I am returned to the dashboard

  Scenario: Tapping "A vital" from the first-log prompt opens the vital entry form
    Given the first-log prompt is visible
    When I tap "A vital"
    Then the new vital entry form opens

  Scenario: Tapping "A meal" from the first-log prompt opens the meal entry form
    Given the first-log prompt is visible
    When I tap "A meal"
    Then the new meal entry form opens

  Scenario: Tapping "A medication" from the first-log prompt opens the add medication form
    Given the first-log prompt is visible
    When I tap "A medication"
    Then the add medication form opens

  Scenario: First-log prompt can be dismissed to explore freely
    Given the first-log prompt is visible
    When I dismiss the prompt
    Then I am taken to the main dashboard
    And the prompt does not appear again for this profile

  Scenario: First-log prompt only appears once per profile
    Given I dismissed the first-log prompt after creating profile "Sarah"
    When I close and reopen the app
    Then the first-log prompt is not shown again
    And I am taken directly to the dashboard for "Sarah"

  Scenario: First-log prompt does not appear for subsequent profiles
    Given profile "Sarah" already exists and onboarding is complete
    When I create a new profile "Dad" from the profile settings
    Then the first-log prompt is shown for "Dad"
    But the full onboarding screen is not shown again

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: Onboarding screen meets WCAG 2.1 AA colour contrast requirements
    Given I am on the onboarding screen
    Then all text elements meet a minimum contrast ratio of 4.5:1 against their background
    And all large text elements meet a minimum contrast ratio of 3:1 against their background

  Scenario: All interactive elements on the onboarding screen are accessible via keyboard
    Given I am using a device with a hardware keyboard (desktop or web)
    When I navigate the onboarding screen using the Tab key
    Then every interactive element receives focus in a logical order
    And I can trigger the primary action button using the Enter or Space key

  Scenario: Onboarding screen is compatible with screen readers
    Given a screen reader is active
    When the onboarding screen loads
    Then all text content is announced in a logical reading order
    And the name input field has a descriptive accessible label
    And the primary action button has a descriptive accessible label
    And no information is conveyed by colour alone

  Scenario: Onboarding text is readable at increased system font sizes
    Given the device system font size is set to the largest accessible option
    When the onboarding screen loads
    Then all text remains readable and does not overflow or overlap other elements
    And the profile creation form remains fully usable
