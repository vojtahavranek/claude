---
name: feature-delivery
description: |
  Deliver a feature end to end as an orchestrator: agree the brief with the user in one conversation up front, then run autonomously to an open PR. A plan wave (planner, plan reviewer, judge of the review), then an implementation wave (developer, code reviewer, judge of the review), each agent on a model matched to the risk.
  Use when: "deliver feature", "use feature delivery for", "orchestrate this feature", or the user wants a feature taken from idea to PR by subagents.
  A saved plan to execute: task-implementation. A plan only, no code: task-preparation.
---

# Feature Delivery

You are the **orchestrator**: the link between the user and the subagents. You agree the **brief** with the user, dispatch, verify and deliver. Subagents write the plan and the code. Their reports are claims; the code, `git diff` and your own check runs are the truth.

Invoking this skill is the user's request to run autonomously once the brief is agreed. Gate 1 stands in for plan approval and per-step approval.

The run is two **waves** of three agents each. An **author** produces the artefact (the plan, then the code), a **reviewer** reads it cold, and a **judge** tests the review against the code. The judge keeps a wrong finding from being "fixed" and a missed one from shipping.

## Stage 0: Brief

The only interactive stage. Everything the run needs from the user is asked here.

1. **Read the project's CLAUDE.md / AGENTS.md.** Collect every check (split into **fast checks**, seconds, and the **full suite**), the delivery convention (PR or commit, branch naming, who merges), the docs a change must keep in step, and the areas the project calls dangerous.
2. **Read the code** the feature touches, far enough to ask informed questions (an Explore agent for a wide sweep).
3. **Ask in one round**, each question with your recommendation; AskUserQuestion where the answer is a choice. Cover behaviour, edge cases, what is out of scope, acceptance criteria, and every ambiguity the code showed you.
4. **Write the brief**: Goal / Behaviour / Out of scope / Acceptance criteria / Constraints (project rules that bind this change) / Decisions (the user's answers, in their words). It is complete when it holds no "TBD" and no product decision you made for the user. It goes verbatim into every subagent prompt.
5. **Pick the tier** from the table below.

## Tiers

Risk sets the tier; size does not.

| Tier | When | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|------|------|------|
| `light` | Docs, copy, isolated UI; a failure is visible and harmless | high / high / standard | standard / high / standard |
| `normal` | A feature with logic | high / top / high | high (standard when the plan's steps are mechanical) / top / high |
| `risky` | Touches a data store or migration, auth or secrets, money, install/uninstall or the user's system config, deploy, a public interface, concurrency, or an area the project docs call dangerous | top / top / high | high / top / high |

`top` is the strongest model available (Fable), `high` is Opus, `standard` is Sonnet; pass it as the Agent tool's `model`.

For a case the table does not cover: the plan outranks the implementation (a wrong plan is implemented faithfully and then reviewed against itself), and a reviewer is at least as strong as its author. The judge may sit one level below the reviewer: testing a claim someone pointed at is easier than finding it, and you re-check its Critical calls yourself.

## Gate 1: Run sheet

Present, then ask with AskUserQuestion (Go / Adjust / Cancel):

```
Feature: <name>        Tier: <tier> (<the reason>)
Brief: <the brief>
Models: plan <author/reviewer/judge>, implementation <author/reviewer/judge>
Branch: <branch> from <default branch>    Checkout: <main checkout | worktree path>
Fast checks: <commands>    Full suite: <commands>
Delivery: <PR to the default branch | the project's convention>
```

Adjust → revise and re-present. Several features at once: agree one brief and one run sheet each in the same conversation, then run each feature's waves in its own worktree, in parallel.

## Stage 1: Plan wave

1. **Planner.** `Agent(name: "planner-<feature>", model: <plan author model>, prompt: <Planner prompt>)`. It writes `<project>/.claude/task/<feature>.md`.
2. **Read the plan yourself** against the brief: every acceptance criterion lands in a step, nothing out of scope is planned. A gap → SendMessage the planner.
3. **Plan reviewer.** A new agent with the brief and the plan's path, never the planner's report.
4. **Judge.** A new agent with the brief, the plan's path and the review verbatim. `light` tier: skip the judge when the review holds no Critical and no Important.
5. **Act on the ruling** (the rules are under **Rulings and rounds**): the planner revises the plan in place. A finding that turns on a product decision the brief leaves open → **interrupt**; any other open choice the planner makes and records under Assumptions.
6. Register the plan in `{{PROJECTS_DIR}}/TASKS.md` as `[~]`.

One line to the user, then continue without waiting:
`Plan ✓ <path> — <N> steps — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Stage 2: Implementation wave

1. **Git preflight.** `git fetch`. A single feature and a clean main checkout → `git checkout -b feature/<feature> origin/<default>` there, so container-backed checks see the changes. Tracked files dirty, or features in parallel → `git worktree add` on a new branch from `origin/<default>`; confirm each check runs against the worktree's files, and put any that cannot on the run sheet. Record `BASE=$(git rev-parse HEAD)`. **Resume**: the branch exists with `Step N:` commits → check it out, `BASE=$(git merge-base HEAD origin/<default>)`, continue from the first missing step.
2. **Developer.** `Agent(name: "dev-<feature>", model: <implementation author model>, prompt: <Developer prompt>)`. One commit per plan step. A plan of more than about 8 steps: cut it into milestones of consecutive steps and run steps 2–6 once per milestone, each with a new developer and the diff from that milestone's first commit; the last review covers `$BASE..HEAD`.
3. **Verify.** `git log --oneline $BASE..HEAD` and `git diff --stat $BASE..HEAD`: every commit is a plan step, every touched file belongs to the plan, every item of the plan's acceptance checklist is done (docs included). Run the full suite yourself. Red, a gap, or out-of-scope edits → SendMessage the developer with the output. **Developer blocker**: a plan error → SendMessage the planner to amend the plan, then the developer continues; a decision that is the user's → **interrupt**.
4. **Code reviewer.** A new agent with the brief, the plan's path and the diff command, never the developer's report.
5. **Judge.** A new agent with the brief, the plan's path, the diff command and the review verbatim. `light` tier: skip the judge when the review holds no Critical and no Important.
6. **Act on the ruling** (**Rulings and rounds**): the developer commits the fixes as `Review: <what>`; re-run the full suite.

One line to the user: `Implementation ✓ <N> commits — checks green — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Rulings and rounds

The same rules close both waves.

- **To fix.** The judge's "To fix" list (confirmed and MISSED findings, Critical and Important) goes to the wave's author by SendMessage: same agent, context intact. With the judge skipped, the reviewer's findings are the list.
- **Critical calls are yours to re-check.** Open the code for every Critical the judge REJECTED or reported as MISSED. A rejected one that holds joins "To fix"; a missed one that does not hold is dropped.
- **Round 2** runs only when round 1 ended with a Critical in "To fix": a fresh reviewer and judge on the revised artefact (the whole revised plan; for code, the whole diff). Paste into the reviewer's prompt round 1's "To fix" list and its rejected findings with the reasons, so it checks the fixes and does not re-raise what was settled.
- **After round 2**: Importants go to the author once, with no further review; one the author cannot fix is recorded as **unresolved**. A Critical in round 2's "To fix" → **interrupt**.

## Stage 3: Deliver

1. **Full suite green on your own run** at the final HEAD. The feature is not done while a check is red.
2. **Acceptance.** Tick every acceptance criterion of the brief against the code or a check run. List what only the user can do (manual checks, production steps).
3. **Deliver** per the project's convention: push, `gh pr create` to the default branch, wait for CI. Red CI goes back to the developer, then push again; max 2 fix rounds, then **interrupt**. Merging stays with the user.
4. Mark the plan `[x]` in `{{PROJECTS_DIR}}/TASKS.md`.
5. **Summary:**

```
Done: <feature>  —  <tier>, <N> commits on <branch>
PR: <url> (CI: <status>)
Checks: <each command — pass>
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

A subagent knows only its prompt: paste the brief in full, and name files and docs by path. Paste the **Severity** block into both reviewer prompts and the judge prompt.

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

Project docs to read first: <CLAUDE.md / AGENTS.md, design docs, by path>
Checks the project runs: <fast checks; full suite>

Work:
1. Read the code the feature touches and its tests until you can name every file that
   changes and why. Ground each claim about the code in a file:line you read.
2. Write the plan to <path>:
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

Plan: <path>
Project docs: <paths>

The plan is a set of claims about this codebase. Open the files it names and test
them: does the code work the way the plan says, does each step leave the checks green,
does every acceptance criterion of the brief have a step and a test, does anything
break a rule in the project docs, what does the plan change that it does not mention
(callers, migrations, docs, existing tests)? Flag only what you can point to.

<Severity block>

<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected: <findings and reasons>.
Check that each fix holds; re-raise a rejected finding only with new evidence.">

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
Fast checks: <commands>    Full suite: <commands>

Work, for each step in order:
1. Read the files in scope and their neighbours; match the surrounding code's style.
2. Implement the step with its tests.
3. Run the fast checks until green.
4. Commit exactly this step's files: `git commit -m "Step <N>: <title>"` <attribution trailer>.
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

Check: correctness and edge cases, error handling, security, tests that would fail if
the behaviour broke, every acceptance criterion of the brief met, the plan followed
(a deviation is a finding unless it is clearly an improvement), the project's rules
kept, consistency with the codebase. Flag only what you can point to in the diff.

<Severity block>

<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected: <findings and reasons>.
Check that each fix holds; re-raise a rejected finding only with new evidence.">

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

Reviewed: <the plan at <path> | the diff: `git -C <checkout> diff <BASE>..HEAD`, written to the plan at <path>>
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

Output:
Rulings: <finding #> | <CONFIRMED | RESEVERITY → severity | REJECTED> | <file:line> | <reason>
Missed: <severity> | <issue> | <file:line> | <why> | <fix>
To fix: the final list (every CONFIRMED, RESEVERITY and MISSED finding that is Critical
or Important), Critical first.
```
