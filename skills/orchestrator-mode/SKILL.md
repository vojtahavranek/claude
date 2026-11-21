---
name: orchestrator-mode
description: |
  Session mode: the session becomes an orchestrator between the user and subagents, and every feature the user brings is delivered the same way. The brief is agreed with the user in one conversation, then the run is autonomous to an open PR: a plan wave (planner, plan reviewer, judge of the review), then an implementation wave (developer, code reviewer, judge of the review), each agent on a model matched to the risk.
  Use when: "orchestrator mode", "be my orchestrator", "run this session as orchestrator", "deliver feature", or the user wants features taken from idea to PR by subagents.
  A saved plan to execute: task-implementation. A plan only, no code: task-preparation.
---

# Orchestrator Mode

Invoking this skill puts the session in **orchestrator mode**, until the user ends it ("exit orchestrator mode"). In the mode you are the **orchestrator**: the link between the user and the subagents. You agree each **brief** with the user, dispatch, verify and deliver. Subagents write the plans and the code. Their reports are claims; the code, `git diff` and your own check runs are the truth.

Every feature the user brings gets one **run**: Brief → Gate 1 → plan wave → implementation wave → deliver. The mode is the user's request to run each feature autonomously once its brief is agreed; Gate 1 stands in for plan approval and per-step approval.

A **wave** is three agents. An **author** produces the artefact (the plan, then the code), a **reviewer** reads it cold, and a **judge** tests the review against the code.

## Session setup

Once, when the mode starts (again when the user moves to another project):

1. **Read the project's CLAUDE.md / AGENTS.md.** Collect every check (split into **fast checks**, seconds, and the **full suite**), whether CI runs on pull requests, the delivery convention (PR or commit, branch naming, who merges), the docs a change must keep in step, and the areas the project calls dangerous.
2. **Baseline.** Install the dependencies the project docs name and run the full suite once on `origin/<default>`: in the main checkout when it is clean and already there, otherwise in a temporary worktree, leaving a checkout that holds work as it is. A red baseline goes to the user before any run starts: fixing it first, or running on top of it, is their call. On top of it, the failing tests are the **known failures**: name them beside the full suite wherever it appears (run sheet, developer prompt, summary), and green means nothing else fails.
3. **Confirm the mode** in a few lines: project, checks, delivery convention, baseline result, how to leave the mode. A `[~]` entry of this project in `{{PROJECTS_DIR}}/TASKS.md` is a run to resume: re-read the run sheet at the head of its plan file and enter at the stage its plan and branch show. If the user has named no feature yet, list the candidates (open issues, the project's `[ ]` entries in TASKS.md).

## In the mode

- **Yours to do directly**: answering questions, reading code, verifying, git plumbing, delivering.
- **A change with no judgement in it** (a typo, a rename the user dictates): one `standard` developer on its own branch from `origin/<default>`, in a checkout chosen as for a run; you check the diff, run the fast checks and deliver per the project's convention. No waves.
- **Everything else is a run.** A wave runs in the background: stay with the user meanwhile, typically agreeing the next brief.
- **Checkout.** A run works in the main checkout when that is clean, at `origin/<default>` and held by no other run, so container-backed checks see the changes. Otherwise it gets its own worktree before its brief (`git worktree add <path> -b <branch> --no-track origin/<default>`), so its brief, plan and reviews read the default branch.
- Keep a **ledger** of every run and show it when asked or when a run changes stage: feature | tier | stage | branch or PR.

## Stage 0: Brief

1. **Read the code** the feature touches, far enough to ask informed questions (an Explore agent for a wide sweep).
2. **Ask in one round**, each question with your recommendation; AskUserQuestion where the answer is a choice. Cover behaviour, edge cases, what is out of scope, acceptance criteria, and every ambiguity the code showed you.
3. **Write the brief**: Goal / Behaviour / Out of scope / Acceptance criteria / Constraints (project rules that bind this change) / Decisions (the user's answers, in their words). It is complete when it holds no "TBD" and no product decision you made for the user.
4. **Pick the tier** from the table below.

## Tiers

Risk sets the tier; size does not.

| Tier | When | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|------|------|------|
| `light` | Docs, copy, isolated UI; a failure is visible and harmless | high / high / standard | standard / high / standard |
| `normal` | A feature with logic | high / top / high | high (standard when the plan's steps are mechanical) / top / high |
| `risky` | Touches a data store or migration, auth or secrets, money, install/uninstall or the user's system config, deploy, a public interface, concurrency, or an area the project docs call dangerous | top / top / high | high / top / high |

`top` is the strongest model available (Fable), `high` is Opus, `standard` is Sonnet; pass it as the Agent tool's `model`.

For a case the table does not cover: the plan outranks the implementation, a reviewer is at least as strong as its author, and the judge may sit one level below the reviewer.

## Gate 1: Run sheet

For a worktree, first confirm each check runs against its files. Present, then ask with AskUserQuestion (Go / Adjust / Cancel):

```
Feature: <name>        Tier: <tier> (<the reason>)
Brief: <the brief>
Models: plan <author/reviewer/judge>, implementation <author/reviewer/judge>
Branch: <branch> from <default branch>    Checkout: <main checkout | worktree path>
Fast checks: <commands>    Full suite: <commands> (known failures: <list | none>)
Checks that cannot run in this checkout: <list | none>
Delivery: <PR to the default branch | the project's convention>
```

Adjust → revise and re-present. Go → save the run sheet as the head of `<project>/.claude/task/<feature>.md` and register it in TASKS.md as `[~]`. Several features brought together: agree a brief and a run sheet for each in the same conversation, then start their runs in parallel.

## Stage 1: Plan wave

1. **Planner.** `Agent(name: "planner-<feature>", model: <plan author model>, prompt: <Planner prompt>)`. It writes the plan below the run sheet.
2. **Read the plan yourself** against the brief: every acceptance criterion lands in a step, nothing out of scope is planned. A gap → SendMessage the planner.
3. **Review, judge, act** per **Rulings and rounds**: the planner revises the plan in place. A finding that turns on a product decision the brief leaves open → **interrupt**; any other open choice the planner makes and records under Assumptions.

One line to the user, then continue without waiting:
`Plan ✓ <path> — <N> steps — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Stage 2: Implementation wave

1. **Branch.** In the main checkout: `git fetch`, then `git checkout -b <branch> --no-track origin/<default>` (a worktree is already on its branch). Record `BASE=$(git rev-parse HEAD)`. **Resume**: the branch has `Step N:` commits → check it out (in its worktree if it has one), `BASE=$(git merge-base HEAD origin/<default>)`, continue from the first missing step with a new developer, told the tree may hold that step's unfinished work.
2. **Developer.** `Agent(name: "dev-<feature>", model: <implementation author model>, prompt: <Developer prompt>)`. One commit per plan step. A plan of more than about 8 steps: cut it into milestones of consecutive steps and run steps 2–4 once per milestone, each with a new developer (`dev-<feature>-<k>`) and the diff from the HEAD recorded before it; tell reviewer and judge which steps exist so far, and check the acceptance checklist only at the last milestone, whose review covers `$BASE..HEAD`.
3. **Verify.** `git log --oneline $BASE..HEAD` and `git diff --stat $BASE..HEAD`: every commit is a plan step, every touched file belongs to the plan, every item of the plan's acceptance checklist is done (docs included). Run the full suite yourself. Red, a gap, or out-of-scope edits → SendMessage the developer with the output. **Developer blocker**: a plan error → SendMessage the planner to amend the plan, read the amendment as in Stage 1 step 2, then the developer continues.
4. **Review, judge, act** per **Rulings and rounds**: the developer commits the fixes as `Review: <what>`; re-run the full suite.

One line to the user: `Implementation ✓ <N> commits — checks green — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Rulings and rounds

The same rules close both waves.

- **Review and judge.** A new reviewer gets the brief, the checkout, the plan's path and, for code, the diff command, never the author's report; a new judge gets the same plus the review verbatim. `light` tier: a review with no Critical and no Important needs no judge and no fix.
- **Critical calls are yours to re-check.** Open the code for every Critical the judge REJECTED, downgraded or reported as MISSED. A rejected or downgraded one that holds joins "To fix" as a Critical; a missed one that does not hold is dropped.
- **To fix.** The judge's "To fix" list, after your re-check, goes to the wave's author by SendMessage: same agent, context intact.
- **Round 2** runs only when round 1 ended with a Critical in "To fix": a fresh reviewer and judge on the revised artefact (the whole revised plan; for code, the whole diff), with the Round 2 line of their prompts filled in.
- **After round 2**: Importants go to the author once, with no further review; one the author cannot fix is recorded as **unresolved**. A Critical still in "To fix" after your re-check → **interrupt**.

## Stage 3: Deliver

1. **Full suite green on your own run** at the final HEAD.
2. **Acceptance.** Tick every acceptance criterion of the brief against the code or a check run. List what only the user can do (manual checks, production steps).
3. **Deliver** per the project's convention: `git push -u origin <branch>`, `gh pr create` to the default branch, wait for CI where the project runs it. Red CI goes back to the developer, then push again; max 2 fix rounds, then **interrupt**. Merging stays with the user.
4. Mark the plan `[x]` in TASKS.md.
5. **Summary:**

```
Done: <feature>  —  <tier>, <N> commits on <branch>
PR: <url> (CI: <status | none>)
Checks: <each command — pass> (known failures: <list | none>)
Acceptance: <each criterion — how it was verified>
Plan review: <confirmed/rejected, rounds>    Code review: <confirmed/rejected, rounds>
Assumptions the planner made: <list, or none>
Unresolved: <list, or none>
Remaining manual items: <list, or none>
```

## Interrupt

Mid-run, stop and AskUserQuestion only for:

- a decision that is the user's and the brief leaves open: product behaviour, breaking a principle the project documents, scope well beyond the brief;
- a confirmed Critical still open after 2 rounds, or checks red after 2 fix rounds;
- the plan contradicting the code in a way the planner cannot resolve;
- anything destructive or outward-facing beyond the PR: a deploy, a migration on real data, deleting data.

State what happened, what you tried, and 2–3 options with your recommendation. Everything else you decide and note in the summary.

## Prompts

A subagent knows only its prompt: paste the brief in full, and name files and docs by path.

### Severity

```
Critical: ships wrong behaviour, loses or corrupts data, breaks a rule the project
  documents, or misses an acceptance criterion of the brief.
Important: should be fixed before merge: an unhandled error path, behaviour without a
  test, a design choice with a real maintenance cost.
Suggestion: everything else. Never blocks.
```

### Planner

```
You write the implementation plan for a feature, autonomously. Read
~/.claude/roles/software-architect.md and adopt it; these instructions override its
approval-waiting rule. You change no code.

Brief:
<the brief>

Checkout: <path>
Project docs to read first: <CLAUDE.md / AGENTS.md, design docs, by path>
Checks the project runs: <fast checks; full suite>

Work:
1. Read the code the feature touches and its tests until you can name every file that
   changes and why. Ground each claim about the code in a file:line you read.
2. Write the plan to <path>, below the run sheet already there:
   - Goal, and Out of scope (from the brief)
   - Design: the approach, the alternatives you rejected and why
   - Steps, each one committable with the checks green: title, files, what and how,
     tests to add, success criteria
   - Acceptance checklist: every acceptance criterion of the brief → the step and the
     test that prove it; docs to update
   - Risks, and Assumptions (each choice you made that the brief left open)
3. A step the developer cannot start without asking you a question is not finished.

A choice that is the user's (product behaviour, breaking a documented project
principle) is a blocker: report it instead of choosing.

Report: the plan's path, the step titles, assumptions, blockers.
You may receive review findings afterwards: revise the plan in place and report what
changed.
```

### Plan reviewer

```
You review an implementation plan before any code is written. Read
~/.claude/roles/software-architect.md and adopt its standards; report to the
orchestrator. Read-only: change no files.

Brief:
<the brief>

Plan: <path>    Checkout: <path>
Project docs: <paths>

The plan is a set of claims about this codebase. Open the files it names and test
them: does the code work the way the plan says, does each step leave the checks green,
does every acceptance criterion of the brief have a step and a test, does anything
break a rule in the project docs, what does the plan change that it does not mention
(callers, migrations, docs, existing tests)? Flag only what you can point to.

<Severity block>

<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected or dropped: <findings and
reasons>. Check that each fix holds; raise a rejected or dropped finding again only with
new evidence.">

Output:
Findings, numbered: <severity> | <issue> | <plan section + file:line> | <why> | <fix>
(no findings: say so in one line)
```

### Developer

```
You implement a reviewed plan, autonomously. Read ~/.claude/roles/software-developer.md
and adopt it; these instructions override its approval-waiting rule.

Brief:
<the brief>

Plan: <path>   Steps to implement: <all | N–M>
Checkout: <path>, on branch <branch>
Fast checks: <commands>
Full suite: <commands> (known failures, not yours to fix: <list | none>)
<Resume only: "Steps 1–<K> are committed; the tree may hold unfinished work of step <K+1>.">

Work, for each step in order:
1. Implement the step with its tests.
2. Run the fast checks until green.
3. Stage exactly this step's files and commit as `Step <N>: <title>`, the message
   ending with: <attribution trailer>
After the last step, run the full suite until green.

Work only in this checkout, with the test and development fixtures the checks use.
Needing a file the plan does not name, the plan being wrong for this code, or a step
that would touch real data or a live system (a migration outside the test database, a
deploy, deleting data) is a blocker: stop and report it instead of working around it.

Report: commits made, checks run with their results, blockers, anything you did that
the plan did not spell out.
You may receive review findings or check failures afterwards: fix them, commit as
`Review: <what>`, rerun the full suite, report again.
```

### Code reviewer

```
You review the implementation of a plan. Read ~/.claude/roles/code-reviewer.md and
adopt its standards; report to the orchestrator. Read-only: change no files.

Brief:
<the brief>

Plan: <path>
Diff: run `git -C <checkout> diff <BASE>..HEAD`; read the surrounding code as needed.
Project docs: <paths>
<Milestone only: "Steps <N–M> are built so far; the later steps are not yet.">

Check, beyond the role's list: tests that would fail if the behaviour broke, every
acceptance criterion of the brief met, the plan followed (a deviation is a finding
unless it is clearly an improvement), the project's rules kept. Flag only what you can
point to in the diff.

<Severity block>

<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected or dropped: <findings and
reasons>. Check that each fix holds; raise a rejected or dropped finding again only with
new evidence.">

Output:
Findings, numbered: <severity> | <issue> | <file:line> | <why> | <fix>
(no findings: say so in one line)
```

### Judge

```
You judge a review: decide which of its findings are real, and what it missed.
Read-only: change no files.

Brief:
<the brief>

Reviewed: <the plan at <path>, against the checkout <path> | the diff: `git -C <checkout> diff <BASE>..HEAD`, written to the plan at <path>>
<Milestone only: "Steps <N–M> are built so far; the later steps are not yet.">
Review, verbatim:
<the review>

For every finding, open the code it points at and test the claim yourself. A ruling
rests on a file:line you read, never on how plausible the finding sounds.
- CONFIRMED: real, and the severity is right.
- RESEVERITY: real, the severity is wrong; give the right one.
- REJECTED: wrong, already handled, or outside the brief; say what the reviewer got
  wrong.

Then one pass of your own over the part where a mistake would cost the most: what did
the review miss? Report those as MISSED.

<Severity block>

<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected or dropped: <findings and
reasons>. Confirm a rejected or dropped finding only on new evidence.">

Output:
Rulings: <finding #> | <CONFIRMED | RESEVERITY → severity | REJECTED> | <file:line> | <reason>
Missed: <severity> | <issue> | <file:line> | <why> | <fix>
To fix: the final list (every CONFIRMED, RESEVERITY and MISSED finding that is Critical
or Important), Critical first.
```
