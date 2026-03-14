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
    Then I am shown the top of the onboarding screen
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
    And the form contains an optional illness selector
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

  Scenario: Profile name containing only whitespace is rejected
    Given I am on the onboarding screen
    When I enter "   " in the name field
    Then the primary action button remains disabled
    And no profile is created

  Scenario: Photo library access denied shows a helpful inline message
    Given I am on the onboarding screen
    When I tap the avatar field
    And I deny photo library permission
    Then a brief message explains that photo access was not granted
    And the profile creation form remains usable without a photo

  # ---------------------------------------------------------------------------
  # Post-setup: first-log prompt
  # ---------------------------------------------------------------------------

  Scenario: First-log prompt is shown after the weather opt-in clears
    Given I have just completed onboarding and the weather opt-in has been dismissed
    When the dashboard loads
    Then I am shown the first-log prompt
    And the prompt acknowledges the profile by name
    And the prompt frames the first entry as the start of a pattern,
        not as a setup task

  Scenario: First-log prompt offers six entry options
    Given the first-log prompt is visible
    Then I can see six options:
      | Option          |
      | An illness      |
      | A symptom       |
      | A vital         |
      | A meal          |
      | A medication    |
      | A journal entry |
    And "An illness" is displayed prominently as the first option
    And each option has a brief sub-label describing what it captures

  Scenario: Tapping "An illness" opens the illness screen and returns to the prompt
    Given the first-log prompt is visible
    When I tap "An illness"
    Then the illness entry screen opens full-screen
    When I finish on the illness screen (with or without saving)
    Then I am returned to the first-log prompt
    And I can now choose what to log next

  Scenario: Prompt heading updates after an illness is added to encourage the next step
    Given the first-log prompt is visible
    When I add an illness and return to the prompt
    Then the prompt heading updates to invite a related first log
    Such as "Now, how are you feeling today?"
    And the non-illness options are visually foregrounded

  Scenario: Tapping a daily-use option opens the entry form and lands on the dashboard
    Given the first-log prompt is visible
    When I tap "A symptom"
    Then the new symptom entry form opens
    When I complete and save the entry
    Then I am taken to the dashboard
    And the saved entry is visible in my dashboard feed
    And the first-log prompt is not shown again

  Scenario: The same transition-to-dashboard applies for all non-illness options
    Given the first-log prompt is visible
    When I tap "A vital" and save a vital entry
    Then I am taken to the dashboard
    Given the first-log prompt is visible
    When I tap "A meal" and save a meal entry
    Then I am taken to the dashboard
    Given the first-log prompt is visible
    When I tap "A medication" and save a medication entry
    Then I am taken to the dashboard
    Given the first-log prompt is visible
    When I tap "A journal entry" and save a journal entry
    Then I am taken to the dashboard

  Scenario: Navigating back from any entry form without saving returns to the prompt
    Given the first-log prompt is visible
    When I tap "A vital"
    And I close the vital entry form without saving
    Then I am returned to the first-log prompt
    And the prompt is still visible

  Scenario: First-log prompt can be dismissed to start using the app freely
    Given the first-log prompt is visible
    When I tap "I'll explore on my own"
    Then I am taken to the dashboard
    And the prompt does not appear again for this profile

  Scenario: First-log prompt only appears once per profile
    Given the first-log prompt was shown and dismissed for profile "Sarah"
    When I close and reopen the app
    Then the first-log prompt is not shown again
    And I am taken directly to the dashboard for "Sarah"

  Scenario: First-log prompt appears for each new profile
    Given profile "Sarah" already exists and has completed the first-log prompt
    When I create a new profile "Dad"
    Then the first-log prompt is shown for "Dad"
    But the full onboarding screen is not shown again

  # ---------------------------------------------------------------------------
  # Post-setup: weather tracking opt-in
  # ---------------------------------------------------------------------------

  Scenario: Weather tracking opt-in is offered after profile creation
    Given I have just completed onboarding and created my first profile
    When I enter the main app
    Then I am shown an optional prompt to enable weather tracking
    And the prompt explains that temperature, humidity, and barometric pressure can correlate with chronic illness symptoms
    And the prompt is framed as a data point worth tracking, not a privacy concern

  Scenario: Enabling weather tracking grants location permission and activates the feature
    Given the weather tracking prompt is visible
    When I tap "Enable weather tracking"
    Then the OS location permission dialog is shown
    When I grant location permission
    Then weather tracking is enabled for this profile
    And the first-log prompt follows

  Scenario: Declining weather tracking skips to the first-log prompt without asking again
    Given the weather tracking prompt is visible
    When I tap "No thanks"
    Then weather tracking is disabled for this profile
    And the first-log prompt follows
    And I am not asked about weather tracking again during this onboarding

  Scenario: Denying location permission after enabling disables the feature gracefully
    Given the weather tracking prompt is visible
    When I tap "Enable weather tracking"
    And I deny the OS location permission
    Then weather tracking is disabled for this profile
    And I see a brief message explaining that location access is needed for weather tracking
    And I can enable it later from settings

  Scenario: Weather tracking can be enabled later from profile settings
    Given "Sarah" declined weather tracking during onboarding
    When I open settings for "Sarah"
    And I enable weather tracking
    Then the OS location permission dialog is shown if not previously granted
    And weather tracking becomes active for "Sarah"

  Scenario: Weather tracking can be disabled at any time from profile settings
    Given "Sarah" has weather tracking enabled
    When I open settings for "Sarah"
    And I disable weather tracking
    Then no weather data is attached to future entries for "Sarah"
    And previously saved weather data on existing entries is preserved

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
