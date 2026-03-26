Feature: Dashboard

  As a Health Flare user
  I want a dashboard that summarises my recent health activity
  So that I can quickly review what I have logged and add new entries

  Background:
    Given the app is running with an active profile

  # ---------------------------------------------------------------------------
  # Empty state
  # ---------------------------------------------------------------------------

  Scenario: Empty state encourages first entry when nothing is logged
    Given I have no journal entries
    And I have no sleep entries
    Then the dashboard shows an encouraging empty-state message

  Scenario: The log-entry FAB is always visible
    Then the log-entry FAB is visible on the dashboard

  # ---------------------------------------------------------------------------
  # Quick-entry sheet
  # ---------------------------------------------------------------------------

  Scenario: Tapping the FAB opens a quick-entry choice sheet
    When I tap the log-entry FAB
    Then a sheet appears offering "Journal entry" and "Sleep" options

  Scenario: Choosing "Journal entry" opens the journal composer
    When I tap the log-entry FAB
    And I choose "Journal entry"
    Then the journal composer screen is shown

  Scenario: Choosing "Sleep" opens the sleep entry screen
    When I tap the log-entry FAB
    And I choose "Sleep"
    Then the sleep entry screen is shown

  # ---------------------------------------------------------------------------
  # Activity feed — content
  # ---------------------------------------------------------------------------

  Scenario: Journal entry body preview appears in the activity feed
    Given I have a journal entry with body "Feeling better today"
    Then "Feeling better today" appears in the activity feed

  Scenario: Journal entry title takes priority over body preview
    Given I have a journal entry with title "Week 3 notes" and body "Rough week"
    Then "Week 3 notes" appears in the activity feed
    And "Rough week" does not appear in the activity feed

  Scenario: Sleep entry duration appears in the activity feed
    Given I have a sleep entry of 7 hours 30 minutes
    Then "7h 30m" appears in the activity feed

  Scenario: Activity feed shows at most five recent items
    Given I have six journal entries
    Then the five most recent entries appear and the oldest does not

  Scenario: Activity feed is in reverse chronological order
    Given I have a journal entry from two days ago
    And I have a sleep entry from today
    Then the sleep entry appears above the journal entry in the feed

  # ---------------------------------------------------------------------------
  # Activity feed — navigation
  # ---------------------------------------------------------------------------

  Scenario: Tapping a journal activity item opens the journal detail screen
    Given I have a journal entry
    When I tap the journal item in the activity feed
    Then the journal detail screen is shown

  Scenario: Tapping a sleep activity item opens the sleep edit screen
    Given I have a sleep entry
    When I tap the sleep item in the activity feed
    Then the sleep edit screen is shown
