Feature: What's new
  As someone who uses Health Flare most days
  I want to hear about changes in a way that never gets between me and logging
  So that a familiar screen never looks broken, I can learn the new thing
  when I have the energy, and I can always find the explanation again

  # Builds on #75. Highlights: 2 to 4 plain-language notes per release,
  # bundled with the app. Nothing is fetched and nothing reports whether a
  # note was read.
  #
  # Release guides (a stepped walkthrough for changes that move something
  # people already use, #145) build on this. Their scenarios are on the
  # feature/navigation-track-care branch (#135) until that work is ready.
  # The one guide rule here, "Turning off highlights turns off guide cards
  # too", is the setting's promise and ships with it.
  #
  # Release rule: a change that moves an existing screen, control or
  # default ships with a guide, or it doesn't ship. See
  # docs/feature-releases.md.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # When anything is shown
  # ---------------------------------------------------------------------------

  Scenario: A fresh install sees no release card
    Given Health Flare has just been installed
    When onboarding finishes and the dashboard opens
    Then no "What's new" card is shown
    And no release guide is offered

  Scenario: An update with highlights shows one quiet card
    Given Health Flare was updated to a version with highlights
    When I open the dashboard
    Then one card at the top of the dashboard says what's new in that version
    And it offers "See what's new"
    And it has a close button labelled "Dismiss" for screen readers
    And nothing covers the screen, and there is no badge or unread count

  Scenario: A bug-fix-only update shows nothing
    Given Health Flare was updated to a version with no highlights
    When I open the dashboard
    Then no "What's new" card is shown
    And the version is still listed in What's new history

  Scenario: The card never sits on top of logging
    Given Health Flare was updated to a version with highlights
    When I open the app from a reminder or link straight into a log form
    Then the log form opens with nothing over it
    And the card waits on the dashboard

  Scenario: Updating past several versions shows one card
    Given Health Flare was updated from 1.9.1 straight to 1.12.0
    And 1.10.0 and 1.12.0 both have highlights
    When I open the dashboard
    Then one card is shown covering both versions
    And "See what's new" opens the history at 1.12.0 with 1.10.0 below it

  Scenario: The first release with What's new tells existing users about it
    Given I have used Health Flare since before What's new existed
    And Health Flare was updated to the first version that has What's new
    When I open the dashboard
    Then one card is shown for that version's highlights
    And earlier versions are listed in What's new history with no card for them

  Scenario: Opening What's new from the card counts as seen
    Given a release card is showing
    When I tap "See what's new"
    Then What's new opens at the newest release
    And when I come back to the dashboard the card is gone for good

  # ---------------------------------------------------------------------------
  # Card behaviour
  # ---------------------------------------------------------------------------

  Scenario: Dismissing is final for that release
    Given a release card is showing
    When I tap "Dismiss" or swipe the card away
    Then the card is gone with no "Are you sure?"
    And it does not come back for that release
    And no "you missed this" follow-up is ever shown

  Scenario: An ignored card goes away on its own
    Given a release card has been shown on 5 app opens
    And I have neither opened nor dismissed it
    When I open the app again
    Then the card is no longer shown
    And the release stays in What's new history

  Scenario: The card holds off during an active flare
    Given "Sarah" has an active flare
    And Health Flare was updated to a version with highlights or a guide
    When I open the dashboard
    Then no release card is shown
    And it appears the first time I open the dashboard after the flare ends
    And the 5-open limit only counts opens where it was shown

  # ---------------------------------------------------------------------------
  # Finding it later
  # ---------------------------------------------------------------------------

  Scenario: What's new history lives in Settings
    When I open Settings
    Then the About section has "What's new"
    And it lists every release newest first, with version and date
    And each release shows its highlights first and "All changes" collapsed

  Scenario: Highlights can be turned off
    When I turn off "Show update highlights" in Settings
    Then no release card is shown on the dashboard after later updates
    And What's new history still works

  Scenario: Turning highlights back on doesn't bring back missed cards
    Given "Show update highlights" was off while Health Flare updated to 1.11.0
    When I turn "Show update highlights" back on
    Then no card is shown for 1.11.0
    And the next update with highlights shows its card

  Scenario: Turning off highlights turns off guide cards too
    Given "Show update highlights" is off
    When Health Flare is updated to a version with a guide
    Then no card is shown
    And the guide is in Settings > What's new
    # Off means off.

  Scenario: The setting says what turning it off means
    When I turn off "Show update highlights"
    Then I see "You won't be told when screens move. Guides stay in What's new."
    And there is no "Are you sure?"

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: The card works with a screen reader
    Given a screen reader is active
    When the release card appears
    Then it is announced once, politely, without moving focus

  Scenario: Reduce Motion turns off the card's slide
    Given the system Reduce Motion setting is on
    When I swipe the release card away
    Then it is removed without sliding or shrinking

  # ---------------------------------------------------------------------------
  # Offline and storage
  # ---------------------------------------------------------------------------

  Scenario: Release content is bundled
    When What's new is shown
    Then no network request is made
    And nothing is recorded about whether it was read beyond the settings on this device

  Scenario: Going back to an older version shows nothing
    Given I have seen the card for 1.12.0
    When Health Flare 1.11.0 is installed over it
    Then no release card is shown
    And What's new history lists nothing newer than 1.11.0

  Scenario: Release state is per device, not per profile
    Given profiles "Sarah" and "Dad" exist
    When I dismiss the release card while "Sarah" is active
    And I switch to "Dad"
    Then the release card is not shown for "Dad"

  Scenario: "Show update highlights" is part of backups
    Given a backup was made with "Show update highlights" off
    When I restore it with "Replace everything"
    Then "Show update highlights" is off

  Scenario: Restoring onto a newer version still shows that version's card
    Given a backup was made on 1.10.0 after its card was dismissed
    When I restore it onto 1.12.0, which has highlights
    Then the 1.12.0 card is shown
    And the 1.10.0 card is not shown again
