Feature: UI Patterns and Design Language
  As a developer building Health Flare
  I want a shared vocabulary and consistent implementation patterns
  So that every screen behaves predictably and is easy to maintain

  # ---------------------------------------------------------------------------
  # Primary action buttons — placement
  # ---------------------------------------------------------------------------

  Scenario: Primary action buttons live in Scaffold.bottomNavigationBar
    Given any screen with a single primary save or submit action
    Then the button is placed in the Scaffold.bottomNavigationBar slot
    And not in the AppBar actions row
    And not as a FloatingActionButton

  Scenario: Scaffold.bottomNavigationBar button is padded and full-width
    Given a primary action button in the Scaffold.bottomNavigationBar slot
    Then it is wrapped in a SafeArea to respect system navigation bars
    And padded with 16 dp on left, right, and bottom and 8 dp on top
    And it expands to fill the available width

  # ---------------------------------------------------------------------------
  # Primary action buttons — style
  # ---------------------------------------------------------------------------

  Scenario: Primary action buttons use FilledButton
    Given a primary save or submit action on any screen
    Then the button widget is FilledButton
    And not ElevatedButton
    And not TextButton

  Scenario: Primary action buttons show a loading spinner during async operations
    Given the user has tapped a primary action button
    And the save operation is in progress
    Then the button label is replaced with a CircularProgressIndicator
    And the button is disabled until the operation completes

  Scenario: Primary action buttons are disabled when the minimum required input is absent
    Given a screen that requires at least one selection or field to be valid
    When no valid input has been provided
    Then the primary action button is disabled via a null onPressed
    And not hidden — the button remains visible in its disabled state

  # ---------------------------------------------------------------------------
  # Button vocabulary
  # ---------------------------------------------------------------------------

  Scenario: Selection screens use "Add to profile" as the primary action label
    Given a screen where the user selects items to associate with the active profile
    Then the primary action button is labelled "Add to profile"
    And this label is used regardless of whether the profile belongs to the user or a dependant

  Scenario: "Add to profile" is the label for illness, symptom, and medication tracking screens
    Given any of the following screens:
      | Screen                     |
      | Illness tracking screen    |
      | Symptom tracking screen    |
      | Medication tracking screen |
    Then the primary action button is labelled "Add to profile"

  Scenario: Edit screens use "Save changes" as the primary action label
    Given a screen where the user modifies an existing entity
    Then the primary action button is labelled "Save changes"
    And this applies to edit profile, edit journal entry, and similar edit flows

  Scenario: Profile-creation screens use a contextual descriptive phrase
    Given the onboarding profile creation screen
    Then the primary action button is labelled "Create profile and get started  →"

  # ---------------------------------------------------------------------------
  # Profile-aware language
  # ---------------------------------------------------------------------------

  Scenario: UI copy does not use first-person possessive for profile data
    Given the active profile may belong to the user or to a dependant
    Then UI copy never uses phrases like "my conditions", "my profile", or "add to my tracking"
    And instead uses "Add to profile", "tracked conditions", or references the profile name directly

  Scenario: Profile name is used when personalisation adds clarity
    Given "Dad" is the active profile
    And context makes it helpful to name the profile
    Then copy reads "for Dad" or "Dad's conditions" rather than "my conditions"
    But generic screens default to "profile" without a name for brevity

  # ---------------------------------------------------------------------------
  # Secondary and destructive actions
  # ---------------------------------------------------------------------------

  Scenario: Two-button layouts use FilledButton and OutlinedButton
    Given a screen or sheet with one primary and one secondary action in the same visual group
    Then the primary action is a FilledButton
    And the secondary action is an OutlinedButton
    And the two buttons are stacked vertically with 12 dp between them
    And both buttons are full-width

  Scenario: Standalone secondary actions use TextButton
    Given a secondary action that is positioned separately from the primary button
    Such as a "Cancel" link above a form, a "Skip" option below a prompt, or a dismiss link
    Then the secondary action uses TextButton
    And is never placed inside the same Scaffold.bottomNavigationBar slot as a FilledButton

  Scenario: Destructive actions use the error colour scheme
    Given a destructive action such as deleting a profile or removing tracked data
    Then the action button uses the error colour token
    And inline destructive actions in lists use IconButton with the error colour
    And dedicated destructive actions on edit screens use FilledButton with the error colour
    And the action is always preceded by a confirmation dialog before executing

  Scenario: Confirmation dialog for destructive actions uses specific copy
    Given a destructive action confirmation dialog
    Then the dialog title names the specific thing being deleted (e.g. "Delete profile?")
    And the confirm button is labelled "Delete" and uses the error colour
    And the cancel button is labelled "Cancel" and uses a neutral style
    And tapping outside the dialog or pressing the back button cancels the action

  # ---------------------------------------------------------------------------
  # Modal bottom sheet actions
  # ---------------------------------------------------------------------------

  Scenario: Modal sheet primary action follows the same button rules as full screens
    Given a modal bottom sheet with a save or confirm action
    Then the primary action is a FilledButton placed at the bottom of the sheet content
    And is padded 24 dp on left and right and 40 dp on the bottom
    And respects the device safe area

  Scenario: Modal sheet with a primary and secondary action uses a stacked layout
    Given a modal bottom sheet with both a primary and a secondary action
    Then the primary FilledButton is stacked above the secondary OutlinedButton
    And the two buttons are separated by 12 dp
    And both are full-width within the sheet padding

  Scenario: Modal sheets are non-dismissible when completing an action is required
    Given a modal sheet that the user must respond to before continuing
    Then isDismissible is false
    And enableDrag is false
    And the sheet can only be closed by tapping one of its action buttons

  # ---------------------------------------------------------------------------
  # Form validation errors
  # ---------------------------------------------------------------------------

  Scenario: Field-level validation errors appear inline below the field
    Given a form field that fails validation on submit
    Then a validation error message appears directly below the field
    And uses the error colour token
    And the message describes specifically what is wrong (e.g. "Name is required")
    And not a generic message (e.g. "Invalid input")

  Scenario: The primary action button remains disabled until required fields are valid
    Given a form with required fields
    When the user has not provided valid input for all required fields
    Then the primary action button has a null onPressed
    And no validation error is shown until the user attempts to submit or leaves a field

  # ---------------------------------------------------------------------------
  # Post-save feedback
  # ---------------------------------------------------------------------------

  Scenario: A brief snackbar confirms a successful save
    Given the user has tapped a primary action button and the save succeeded
    Then a SnackBar is shown at the bottom of the screen
    And the message confirms the action in past tense (e.g. "Entry saved", "Profile created")
    And the snackbar auto-dismisses after 3 seconds
    And no persistent dialog or overlay is shown

  Scenario: A save error shows a snackbar with a retry option
    Given the user has tapped a primary action button
    And the save operation fails
    Then a SnackBar is shown describing the failure in plain language
    And the snackbar includes a "Retry" action
    And the form remains open with the user's input intact

  # ---------------------------------------------------------------------------
  # AppBar conventions
  # ---------------------------------------------------------------------------

  Scenario: AppBar contains only navigation and informational controls
    Given any screen with an AppBar
    Then the AppBar contains the screen title and optional back navigation
    And secondary utility actions such as search or filter may appear in AppBar actions
    But the primary save or submit action is never placed in the AppBar

  Scenario: Icon-only AppBar actions include a tooltip and semantic label
    Given an AppBar action that uses an icon without visible text
    Then the IconButton has a tooltip that describes its action
    And the tooltip text is used as the semantic label for screen readers
    And the label is written in sentence case (e.g. "Filter entries", not "Filter Entries")

  # ---------------------------------------------------------------------------
  # Profile icon and AppBar action co-existence
  # ---------------------------------------------------------------------------

  Scenario: The profile icon is always visible and never hidden by other AppBar actions
    Given any screen with an AppBar that contains the profile icon
    When the screen also has utility actions in the AppBar trailing area
    Then the profile icon and all utility actions are simultaneously visible
    And no action button is clipped, hidden, or placed behind another element

  Scenario: The profile icon is always the rightmost element in the AppBar
    Given any screen that shows the profile icon in the AppBar
    Then the profile icon occupies the rightmost position in the trailing action row
    And all other utility actions (e.g. search, filter, overflow menu) appear to its left

  Scenario: AppBar trailing actions do not overlap the profile icon tap target
    Given a screen with both the profile icon and one or more utility actions
    Then every action button's tap target is fully within the visible screen bounds
    And no tap target overlaps the profile icon's tap target
    And the minimum gap between adjacent tap targets is 0 dp (standard IconButton sizing applies)

  Scenario: Screens requiring many AppBar actions use an overflow menu to preserve space
    Given a screen that would otherwise place three or more utility actions alongside the profile icon
    Then actions beyond the first two are collapsed into a trailing overflow (MoreVert) menu
    And the profile icon remains the rightmost element and is never moved into the overflow

  Scenario: CI or widget test detects when an AppBar action is obscured by the profile icon
    Given a widget test for any screen with an AppBar
    Then the test asserts that every expected action button is within visible bounds
    And the test fails if any IconButton's rect overlaps the profile icon's rect
