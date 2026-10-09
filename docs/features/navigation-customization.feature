Feature: Bottom bar customization
  As someone who goes to the same two or three screens every day
  I want to put those screens in the bottom bar
  So that the app fits how I use it, and later updates don't undo that

  # Rules that keep customization safe across future layout changes:
  #
  # 1. Customization changes the bar only. It never hides or removes a
  #    screen. Every screen is always a tab in its section, so a pin can be
  #    removed without anything becoming unreachable.
  # 2. Sections and tabs have stable ids (dashboard, track, care, journal,
  #    track.symptoms, care.medications, ...). Labels can change; ids cannot.
  #    A retired id must have a replacement in a mapping kept in code.
  # 3. A bar the user hasn't changed follows the default and moves with it.
  #    A bar the user has changed is never rearranged by an update.
  # 4. What's stored is the user's choice (an ordered list of ids plus the
  #    layout version it was made on), not a copy of the default.
  #    "Use default" stores nothing.
  #
  # Settings are per device, like What's new state. Not in backups for now.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Where it lives
  # ---------------------------------------------------------------------------

  Scenario: Navigation settings are in Settings
    When I open Settings
    Then I see a "Navigation" section with "Bottom bar"
    And its subtitle reads "Default" until the bar is changed, then "Customized"

  Scenario: The bottom bar screen shows the current bar
    When I open Settings > Navigation > Bottom bar
    Then I see a preview of the bar as it looks now
    And below it an ordered list of what is in the bar
    And a list of screens that can be added

  # ---------------------------------------------------------------------------
  # Changing the bar
  # ---------------------------------------------------------------------------

  Scenario: Pin a screen to the bar
    Given the bar shows Dashboard, Track, Care and Journal
    When I add "Medications" to the bar
    Then the bar shows Dashboard, Track, Care, Journal and Medications
    And tapping "Medications" in the bar opens the Medications tab in Care
    And the Care section is not highlighted while Medications is open

  Scenario: One screen can be pinned
    Given "Medications" is pinned to the bar
    When I look at the screens that can be added
    Then each one says "Replaces Medications"
    And choosing one swaps it in for Medications

  Scenario: Sections stay in the bar
    When I open Settings > Navigation > Bottom bar
    Then Dashboard, Track, Care and Journal have no remove control
    And it explains "Sections stay in the bar so every screen can be reached"
    # Version 1 limit, on purpose. Removing a section needs a "More"
    # destination to keep its tabs reachable (rule 1). Revisit with the
    # accessibility work, which may need a shorter bar at large text sizes.

  Scenario: Dashboard is always first
    When I open Settings > Navigation > Bottom bar
    Then Dashboard is shown first with no move control

  Scenario: Reorder without dragging
    When I open Settings > Navigation > Bottom bar
    Then Track, Care, Journal and any pinned screen have "Move up" and "Move down" buttons
    And dragging also works for those who prefer it
    And after each move the new position is announced, e.g. "Medications, position 3 of 5"

  Scenario: Changes apply straight away and can be undone
    When I make any change to the bar
    Then the real bar updates at once
    And a message offers "Undo" for that change

  Scenario: Reset to the default
    Given the bar is customized
    When I tap "Use default"
    Then I am asked "Go back to the default bar?" with Cancel
    And confirming restores Dashboard, Track, Care and Journal
    And the subtitle reads "Default"

  Scenario: The guide's shortcut choice is a customization
    Given I chose "Keep Meds in the bar" in the Track and Care guide
    When I open Settings > Navigation > Bottom bar
    Then the bar shows Dashboard, Track, Care, Journal and Medications
    And the subtitle reads "Customized"

  # ---------------------------------------------------------------------------
  # Later updates
  # ---------------------------------------------------------------------------

  Scenario: A default bar follows a new default
    Given I never changed the bar
    When an update changes the default bar
    Then my bar becomes the new default

  Scenario: A customized bar is kept as it is
    Given I customized the bar
    When an update changes the default bar
    Then my bar stays exactly as I set it
    And the release guide says the default changed and mine was kept

  Scenario: A new screen in a later version lands in its section
    Given I customized the bar
    When an update adds a new tab to Track
    Then the new tab appears in Track
    And my bar is not changed
    And the new screen is listed under screens that can be added

  Scenario: A pinned screen that was merged follows its replacement
    Given "Activity" is pinned to my bar
    When an update merges Activity into another tab
    Then the pin points at the tab it was merged into
    And if that tab is already in the bar, the duplicate is removed

  Scenario: An id the app doesn't recognise is dropped safely
    Given the stored bar contains an id this version doesn't know
    When the app starts
    Then that item is left out of the bar
    And the rest of the bar keeps its order
    And if a section id is unknown, the default bar is used

  Scenario: Going back to an older version doesn't break the bar
    Given I customized the bar on a newer version
    When an older version of Health Flare opens the same data
    Then any item it doesn't know is left out
    And the stored choice is not rewritten until I change it

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: Bar labels stay readable with large text
    Given the system text size is set to 200%
    When the bar has five items
    Then every label is readable in full or the bar shows icons with labels read by screen readers
    And every item is at least 48 by 48 dp
    # Exact large-text behaviour is settled with the accessibility work.

  Scenario: The settings screen works with a screen reader
    Given a screen reader is active
    When I open Settings > Navigation > Bottom bar
    Then each item is read with its position and available actions
    And the preview is read as "Bottom bar: Dashboard, Track, Care, Journal"
