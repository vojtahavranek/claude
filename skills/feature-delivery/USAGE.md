# Feature Delivery — Usage

```
"feature delivery mode"                  # the session becomes the orchestrator
"deliver feature: <what you want>"       # the same, starting with this feature
"exit feature delivery"                  # back to a normal session
```

The mode lasts for the session. Once, at the start, the orchestrator reads the project,
collects its checks and runs the full suite on the default branch as a baseline. Then,
for every feature you bring:

1. **Brief** — it reads the code and asks you everything in one round (behaviour, edge
   cases, out of scope, acceptance criteria).
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

**While a wave runs** you can already agree the next feature's brief; features in
flight together each get their own worktree. Ask for "status" to see the ledger of runs.

**Small asks**: questions the orchestrator answers itself; a change with no judgement in
it (a typo, a dictated rename) gets one developer agent and no waves.

**Already have a plan?** `"implement plan: <path>"` (task-implementation).
**Want the plan only?** `"use task preparation for <feature>"`.
