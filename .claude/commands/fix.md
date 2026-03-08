# Fix Issue

You are fixing an issue in Health Flare. Follow this process to ensure the fix is complete and doesn't introduce regressions.

## Input

The user will describe:
- An error message
- A bug they observed
- A test failure
- A lint/analysis warning

## Process

### 1. Understand the Issue

1. If an error message is provided, identify the root cause
2. If a bug is described, locate the relevant code
3. Read the related feature file to understand expected behavior

### 2. Find the Code

Search for:
- The file and line mentioned in errors
- The screen/widget where the bug appears
- The provider handling the logic

### 3. Identify the Fix

Before changing code:
1. Understand WHY the bug exists
2. Determine the minimal change needed
3. Consider if this should become a regression test

### 4. Write a Regression Test (if applicable)

For bugs that could recur:
1. Add a scenario to the feature file
2. Write a test that would have caught this bug
3. Verify the test fails with current code (optional)

### 5. Apply the Fix

Make the minimal change to fix the issue:
- Don't refactor unrelated code
- Don't add features
- Don't change formatting of untouched code

### 6. Validate

```bash
flutter analyze
flutter test
```

## Output

Provide:
1. Root cause analysis
2. The fix applied
3. Any regression test added
4. Validation results

## User Input

$ARGUMENTS
