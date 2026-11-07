# Validation Reference

Detailed reference for the two-tier quality model: per-step duo review + post-wave integration review.

## Overview

Quality assurance happens at two levels:

```
Tier 1: Per-Step Duo Review (during implementation)
  Each step has a developer + reviewer teammate.
  They iterate together: implement → review → fix → re-review.
  Max 3 review rounds per duo.

Tier 2: Final Integration Review (after ALL waves complete — Stage 2)
  Checks cross-step compatibility: imports, types, API contracts.
  Lighter than Tier 1 — individual quality already assured.
  Max 2 iterations.

Note: Each wave also has a quick integration check (build, lint, tests)
in Stage 1 Step 5, but the full Tier 2 review runs once after all waves.
```

## Tier 1: Per-Step Duo Review

### How the Duo Works

```
Developer                         Reviewer
    |                                 |
    |-- implements step               |
    |                                 |
    |-- "ready for review" --------->  |
    |                                 |-- reads changes
    |                                 |-- reviews against checklist
    |                                 |
    |  <-------- feedback ----------- |
    |                                 |
    |-- fixes issues                  |
    |                                 |
    |-- "fixes applied" -----------> |
    |                                 |-- re-reviews
    |                                 |
    |  <-------- APPROVED ---------- |
    |                                 |
    [both report completion to orchestrator]
```

### Reviewer Checklist

Per-step reviewers focus on **individual step quality**:

1. Security vulnerabilities (injection, XSS, auth bypass)
2. Logic errors and bugs
3. Error handling gaps
4. Missing edge cases
5. Code quality (naming, structure, duplication)
6. Plan compliance (does implementation match this step's intent?)
7. Success criteria met?

**NOT in scope for per-step review** (these are Tier 2):
- Cross-step import consistency
- Type alignment between steps
- API contract matching between producers and consumers

### Reviewer Feedback Format

```
Verdict: APPROVED | NEEDS FIXES

Critical Issues: (must fix — security, bugs, data corruption)
- [issue] | [file:line] | [why] | [suggested fix]

Important Issues: (should fix — error handling, edge cases)
- [issue] | [file:line] | [why] | [suggested fix]

Suggestions: (optional — do NOT block approval for these)
- [suggestion]

What's good:
- [praise]
```

### Duo Iteration Limits

- **Max 3 review rounds** per duo
- After round 3, reviewer MUST approve with remaining issues noted as "unresolved"
- Unresolved issues escalate to Tier 2 integration review
- If issues persist to Gate 2, user decides

### Issue Tracking Within a Duo

Each issue gets an identifier for tracking across rounds:

```
Round 1: Found C-1, I-1, I-2
  Developer fixes: C-1, I-1, I-2

Round 2: C-1 resolved, I-1 resolved, I-2 partially fixed, new I-3
  Developer fixes: I-2 (remainder), I-3

Round 3: All resolved
  -> APPROVED
```

Or at max iterations:
```
Round 3: I-2 still not fully resolved
  -> APPROVED WITH NOTES: "I-2 unresolved — [description]"
  -> Escalates to integration review
```

### Regression Detection

If a fix introduces a new issue:
- Reviewer flags it: "Fix for [issue] introduced [new issue]"
- Developer addresses both in next round
- If same issue ping-pongs across rounds, flag as "needs orchestrator attention"

---

## Tier 2: Final Integration Review (Stage 2)

### Purpose

After ALL waves complete, verify that independently-developed pieces work together across the full implementation. This is a single review pass over all changes, not per-wave.

Note: Each wave already gets a quick integration check (build, lint, tests) in Stage 1 Step 5. Tier 2 is the deeper cross-step review.

```
[ALL waves complete]
        |
        v
  +---> Integration Reviewer + Test Runner (parallel)
  |           |
  |           v
  |     Evaluate Results
  |           |
  |     PASS? --> Proceed to Gate 2
  |           |
  |     NEEDS FIXES
  |           |
  |           v
  |     Fix (orchestrator or fix teammate)
  |           |
  +-----<-----+ (max 2 iterations)
```

### Integration Checklist

Integration reviewers focus ONLY on cross-step concerns:

1. **Cross-step imports/exports**: Do files from Step A correctly import from Step B's output?
2. **Shared types**: Do type definitions from different steps align?
3. **API contracts**: Do API consumers match producers across step boundaries?
4. **Database/state**: Are migrations, schema changes, and data flows coherent across steps?
5. **Configuration**: Are all new env vars, config keys consistent?
6. **Missing glue**: Is any wiring code needed to connect steps?
7. **Plan compliance**: Does the aggregate match the plan's overall intent?

### Integration Review Output

```
Overall: PASS | NEEDS FIXES

Integration Issues:
- [issue] | [files from different steps] | [which steps conflict] | [fix]

Missing Glue:
- [what needs connecting] | [between which steps]

Plan Compliance:
- [overall assessment]
```

### Decision Matrix

| Integration Review | Tests | Action |
|-------------------|-------|--------|
| PASS | Pass | Proceed to Gate 2 |
| PASS | Fail | Fix test failures, re-run |
| NEEDS FIXES | Pass | Fix integration issues, re-review |
| NEEDS FIXES | Fail | Fix both, re-review |
| Any (iteration 2) | Any | Escalate remaining to Gate 2 |

### Why Max 2 Iterations (Not 3)

Per-step quality is already handled by duos. Integration issues are typically:
- Missing imports (1-line fix)
- Type mismatches across boundaries (straightforward)
- Missing wiring code (small additions)

These are usually resolved in 1 iteration. The 2nd iteration is a safety net, not the norm.

---

## Escalation to User (Gate 2)

Issues reach the user at Gate 2 when:

1. **Duo unresolved**: A reviewer approved with notes after 3 rounds
2. **Integration stuck**: Cross-step issues persist after 2 integration iterations
3. **Test failures**: Tests still failing after integration fixes
4. **Architectural issues**: Reviewer flagged something needing design-level changes

At Gate 2, the user sees all unresolved issues and chooses: accept, fix more, or rollback.

## Performance Notes

- **Per-step duo**: 1-3 review rounds each (typically 1-2 for well-written plans)
- **Integration check**: 1-2 iterations per wave (typically 1)
- **Best case**: All duos approve in round 1, integration passes immediately
- **Worst case**: 3 duo rounds + 2 integration iterations = 5 review cycles total
- **vs old model**: Old batch review needed 3 iterations reviewing ALL code at once. Duos spread the review work across steps with better context per reviewer.
