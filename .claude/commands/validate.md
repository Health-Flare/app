# Validate

You are validating Health Flare code changes. Run the full validation suite and report results.

## Validation Steps

Run all of the following checks:

### 1. Static Analysis
```bash
flutter analyze
```
**Requirement:** Must exit with code 0, no warnings or errors.

### 2. Code Formatting
```bash
dart format --output=none --set-exit-if-changed .
```
**Requirement:** Must exit with code 0.

### 3. Tests
```bash
flutter test
```
**Requirement:** All tests must pass.

### 4. Build (optional, if requested)
```bash
flutter build apk --debug
```
**Requirement:** Must complete successfully.

## Offline-First Checks

Manually verify:
- No `http://` or `https://` URLs in Dart files (except comments)
- No `google_fonts` import
- No network-related packages imported

## Report Format

Provide a summary:

```
## Validation Results

### Static Analysis
✅ PASS / ❌ FAIL
[Details if failed]

### Formatting
✅ PASS / ❌ FAIL
[Details if failed]

### Tests
✅ PASS / ❌ FAIL
[X passed, Y failed]
[Failure details if any]

### Offline Compliance
✅ PASS / ❌ FAIL
[Issues if any]

### Overall
✅ Ready to commit / ❌ Issues to fix
```

## Fixing Issues

If validation fails:
1. For formatting issues: Run `dart format .`
2. For lint issues: Fix the reported problems
3. For test failures: Debug and fix the tests
4. For offline violations: Remove network dependencies

## User Input

$ARGUMENTS
