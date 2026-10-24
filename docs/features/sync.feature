Feature: Shared profile sync between devices
  As one of two parents tracking the same child
  I want both our phones to keep that child's profile in step
  So that each of us sees what the other logged, without an account, a
  Health Flare server, or anyone else able to read it

  # UNVERIFIED (TODO): the scenarios still tagged @unverified hold wording
  # written after the spec review on #207 (button labels and messages).
  # Every other scenario has been read and agreed. Build work (#206 and
  # later) starts only from verified scenarios.

  # ---------------------------------------------------------------------------
  # Scope (#205)
  # ---------------------------------------------------------------------------
  #
  # The unit of sync is one profile. Two to four devices can share a profile.
  # Devices exchange changes directly: over the home Wi-Fi, or as an encrypted
  # file sent any way the person likes (AirDrop, a messaging app, email).
  # Nothing goes over the internet, and Health Flare runs no server.
  #
  # Out of scope: syncing all profiles at once, sharing with clinicians (that
  # is export), real-time collaboration, sync over the internet, Inner Flare.
  #
  # ---------------------------------------------------------------------------
  # Rules
  # ---------------------------------------------------------------------------
  #
  #  1. Sync is off until it is turned on for a profile. A profile with sync
  #     off behaves exactly as today, and no sync network code runs for it.
  #  2. Devices are paired in person by scanning a QR code. The key that
  #     protects the profile is in the code and never crosses a network.
  #  3. Everything a device sends is encrypted so only paired devices can
  #     read it, and signed so the receiver knows which device wrote it.
  #  4. Transport is the local network (same Wi-Fi) or an encrypted file.
  #     Nothing is sent over the internet.
  #  5. A profile can be shared by at most 4 devices.
  #  6. No sync path loses data. When two devices change the same field of
  #     the same entry, the later change is shown and the other is kept and
  #     can be viewed from a "Changed on another device" notice. "Later" is
  #     the sync clock's order, not the phone's clock: two offline edits on
  #     phones whose clocks disagree may be ordered differently from wall
  #     time, and the other value is still kept.
  #  7. A delete on one device is never applied silently on another. Each
  #     other device is told what was deleted and its person chooses to
  #     delete it there too or keep it. A kept entry keeps syncing among the
  #     devices that kept it and is never sent to a device that deleted it.
  #  8. Weather capture, the profile photo and one-time hints stay per
  #     device. They are never synced. Every other profile setting (name,
  #     date of birth, colour, temperature unit, which features are on)
  #     syncs.
  #  9. Sync is not a way to coordinate medication in real time. Dose
  #     screens say when the other device last synced and flag possible
  #     double doses. A possible double dose is two "taken" logs of the same
  #     medication from different devices: on the same calendar day for
  #     "Once daily", less than 6 days apart for "Weekly", and less than
  #     4 hours apart for every other frequency.
  # 10. Removing a device stops future sharing. It can't take back what that
  #     device already has, and the app says so plainly.
  # 11. A device on an older version holds back any change it can't fully
  #     read, shows a placeholder where the entry would be, and applies the
  #     whole change after updating. It never applies half a change.
  # 12. The privacy policy, website and store listing are updated before
  #     sync ships.
  # 13. On a synced profile, deleting a medication never takes its doses
  #     with it silently. The delete asks to delete the doses as well, and
  #     each is raised on the other devices as its own entry. A dose that
  #     arrives for a medication this device deleted is held until the
  #     person brings the medication back or declines doses for it.

  Background:
    Given a profile named "Mia" exists on "Dad's phone"

  # ---------------------------------------------------------------------------
  # Turning sync on (rule 1)
  # ---------------------------------------------------------------------------

  Scenario: Sync is off for every profile until it is turned on
    Given I have never turned on sync
    Then no profile shows as synced
    And the app does not look for other devices on the network
    And the app does not ask for local network access

  Scenario: Turning on sync explains what it does before anything happens
    When I open the profile settings for "Mia"
    And I tap "Share this profile with another device"
    Then I see what sync shares, how devices connect, and that a device I later remove keeps what it already has
    And I can cancel without anything changing

  Scenario: Local network access is asked for only when it is needed
    When I turn on sync for "Mia"
    Then the system asks for local network access
    When I decline local network access
    Then sync for "Mia" still works with "Send updates as a file"
    And I am told syncing over Wi-Fi needs local network access

  Scenario: Sync is per profile
    Given a profile named "Dad" also exists on "Dad's phone"
    When I turn on sync for "Mia"
    Then "Dad" is not shared
    And nothing about "Dad" is sent to any device

  # ---------------------------------------------------------------------------
  # Pairing (rules 2, 5)
  # ---------------------------------------------------------------------------

  Scenario: Pair a second device by scanning a QR code
    Given sync is on for "Mia" on "Dad's phone"
    When "Dad's phone" shows the pairing QR code for "Mia"
    And "Mum's phone" scans it
    Then both phones show the profile name, the other phone's name and the same 6-digit code
    And nothing is merged until both people confirm the codes match

  Scenario: Codes that don't match stop the pairing
    Given "Dad's phone" and "Mum's phone" show different 6-digit codes
    When either person taps "Codes don't match"
    Then the pairing is cancelled
    And no data is shared in either direction

  Scenario: Joining a phone that already has a profile with the same name
    Given "Mum's phone" already has a profile named "Mia" with entries
    When "Mum's phone" pairs with "Dad's phone" for "Mia"
    Then "Mum's phone" asks whether to combine its "Mia" with the shared "Mia" or keep them separate
    And it shows how many entries each side has before I choose
    And nothing is combined without that choice

  Scenario: Combining keeps every entry from both phones
    Given "Mum's phone" chose to combine its "Mia" with the shared "Mia"
    Then every entry from both phones is in the shared "Mia" on both phones
    And entries that exist on both phones appear once

  Scenario: A profile can be shared by at most 4 devices
    Given "Mia" is shared by 4 devices
    When a fifth device tries to pair for "Mia"
    Then pairing is refused with "Mia is already shared by 4 devices. Remove one before adding another."

  Scenario: Pairing never needs an account or the internet
    Given both phones have no internet connection
    When "Mum's phone" pairs with "Dad's phone" for "Mia"
    Then pairing completes
    And no account is created or asked for

  # ---------------------------------------------------------------------------
  # Moving changes between devices (rules 3, 4)
  # ---------------------------------------------------------------------------

  Scenario: Phones on the same Wi-Fi sync when the app is opened
    Given "Mia" is shared by "Dad's phone" and "Mum's phone"
    And both phones are on the same Wi-Fi
    And Mum logged a symptom for "Mia" on "Mum's phone"
    When I open Health Flare on "Dad's phone"
    Then the symptom appears for "Mia" on "Dad's phone"
    And it shows it was logged on "Mum's phone"

  Scenario: Logging on a synced profile sends the change straight away
    Given "Mum's phone" is on the same Wi-Fi with Health Flare open
    When I log a dose for "Mia" on "Dad's phone"
    Then "Dad's phone" sends the dose to "Mum's phone" without being asked

  Scenario: Send updates as a file when the phones are not on the same Wi-Fi
    Given "Mum's phone" is not on the same network
    When I tap "Send updates as a file" for "Mia" on "Dad's phone"
    Then an encrypted file is created and the share sheet opens
    When "Mum's phone" opens that file in Health Flare
    Then the new entries for "Mia" appear on "Mum's phone"

  Scenario: An update file is useless to anyone outside the paired devices
    Given an update file for "Mia" was sent by email
    When someone opens it on a device that is not paired for "Mia"
    Then nothing is imported
    And they see "This file is for a profile this device isn't paired with."

  Scenario: Receiving the same change twice changes nothing
    Given "Mum's phone" already has the latest changes from "Dad's phone"
    When "Mum's phone" opens an older update file from "Dad's phone"
    Then no entry is duplicated or changed

  Scenario: Changes that arrive out of order are applied in order
    Given "Dad's phone" made three changes to "Mia"
    And "Mum's phone" receives the third before the second
    Then "Mum's phone" waits for the second before applying the third
    And it never shows a state "Dad's phone" was never in

  Scenario: The profile shows when it last synced with each device
    Given "Mia" is shared by "Dad's phone" and "Mum's phone"
    When I open the sync settings for "Mia" on "Dad's phone"
    Then I see "Mum's phone" with when it last synced

  Scenario: Nothing is sent over the internet
    Given sync is on for "Mia"
    When the phones sync over Wi-Fi or by file
    Then the only network traffic is between the paired devices on the local network
    And no request goes to a Health Flare server or any other internet host

  # ---------------------------------------------------------------------------
  # Merging changes (rules 6, 7)
  # ---------------------------------------------------------------------------

  Scenario: Different entries logged on both phones are all kept
    Given both phones were offline all day
    And Dad logged 3 entries for "Mia" and Mum logged 2
    When the phones sync
    Then both phones have all 5 entries

  Scenario: An entry edited on one phone is updated on the other
    Given a symptom entry for "Mia" with severity 4 is on both phones
    When Dad changes its severity to 6 on "Dad's phone"
    And the phones sync
    Then the entry shows severity 6 on "Mum's phone"
    And no second copy of the entry is created

  Scenario: Two edits to the same field keep both values
    Given a symptom entry for "Mia" with severity 4 is on both phones
    And both phones are offline
    When Dad changes its severity to 6
    And later Mum changes its severity to 7
    And the phones sync
    Then both phones show severity 7
    And the entry shows "Changed on another device"
    And tapping it shows severity 6, who set it and when, with "Use this one"

  Scenario: Edits to different fields of the same entry both stay
    Given both phones are offline
    When Dad changes a symptom entry's severity
    And Mum changes the same entry's notes
    And the phones sync
    Then the entry has Dad's severity and Mum's notes on both phones
    And no "Changed on another device" notice is shown

  Scenario: Phone clocks that disagree don't reorder changes
    Given "Mum's phone" clock is 10 minutes behind
    When Dad edits an entry and then Mum edits the same field after seeing it
    And the phones sync
    Then Mum's edit is the one shown on both phones

  Scenario: Offline edits are ordered by the sync clock, not the phone's clock
    Given both phones are offline
    And "Mum's phone" clock is 10 minutes slow
    When Dad changes a symptom entry's severity to 6
    And 5 minutes later Mum changes the same entry's severity to 7
    And the phones sync
    Then both phones show severity 6
    And the entry shows "Changed on another device"
    And tapping it shows severity 7, who set it and when, with "Use this one"

  Scenario: Deleting an entry on a shared profile says what happens elsewhere
    Given "Mia" is shared by "Dad's phone" and "Mum's phone"
    When I delete a meal entry for "Mia" on "Dad's phone"
    Then the confirmation says "Mum's phone will be asked whether to delete it too."
    And I can cancel

  Scenario: A delete from another phone is raised, not applied
    When Dad deletes a meal entry for "Mia"
    And the phones sync
    Then the meal entry is still on "Mum's phone"
    And "Mum's phone" shows "Dad's phone deleted 1 entry for Mia" with "Review"
    And each deleted entry can be deleted here too or kept

  Scenario: Deleting it here too removes it from this phone
    Given "Mum's phone" is showing the entries Dad deleted
    When Mum taps "Delete here too"
    Then the meal entry is gone from "Mum's phone"
    And it does not come back on any later sync

  Scenario: Keeping an entry the other phone deleted
    Given "Mum's phone" is showing the entries Dad deleted
    When Mum taps "Keep on this phone"
    Then the meal entry stays on "Mum's phone" marked "Only on this phone"
    And it is not sent back to "Dad's phone"
    And later edits to it stay on "Mum's phone"

  Scenario: An entry kept on several phones keeps syncing between them
    Given "Mia" is shared by "Dad's phone", "Mum's phone" and "Grandma's phone"
    And Dad deleted a meal entry for "Mia"
    And Mum and Grandma both tapped "Keep on this phone"
    When Mum edits that meal entry
    And the phones sync
    Then "Grandma's phone" shows Mum's edit
    And the meal entry does not come back on "Dad's phone"

  @unverified
  Scenario: An entry kept on several phones says where it was deleted
    Given "Mia" is shared by "Dad's phone", "Mum's phone" and "Grandma's phone"
    And Mum and Grandma both kept a meal entry Dad deleted
    Then the meal entry is marked "Deleted on Dad's phone" on both their phones
    And it is not marked "Only on this phone"

  Scenario: An entry edited on one phone and deleted on the other
    Given both phones are offline
    When Dad deletes a journal entry for "Mia"
    And Mum edits the same journal entry
    And the phones sync
    Then the journal entry stays on "Mum's phone" with Mum's edit
    And "Mum's phone" asks whether to delete it too or keep it
    And the entry does not come back on "Dad's phone"

  Scenario: Deleted entries waiting for a choice are never removed on their own
    Given "Mum's phone" has deleted entries from Dad waiting for review
    When Mum ignores the notice for a month
    Then every one of those entries is still on "Mum's phone"

  Scenario: Journal edits from both phones are kept as versions
    Given both phones edit the same journal entry while offline
    When the phones sync
    Then the entry shows the most recent edit
    And both phones' earlier versions are in its history

  Scenario: A dose log points at the right medication on every phone
    Given "Mia" has a medication "Naproxen" on both phones
    When Dad logs a dose of "Naproxen"
    And the phones sync
    Then the dose on "Mum's phone" is linked to "Naproxen"

  # Medications and their doses (rule 13)

  @unverified
  Scenario: Deleting a medication on a shared profile asks about its doses
    Given "Mia" is shared by "Dad's phone" and "Mum's phone"
    And 30 doses of "Naproxen" are logged for "Mia"
    When I delete "Naproxen" on "Dad's phone"
    Then the confirmation says "This also deletes its 30 doses. Mum's phone will be asked about each one."
    And I can cancel, and then nothing is deleted

  Scenario: A deleted medication and its doses are raised one by one
    Given Dad deleted "Naproxen" and its 30 doses for "Mia"
    When the phones sync
    Then "Mum's phone" shows "Dad's phone deleted 31 entries for Mia" with "Review"
    And "Naproxen" and each of its doses can be deleted here too or kept, each on its own
    And no dose is removed from "Mum's phone" because its medication was deleted elsewhere

  @unverified
  Scenario: Deleting a medication here too while keeping some of its doses
    Given "Mum's phone" is reviewing Dad's delete of "Naproxen" and its doses
    And Mum kept some of the doses
    When Mum taps "Delete here too" on "Naproxen"
    Then she is asked to delete the doses she kept as well, or cancel
    And no dose is left pointing at a medication that is gone

  Scenario: A dose arrives for a medication this phone deleted
    Given Dad deleted "Naproxen" on "Dad's phone"
    And Mum logged a dose of "Naproxen" on "Mum's phone" before the phones synced
    When the phones sync
    Then "Dad's phone" shows the dose and asks "Mum's phone logged a dose of Naproxen, which you deleted. Bring Naproxen back here, or don't take doses for it from Mum's phone?"
    And nothing is dropped until Dad chooses

  @unverified
  Scenario: Bringing a deleted medication back for a synced dose
    Given "Dad's phone" is asking about Mum's dose of the deleted "Naproxen"
    When Dad taps "Bring Naproxen back"
    Then "Naproxen" is back on "Dad's phone" with Mum's dose linked to it

  @unverified
  Scenario: Declining doses for a deleted medication
    Given "Dad's phone" is asking about Mum's dose of the deleted "Naproxen"
    When Dad taps "Don't take these doses"
    Then the dose stays on "Mum's phone" only
    And later "Naproxen" doses from "Mum's phone" are not added to "Dad's phone"
    And "Naproxen" stays on "Mum's phone"

  # ---------------------------------------------------------------------------
  # What stays on each device (rule 8)
  # ---------------------------------------------------------------------------

  Scenario: Weather capture is decided on each device
    Given weather capture is on for "Mia" on "Dad's phone"
    When the phones sync
    Then weather capture for "Mia" on "Mum's phone" is unchanged
    And "Mum's phone" never sends its location because of Dad's choice

  Scenario: Weather already attached to an entry travels with the entry
    Given Dad logged a symptom with weather attached
    When the phones sync
    Then the symptom on "Mum's phone" shows the same weather

  Scenario: The profile photo stays on each device
    Given Dad set a photo for "Mia" on "Dad's phone"
    When the phones sync
    Then "Mia"'s photo on "Mum's phone" is unchanged

  Scenario: Every other profile setting syncs
    Given Dad changes "Mia"'s date of birth, temperature unit to °F and turns off bowel tracking on "Dad's phone"
    When the phones sync
    Then "Mum's phone" shows the new date of birth for "Mia"
    And "Mum's phone" shows "Mia"'s temperatures in °F
    And bowel tracking is off for "Mia" on "Mum's phone"
    And "Mia"'s bowel entries are still on both phones

  Scenario: Meal photos stay on the device that took them
    Given Dad logged a meal with a photo
    When the phones sync
    Then the meal appears on "Mum's phone" without the photo
    And it says "Photo is on Dad's phone"

  Scenario: One-time hints are per device
    Given "Dad's phone" has shown the first-log hint for "Mia"
    When the phones sync
    Then "Mum's phone" still shows the first-log hint the first time

  # ---------------------------------------------------------------------------
  # Medication safety (rule 9)
  # ---------------------------------------------------------------------------

  Scenario: The dose screen says when the other phone last synced
    Given "Mia" is shared and "Mum's phone" last synced 3 hours ago
    When I open the dose logging screen for "Mia" on "Dad's phone"
    Then I see "Last synced with Mum's phone 3 h ago"

  Scenario: A synced dose shows who gave it
    Given Mum logged a dose of "Naproxen" at 08:00
    When the phones sync
    Then the dose on "Dad's phone" shows "Given on Mum's phone at 08:00"

  Scenario Outline: Two doses from different phones can be flagged as a possible double dose
    Given "<medication>" is taken "<frequency>" for "Mia"
    And Dad logged it taken on <first> on "Dad's phone" while offline
    And Mum logged it taken on <second> on "Mum's phone" while offline
    When the phones sync
    Then both doses are kept
    And the two doses <result> as a possible double dose on both phones

    Examples:
      | medication   | frequency   | first        | second         | result          |
      | Naproxen     | Once daily  | Monday 08:00 | Monday 20:00   | are flagged     |
      | Naproxen     | Once daily  | Monday 22:00 | Tuesday 07:00  | are not flagged |
      | Naproxen     | Twice daily | Monday 08:00 | Monday 11:59   | are flagged     |
      | Naproxen     | Twice daily | Monday 08:00 | Monday 12:00   | are not flagged |
      | Ibuprofen    | As needed   | Monday 08:00 | Monday 10:00   | are flagged     |
      | Methotrexate | Weekly      | Monday 08:00 | Tuesday 08:00  | are flagged     |
      | Methotrexate | Weekly      | Monday 08:00 | Saturday 07:59 | are flagged     |
      | Methotrexate | Weekly      | Monday 08:00 | Sunday 08:00   | are not flagged |

  Scenario: Two doses logged on the same phone are not flagged by sync
    Given Dad logged "Naproxen" taken at 08:00 and again at 08:20 on "Dad's phone"
    When the phones sync
    Then neither phone shows a possible double dose for those two doses

  @unverified
  Scenario: The possible double dose message names both phones and times
    Given Dad logged "Naproxen" taken at 08:00 and Mum logged it taken at 08:20, both offline
    When the phones sync
    Then both phones show "Possible double dose: Naproxen was logged on Dad's phone at 08:00 and on Mum's phone at 08:20."

  Scenario: Sync is never described as real-time
    When I read the sync explanation or the dose screen of a synced profile
    Then nothing says or suggests the other phone is always up to date

  # ---------------------------------------------------------------------------
  # Removing a device and leaving sync (rule 10)
  # ---------------------------------------------------------------------------

  Scenario: Removing a device says plainly what it keeps
    When I tap "Remove" next to "Mum's phone" in the sync settings for "Mia"
    Then I see "Mum's phone keeps everything it already has for Mia. Removing it only stops new changes from reaching it."
    And I can cancel

  Scenario: A removed device gets no new changes
    Given I removed "Mum's phone" from "Mia"
    When I log a new entry for "Mia" on "Dad's phone"
    Then "Mum's phone" can't read or receive it
    And changes "Mum's phone" makes afterwards are not accepted by "Dad's phone"

  Scenario: Leaving sync keeps a full copy
    When I tap "Stop sharing Mia on this phone" on "Mum's phone"
    Then "Mia" stays on "Mum's phone" as an ordinary profile with every entry
    And the other paired devices are told "Mum's phone" left

  @unverified
  Scenario: A device that left gets no new changes
    Given "Mum's phone" stopped sharing "Mia"
    When I log a new entry for "Mia" on "Dad's phone"
    Then "Mum's phone" can't read or receive it
    And changes "Mum's phone" makes afterwards are not accepted by "Dad's phone"

  Scenario: Deleting a synced profile on one phone asks what to do
    When I delete "Mia" on "Dad's phone"
    Then I am asked whether to delete "Mia" on this phone only or stop sharing first
    And the profile is never deleted from "Mum's phone" by this action

  # ---------------------------------------------------------------------------
  # Different app versions (rule 11)
  # ---------------------------------------------------------------------------

  # F-Droid / IzzyOnDroid builds link to the listing they were installed
  # from, not Google Play.
  Scenario: An older version holds back a change it can't fully read
    Given "Mum's phone" runs an older version of Health Flare
    And Dad logs a dose at 08:00 using a field the older version doesn't have
    When the phones sync
    Then "Mum's phone" applies none of that change
    And where the dose would be it shows "A dose from Dad's phone at 08:00 needs an update to show."
    And tapping it opens the store listing to update Health Flare
    And after "Mum's phone" updates, the full dose is shown
    And nothing Dad logged is lost

  Scenario: A version too old to sync says so
    Given "Mum's phone" runs a version that can't read the sync format
    When the phones try to sync
    Then "Mum's phone" shows "Update Health Flare to keep syncing with Dad's phone."
    And it applies nothing from "Dad's phone" until it is updated

  # ---------------------------------------------------------------------------
  # Security (rule 3)
  # ---------------------------------------------------------------------------

  Scenario Outline: Changes that fail a check are rejected without changing data
    Given "Mia" is shared by "Dad's phone" and "Mum's phone"
    When "Mum's phone" receives <bad change>
    Then nothing on "Mum's phone" changes
    And the rejection is noted in the sync settings for "Mia"

    Examples:
      | bad change                                       |
      | a change encrypted with the wrong key            |
      | a change with one byte altered                   |
      | a change for a different profile replayed as Mia |
      | a change from a device that was removed          |

  Scenario: A stranger on the same Wi-Fi sees nothing readable
    Given another device on the network is not paired for "Mia"
    When "Dad's phone" and "Mum's phone" sync
    Then that device can't read any entry
    And it can't get either phone to accept a change from it

  Scenario: The profile key is never in a backup
    Given sync is on for "Mia"
    When I export a backup
    Then the backup contains "Mia"'s entries
    And it does not contain the key that protects "Mia"'s sync

  Scenario: Restoring a backup brings a synced profile back unshared
    Given a backup was exported while "Mia" was shared
    When I restore it on a new phone
    Then "Mia" is restored as an ordinary profile
    And I can pair the new phone again to resume sharing

  # ---------------------------------------------------------------------------
  # Privacy copy (rule 12)
  # ---------------------------------------------------------------------------

  Scenario: The privacy policy describes sync before it ships
    When sync is available in a release
    Then the privacy policy says synced profiles travel between paired devices over the local network or as a file the person sends
    And it says what other devices on the network can see: that two phones exchange data, and when, but not what
