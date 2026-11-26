Feature: Continue appointment work through iPhone Duo display changes
  As a person moving between the outer and inner displays
  I want my current appointment work to stay in place
  So that opening or closing the device does not lose or save an unfinished edit

  # UNVERIFIED (TODO): Agent-written proposal, including these notes.
  # Review all scenarios before Flutter tests or implementation.
  # Depends on large-screen-layout.feature, not a second layout engine.
  # Apple describes a foldable device with inner and outer displays.
  # No logical viewport dimensions, hinge API or Flutter support is assumed.
  # The HTML controls simulate available width only, not native transitions.
  # SDK, lifecycle, safe-area and real-device validation remain required.

  @unverified
  Scenario: Continue an unfinished edit from outer to inner display
    Given I am editing an appointment on the outer display
    And I have typed a title without saving
    When the app receives a larger available content area on the inner display
    Then the same profile, appointment, draft, focused field and text selection remain
    And the shared appointment layout shows the list only if both panes fit
    And no appointment is saved or marked completed by opening the device

  @unverified
  Scenario: Continue from inner to outer display with the editor foremost
    Given I have an unfinished appointment edit beside the list on the inner display
    When the app receives a compact content area on the outer display
    Then the editor remains the visible task rather than returning to the dashboard
    And its unsaved values and keyboard focus remain available
    And returning to the list restores its previous selection and position
    And Save and Cancel retain their existing meaning

  @unverified
  Scenario: Repeated display changes do not duplicate an explicit save
    Given I have changed one appointment title
    When I change between compact and expanded content areas repeatedly
    And I choose Save once
    Then only that appointment in its original profile is updated once
    And the list and detail agree on the saved title
    And no duplicate appointment is created

  @unverified
  Scenario: Preserve preparation input without changing save semantics
    Given I have typed a question or outcome note without submitting it
    When the available display area changes
    Then the unfinished text and its appointment remain associated
    And no question is added and no outcome is saved by the display change
    And the existing Save outcome action still explicitly marks the appointment completed

  @unverified
  Scenario: Use the same layout decision on any device
    Given two app windows have the same usable content width and text scale
    When one window is on iPhone Duo and one is on a tablet
    Then both use the same readable pane decision
    And neither requires a device-name check or an assumed hinge geometry
    And a large text size can keep the inner display in one-column layout

  @unverified
  Scenario: Respect safe areas and interruptions during a transition
    Given an appointment edit is active with 200 percent text and a keyboard
    When a display transition changes safe areas or interrupts the app
    Then no health data is saved or discarded as a side effect of relayout
    And the focused field and actions remain reachable on resume
    And the native implementation uses supported lifecycle restoration where required
    And native process termination behavior is verified separately from in-session resizing

  @unverified
  Scenario: Keep profile isolation and personal navigation during a transition
    Given I have a customized bar and an appointment selected for profile A
    When I change displays and request profile B
    Then the unsaved edit guard runs before the profile changes
    And profile B never shows profile A's selected appointment or draft
    And the bar choices, disabled features and More access are unchanged

  @unverified
  Scenario: Treat hardware support as a release gate rather than a mockup claim
    Given the browser review works at illustrative compact and expanded widths
    When native support is considered for release
    Then SDK and Flutter support are checked against Apple's current documentation
    And supported native display transitions are tested on available simulator or hardware targets
    And compact phones, tablet multitasking, keyboard, text scale and screen readers are regression tested
    And the browser review alone is not reported as iPhone Duo support
