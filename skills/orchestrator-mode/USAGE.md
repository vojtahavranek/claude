# Orchestrator Mode — Usage

```
"orchestrator mode"                    # the session becomes the orchestrator
"deliver feature: <what you want>"     # the same, starting with this feature
"exit orchestrator mode"               # back to a normal session
```

The mode lasts for the session. Once, at the start, the orchestrator reads the project,
collects its checks, the runtime versions it supports and the rules of your machine, and
runs the full suite on the default branch as a baseline. Then, for every feature you
bring:

1. **Brief** — it reads the code and asks you everything in one round (behaviour, edge
   cases, out of scope, acceptance criteria).
2. **Gate 1** — you approve the run sheet: the brief, the risk tier, the shape of the
   run, the model of each agent, an estimate with the cheaper option, branch, checks,
   delivery. This is the only approval.
3. **The run**, in one of two shapes:
   - **lean** (two agents) — a developer builds from the brief, tests first; a reviewer
     checks the brief and the code together and proves its findings by running them;
     the orchestrator rules on the findings.
   - **full** (six agents) — a plan wave (planner, plan reviewer, a judge of the
     review), then an implementation wave (developer, code reviewer, a judge of the
     review).

   Either way the run's file is `<project>/.claude/task/<name>.md`: the run sheet, the
   brief, the orchestrator's rulings, and the steps (the plan, in a full run).
4. **Deliver** — the full suite on the final commit on every supported runtime version,
   push, PR, CI, a summary. You merge, unless the run sheet gives the merge to the
   orchestrator.

**Tiers** set the models and the default shape. A reviewer is never weaker than its
author:

| Tier | Shape | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|-------|------|------|
| `light` (docs, copy, isolated UI) | lean | Opus / Opus / Sonnet | Sonnet / Opus / Sonnet |
| `normal` (a feature with logic) | lean | Opus / Fable / Opus | Opus / Fable / Opus |
| `risky` (data, auth, money, install, deploy) | full | Fable / Fable / Opus | Opus / Fable / Opus |

A lean run uses the implementation column's author and reviewer, and no judge. Overrule
the tier, the shape or any single model at Gate 1.

It only stops mid-run for real blockers: a decision that is yours and the brief left
open, a Critical finding or red checks that survive the fix rounds, an action the
permission system refused, or anything destructive beyond opening the PR.

**While a run is in flight** you can already agree the next feature's brief; features in
flight together each get their own worktree, and two that touch the same files land one
after the other. Ask for "status" to see the ledger of runs.

**What you get at the end**: the PR, what you will see in the product, how each
acceptance criterion was verified, the decisions the orchestrator took for you along
the way, and what no test could prove.

**Small asks**: questions the orchestrator answers itself; a change with no judgement in
it (a typo, a dictated rename) gets one developer agent and no waves.

**Resume**: start the mode again. Each run's brief, run sheet and rulings are saved at
the head of its plan file, and a run marked `[~]` in TASKS.md is picked up where it
stopped.

**A red baseline**: you choose between fixing it first and working on top of it; on top,
the failing tests are carried as known failures in every run.

**Already have a plan?** `"implement plan: <path>"` (task-implementation).
**Want the plan only?** `"use task preparation for <feature>"`.
