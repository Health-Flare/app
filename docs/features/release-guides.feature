Feature: Release guides
  As someone who uses Health Flare most days
  I want to be shown, step by step, when something I use has moved
  So that a familiar screen never looks broken and I can find things again

  # Builds on What's new (whats-new.feature, #139): the guide card is a
  # release card, and the same setting turns both off. Built in #145.
  #
  # A guide is written only for a change that moves something people
  # already use (docs/feature-releases.md: a "move"). Track and Care (#135)
  # is the first; accessibility settings are next. A release has at most
  # one guide, named by its "guideId" in assets/whats_new/releases.json.
  #
  # Release rule: a move ships with its guide, or stays behind its build
  # flag. The release checks (#140) fail a move fragment with no guide.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # The guide card
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

  Scenario: Skipping or finishing the guide counts as seen
    Given the guide is open
    When I tap "Skip", press Back on the first step, tap "Done", or make a
      choice on "Keep it or change it"
    Then the guide card does not come back
    And no layout change is made unless I chose one on "Keep it or change it"

  Scenario: Leaving the app mid-guide resumes it next time
    Given the guide is open on "Where things moved"
    When I leave the app, or it is closed
    And I open the app again
    Then the guide opens on "Where things moved"
    And it does not count as seen
    # A phone call halfway through shouldn't lose the guide for good.

  # ---------------------------------------------------------------------------
  # The guide itself
  # ---------------------------------------------------------------------------

  Scenario: "Show me" opens the guide
    Given the Track and Care guide card is showing
    When I tap "Show me"
    Then the guide opens with the same dots, Back and Skip as onboarding
    And it has these steps, in order:
      | Step                 |
      | Four sections now    |
      | Where things moved   |
      | Keep it or change it |
      | Finding this again   |

  Scenario: The guide shows the new bar next to the old one
    Given I am on the "Four sections now" step
    Then I see the old bar and the new bar drawn one above the other
    And each new section has a one-line description:
      | Section   | Description                                   |
      | Dashboard | Today, and what's coming up                   |
      | Track     | Symptoms, vitals, meals, sleep and activity   |
      | Care      | Medications, appointments, conditions, flares |
      | Journal   | Journal entries and daily check-ins           |

  Scenario: Every moved screen is listed with where it went
    Given I am on the "Where things moved" step
    Then I see each old destination and where it is now:
      | Was      | Now                |
      | Tracking | Track              |
      | Meds     | Care > Medications |
      | Meals    | Track > Meals      |
      | Sleep    | Track > Sleep      |
      | Journal  | Journal > Entries  |
    And I see the screens that now have a place of their own:
      | Screen       | Now                 |
      | Appointments | Care > Appointments |
      | Activity     | Track > Activity    |
      | Check-ins    | Journal > Check-ins |
      | Flares       | Care > Flares       |

  Scenario: "Pin" on a moved row puts it back in the bar
    Given I am on the "Where things moved" step
    Then each screen that used to be in the bar (Meds, Meals, Sleep) has a
      "Pin" button next to "Show me"
    When I tap "Pin" next to "Sleep"
    Then Sleep is added to the end of my bar
    And the button reads "Pinned" and the step says "Sleep is in your bar"
    And "Bottom bar" in Settings reads "Customized"

  Scenario: "Pin" with a full bar opens the bar editor
    Given my bar already has five items
    When I tap "Pin" next to "Sleep" on "Where things moved"
    Then the bar editor opens with Sleep ready to add
    And a line says "The bar holds five items. Remove one to add Sleep."
    And closing the editor returns me to the same guide step

  Scenario: "Show me" on a row goes to that screen
    Given I am on the "Where things moved" step
    When I tap "Show me" next to "Meds"
    Then the guide closes
    And the Medications tab in Care opens
    And the Care section in the bottom bar is outlined for two pulses

  Scenario: The guide offers to keep it like before
    Given I never changed the bottom bar
    And I am on the "Keep it or change it" step
    Then I can choose one of:
      | Choice              | What happens                                                               |
      | Use the new layout  | The default bar is kept                                                    |
      | Keep it like before | The "Like before" bar preset is applied (navigation-customization.feature) |
      | Set it up myself    | Settings > Your layout opens after the guide                               |
    And "Use the new layout" is selected by default
    And the step says features I don't use can be turned off in Settings > Your layout
    And it says all of this can be changed any time

  Scenario: The last step says where to find the guide again
    Given I am on the "Finding this again" step
    Then it says the guide is in Settings > What's new
    And the only button is "Done"

  Scenario: A guide can be replayed from its release
    Given I dismissed the Track and Care guide card
    When I open Settings > What's new
    Then the release that introduced Track and Care shows "Replay guide"
    And tapping it opens the guide at the first step

  # ---------------------------------------------------------------------------
  # Customized layouts
  # ---------------------------------------------------------------------------

  Scenario: Every change to the default bar comes with a guide
    Given a release changes the default bottom bar
    Then its What's new entry has a guide
    And the guide shows the old bar beside the new one and where each item went
    And the release cannot be cut without it

  Scenario: Someone on the default bar is shown what changed
    Given I never changed the bottom bar
    And Health Flare was updated to a version that changes the default bar
    When I open the dashboard
    Then that release's guide card is showing
    And "Show me" opens a guide that starts with the bar I had beside the new one

  Scenario: Someone with a custom bar is told their bar was kept
    Given I customized the bottom bar in an earlier version
    And Health Flare was updated to a version that changes the default bar
    When I open the dashboard
    Then the guide card reads "The default bottom bar has changed. Yours has been kept."
    And "Show me" opens a guide that shows the new default
    And its "Keep it or change it" step offers, in order:
      | Choice             | What happens                                 |
      | Keep my bar        | Nothing changes                              |
      | Use the new layout | The bar goes back to the new default         |
      | Set it up myself   | Settings > Your layout opens after the guide |
    And "Keep my bar" is selected by default

  Scenario: A pinned screen that moved is explained, not silently swapped
    Given I pinned a screen that a later version merged into another screen
    When Health Flare is updated to that version
    Then the pin now points at the screen it was merged into
    And the guide card names the old and the new screen

  # ---------------------------------------------------------------------------
  # Accessibility
  # ---------------------------------------------------------------------------

  Scenario: The guide works with a screen reader
    Given a screen reader is active
    When the guide opens
    Then each step is announced as "Step 2 of 4, Where things moved"
    And the old and new bar drawings have text descriptions
    # The card's own announcement is in whats-new.feature.

  Scenario: Reduce Motion turns off pulses and guide slides
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
