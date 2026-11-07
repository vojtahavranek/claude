---
name: task-implementation
description: |
  Execute a saved implementation plan autonomously, step by step: a developer subagent builds each step, a fresh reviewer subagent checks it, the orchestrator verifies and commits. One approval up front, one at the end.
  Use when: "implement plan", "execute plan", or the user hands over a plan file.
  Plans with 2+ independent work streams worth parallelizing: use complex-task-implementation. No plan yet: use task-preparation.
---

# Task Implementation

You are the **orchestrator**. You do not write the plan's code yourself (except `inline` steps, below); you dispatch, verify, and commit. Subagent reports are claims; `git diff` and your own check runs are the truth.

Invoking this skill is the user's explicit request to implement autonomously. The two gates below replace per-step approval.

## Stage 0: Intake

1. **Load the plan.** A path → read it. A bare name → `<project>/.claude/task/<name>.md`; not there → ask. Inline → use the message.
2. **Read the project's CLAUDE.md** and collect every check it lists (tests, lint, format, types, build, E2E). Split them into **fast checks** (seconds; a dev runs them every step) and the **full suite** (everything; run at the end).
3. **Git preflight.**
   - Tracked files dirty (`git status --porcelain`, ignoring `??`) → stop, ask the user to commit or stash.
   - On the default branch → `git checkout -b feature/<plan-name>` (or the branch the plan names). Always branch from the default branch.
   - Record `BASE=$(git rev-parse HEAD)`.
   - **Resume**: already on this plan's branch with commits → `git log --oneline $BASE..HEAD` (or since the merge-base with the default branch); every `Step N:` commit is done. Continue from the first missing step.
4. **Assign each step a review depth**:
   - `full`: developer subagent + reviewer subagent. The default for anything with logic, data, auth, or public interfaces.
   - `light`: developer subagent only; the final review covers it. Mechanical changes (renames, wiring, config, docs).
   - `inline`: you do it directly. A few lines with no judgement involved.

## Gate 1: Strategy

Present, then ask with AskUserQuestion (Approve / Adjust / Cancel):

```
Plan: <name>   Branch: <branch> @ <short BASE>
Steps:
  1. <title> — <files> — full
  2. <title> — <files> — light
  ...
Fast checks: <commands>   Full suite: <commands>
Delivery: <PR to main | commit only, per project CLAUDE.md>
Risks / plan gaps: <anything the plan leaves unclear>
```

If the plan has 2+ independent streams across 8+ steps, say complex-task-implementation would parallelize it. Adjust → revise and re-present.

## Stage 1: Step loop

For each step, in order:

### 1. Develop
`full` / `light`: spawn `Agent(subagent_type: "general-purpose", name: "dev-step-<N>", prompt: <Developer prompt>)`. No worktree: steps are sequential in the main checkout, so container-backed checks see the real changes.
`inline`: make the change yourself, then go to **Verify**.

### 2. Verify
- `git status --porcelain` + `git diff --stat`: every touched file belongs to this step. Out-of-scope edits → revert them or send the dev back; a genuine need for more files → **interrupt**.
- Run the fast checks yourself. Red → SendMessage the failure output to `dev-step-<N>`, re-verify.
- Stage exactly this step's files: `git add <paths>` (never `-A`).

### 3. Review (`full` only)
Spawn a new `Agent(subagent_type: "general-purpose", prompt: <Reviewer prompt>)`. It sees the step spec and the staged diff, never the developer's report, so it judges the code rather than the narrative.

- **APPROVED** → commit.
- **NEEDS FIXES** → SendMessage the Critical/Important list to `dev-step-<N>` (same agent, context intact), then Verify again and spawn a fresh reviewer with the new diff. **Max 2 fix rounds.**
- Still NEEDS FIXES after round 2: Important-only → record as **unresolved**, commit. Any Critical → **interrupt**.

### 4. Commit
`git commit -m "Step <N>: <title>"` with the attribution trailer. The commit is the progress record; resume relies on it.

One line to the user, then continue without waiting:
`Step N/M ✓ <title> — <files changed> — review: <approved in R rounds | light | inline>`

## Stage 2: Final verification

1. **Full suite**: every check from the project's CLAUDE.md, all green. Failures → spawn a fix developer with the output, re-run; still red after 2 rounds → **interrupt**. The task is not done while a check is red.
2. **Final review**: one fresh reviewer over `git diff $BASE..HEAD`, with the whole plan. Focus: cross-step integration (interfaces, types, wiring, missing glue), the `light` steps, plan compliance, the unresolved list. Fix Critical/Important the same way, max 2 rounds, then re-run the full suite.
3. **Plan acceptance checklist**: complete every item completable now (docs, `.env.example`, CLAUDE.md updates); list the rest (prod verification, manual steps) explicitly.
4. **Deliver** per project convention: push, `gh pr create` targeting the default branch, report CI status.

## Gate 2: Summary

```
Done: <plan>  —  <N> steps, <commits> commits on <branch>
PR: <url> (CI: <status>)
Checks: <each command — pass>
Review: <full steps approved / rounds>, final review: <PASS | issues fixed>
Unresolved: <list, or none>
Remaining manual items: <list, or none>
```

Then mark the plan's entry `[x]` in `{{PROJECTS_DIR}}/TASKS.md` and bump its "Last updated" date.

## Interrupt

Mid-run, stop and AskUserQuestion only for: a step needing files or behaviour outside the plan, a dev-reported blocker, a Critical issue unresolved after 2 rounds, checks red after 2 fix rounds, or the plan contradicting the code. State what happened, what you tried, and 2–3 concrete options. Everything else you decide and note in the summary.

## Prompts

### Developer

```
You implement Step <N> of a plan, autonomously. Read ~/.claude/roles/software-developer.md
and adopt it; the orchestrator's instructions here override its approval-waiting rule.

Plan: <path>  (read it for context; implement ONLY Step <N>)
Step <N>: <title>
What / how: <step text from the plan>
Success criteria: <criteria>
Files in scope: <list>
Fast checks: <commands>

Work:
1. Read the files in scope and their neighbours; match the surrounding code's style.
2. Implement the step. Add or update tests for the behaviour you change.
3. Run the fast checks until green.
4. Leave changes uncommitted; the orchestrator commits.

Needing a file outside scope, or the plan being wrong for this code, is a blocker:
stop and report it instead of working around it.

Report: files changed, checks run with results, blockers, notes for the reviewer.
You may receive follow-up messages with review feedback or check failures; fix
Critical and Important items, rerun the fast checks, report again.
```

### Reviewer

```
You review Step <N> of a plan. Read ~/.claude/roles/code-reviewer.md and adopt its
review standards; report to the orchestrator rather than waiting on a user. Read-only:
change no files.

Plan: <path>
Step <N>: <title>
What / how: <step text>
Success criteria: <criteria>
Diff: run `git diff --cached`; read surrounding code as needed.

Check: correctness and edge cases, security, error handling, tests covering the
changed behaviour, plan compliance, success criteria met, consistency with the codebase.
Flag only what you can point to in the diff.

Output:
Verdict: APPROVED | NEEDS FIXES
Critical (blocks): - <issue> | <file:line> | <why> | <fix>
Important (should fix): - ...
Suggestions (never block): - ...
```
