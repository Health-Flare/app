Feature: App lock and hiding the app in the app switcher
  As someone tracking my own or my family's health
  I want Health Flare to ask for my face, fingerprint or phone passcode before
  it shows anything, and to keep its screens out of the app switcher
  So that a person holding my unlocked phone can't read every profile

  # ---------------------------------------------------------------------------
  # Scope (#100, #101)
  # ---------------------------------------------------------------------------
  #
  # Two independent, opt-in settings under Settings > Privacy:
  #
  #   1. App lock (#100): a gate in front of the whole app, every profile at
  #      once. It unlocks with the phone's own security (biometrics, falling
  #      back to the phone's passcode). There is no app PIN: nothing secret is
  #      stored by Health Flare, and there is nothing to forget. The trade-off
  #      is that anyone who knows the phone's passcode can open the app.
  #
  #   2. Hide in app switcher (#101): the app switcher shows a blank screen
  #      instead of the last health screen. On Android this is FLAG_SECURE,
  #      which also blocks screenshots and screen recording (Android can't
  #      separate the two). iOS only hides the app switcher snapshot;
  #      screenshots still work there.
  #
  # The lock is a screen in front of the app, not encryption. The database on
  # the phone is stored as it was before (see datastore.feature), and it stays
  # in the phone's own backup (#97, #98). Copy must never say the lock
  # encrypts or protects the data at rest.
  #
  # Platforms: iOS and Android only. On macOS, Windows, Linux and web, the
  # Privacy section doesn't offer either setting; the OS login session is the
  # boundary there.
  #
  # Both settings belong to this phone, not to the data: importing or
  # restoring a backup file never turns them on or off.

  # Unless a scenario names a platform, it runs on iOS and Android.

  Background:
    Given a profile named "Sarah" exists and is active

  # ---------------------------------------------------------------------------
  # Turning the lock on
  # ---------------------------------------------------------------------------

  Scenario: The app lock is off by default
    Given I have just finished onboarding without turning on the app lock
    When I close and reopen the app
    Then the dashboard is shown without asking me to unlock

  Scenario: The onboarding privacy step offers the app lock
    Given I am on the privacy step of onboarding
    And my phone has a screen lock set up
    Then I see a "Lock Health Flare" option, switched off
    And it says the app will ask for my face, fingerprint or phone passcode before showing my records
    And it says the lock does not encrypt the records stored on my phone

  Scenario: Turning the lock on during onboarding
    Given I am on the privacy step of onboarding
    And my phone has a screen lock set up
    When I switch on "Lock Health Flare"
    And I confirm with my phone's face, fingerprint or passcode
    Then the app lock is on
    And the re-lock time is 15 minutes

  Scenario: Turning the lock on from Settings
    Given the app lock is off
    And my phone has a screen lock set up
    When I open Settings > Privacy
    And I switch on "App lock"
    And I confirm with my phone's face, fingerprint or passcode
    Then the app lock is on
    And the re-lock time is 15 minutes

  Scenario: Cancelling the confirmation leaves the lock off
    Given the app lock is off
    When I switch on "App lock"
    And I cancel the face, fingerprint or passcode prompt
    Then the app lock is still off

  Scenario: The lock can't be turned on without a screen lock on the phone
    Given my phone has no passcode, fingerprint or face unlock set up
    When I switch on "App lock"
    Then the app lock stays off
    And I see "Set a screen lock in your phone's settings first, then come back to turn this on."

  Scenario: Turning the lock on suggests hiding the app in the app switcher
    Given the app lock is off
    And "Hide in app switcher" is off
    When I turn on the app lock
    Then I am asked whether to also hide Health Flare in the app switcher
    And "Hide in app switcher" is still off until I accept

  Scenario: Accepting the suggestion hides the app in the app switcher
    Given I was just asked whether to also hide Health Flare in the app switcher
    When I tap "Hide it"
    Then "Hide in app switcher" is on

  Scenario: Declining the suggestion leaves the app switcher alone
    Given I was just asked whether to also hide Health Flare in the app switcher
    When I tap "Not now"
    Then "Hide in app switcher" is off
    And the app lock is still on

  Scenario: No suggestion when the app is already hidden in the app switcher
    Given "Hide in app switcher" is on
    When I turn on the app lock
    Then I am not asked about the app switcher

  # ---------------------------------------------------------------------------
  # When the app locks
  # ---------------------------------------------------------------------------

  Scenario: The app is locked when it starts
    Given the app lock is on
    When I open the app from scratch
    Then I see the lock screen before any health screen

  Scenario Outline: The app locks again after it has been in the background
    Given the app lock is on
    And the re-lock time is <relock>
    And the app is unlocked
    When the app is in the background for <away>
    And I return to the app
    Then the app is <result>

    Examples:
      | relock      | away       | result   |
      | Immediately | 1 second   | locked   |
      | 1 minute    | 59 seconds | unlocked |
      | 1 minute    | 1 minute   | locked   |
      | 5 minutes   | 4 minutes  | unlocked |
      | 5 minutes   | 5 minutes  | locked   |
      | 15 minutes  | 14 minutes | unlocked |
      | 15 minutes  | 15 minutes | locked   |

  Scenario Outline: Things the app opens itself don't lock it
    Given the app lock is on
    And the re-lock time is Immediately
    And the app is unlocked
    When I <action>
    And I come back to Health Flare
    Then the app is unlocked

    Examples:
      | action                                         |
      | take a photo for a meal                        |
      | choose a backup file to import                 |
      | share an exported backup or report             |
      | answer the location permission prompt          |

  Scenario: Answering the unlock prompt doesn't lock the app again
    Given the app lock is on
    And the re-lock time is Immediately
    And the lock screen is shown
    When I confirm with my phone's face, fingerprint or passcode
    Then the app is unlocked
    And I am not asked to unlock a second time

  # ---------------------------------------------------------------------------
  # The lock screen
  # ---------------------------------------------------------------------------

  Scenario: The lock screen asks for the phone's security straight away
    Given the app lock is on
    When the lock screen is shown
    Then I am asked for my face, fingerprint or phone passcode without tapping anything

  Scenario: The lock screen doesn't say whose data is in the app
    Given the app lock is on
    And profiles named "Sarah" and "Mia" exist
    When the lock screen is shown
    Then I see "Health Flare" and an "Unlock" button
    And I do not see "Sarah" or "Mia"
    And I do not see any profile picture, count or health record

  Scenario: Nothing behind the lock screen can be read or reached
    Given the app lock is on
    And the lock screen is shown
    Then screen readers announce only the lock screen
    And taps can't reach the screen underneath

  Scenario: Cancelling the prompt keeps the app locked
    Given the lock screen is shown
    When I cancel the face, fingerprint or passcode prompt
    Then the app stays locked
    And I can tap "Unlock" to try again

  Scenario: Unlocking returns to exactly where I was
    Given the app lock is on
    And I am halfway through writing a journal entry
    When the app locks
    And I unlock it
    Then the journal entry I was writing is still open with my text in it

  Scenario: The lock pauses if the phone's screen lock is removed
    Given the app lock is on
    When my phone no longer has a passcode, fingerprint or face unlock set up
    And I open the app
    Then the dashboard is shown without asking me to unlock
    And I see "App lock is paused because your phone has no screen lock. Set one in your phone's settings to turn it back on."
    And the app lock setting is kept, so the lock returns once a screen lock is set up again

  # ---------------------------------------------------------------------------
  # Changing or turning off the lock
  # ---------------------------------------------------------------------------

  Scenario: Turning the lock off asks for the phone's security first
    Given the app lock is on
    When I switch off "App lock"
    Then I am asked for my face, fingerprint or phone passcode
    And the app lock is only turned off once I confirm

  Scenario: Cancelling while turning the lock off keeps it on
    Given the app lock is on
    When I switch off "App lock"
    And I cancel the face, fingerprint or passcode prompt
    Then the app lock is still on

  Scenario: Choosing the re-lock time
    Given the app lock is on
    When I open "Lock after"
    Then I can choose "Immediately", "1 minute", "5 minutes" or "15 minutes"

  Scenario: Making the re-lock time longer asks for the phone's security first
    Given the app lock is on
    And the re-lock time is 1 minute
    When I choose "15 minutes"
    Then I am asked for my face, fingerprint or phone passcode
    And the re-lock time only changes once I confirm

  Scenario: Making the re-lock time shorter doesn't ask
    Given the app lock is on
    And the re-lock time is 15 minutes
    When I choose "Immediately"
    Then the re-lock time is Immediately without asking me to confirm

  Scenario: The re-lock time is hidden while the lock is off
    Given the app lock is off
    When I open Settings > Privacy
    Then I do not see "Lock after"

  # ---------------------------------------------------------------------------
  # Hide in app switcher
  # ---------------------------------------------------------------------------

  Scenario: Hide in app switcher is off by default
    When I open Settings > Privacy
    Then "Hide in app switcher" is off

  Scenario: Hide in app switcher works without the app lock
    Given the app lock is off
    When I switch on "Hide in app switcher"
    Then "Hide in app switcher" is on
    And the app lock is still off

  Scenario: Hiding the app blanks the app switcher on Android
    Given the app is running on Android
    And "Hide in app switcher" is on
    When I open the app switcher
    Then Health Flare's card is blank
    And screenshots and screen recordings of Health Flare are blank

  Scenario: Hiding the app covers the app switcher snapshot on iPhone
    Given the app is running on iOS
    And "Hide in app switcher" is on
    When I open the app switcher
    Then Health Flare's card shows a plain cover instead of the last screen

  Scenario: The setting explains what it blocks on Android
    Given the app is running on Android
    When I open Settings > Privacy
    Then "Hide in app switcher" says it also blocks screenshots and screen recording of Health Flare

  Scenario: The setting is applied from the moment the app starts
    Given "Hide in app switcher" is on
    When I open the app from scratch
    Then the app is hidden in the app switcher before the first screen is shown

  Scenario: Turning off hide in app switcher doesn't ask for the phone's security
    Given "Hide in app switcher" is on
    When I switch off "Hide in app switcher"
    Then "Hide in app switcher" is off

  # ---------------------------------------------------------------------------
  # Device-local settings
  # ---------------------------------------------------------------------------

  Scenario: Importing a backup doesn't change the lock settings
    Given the app lock is on with a re-lock time of 1 minute
    And "Hide in app switcher" is on
    When I import records from a backup made on a phone with the app lock off
    Then the app lock is still on with a re-lock time of 1 minute
    And "Hide in app switcher" is still on

  Scenario: Restoring a backup over my data keeps this phone's lock settings
    Given the app lock is off
    And "Hide in app switcher" is off
    When I replace my data with a backup made on a phone with the app lock on
    And I restart the app
    Then the app lock is off
    And "Hide in app switcher" is off

  # ---------------------------------------------------------------------------
  # Platforms
  # ---------------------------------------------------------------------------

  Scenario Outline: Desktop and web builds don't offer the lock
    Given the app is running on <platform>
    When I open Settings
    Then I do not see "App lock"
    And I do not see "Hide in app switcher"

    Examples:
      | platform |
      | macOS    |
      | Windows  |
      | Linux    |
      | web      |

  Scenario: The onboarding privacy step doesn't offer the lock on desktop
    Given the app is running on macOS, Windows, Linux or web
    When I am on the privacy step of onboarding
    Then I do not see "Lock Health Flare"

  # ---------------------------------------------------------------------------
  # Honest copy
  # ---------------------------------------------------------------------------

  Scenario: Lock copy never claims encryption
    Then no app lock or app switcher text says the lock encrypts, secures or protects the data stored on the phone
