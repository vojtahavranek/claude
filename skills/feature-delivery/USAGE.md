# Feature Delivery — Usage

```
"deliver feature: <what you want>"
"use feature delivery for <issue / idea>"
```

What happens:
1. **Brief** — the orchestrator reads the project and asks you everything in one round
   (behaviour, edge cases, out of scope, acceptance criteria).
2. **Gate 1** — you approve the run sheet: the brief, the risk tier, the model of each
   agent, branch, checks, delivery. This is the only approval.
3. **Plan wave** — a planner writes the plan to `<project>/.claude/task/<name>.md`, a
   plan reviewer checks it against the code, a judge decides which findings are real;
   the planner revises.
4. **Implementation wave** — a developer implements the plan (one commit per step), a
   code reviewer reviews the diff, a judge decides which findings are real; the
   developer fixes.
5. **Deliver** — full check suite, push, PR, CI, a summary. You merge.

**Tiers** set the models. The plan gets stronger models than the implementation, and a
reviewer is never weaker than its author:

| Tier | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|------|------|
| `light` (docs, copy, isolated UI) | Opus / Opus / Sonnet | Sonnet / Opus / Sonnet |
| `normal` (a feature with logic) | Opus / Fable / Opus | Opus / Fable / Opus |
| `risky` (data, auth, money, install, deploy) | Fable / Fable / Opus | Opus / Fable / Opus |

Overrule the tier or any single model at Gate 1.

It only stops mid-run for real blockers: a decision that is yours and the brief left
open, a Critical finding or red checks that survive two fix rounds, or anything
destructive beyond opening the PR.

**Several features at once**: name them all; each gets its own brief, worktree and waves.

**Already have a plan?** `"implement plan: <path>"` (task-implementation).
**Want the plan only?** `"use task preparation for <feature>"`.
