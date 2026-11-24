# Orchestrator Mode — Usage

```
"orchestrator mode"                    # the session becomes the orchestrator
"deliver feature: <what you want>"     # the same, starting with this feature
"autonomous orchestrator mode"         # every run of the session autonomous (below)
"deliver feature autonomously: <what>" # this one run autonomous
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
   delivery. This is the only approval; in an autonomous full run it comes after the
   reviewed plan.
3. **The run**, in one of two shapes:
   - **lean** (two agents) — a developer builds from the brief, tests first; a reviewer
     checks the brief and the code together and proves its findings by running them;
     the orchestrator rules on the findings.
   - **full** (six agents), for risky changes and important features — a plan wave (planner, plan reviewer, a judge of the
     review), then an implementation wave (developer, code reviewer, a judge of the
     review).

   Either way the run's file is `<project>/.claude/task/<name>.md`: the run sheet, the
   brief, the orchestrator's rulings, and the steps (the plan, in a full run).
4. **Deliver** — the full suite on the final commit on every supported runtime version,
   push, PR, CI, a summary. In a supervised run you merge, unless the run sheet gives the
   merge to the orchestrator; an autonomous run the orchestrator merges.

**Two autonomies**, named on every run sheet; change it for one run at Gate 1:

| | supervised (the default) | autonomous |
|---|---|---|
| Ends at | an open PR; you merge | a merged PR |
| Gate 1 of a full run | after the brief | after the reviewed plan, with every decision the plan left open |
| A decision that is yours, mid-run | it stops and asks | it takes its recommendation and lists it under "Decided for you", with how to undo it |
| A real blocker | it stops and asks | it parks that run (a draft PR when the checks are green, never a merge), tells you, and goes on with the others |

Before a project's first autonomous run it asks you two things, once: whether it may
merge when a merge deploys (every run, every run except `risky` ones, or none), and
whether it may bypass a required review on its own PRs where your account can. After a
merge that deploys it verifies the deploy; a failed one stops all further merges in that
project and comes to you.

**Tiers** set the models and the default shape. A reviewer is never weaker than its
author:

| Tier | Shape | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|-------|------|------|
| `light` (docs, copy, isolated UI) | lean | Opus / Opus / Sonnet | Sonnet / Opus / Sonnet |
| `normal` (a feature with logic) | lean; full when important | Opus / Fable / Opus | Opus / Fable / Opus |
| `risky` (data, auth, money, install, deploy) | full | Fable / Fable / Opus | Opus / Fable / Opus |

A lean run uses the implementation column's author and reviewer, and no judge. A `normal`
feature runs full when it is important: you call it important, its design is still open
after the brief, other work will build on it, or it is likely to need more than about 8
steps. Overrule the tier, the shape or any single model at Gate 1.

A supervised run only stops mid-run for real blockers: a decision that is yours and the
brief left open, a Critical finding or red checks that survive the fix rounds, an action
the permission system refused, or anything destructive beyond opening the PR. An
autonomous run decides the first and parks on the rest.

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
stopped. A parked run is marked `[-]`: the orchestrator shows you its open point and
resumes on your answer.

**A red baseline**: you choose between fixing it first and working on top of it; on top,
the failing tests are carried as known failures in every run.

**Already have a plan?** `"implement plan: <path>"` (task-implementation).
**Want the plan only?** `"use task preparation for <feature>"`.
