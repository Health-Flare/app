# Scenario Writer

You are writing BDD scenarios for Health Flare, a chronic illness tracking Flutter app. Your job is to translate user requirements into Gherkin scenarios.

## Input

The user will describe a capability or behavior they want to specify. This could be:
- A new feature idea
- An edge case that needs documenting
- A bug that should become a regression test scenario
- An enhancement to existing functionality

## Process

1. **Identify the feature area**: Determine which feature file this belongs to:
   - Onboarding → `docs/features/onboarding.feature`
   - Illness/conditions → `docs/features/illness.feature`
   - Journal entries → `docs/features/journal.feature`
   - Profiles → `docs/features/profiles.feature`
   - Navigation → `docs/features/navigation.feature`
   - Symptoms/vitals → `docs/features/symptoms_and_vitals.feature`
   - Medications → `docs/features/medications.feature`
   - Meals → `docs/features/meals.feature`
   - Reports → `docs/features/reports.feature`
   - Developer experience → `docs/features/developer-experience.feature`
   - Data storage → `docs/features/datastore.feature`

2. **Read the existing feature file**: Understand the context, existing scenarios, and writing style

3. **Write scenarios** following these guidelines:
   - Each scenario tests ONE behavior
   - Use concrete examples, not abstract descriptions
   - Write from the user's perspective (I/me)
   - Be specific about UI elements and interactions
   - Group related scenarios under section headers (`# -----------`)

4. **Use consistent step patterns**:
   ```gherkin
   # Preconditions
   Given I am on the <screen> screen
   Given a profile named "<name>" exists and is active
   Given the app has been launched for the first time

   # Actions
   When I tap "<button text>"
   When I enter "<text>" in the <field> field
   When I scroll to "<element>"
   When I navigate to <destination>

   # Assertions
   Then I see "<text>"
   Then the <element> is visible/hidden/enabled/disabled
   Then a <record type> is created/saved
   Then I am taken to the <screen>
   ```

5. **Present scenarios**: Show the user the scenarios before adding them to the file

## Output Format

```gherkin
# ---------------------------------------------------------------------------
# <Section title>
# ---------------------------------------------------------------------------

Scenario: <Descriptive title>
  Given <precondition>
  When <action>
  Then <expected outcome>
```

## User Input

$ARGUMENTS
