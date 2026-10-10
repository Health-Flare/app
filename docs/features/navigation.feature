Feature: Navigation and General UX
  As a primary user
  I want clear, fast navigation and quick entry throughout the app
  So that logging health data is effortless and the app never feels confusing

  # UNVERIFIED (TODO): scenarios tagged @unverified were written by an agent
  # and haven't been checked by a person. Read each one, fix it or agree it,
  # then delete its tag. Tracked on #135. List them all:
  #   bash scripts/unverified_specs.sh

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active
    And "Sarah" has some existing health data

  # ---------------------------------------------------------------------------
  # Primary navigation
  # ---------------------------------------------------------------------------
  #
  # UNVERIFIED (TODO): this Layout v2 note is agent-written, not yet checked.
  # Layout v2 (Track and Care). The bar had six destinations and still left
  # appointments, activity, check-ins and flare history with no way in.
  # It now has four sections, and every list screen lives in exactly one
  # of them as a tab. Each section and tab has a stable id
  # (see navigation-customization.feature); labels can change, ids cannot.
  # Sections and tabs below are the defaults. People can turn features off
  # and change the bar in Settings > Your layout.
  #
  # Release rule: layout v2 ships only together with its release guide
  # (release-guides.feature) and Your layout
  # (navigation-customization.feature). Until all three are done it stays
  # behind a build flag, so the pieces can merge to main separately.

  @unverified
  Scenario: The primary navigation has four sections
    When the app is open with "Sarah" as the active profile
    Then the primary navigation contains the following destinations, in order:
      | Destination | Id        |
      | Dashboard   | dashboard |
      | Track       | track     |
      | Care        | care      |
      | Journal     | journal   |
    And Reports is opened from the Dashboard app bar, not the primary navigation

  @unverified
  Scenario Outline: Each section opens with its first tab selected
    When I tap "<Section>" in the primary navigation
    Then I see the "<Section>" screen for "Sarah"
    And it has these tabs, in order: <Tabs>
    And the "<First>" tab is selected

    Examples:
      | Section | Tabs                                          | First       |
      | Track   | Symptoms, Vitals, Meals, Sleep, Activity      | Symptoms    |
      | Care    | Medications, Appointments, Conditions, Flares | Medications |
      | Journal | Entries, Check-ins                            | Entries     |

  Scenario: Navigate to the Dashboard
    When I tap "Dashboard" in the primary navigation
    Then I am shown the dashboard for "Sarah"
    And the dashboard shows a recent summary of logged data

  @unverified
  Scenario: Every list screen can be reached in two taps or fewer
    Given I am on any screen in the primary navigation
    Then each of these screens is at most two taps away:
      | Screen               | Path                       |
      | Symptoms             | Track > Symptoms           |
      | Vitals               | Track > Vitals             |
      | Meals                | Track > Meals              |
      | Sleep                | Track > Sleep              |
      | Activity             | Track > Activity           |
      | Medications          | Care > Medications         |
      | Appointments         | Care > Appointments        |
      | Conditions           | Care > Conditions          |
      | Flare history        | Care > Flares              |
      | Journal entries      | Journal > Entries          |
      | Check-in history     | Journal > Check-ins        |
      | Reports              | Dashboard > Reports        |

  @unverified
  Scenario: The section remembers the last tab used
    Given I opened the "Appointments" tab in Care
    When I tap "Dashboard" in the primary navigation
    And I tap "Care" in the primary navigation
    Then the "Appointments" tab is selected

  @unverified
  Scenario: Old links still open the right screen
    Given a link or notification points at an old address such as "/medications" or "/sleep"
    When it is opened
    Then the matching tab is shown inside its section
    And the matching section is selected in the primary navigation

  @unverified
  Scenario: Section tabs stay usable with large text
    Given the system text size is set to 200%
    When I open any section
    Then every tab label is readable in full
    And the tabs scroll sideways instead of truncating or wrapping
    And each tab is at least 48 by 48 dp

  # ---------------------------------------------------------------------------
  # Section tabs
  # ---------------------------------------------------------------------------
  #
  # Schema note (pending): the Conditions tab surfaces UserConditionIsar fields
  # (status, recoveryDate, relapseDate, conditionHistory) that are not yet in
  # the schema. The tab structure can be built before those fields land, but
  # the recovery/relapse UI within the tab requires the schema version bump first.

  @unverified
  Scenario: Conditions tab is in Care
    Given I am on the Care screen
    When I tap the "Conditions" tab
    Then I see the list of conditions tracked for "Sarah"
    And I can manage diagnosis dates, recovery status, and condition links from this tab

  @unverified
  Scenario: Appointments tab lists upcoming and past appointments
    Given "Sarah" has one upcoming and one past appointment
    When I open Care and tap the "Appointments" tab
    Then I see an upcoming section and a past section
    And the add button opens the new appointment form

  @unverified
  Scenario: Appointments tab has an empty state
    Given "Sarah" has no appointments
    When I open Care and tap the "Appointments" tab
    Then I see a short message saying no appointments are recorded yet
    And a button to add an appointment

  @unverified
  Scenario: Switching tabs does not lose scroll position
    Given I have scrolled partway down the Symptoms tab on the Track screen
    When I tap the "Vitals" tab
    And I tap the "Symptoms" tab
    Then my scroll position on the Symptoms tab is preserved

  @unverified
  Scenario: Each log screen shows a helpful empty state when no data exists
    Given "Sarah" has no data logged
    When I open each tab in Track, Care and Journal
    Then each tab shows an empty state message guiding me to add its first entry

  # ---------------------------------------------------------------------------
  # Quick entry
  # ---------------------------------------------------------------------------

  Scenario: Any health entry can be started in 2 taps from the dashboard
    Given I am on the Dashboard screen
    When I tap the log entry button
    Then the quick log sheet opens
    And I can begin typing immediately
    And tapping Save completes the entry: 2 taps total from the dashboard

  @unverified
  Scenario Outline: A section's add button follows the selected tab
    Given I am on the <Section> screen
    And the "<Tab>" tab is selected
    When I tap the add button
    Then <Form> opens
    And the quick log sheet stays closed

    Examples:
      | Section | Tab          | Form                      |
      | Track   | Symptoms     | the symptom form          |
      | Track   | Vitals       | the vital form            |
      | Track   | Meals        | the meal form             |
      | Track   | Sleep        | the sleep form            |
      | Track   | Activity     | the activity form         |
      | Care    | Medications  | the medication form       |
      | Care    | Appointments | the new appointment form  |
      | Care    | Conditions   | the condition screen      |
      | Care    | Flares       | the new flare form        |
      | Journal | Entries      | the journal composer      |
      | Journal | Check-ins    | today's check-in          |

  # ---------------------------------------------------------------------------
  # Profile switcher
  # ---------------------------------------------------------------------------

  Scenario: Active profile name is always visible
    When I navigate to any screen in the app
    Then the active profile name "Sarah" is visible in a persistent location on screen

  Scenario: Profile switcher is accessible from any screen
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    When I am on any main screen
    Then I can open the profile switcher
    And I can see all available profiles listed

  Scenario: Switching profile from any screen updates all content
    Given the following profiles exist:
      | Name  |
      | Sarah |
      | Dad   |
    And "Sarah" is the active profile
    When I open the profile switcher from the Meals screen
    And I select "Dad"
    Then "Dad" becomes the active profile
    And the Meals screen now shows "Dad"'s meal data
    And the persistent profile indicator shows "Dad"

  # ---------------------------------------------------------------------------
  # First launch / onboarding empty states
  # ---------------------------------------------------------------------------

  Scenario: First launch shows onboarding instead of empty data screens
    Given the app has just been installed
    When I open the app for the first time
    Then I am shown a welcome or onboarding screen
    And I am prompted to create my first profile
    And I am not shown any data lists or logs until a profile is created

  Scenario: Dashboard empty state guides the user
    Given a newly created profile "NewUser" is active with no logged data
    When I navigate to the Dashboard
    Then I see an empty state that clearly communicates that no data has been logged yet
    And I am shown clear calls-to-action to log a symptom, vital, meal, or medication

  # ---------------------------------------------------------------------------
  # Data privacy
  # ---------------------------------------------------------------------------

  Scenario: No data is transmitted without an explicit user action
    Given the app is running normally
    When the user has not triggered any export or share action
    Then no health data is sent over the network
    And all data remains on the device

  Scenario: Exporting data requires an explicit user action
    When I generate a report and export it as PDF
    Then I must explicitly tap a share or save button before any file leaves the app
    And I am shown the OS share sheet to choose where the file goes
