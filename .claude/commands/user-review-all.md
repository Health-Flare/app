# Full User Review — All Personas

Run a full user review of all Health Flare feature files across three distinct user personas in parallel, then synthesise the findings.

## Step 1 — Launch three parallel persona reviews

Invoke the Agent tool three times **simultaneously** (in a single response) with the following personas. Each agent should independently read all feature files in `docs/features/` and produce its review.

### Agent 1: Solo User with Illness (`user-review-solo`)
Prompt the agent with the full contents of `.claude/commands/user-review-solo.md`.
Persona: Alex, 34, fibromyalgia + CFS, tracking only for themselves.

### Agent 2: Parent with a Dependent with Illness (`user-review-parent`)
Prompt the agent with the full contents of `.claude/commands/user-review-parent.md`.
Persona: Jordan, 42, healthy parent tracking for child Mia (juvenile idiopathic arthritis).

### Agent 3: User with Illness AND Dependents with Illness (`user-review-dual`)
Prompt the agent with the full contents of `.claude/commands/user-review-dual.md`.
Persona: Sam, 38, Crohn's disease, also tracking daughter Lily (T1D) and mother Rose (COPD + lupus).

## Step 2 — Wait for all three agents to complete

Do not proceed until all three agents have returned their full reviews.

## Step 3 — Synthesise findings

Produce a consolidated report with this structure:

```
# Health Flare — Full Persona Review

## Participants
- Alex (solo user with illness)
- Jordan (parent, tracking dependent only)
- Sam (self + two dependents with illness)

---

## Feature-by-Feature Consensus

For each feature file reviewed, summarise:
- Where all three personas agree it works well
- Where two or more personas found the same gap
- Persona-specific gaps that only one user identified
- Priority: 🔴 Critical / 🟡 Important / 🟢 Nice to have

---

## Top Issues by Theme

### Theme: [e.g. Multi-profile safety]
- [consolidated finding]
- Affects: [which personas]
- Suggested scenario(s): [Gherkin stubs]

### Theme: [e.g. Carer vs patient language]
...

---

## Prioritised Scenario Backlog

Rank the missing scenarios from highest to lowest priority, formatted as:

| Priority | Feature | Scenario Title | Persona(s) |
|----------|---------|---------------|-----------|
| 🔴 | profiles | Switching profiles shows whose data is active | Jordan, Sam |
| ...

---

## Overall Assessment

[2-3 paragraph summary of the app's readiness across all three user types]
```

## Notes

- Read `.claude/commands/user-review-solo.md`, `.claude/commands/user-review-parent.md`, and `.claude/commands/user-review-dual.md` to get the full persona definitions before launching the agents.
- Feature files are in `docs/features/`; skip `developer-experience.feature`
- The synthesis should surface cross-cutting themes, not just concatenate the three reviews

$ARGUMENTS
