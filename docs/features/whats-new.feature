Feature: What's new and release guides
  As someone who uses Health Flare most days
  I want to hear about changes in a way that never gets between me and logging
  So that a familiar screen never looks broken, I can learn the new thing
  when I have the energy, and I can always find the explanation again

  # Builds on #75. Two kinds of release content, one place to find them:
  #
  # - Highlights: 2 to 4 plain-language notes per release (#75).
  # - Guides: a short stepped walkthrough, written only for changes that
  #   move something people already use (the Track and Care layout first,
  #   accessibility settings next). A guide is attached to a release entry.
  #
  # Both are bundled with the app. Nothing is fetched and nothing reports
  # whether a note or guide was read.
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
  # Updates that move things: the guide card
  # ---------------------------------------------------------------------------

  Scenario: An update with a guide says plainly what moved
    Given Health Flare was updated to the version that introduced Track and Care
    When I open the dashboard
    Then the card reads "The bottom bar has changed"
    And it says "Meds, Meals and Sleep have moved. Nothing has been removed."
    And it offers "Show me" and "Not now"

  Scenario: The guide card comes back once if put off
    Given the guide card is showing
    When I tap "Not now"
    Then the card is hidden for the rest of this session
    When I next open the app on a later day
    Then the card is shown one more time, with "Dismiss" instead of "Not now"

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
  # The guide itself
  # ---------------------------------------------------------------------------

  Scenario: "Show me" opens the guide
    Given the Track and Care guide card is showing
    When I tap "Show me"
    Then the guide opens with the same dots, Back and Skip as onboarding
    And it has these steps, in order:
      | Step                     |
      | Four sections now        |
      | Where things moved       |
      | Keep it or change it     |
      | Finding this again       |

  Scenario: The guide shows the new bar next to the old one
    Given I am on the "Four sections now" step
    Then I see the old bar and the new bar drawn one above the other
    And each new section has a one-line description:
      | Section   | Description                                  |
      | Dashboard | Today, and what's coming up                  |
      | Track     | Symptoms, vitals, meals, sleep and activity  |
      | Care      | Medications, appointments, conditions, flares |
      | Journal   | Journal entries and daily check-ins          |

  Scenario: Every moved screen is listed with where it went
    Given I am on the "Where things moved" step
    Then I see each old destination and where it is now:
      | Was      | Now                 |
      | Tracking | Track               |
      | Meds     | Care > Medications  |
      | Meals    | Track > Meals       |
      | Sleep    | Track > Sleep       |
      | Journal  | Journal > Entries   |
    And I see the screens that now have a place of their own:
      | Screen       | Now                  |
      | Appointments | Care > Appointments  |
      | Activity     | Track > Activity     |
      | Check-ins    | Journal > Check-ins  |
      | Flares       | Care > Flares        |

  Scenario: "Show me" on a row goes to that screen
    Given I am on the "Where things moved" step
    When I tap "Show me" next to "Meds"
    Then the guide closes
    And the Medications tab in Care opens
    And the Care section in the bottom bar is outlined for two pulses

  Scenario: The guide offers to keep it like before
    Given I am on the "Keep it or change it" step
    Then I can choose one of:
      | Choice              | What happens                                                        |
      | Use the new layout  | The default bar is kept                                             |
      | Keep it like before | The "Like before" bar preset is applied (navigation-customization.feature) |
      | Set it up myself    | Settings > Your layout opens after the guide                        |
    And "Use the new layout" is selected by default
    And the step says features I don't use can be turned off in Settings > Your layout
    And it says all of this can be changed any time

  Scenario: The last step says where to find the guide again
    Given I am on the "Finding this again" step
    Then it says the guide is in Settings > What's new
    And the only button is "Done"

  Scenario: Skipping or leaving the guide counts as seen
    Given the guide is open
    When I tap "Skip", press Back on the first step, or leave the app
    Then the guide card does not come back
    And no layout change is made unless I chose one on "Keep it or change it"

  # ---------------------------------------------------------------------------
  # Finding it later
  # ---------------------------------------------------------------------------

  Scenario: What's new history lives in Settings
    When I open Settings
    Then the About section has "What's new"
    And it lists every release newest first, with version and date
    And each release shows its highlights first and "All changes" collapsed

  Scenario: A guide can be replayed from its release
    Given I dismissed the Track and Care guide card
    When I open Settings > What's new
    Then the release that introduced Track and Care shows "Replay guide"
    And tapping it opens the guide at the first step

  Scenario: Highlights can be turned off
    When I turn off "Show update highlights" in Settings
    Then no release card is shown on the dashboard after later updates
    And What's new history and "Replay guide" still work

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
  # Customized layouts
  # ---------------------------------------------------------------------------

  Scenario: Someone with a custom bar is told their bar was kept
    Given I customized the bottom bar in an earlier version
    And Health Flare was updated to a version that changes the default bar
    When I open the dashboard
    Then the guide card reads "The default bottom bar has changed. Yours has been kept."
    And "Show me" opens a guide that shows the new default
    And its "Keep it or change it" step defaults to "Keep the current bar"

  Scenario: A pinned screen that moved is explained, not silently swapped
    Given I pinned a screen that a later version merged into another screen
    When Health Flare is updated to that version
    Then the pin now points at the screen it was merged into
    And the guide card names the old and the new screen

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: The card and guide work with a screen reader
    Given a screen reader is active
    When the release card appears
    Then it is announced once, politely, without moving focus
    And in the guide each step is announced as "Step 2 of 4, Where things moved"
    And the old and new bar drawings have text descriptions

  Scenario: Reduce Motion turns off pulses and slides
    Given the system Reduce Motion setting is on
    When I use "Show me" or move between guide steps
    Then the outline is shown without pulsing
    And steps change without sliding

  Scenario: The guide fits large text
    Given the system text size is set to 200%
    When I open the guide
    Then every step scrolls instead of cutting off text
    And the "Where things moved" table becomes a list of rows

  Scenario: The guide works with a keyboard on desktop
    Given I am using Health Flare on macOS, Linux or Windows
    When I open the guide
    Then Tab moves through each control in reading order
    And Escape closes the guide

  # ---------------------------------------------------------------------------
  # Offline and storage
  # ---------------------------------------------------------------------------

  Scenario: Release content is bundled
    When What's new or a guide is shown
    Then no network request is made
    And nothing is recorded about whether it was read beyond the settings on this device

  Scenario: Going back to an older version shows nothing
    Given I have seen the card for 1.12.0
    When Health Flare 1.11.0 is installed over it
    Then no release card is shown
    And What's new history lists nothing newer than 1.11.0

  Scenario: Release state is per device, not per profile
    Given profiles "Sarah" and "Dad" exist
    When I dismiss the guide card while "Sarah" is active
    And I switch to "Dad"
    Then the guide card is not shown for "Dad"

  Scenario: "Show update highlights" is part of backups
    Given a backup was made with "Show update highlights" off
    When I restore it with "Replace everything"
    Then "Show update highlights" is off

  Scenario: Restoring onto a newer version still shows that version's card
    Given a backup was made on 1.10.0 after its card was dismissed
    When I restore it onto 1.12.0, which has highlights
    Then the 1.12.0 card is shown
    And the 1.10.0 card is not shown again
