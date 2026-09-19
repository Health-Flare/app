Feature: Encrypted backups
  As a Health Flare user
  I want to optionally lock an exported backup with a password
  So that my health data stays private if the backup file is stored somewhere
  shared or sent to someone else, without relying on any account or cloud service

  # ---------------------------------------------------------------------------
  # Scope
  # ---------------------------------------------------------------------------
  #
  # This feature covers the confidentiality of *portable backup files* produced
  # by export and consumed by import/restore. It does not change how the live
  # on-device database is stored — the Isar database file on disk remains
  # unencrypted at rest, protected only by the OS's app-sandbox permissions
  # (see datastore.feature, "Database file is not accessible to other apps").
  # Encryption is applied only at the boundary where data leaves the device as
  # a file (export) and where a file re-enters the device (import).
  #
  # All encryption and decryption happens entirely on-device. No password, key,
  # salt, or backup content is ever sent over the network — this stays true to
  # the app's offline-first design (the only network call the app ever makes is
  # the opt-in Open-Meteo weather lookup, which this feature does not touch).

  # ---------------------------------------------------------------------------
  # Background
  # ---------------------------------------------------------------------------

  Background:
    Given a profile named "Sarah" exists and is active
    And "Sarah" has journal, sleep, and medication data saved
    And the settings screen's "Data & backup" section is open

  # ---------------------------------------------------------------------------
  # Data ownership messaging on export
  # ---------------------------------------------------------------------------
  #
  # Language reference: informed-patient.ai (confirmed correct domain — note
  # the hyphen, not "informedpatients.ai"), created by patient advocate Cat
  # Hicks, PhD. Related GitHub repo: github.com/DrCatHicks/informed-patient
  # (CC-BY-4.0). Its writing on what happens to a patient's data, who can see
  # it, and why patients deserve a specific answer (not a vague reassurance)
  # is a strong model for the tone we want on this screen — consistent with
  # CLAUDE.md's existing "Privacy-Centric" principle ("no vague 'we value
  # privacy'").
  #
  # NOTE: this session's network egress to informed-patient.ai itself is
  # blocked (and archive.org is unreachable too), so its exact on-site copy
  # still hasn't been pulled. The GitHub repo *was* reachable, but it's a
  # Claude Skill for evidence reviews, not a data-export product — its actual
  # privacy language is caution about using AI chat for health questions
  # (e.g. "This is not a HIPAA-covered tool"; "consider whether you want your
  # conversation used to train Anthropic's models"), not data-ownership
  # language for an export flow. That may mean the live site has different,
  # more relevant copy on its own pages — or that this isn't quite the source
  # intended. TODO before shipping: get someone with access to
  # informed-patient.ai to confirm and pull the actual ownership/export
  # language; what's below documents the requirement, not the final copy.
  #
  # This messaging applies to the export flow generally — both the plain and
  # encrypted paths — not just the encryption-specific scenarios below.

  Scenario: The export screen explains data ownership before the user shares anything
    Given the user has opened "Export backup"
    Then the screen states, in plain language, that this data belongs to the user
    And it states specifically what happens on export: the data is written to a
      file the user controls, and Health Flare has no server or account that
      receives a copy of it
    And it states who can access the file afterward: only whoever the user
      chooses to share it with — Health Flare never sees, stores, or has access
      to it
    And the language is specific and checkable, not a vague reassurance
      ("we value your privacy")

  # ---------------------------------------------------------------------------
  # Choosing to encrypt an export
  # ---------------------------------------------------------------------------

  Scenario: Encryption is off by default on export
    When the user taps "Export backup"
    Then the "Encrypt with a password" toggle is shown, unchecked
    And no password fields are shown until the toggle is switched on

  Scenario: Exporting without encryption behaves exactly as before
    Given the user leaves "Encrypt with a password" switched off
    When the user completes the export
    Then a plain, unencrypted ".isar" backup file is produced
    And the OS share sheet opens with that file, as it does today

  Scenario: Turning on encryption reveals password fields
    When the user switches on "Encrypt with a password"
    Then a "Password" field and a "Confirm password" field are shown
    And a warning is shown that the password cannot be recovered if lost

  # ---------------------------------------------------------------------------
  # Password requirements
  # ---------------------------------------------------------------------------

  Scenario: A password shorter than the minimum length is rejected
    Given "Encrypt with a password" is switched on
    When the user enters "abc123" as the password
    Then an inline error explains the password must be at least 8 characters
    And the export cannot proceed

  Scenario: Mismatched password confirmation is rejected
    Given "Encrypt with a password" is switched on
    When the user enters "correcthorsebattery" as the password
    And enters "correcthorsebatteri" as the confirmation
    Then an inline error explains the passwords don't match
    And the export cannot proceed

  Scenario: A valid, matching password enables the export
    Given "Encrypt with a password" is switched on
    When the user enters "correcthorsebattery" as the password
    And enters "correcthorsebattery" as the confirmation
    Then the "Export" action becomes enabled

  Scenario: The user must acknowledge the loss-of-password warning
    Given "Encrypt with a password" is switched on
    And a valid, matching password has been entered
    When the user taps "Export" without acknowledging the warning
    Then the export does not proceed
    And the user is prompted to confirm they understand the password can't be recovered

  # ---------------------------------------------------------------------------
  # Producing an encrypted backup
  # ---------------------------------------------------------------------------

  Scenario: An encrypted export produces a distinct, locked file
    Given "Encrypt with a password" is switched on with a valid, confirmed password
    When the user completes the export
    Then the exported file has the ".hfbackup" extension, not ".isar"
    And the file's content is not readable as a plain Isar database
    And the OS share sheet opens with the encrypted file

  Scenario: The password is never written to disk
    Given "Encrypt with a password" is switched on with a valid, confirmed password
    When the export completes
    Then the password does not appear anywhere in the exported ".hfbackup" file
    And the password is not written to any log, cache, or settings entry
    And the password is cleared from memory once the export finishes

  Scenario: No unencrypted intermediate file is left behind
    Given "Encrypt with a password" is switched on with a valid, confirmed password
    When the export completes
    Then any temporary plaintext copy used to build the backup has been deleted
    And only the encrypted ".hfbackup" file remains on disk

  Scenario: Encryption uses vetted, authenticated cryptography
    Given the pubspec.yaml is checked
    Then a well-vetted, actively maintained encryption package is a dependency
    And no cryptographic primitive (cipher, key derivation, random source) is hand-implemented
    And the backup is encrypted with an authenticated cipher (AES-256-GCM or equivalent)
    And the encryption key is derived from the password with a memory-hard KDF (Argon2id or equivalent)
    And a fresh random salt and nonce are generated for every export
    And the salt and nonce are stored unencrypted in the file header, as is standard practice

  # ---------------------------------------------------------------------------
  # Importing an encrypted backup
  # ---------------------------------------------------------------------------

  Scenario: Selecting an encrypted file prompts for its password
    Given the user taps "Import / restore" and picks an import mode
    When the user selects a ".hfbackup" file in the file picker
    Then a password prompt is shown before anything else happens
    And no preview, merge, or staging begins until a password is submitted

  Scenario: Selecting a plain, unencrypted backup skips the password prompt
    Given the user taps "Import / restore" and picks an import mode
    When the user selects a plain ".isar" file in the file picker
    Then no password prompt is shown
    And the import proceeds exactly as it does today

  Scenario: The app detects file type automatically
    Given the user is picking a file to import
    Then the app determines whether a selected file is encrypted from its content, not by asking the user
    And the file picker accepts both ".isar" and ".hfbackup" files

  Scenario: The correct password unlocks the backup for import
    Given the user selected an encrypted ".hfbackup" file
    When the user enters the correct password
    Then the backup is decrypted into a temporary working copy
    And the import (overwrite, merge, or selective) proceeds using that copy exactly as with a plain backup

  Scenario: An incorrect password is rejected without side effects
    Given the user selected an encrypted ".hfbackup" file
    When the user enters an incorrect password
    Then a clear "incorrect password" error is shown
    And no data in the main database is changed
    And the user can retry with a different password without re-selecting the file

  Scenario: A corrupted or tampered backup cannot be distinguished from a wrong password
    Given the user selected a ".hfbackup" file whose contents have been altered after export
    When the user enters what they believe is the correct password
    Then decryption fails the same way it would for a wrong password
    And the app shows the same "incorrect password" error rather than guessing at the cause
    And no data in the main database is changed

  Scenario: The decrypted working copy is always cleaned up
    Given the user selected an encrypted ".hfbackup" file and entered the correct password
    When the import operation finishes, is cancelled, or fails
    Then the temporary decrypted working copy is deleted
    And no decrypted plaintext of the backup remains on disk afterward

  # ---------------------------------------------------------------------------
  # Encryption across all three restore modes
  # ---------------------------------------------------------------------------

  Scenario: Encrypted backup with "Replace everything" (staged overwrite)
    Given the user chooses "Replace everything" and selects an encrypted ".hfbackup" file
    When the user enters the correct password and confirms the replacement
    Then the decrypted content is staged for restore on next launch
    And the staging behaves exactly as it does for a plain backup today
    And the on-disk pending-restore file itself is a plain Isar database,
      consistent with the live database also being unencrypted at rest

  Scenario: Encrypted backup with "Add missing data" (merge)
    Given the user chooses "Add missing data" and selects an encrypted ".hfbackup" file
    When the user enters the correct password
    Then the backup is decrypted before any record is compared or merged
    And records are added to the main database exactly as with a plain backup today

  Scenario: Encrypted backup with "Choose what to import" (selective)
    Given the user chooses "Choose what to import" and selects an encrypted ".hfbackup" file
    When the user enters the correct password
    Then the backup is decrypted once
    And the category preview (counts of new records per category) is built from the decrypted content
    And the user is not asked for the password again when confirming which categories to import

  # ---------------------------------------------------------------------------
  # Interoperability with existing (pre-encryption) backups
  # ---------------------------------------------------------------------------

  Scenario: A backup exported before this feature existed still imports
    Given a plain ".isar" backup file created by an older version of the app
    When the user imports it, in any of the three restore modes
    Then it is imported successfully without any password prompt

  Scenario: An encrypted backup cannot be opened by an older app version
    Given a ".hfbackup" file produced by a version of the app that supports encryption
    When that file is opened with a version of the app that predates this feature
    Then the older version does not recognize the file as a valid backup
    And no data is lost or corrupted as a result — the attempt simply fails cleanly
