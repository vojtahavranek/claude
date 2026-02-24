# Validation Loop Reference

Detailed reference for the review -> fix -> re-review cycle.

## Overview

The validation loop is the quality backbone of complex-task-implementation. It replaces per-step user approval with automated, iterative code review.

```
[All waves complete]
        |
        v
  +---> Code Review Agent + Test Runner (parallel)
  |           |
  |           v
  |     Evaluate Results
  |           |
  |     PASS? --> Exit to Gate 2
  |           |
  |     NEEDS FIXES
  |           |
  |           v
  |     Fix Agent (addresses issues)
  |           |
  +-----<-----+ (max 3 iterations)
```

## Issue Tracking Across Iterations

### Issue Format

Each issue gets a unique identifier for tracking:

```
[iteration]-[severity]-[number]
Example: 1-CRIT-1, 1-IMP-3, 2-SUG-1
```

### Persistence Tracking

Track which issues persist across iterations:

```
Iteration 1: Found 1-CRIT-1, 1-IMP-1, 1-IMP-2, 1-SUG-1
  Fix agent addresses: 1-CRIT-1, 1-IMP-1, 1-IMP-2

Iteration 2: Found 2-IMP-1 (new), 1-SUG-1 (persists)
  1-CRIT-1: RESOLVED
  1-IMP-1: RESOLVED
  1-IMP-2: RESOLVED
  1-SUG-1: PERSISTS (was not auto-fixable)
  2-IMP-1: NEW (possibly introduced by fixes)
  Fix agent addresses: 2-IMP-1

Iteration 3: Found 1-SUG-1 (persists)
  All Critical/Important: RESOLVED
  Remaining: 1 Suggested item
  -> EXIT LOOP (only suggestions remain)
```

### Regression Detection

If a fix introduces new Critical/Important issues:
- Flag it explicitly: "Fix for [issue-id] introduced new issue [new-id]"
- The fix agent in next iteration should address both
- If same issue ping-pongs (fixed then reintroduced), flag as "potentially unfixable by automation" and escalate

## Review Agent Output Specification

The review agent MUST use this structured format:

```
Overall: PASS | PASS WITH NOTES | NEEDS FIXES

Critical Issues: (must fix - security, bugs, data corruption, logic errors)
- [C-1] [description] | [file:line] | [why it matters] | [suggested fix]

Important Issues: (should fix - error handling, edge cases, quality)
- [I-1] [description] | [file:line] | [why it matters] | [suggested fix]

Suggested: (nice to have - style, refactoring)
- [S-1] [description]

Auto-fixable: (subset of above that can be fixed without architectural changes)
- [C-1] [fix description]  (if a critical is auto-fixable)
- [I-1] [fix description]

Praise:
- [what was done well]

Integration Check:
- [Do changes from different implementation agents work together?]
- [Are imports/exports consistent?]
- [Do shared types/interfaces align?]

Plan Compliance:
- [Does the implementation match the plan's intent?]
- [Any deviations from the plan? If so, are they justified?]
```

## Fix Agent Behavior

### Priority Order

1. **Critical issues**: Always fix. These are security vulnerabilities, bugs, data corruption risks.
2. **Important issues**: Always fix. These are error handling gaps, missing edge cases.
3. **Test failures**: Always fix. Broken tests mean broken code.
4. **Auto-fixable Suggested**: Fix if clearly mechanical (formatting, naming, simple style).
5. **Non-auto-fixable Suggested**: Do NOT fix. These require architectural changes and should be noted for the user.

### Fix Constraints

- Fix agent should make minimal changes to address issues
- Do NOT refactor surrounding code while fixing
- Do NOT add features or improvements beyond the fix
- After fixing, run affected tests to verify

### Fix Report

```
Fixes Applied:
- [issue-id]: [what was done] | [file:line]
- [issue-id]: [what was done] | [file:line]

Not Fixed (with reason):
- [issue-id]: [reason - e.g., "requires architectural change", "ambiguous requirement"]

Tests After Fixes:
- [pass/fail count]
- [any new failures introduced?]
```

## Decision Matrix

| Review Result | Tests | Action |
|--------------|-------|--------|
| PASS | Pass | Exit loop -> Gate 2 |
| PASS WITH NOTES | Pass | Exit loop -> Gate 2 (note suggestions) |
| PASS | Fail | Continue loop (fix test failures) |
| PASS WITH NOTES | Fail | Continue loop (fix test failures) |
| NEEDS FIXES | Pass | Continue loop (fix review issues) |
| NEEDS FIXES | Fail | Continue loop (fix both) |
| Any (iteration 3) | Any | Exit loop -> Gate 2 (escalate remaining) |

## Escalation Criteria

Issues are escalated to the user at Gate 2 when:

1. **Max iterations reached** (3) with unresolved Critical/Important issues
2. **Persistent issues** that appear in all iterations (unfixable by automation)
3. **Regression loop** where fixes keep introducing new issues
4. **Architectural issues** flagged by reviewer as needing design changes

## Performance Notes

- Each iteration spawns 2-3 agents (reviewer + test runner + optional fix agent)
- Typical validation: 1-2 iterations for clean code, 2-3 for complex changes
- If iteration 1 produces PASS, the loop exits immediately (best case)
- Budget for worst case: 3 iterations = ~9 agent invocations in validation phase
