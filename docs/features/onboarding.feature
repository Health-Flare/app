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
    And the quick-log sheet opens automatically, ready for a first entry

  Scenario: Complete onboarding with all profile fields filled
    Given I am on the onboarding screen
    When I enter "Dad" in the name field
    And I enter "1952-04-10" in the date of birth field
    And I choose a photo from the library as the avatar
    And I tap the primary action button
    Then a profile named "Dad" is created with the date of birth and avatar saved
    And I am taken into the main app
    And the quick-log sheet opens automatically, ready for a first entry

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
  # Post-setup: first log
  #
  # There is no separate first-log prompt UI. The very first thing a new
  # profile sees on the dashboard is the same quick-log sheet the "+" FAB
  # opens for daily use — free text, classified live, save with one tap.
  # Using the app's actual everyday entry point from the first second avoids
  # teaching a second, throwaway interaction pattern that only ever appears
  # once and then never matches how logging actually works afterwards.
  # ---------------------------------------------------------------------------

  Scenario: The quick-log sheet opens automatically the first time a new profile reaches the dashboard
    Given I have just completed onboarding and created my first profile
    When I enter the main app
    Then the dashboard loads behind the quick-log sheet
    And the quick-log sheet is already open, ready for free text
    And it behaves exactly like tapping the "+" button on any other day

  Scenario: Dismissing or completing the automatic first log returns to the dashboard
    Given the quick-log sheet opened automatically for a new profile
    When I save an entry, or dismiss the sheet without saving
    Then I am taken to (or remain on) the dashboard
    And the sheet does not open automatically again for this profile

  Scenario: The automatic first log only appears once per profile
    Given the automatic first log was already shown for profile "Sarah"
    When I close and reopen the app
    Then the quick-log sheet does not open automatically
    And I am taken directly to the dashboard for "Sarah"

  Scenario: The automatic first log appears for each new profile
    Given profile "Sarah" already exists and has already seen her automatic first log
    When I create a new profile "Dad"
    Then the quick-log sheet opens automatically once for "Dad"
    But the full onboarding screen is not shown again

  # ---------------------------------------------------------------------------
  # Post-setup: weather tracking opt-in
  #
  # Offered the first time a profile is about to log something — whether
  # that's the automatic first log above or any later manual "+" tap — not
  # as a blocking modal shown before the user has seen the app at all.
  # ---------------------------------------------------------------------------

  Scenario: Weather tracking opt-in is offered the first time a profile is about to log something
    Given I have just completed onboarding and created my first profile
    When the quick-log sheet is about to open for the first time — automatically or via the "+" button
    Then I am first shown an optional prompt to enable weather tracking
    And the prompt explains that temperature, humidity, and barometric pressure can correlate with chronic illness symptoms
    And the prompt is framed as a data point worth tracking, not a privacy concern

  Scenario: Enabling weather tracking grants location permission and activates the feature
    Given the weather tracking prompt is visible
    When I tap "Enable weather tracking"
    Then the OS location permission dialog is shown
    When I grant location permission
    Then weather tracking is enabled for this profile
    And the quick-log sheet opens

  Scenario: Declining weather tracking still opens the quick-log sheet, without asking again
    Given the weather tracking prompt is visible
    When I tap "No thanks"
    Then weather tracking is disabled for this profile
    And the quick-log sheet opens
    And I am not asked about weather tracking again for this profile

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
