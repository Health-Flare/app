Feature: Your layout: features in use and the bottom bar
  As someone who tracks some things and not others
  I want to turn off what I don't use and put what I do use in the bottom bar
  So that the app fits how I manage my health, and updates don't undo that

  # UNVERIFIED (TODO): this whole file, scenarios and the notes in it, was
  # written by an agent and hasn't been checked by a person. Each scenario
  # is tagged @unverified. Read each one, fix it or agree it, then delete
  # its tag; delete this note when none are left. Tracked on #135.
  # List them all: bash scripts/unverified_specs.sh

  # Two settings, one idea: the app should fit the person.
  #
  # - Features in use (per profile): turn off a whole kind of tracking.
  #   Its tab, quick log type and dashboard card go away. Its data does not.
  # - Bottom bar (per device): choose what goes in the bar and in what order.
  #
  # "Keep the old layout" from the Track and Care guide is a bar preset,
  # not a separate mode. There is one navigation system to maintain.
  #
  # Rules that keep this safe across future layout changes:
  #
  # 1. Nothing is ever unreachable by accident. A turned-off feature is one
  #    switch away in Settings. A section left out of the bar is in "More".
  # 2. Sections, tabs and features have stable ids (track, care.medications,
  #    meals, ...). Labels can change; ids cannot. A retired id must have a
  #    replacement in a mapping kept in code, with a test.
  # 3. A bar the user hasn't changed follows the default and moves with it.
  #    A bar the user has changed is never rearranged by an update.
  # 4. What's stored is the user's choice (ordered ids plus the layout
  #    version it was made on), never a copy of the default. "Use default"
  #    stores nothing.
  # 5. Turning a feature off never deletes, hides from reports, or changes
  #    logged data. It changes what the app offers, not what it keeps.
  # 6. Layout and features in use are part of backups.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Where it lives
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: Layout settings are in Settings
    When I open Settings
    Then I see a "Your layout" section with "Features in use" and "Bottom bar"
    And "Bottom bar" reads "Default" until the bar is changed, then "Customized"

  # ---------------------------------------------------------------------------
  # Features in use (per profile)
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: Features in use lists what can be turned off
    When I open Settings > Your layout > Features in use
    Then I see a switch for each of these, all on by default:
      | Feature      | Section |
      | Vitals       | Track   |
      | Meals        | Track   |
      | Sleep        | Track   |
      | Activity     | Track   |
      | Medications  | Care    |
      | Appointments | Care    |
      | Flares       | Care    |
      | Journal      | Journal |
      | Check-ins    | Journal |
    And Symptoms and Conditions are listed as always on
    And the screen says these switches apply to "Sarah"

  @unverified
  Scenario: Turning a feature off removes it from everyday use
    When I turn off "Meals" for "Sarah"
    Then the Meals tab is not shown in Track
    And Meals is not offered in the Quick Log type chips
    And no Meals card or prompt is shown on the dashboard
    And "Meals" is not listed when adding to the bottom bar

  @unverified
  Scenario: Turning a feature off keeps its data
    Given "Sarah" has 40 meals logged
    When I turn off "Meals" for "Sarah"
    Then I am told "Sarah's 40 meals are kept. Turn Meals back on any time to see them."
    And no meal is deleted or changed
    And reports and exports still offer Meals while "Sarah" has meal data

  @unverified
  Scenario: Turning a feature back on brings everything back
    Given "Meals" is off for "Sarah" and she has 40 meals logged
    When I turn "Meals" back on
    Then the Meals tab shows all 40 meals

  @unverified
  Scenario: Quick Log text about a turned-off feature isn't lost
    Given "Meals" is off for "Sarah"
    When I quick-log "Had toast and eggs"
    Then the entry saves as a journal note with the text as typed
    And a line under the sheet reads "Meals is turned off for Sarah. Turn it on"

  @unverified
  Scenario: Features in use is per profile
    Given profiles "Sarah" and "Dad" exist
    When I turn off "Meals" for "Dad"
    Then the Meals tab is still shown when "Sarah" is active
    And it is hidden when "Dad" is active

  @unverified
  Scenario: A section with every tab turned off leaves the bar
    Given Journal and Check-ins are both off for "Sarah"
    When "Sarah" is active
    Then Journal is not shown in the bottom bar or in "More"
    And Settings > Your layout > Features in use is where it comes back

  @unverified
  Scenario: A section with one tab left shows no tab row
    Given only Medications is on in Care for "Sarah"
    When I tap "Care"
    Then the Medications list opens with no tab row above it

  @unverified
  Scenario: Onboarding never asks this up front
    When a new profile is created
    Then every feature is on
    And Features in use is not part of onboarding
    # Asking someone to predict what they'll track before they've used the
    # app leads to turning off things they later need.

  # ---------------------------------------------------------------------------
  # Bottom bar (per device)
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: The bottom bar screen shows the current bar
    When I open Settings > Your layout > Bottom bar
    Then I see a preview of the bar as it looks now
    And below it an ordered list of what is in the bar
    And a list of sections and screens that can be added

  @unverified
  Scenario: The bar holds three to five items
    When I edit the bottom bar
    Then I can't remove an item when three are left
    And I can't add an item when five are in the bar
    And each limit is explained in a line of text, not a disabled control alone

  @unverified
  Scenario: Dashboard is always first
    When I open Settings > Your layout > Bottom bar
    Then Dashboard is shown first with no remove or move control

  @unverified
  Scenario: Pin a screen to the bar
    Given the bar shows Dashboard, Track, Care and Journal
    When I add "Medications" to the bar
    Then the bar shows Dashboard, Track, Care, Journal and Medications
    And tapping "Medications" opens the Medications tab in Care
    And Care is not highlighted while Medications is open

  @unverified
  Scenario: A section left out of the bar goes into More
    Given the bar shows Dashboard, Track, Care and Journal
    When I remove "Journal" from the bar
    Then the bar shows Dashboard, Track, Care and More
    And More lists Journal with its tabs
    And More counts toward the five-item limit

  @unverified
  Scenario: More only appears when it has something in it
    Given every section with a feature on is in the bar
    Then no More item is shown

  @unverified
  Scenario: Reorder without dragging
    When I open Settings > Your layout > Bottom bar
    Then each item except Dashboard and More has "Move up" and "Move down" buttons
    And dragging also works
    And after each move the new position is announced, e.g. "Medications, position 3 of 5"

  @unverified
  Scenario: Changes apply straight away and can be undone
    When I make any change to the bar
    Then the real bar updates at once
    And a message offers "Undo" for that change

  @unverified
  Scenario: Reset to the default
    Given the bar is customized
    When I tap "Use default"
    Then I am asked "Go back to the default bar?" with Cancel
    And confirming restores Dashboard, Track, Care and Journal
    And "Bottom bar" reads "Default"

  @unverified
  Scenario: The bar can be set up close to the old one
    When I choose the "Like before" preset
    Then the bar shows Dashboard, Track, Medications, Meals and More
    And More lists Care and Journal
    And a note says "The old bar had six items. Sleep is now in Track."
    # The old bar can't come back exactly: six items doesn't fit at large
    # text sizes, and it still left four screens unreachable.

  @unverified
  Scenario: The guide's "Keep it like before" choice uses the preset
    Given I chose "Keep it like before" in the Track and Care guide
    When I open Settings > Your layout > Bottom bar
    Then the bar matches the "Like before" preset
    And "Bottom bar" reads "Customized"

  @unverified
  Scenario: Pinned screens for a turned-off feature drop out quietly
    Given "Meals" is pinned to the bar
    When "Dad", who has Meals off, becomes the active profile
    Then the Meals item is not shown while "Dad" is active
    And it is back when "Sarah" is active
    And the stored bar is not changed

  # ---------------------------------------------------------------------------
  # Later updates
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: A default bar follows a new default
    Given I never changed the bar
    When an update changes the default bar
    Then my bar becomes the new default

  @unverified
  Scenario: A customized bar is kept as it is
    Given I customized the bar
    When an update changes the default bar
    Then my bar stays exactly as I set it
    And the release guide says the default changed and mine was kept

  @unverified
  Scenario: A new tab in a later version lands in its section, switched on
    Given I customized the bar and turned off some features
    When an update adds a new tab to Track
    Then the new tab appears in Track, switched on
    And my bar and my other feature switches are not changed
    And the release guide says where the new tab is and how to turn it off

  @unverified
  Scenario: A pinned screen that was merged follows its replacement
    Given "Activity" is pinned to my bar
    When an update merges Activity into another tab
    Then the pin points at the tab it was merged into
    And if that tab is already in the bar, the duplicate is removed
    And the release guide names the old and the new screen

  @unverified
  Scenario: A turned-off feature that was merged keeps the user's choice
    Given "Activity" is off for "Sarah"
    When an update merges Activity into another tab that is on
    Then the merged tab stays on
    And the release guide tells "Sarah" that Activity data is now in that tab
    # Turning off one part of a merged feature is not the same as turning
    # off the whole thing. Tell, don't guess.

  @unverified
  Scenario: An id the app doesn't recognise is skipped safely
    Given the stored bar contains an id this version doesn't know
    When the app starts
    Then that item is left out of the bar
    And the rest of the bar keeps its order
    And if fewer than three items remain, the default bar is used
    And the stored choice is not rewritten until I change it

  # ---------------------------------------------------------------------------
  # Backups
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: Replace everything restores layout and features in use
    Given a backup was made with a customized bar and Meals off for "Sarah"
    When I restore it with "Replace everything"
    Then the bar is as it was in the backup
    And Meals is off for "Sarah"

  @unverified
  Scenario: Add missing data keeps this device's bar if it was customized
    Given this device has a customized bar
    And the backup has a different customized bar
    When I import with "Add missing data"
    Then this device's bar is kept

  @unverified
  Scenario: Add missing data takes the backup's bar onto a default device
    Given this device has never changed the bar
    And the backup has a customized bar
    When I import with "Add missing data"
    Then the bar becomes the backup's bar
    And a message says "Bottom bar restored from the backup. Change it in Settings > Your layout."

  @unverified
  Scenario: Features in use travel with their profile
    Given the backup has profile "Dad" with Meals off
    And this device has no profile "Dad"
    When I import with "Add missing data"
    Then "Dad" is added with Meals off

  @unverified
  Scenario: A profile that exists on both keeps this device's switches
    Given "Sarah" exists on this device with Meals on
    And the backup has "Sarah" with Meals off
    When I import with "Add missing data"
    Then Meals stays on for "Sarah"

  @unverified
  Scenario: Choose what to import lists layout as its own item
    When I import with "Choose what to import"
    Then "Bottom bar and layout" is listed with the data categories
    And it is unticked by default when this device's bar is customized

  @unverified
  Scenario: A backup from a newer version with unknown ids still imports
    Given the backup's bar contains ids this version doesn't know
    When I restore it
    Then the bar follows the "id the app doesn't recognise" rule
    And the import does not fail

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  @unverified
  Scenario: Bar labels stay readable with large text
    Given the system text size is set to 200%
    When the bar has five items
    Then every label is readable in full or the bar shows icons with labels read by screen readers
    And every item is at least 48 by 48 dp
    # Exact large-text behaviour is settled with the accessibility work.

  @unverified
  Scenario: The settings screens work with a screen reader
    Given a screen reader is active
    When I open Settings > Your layout > Bottom bar
    Then each item is read with its position and available actions
    And the preview is read as "Bottom bar: Dashboard, Track, Care, Journal"
    And each feature switch in Features in use is read with its on or off state and the profile name
