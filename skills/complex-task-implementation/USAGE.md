# Complex Task Implementation - Quick Start

## What Is This?

Autonomous parallel plan execution with iterative validation. Unlike `task-implementation` which asks for approval at every step, this skill:

1. Gets your approval on the execution strategy (once)
2. Runs all steps in parallel waves using isolated agents
3. Validates quality through automated code review loops
4. Presents final results for your acceptance (once)

**Only 2 approval gates** instead of N.

## Comparison

| | task-implementation | complex-task-implementation |
|---|---|---|
| **Approval** | Per-step (N gates) | Strategy + final only (2 gates) |
| **Execution** | Sequential | Parallel (waves) |
| **Validation** | User verifies each step | Automated review-fix loop |
| **Speed** | Slower (waiting for approvals) | Faster (parallel + autonomous) |
| **Control** | Maximum (every step) | Strategic (plan-level) |
| **Best for** | Learning codebase, risky changes, small plans | Trusted plans, speed, complex work (8+ steps) |
| **Agents** | Single (orchestrator only) | Multiple (implement + review + fix) |

## Quick Start

### 1. Have a Plan

Either create one with task-preparation:
```
"use task preparation for payment processing"
```

Or point to an existing plan file.

### 2. Invoke the Skill

```
"execute complex plan: .claude/task/payment-processing.md"
"run complex implementation: payment-processing"
"parallel implement: ./plans/feature.md"
```

### 3. Approve Strategy

You'll see the wave decomposition showing which steps run in parallel. Approve, modify, or switch to step-by-step.

### 4. Wait

Agents execute in parallel. You'll see brief progress updates (not approval gates). Go grab a coffee.

### 5. Review Results

Final report shows: what was implemented, validation results, code review output. Accept, request more fixes, or rollback.

## Check Progress

While execution is running:
```
/tasks
```

Shows current wave, completed steps, validation iteration.

## FAQ

**Q: What if an agent fails?**
A: The step is marked as failed, downstream dependencies are flagged, but other steps continue. Failed steps are reported at final review.

**Q: What about merge conflicts?**
A: Agents work on isolated copies (git worktrees). Conflicts are rare because agents have non-overlapping file scopes. If conflicts occur, automatic resolution is attempted first.

**Q: How does the validation loop work?**
A: A code review agent inspects all changes and categorizes issues (Critical/Important/Suggested). If fixes are needed, a fix agent addresses them. Then a fresh reviewer re-checks. Max 3 iterations.

**Q: Can I rollback everything?**
A: Yes. The base commit is recorded at start. At final review, option D rolls back all changes with `git reset --hard`.

**Q: When should I use task-implementation instead?**
A: When you want to approve each step, are working in an unfamiliar codebase, or the plan has fewer than 5 steps.

## Learn More

- Full workflow: `~/.claude/skills/complex-task-implementation/SKILL.md`
- Dependency analysis: `~/.claude/skills/complex-task-implementation/references/dependency-analysis.md`
- Merge strategy: `~/.claude/skills/complex-task-implementation/references/merge-strategy.md`
- Validation loop: `~/.claude/skills/complex-task-implementation/references/validation-loop.md`
- Example walkthrough: `~/.claude/skills/complex-task-implementation/examples/parallel-execution-example.md`
