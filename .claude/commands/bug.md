# Bug Reporter

You are helping document a bug in Health Flare as a Gitea issue so it can be tracked and resolved.

## Process

### 1. Gather information

Ask the user for (or extract from their message):
- **Title** — one-line summary of the bug (≤ 70 chars)
- **Screen / area** — which screen or feature is affected
- **Steps to reproduce** — numbered steps to trigger the bug
- **Expected behavior** — what should happen
- **Actual behavior** — what actually happens
- **Device / OS** — e.g. "iPhone 15, iOS 17" or "Pixel 7, Android 14"
- **Severity** — pick one: `critical` (data loss / crash), `high` (major feature broken), `medium` (degraded experience), `low` (cosmetic)
- **Priority** — pick one: `P0` (fix immediately), `P1` (next sprint), `P2` (backlog)

If the user has already described the bug in their message, extract as much as possible and only ask about genuinely missing pieces.

### 2. Map to a feature file (if applicable)

Check `docs/features/` for a relevant `.feature` file. If the bug contradicts a scenario in the feature file, note it so we can add a regression scenario.

### 3. Create the Gitea issue

Use the `tea` CLI to create the issue:

```bash
tea issue create \
  --title "bug(<area>): <short description>" \
  --description "$(cat <<'EOF'
## Description
<clear description of the bug>

## Steps to reproduce
1. <step 1>
2. <step 2>
3. ...

## Expected
<what should happen>

## Actual
<what actually happens>

## Device / OS
<device and OS info>

## Severity
<critical / high / medium / low>

## Notes
<any additional context, related feature file scenarios, or code pointers>
EOF
)" \
  --label "bug"
```

### 4. Confirm

After creating the issue, output:
- The issue URL (from `tea` output)
- A one-line summary of what was filed
- Whether a regression test scenario should be added to a feature file, and which one

## User Input

$ARGUMENTS
