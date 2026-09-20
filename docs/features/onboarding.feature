Feature: Onboarding
  As a first-time user
  I want a short, guided, skippable introduction to Health Flare
  So that I understand what the app does, trust it with my health data,
  set up a profile, and start logging without a jarring change in UX
  partway through

  # ---------------------------------------------------------------------------
  # Trigger
  # ---------------------------------------------------------------------------

  Scenario: The guided flow is shown on first launch when no profiles exist
    Given the app has been installed and launched for the first time
    And no profiles exist on this device
    When the app loads
    Then I am shown the "Welcome" step of the onboarding flow
    And I am not shown any log screens, dashboard, or navigation

  Scenario: Onboarding is not shown if a profile already exists
    Given at least one profile exists on this device
    When the app launches
    Then I am taken directly to the dashboard for the last active profile

  # ---------------------------------------------------------------------------
  # Guided flow shell — progress, navigation, skip
  #
  # One shared header component (dots + optional Back + optional Skip) is
  # used everywhere a guided, multi-step flow appears in the app: the
  # onboarding flow below, and the shorter post-setup mini-flow further
  # down. No screen introduces its own, different progress UI.
  # ---------------------------------------------------------------------------

  Scenario: The progress indicator is minimal by design
    Given I am on any step of a guided flow
    Then I see a small row of dots, one per step, with no numbers, labels, or percentage text
    And the current step's dot is visually distinct from the others
    And the indicator occupies no more than a single line near the top of the screen

  Scenario: "Next" advances to the following step
    Given I am on the "Welcome" step
    When I tap "Next"
    Then I am shown the "What you can track" step

  Scenario: "Back" returns to the previous step without losing progress
    Given I am on the "Your privacy" step
    When I tap "Back"
    Then I am shown the "What you can track" step
    And any information I already entered is preserved

  Scenario: Skip advances straight to the mandatory "Create profile" step
    Given I am on "Welcome", "What you can track", or "Your privacy"
    When I tap "Skip"
    Then I am taken directly to "Create profile"

  Scenario: There is no way to bypass profile creation entirely
    Given I am on "Create profile"
    Then no "Skip" control is shown on this step
    And no navigation forward is possible until a profile with a name is saved

  Scenario: Screen readers hear more detail than the dots visually show
    Given a screen reader is active
    When I land on any step of a guided flow
    Then the screen reader announces the step's name and position, e.g. "Step 2 of 4, What you can track"
    And the on-screen indicator itself still shows only dots

  # ---------------------------------------------------------------------------
  # Step: Welcome
  # ---------------------------------------------------------------------------

  Scenario: Welcome step introduces the app briefly
    Given I am on the "Welcome" step
    Then I see the app name "Health Flare"
    And I see a short welcome headline communicating the app's purpose
    And I see a brief supporting statement that positions the app as a health companion, not a medical device
    And I see the plain-language medical disclaimer
    And the tone is warm and encouraging, not clinical

  Scenario: Medical disclaimer is present but not alarming
    Given I am on the "Welcome" step
    Then I can see a plain-language statement clarifying that Health Flare is not a medical device
    And the statement does not use fear language or warnings

  # ---------------------------------------------------------------------------
  # Step: What you can track (feature highlights)
  # ---------------------------------------------------------------------------

  Scenario: Feature highlights are shown as icon-led chips
    Given I am on the "What you can track" step
    Then I see a chip for each of: Symptoms, Vitals, Medications, Meals, Journal, and Conditions
    And each chip displays a distinct icon alongside its label
    And the copy emphasises how flexible and simple logging is day-to-day

  Scenario: Feature highlight icons render reliably regardless of platform
    Given I am on the "What you can track" step
    Then each chip's icon is a rendered vector icon, not a text or emoji character
    And no chip is shown with a missing or blank icon glyph on iOS or Android

  Scenario: Feature highlights are informational only, not selectable
    Given I am on the "What you can track" step
    When I tap a feature chip
    Then nothing is selected or toggled

  # ---------------------------------------------------------------------------
  # Step: Your privacy
  # ---------------------------------------------------------------------------

  Scenario: Primary privacy promise is prominently displayed
    Given I am on the "Your privacy" step
    Then I see a prominent headline stating that all data stays on this device
    And I see 3 to 4 concise supporting privacy statements
    And one statement confirms no account or login is required
    And one statement confirms no data is uploaded to any cloud or server
    And one statement confirms data only leaves the device when the user explicitly exports or shares it

  Scenario: "Learn more" expands a plain-English privacy detail section
    Given I am on the "Your privacy" step
    When I tap "Learn more"
    Then an expanded privacy explanation is shown inline without leaving the step
    And the expanded content explains in plain English exactly where data is stored, what is collected, and what is never collected

  Scenario: "Learn more" section can be collapsed again
    Given I have expanded the "Your privacy" step's detail section
    When I tap to collapse it
    Then the expanded content is hidden

  Scenario: Privacy section uses specific, verifiable language
    Given I am on the "Your privacy" step
    Then no privacy statement uses vague language such as "we value your privacy" or "we care about your data"
    And every privacy claim is specific and describes a concrete behaviour of the app

  # ---------------------------------------------------------------------------
  # Step: Create profile (mandatory)
  # ---------------------------------------------------------------------------

  Scenario: Only a name is required to complete this step
    Given I am on the "Create profile" step
    Then I see a required name field
    And I see an optional date of birth field, avatar field, and condition selector
    And the primary action is disabled until a name is entered

  Scenario: Completing profile creation advances into the app
    Given I am on the "Create profile" step
    When I enter "Sarah" in the name field
    And I tap "Create profile and get started"
    Then a profile named "Sarah" is created and made active
    And I am taken into the main app
    And the post-setup mini-flow begins

  Scenario: Complete onboarding with all profile fields filled
    Given I am on the "Create profile" step
    When I enter "Dad" in the name field
    And I enter "1952-04-10" in the date of birth field
    And I choose a photo from the library as the avatar
    And I tap "Create profile and get started"
    Then a profile named "Dad" is created with the date of birth and avatar saved

  Scenario: Cannot complete profile creation without entering a name
    Given I am on the "Create profile" step
    When I leave the name field empty
    And I tap "Create profile and get started"
    Then I see a validation message indicating a name is required
    And no profile is created

  Scenario: Reaching "Create profile" via Skip still requires a name before proceeding
    Given I skipped the "Welcome", "What you can track", and "Your privacy" steps
    When I am on "Create profile" and leave the name field empty
    Then the primary action button remains disabled

  Scenario: A name containing only whitespace is rejected
    Given I am on the "Create profile" step
    When I enter "   " in the name field
    Then the primary action button remains disabled
    And no profile is created

  Scenario: Photo library access denied shows a helpful inline message
    Given I am on the "Create profile" step
    When I tap the avatar field
    And I deny photo library permission
    Then a brief message explains that photo access was not granted
    And the profile creation form remains usable without a photo

  # ---------------------------------------------------------------------------
  # Post-setup mini-flow: weather opt-in, then log your first entry
  #
  # Shown once per profile, immediately after that profile's dashboard first
  # loads. Reuses the same guided-flow shell as onboarding above — the same
  # header, dots, and button styling — rather than a modal bottom sheet, so
  # a one-time prompt never feels like a different screen bolted onto the
  # side of the app.
  # ---------------------------------------------------------------------------

  Scenario: The mini-flow shows only the steps still pending for this profile
    Given a profile has just been created
    When its dashboard loads for the first time
    Then I am shown the "Enable weather tracking" step followed by "Log your first entry"
    And each uses the same guided-flow header, dots, and button styling as the main onboarding steps

  Scenario: Weather tracking is offered before the first-log prompt
    Given I am on the "Enable weather tracking" step
    Then I see an explanation of why weather correlates with chronic illness symptoms
    And I see "Enable weather tracking" and "Not now" as equally weighted actions

  Scenario: Enabling weather tracking requests location permission
    Given I am on the "Enable weather tracking" step
    When I tap "Enable weather tracking"
    Then the OS location permission dialog is shown
    When I grant location permission
    Then weather tracking is enabled for this profile
    And I am shown "Log your first entry"

  Scenario: Declining weather tracking advances without asking again
    Given I am on the "Enable weather tracking" step
    When I tap "Not now" or "Skip"
    Then weather tracking is disabled for this profile
    And I am shown "Log your first entry"
    And I am not asked about weather tracking again for this profile

  Scenario: Denying location permission after enabling disables the feature gracefully
    Given I am on the "Enable weather tracking" step
    When I tap "Enable weather tracking" and then deny the OS location permission
    Then weather tracking is disabled for this profile
    And I see a brief message explaining that location access is needed
    And I can enable it later from profile settings

  Scenario: Weather tracking can be changed later from profile settings
    Given a profile declined weather tracking during the mini-flow
    When I open settings for that profile and enable weather tracking
    Then the OS location permission dialog is shown if not previously granted
    And weather tracking becomes active for that profile

  Scenario: Six entry options are offered as icon-led options
    Given I am on the "Log your first entry" step
    Then I see an option for each of: A condition, A symptom, A vital, A meal, A medication, A journal entry
    And "A condition" is displayed prominently as the first option
    And each option uses a rendered vector icon, matching the icon system used on "What you can track"
    And each option has a brief sub-label describing what it captures

  Scenario: Tapping "A condition" opens the illness screen and returns to this step
    Given I am on the "Log your first entry" step
    When I tap "A condition"
    Then the illness entry screen opens full-screen, on top of this step
    When I finish on the illness screen (with or without saving)
    Then I am returned to "Log your first entry"
    And the step's heading updates to invite a related first log

  Scenario: Tapping any other option opens its entry form and finishes the flow on save
    Given I am on the "Log your first entry" step
    When I tap "A symptom" (or vital, meal, medication, or journal entry)
    And I complete and save the entry
    Then I am taken to the dashboard
    And the saved entry is visible in my dashboard feed
    And the mini-flow does not appear again for this profile

  Scenario: This step can be dismissed to start using the app freely
    Given I am on the "Log your first entry" step
    When I tap "I'll explore on my own" or "Skip"
    Then I am taken to the dashboard
    And the mini-flow does not appear again for this profile

  Scenario: The mini-flow only appears once per profile
    Given a profile has already completed the weather and first-log steps
    When I close and reopen the app on that profile
    Then neither step is shown again
    And I am taken directly to that profile's dashboard

  Scenario: A caregiver adding a later profile only sees the mini-flow, not the full onboarding steps
    Given profile "Sarah" already exists and has completed onboarding
    When I create a new profile "Dad" from the profile manager
    Then "Welcome", "What you can track", "Your privacy", and "Create profile" are not shown again
    And the "Enable weather tracking" and "Log your first entry" steps are shown for "Dad" once his dashboard loads

  Scenario: Classification runs locally with no network call during the mini-flow
    Given I am on the "Log your first entry" step
    Then no text I type is transmitted off the device

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: Onboarding meets WCAG 2.1 AA colour contrast requirements
    Given I am on any step of a guided flow
    Then all text elements meet a minimum contrast ratio of 4.5:1 against their background
    And all large text elements meet a minimum contrast ratio of 3:1 against their background

  Scenario: All interactive elements are accessible via keyboard
    Given I am using a device with a hardware keyboard (desktop or web)
    When I navigate a guided flow using the Tab key
    Then "Back", "Skip", and the step's primary action all receive focus in a logical order
    And I can trigger any of them using the Enter or Space key

  Scenario: Guided flow screens are compatible with screen readers
    Given a screen reader is active
    When a guided flow step loads
    Then all text content is announced in a logical reading order
    And the name input field on "Create profile" has a descriptive accessible label
    And no information is conveyed by colour alone

  Scenario: Guided flow text is readable at increased system font sizes
    Given the device system font size is set to the largest accessible option
    When any step of a guided flow loads
    Then all text remains readable and does not overflow or overlap other elements
    And "Back", "Skip", and the step's primary action remain visible and usable
