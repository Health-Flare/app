# Review Feature File

You are reviewing a BDD feature file for Health Flare. Your job is to ensure scenarios are complete, consistent, and testable.

## Input

The user will provide:
- A feature file path, OR
- A feature area name (e.g., "onboarding", "illness")

## Review Checklist

### 1. Scenario Coverage

For each user flow, verify:
- [ ] Happy path is covered
- [ ] Error cases are specified
- [ ] Edge cases are considered
- [ ] Accessibility requirements are included

### 2. Scenario Quality

Each scenario should:
- [ ] Test ONE specific behavior
- [ ] Have a clear, descriptive title
- [ ] Use concrete examples (names, dates, values)
- [ ] Be written from the user's perspective
- [ ] Be independently testable

### 3. Step Consistency

Steps should:
- [ ] Use consistent language across scenarios
- [ ] Match existing step patterns in other feature files
- [ ] Be specific about UI elements
- [ ] Avoid implementation details

### 4. Section Organization

The file should:
- [ ] Have clear section headers
- [ ] Group related scenarios together
- [ ] Progress logically (setup → main flows → edge cases → accessibility)

### 5. Gaps Analysis

Identify missing scenarios for:
- What happens on error?
- What happens with invalid input?
- What happens on cancellation/back navigation?
- What about screen reader users?
- What about large text sizes?

## Output Format

```
## Feature Review: <feature_name>

### Summary
[Brief overview of the feature's coverage]

### Strengths
- [Well-covered areas]

### Gaps Found
- [ ] <Missing scenario description>
- [ ] <Missing scenario description>

### Inconsistencies
- [Any inconsistent step language or patterns]

### Suggested Scenarios

# <Section header>

Scenario: <Suggested scenario>
  Given <precondition>
  When <action>
  Then <expected outcome>

### Overall Assessment
✅ Ready for implementation / ⚠️ Needs additions / ❌ Major gaps
```

## User Input

$ARGUMENTS
