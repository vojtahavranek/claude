# Complex Task Implementation - Quick Start

## What Is This?

Autonomous parallel plan execution using **Agent Teams** with **developer+reviewer duos**. Unlike `task-implementation`, which runs steps one at a time, this skill:

1. Gets your approval on the execution strategy (once)
2. Spawns developer+reviewer duo teammates per step — they iterate on quality together
3. Merges results per wave with a lightweight integration check
4. Presents final results for your acceptance (once)

**Only 2 approval gates** instead of N. Quality is built into each step via inline review.

## Comparison

| | task-implementation | complex-task-implementation |
|---|---|---|
| **Approval** | Per-step (N gates) | Strategy + final only (2 gates) |
| **Execution** | Sequential | Parallel waves (Agent Teams) |
| **Quality** | User verifies each step | Developer+reviewer duos per step |
| **Integration** | N/A (sequential) | Lightweight post-wave check |
| **Speed** | Slower (waiting for approvals) | Faster (parallel + autonomous) |
| **Control** | Maximum (every step) | Strategic (plan-level) |
| **Best for** | Learning codebase, risky changes, small plans | Trusted plans, speed, complex work (8+ steps) |
| **Agents** | Single (orchestrator only) | Teammates: dev+reviewer duos per step |

## Prerequisites

- **Agent Teams enabled**: Set `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your Claude Code settings env
- A complete plan file
- Clean git working tree

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

You'll see the wave decomposition showing which steps run in parallel, each with a developer+reviewer duo. Approve, modify, or switch to sequential (task-implementation).

### 4. Wait

Duos execute in parallel within each wave. Each developer implements while their paired reviewer gives inline feedback. You'll see brief progress updates between waves (not approval gates). Go grab a coffee.

### 5. Review Results

Final report shows: what was implemented, per-step review results, integration validation, and test results. Accept, request more fixes, or rollback.

## Check Progress

While execution is running:
```
/tasks
```

Shows current wave, completed steps, duo review iterations, validation status.

## FAQ

**Q: What if Agent Teams is not enabled?**
A: The skill falls back to the Agent tool with worktree isolation. Duos still work but communication goes through the orchestrator instead of direct teammate messaging.

**Q: What's different about the duo model?**
A: Each step gets a paired developer and code-reviewer. They communicate directly — the developer implements, the reviewer reviews, the developer fixes issues, the reviewer re-checks. Quality is built into each step instead of checked in a batch after everything is done.

**Q: What if a duo can't agree?**
A: After 3 review rounds, the reviewer approves with remaining issues noted. These surface in the integration check and/or the final review for your decision.

**Q: What about merge conflicts?**
A: Duos work on isolated copies. Conflicts are rare because each duo has non-overlapping file scope. If conflicts occur, automatic resolution is attempted first.

**Q: How does integration validation work?**
A: Since each step is already reviewed by its duo, integration validation only checks cross-step compatibility (imports, types, API contracts between steps). It's lighter — max 2 iterations vs 3 in the old model.

**Q: Can I rollback everything?**
A: Yes. The base commit is recorded at start. At final review, option D rolls back all changes.

**Q: When should I use task-implementation instead?**
A: When you want to approve each step, are working in an unfamiliar codebase, or the plan has fewer than 5 steps.

## Learn More

- Full workflow: `~/.claude/skills/complex-task-implementation/SKILL.md`
- Dependency analysis: `~/.claude/skills/complex-task-implementation/references/dependency-analysis.md`
- Merge strategy: `~/.claude/skills/complex-task-implementation/references/merge-strategy.md`
- Validation loop: `~/.claude/skills/complex-task-implementation/references/validation-loop.md`
- Example walkthrough: `~/.claude/skills/complex-task-implementation/examples/parallel-execution-example.md`
