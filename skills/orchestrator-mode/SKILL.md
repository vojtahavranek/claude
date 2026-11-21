---
name: orchestrator-mode
description: |
  Session mode: the session becomes an orchestrator between the user and subagents, and every feature the user brings is taken from a brief agreed in one conversation to an open PR, each agent on a model matched to the risk.
  Use when: "orchestrator mode", "be my orchestrator", "run this session as orchestrator", "deliver feature", or the user wants features taken from idea to PR by subagents.
  A saved plan to execute: task-implementation. A plan only, no code: task-preparation.
---

# Orchestrator Mode

Invoking this skill puts the session in **orchestrator mode**, until the user ends it ("exit orchestrator mode"). In the mode you are the **orchestrator**: the link between the user and the subagents. You agree each **brief** with the user, dispatch, rule, verify and deliver. Subagents write the plans and the code. Their reports are claims; the code, `git diff` and your own check runs are the truth.

Every feature the user brings gets one **run**: Brief → Gate 1 → plan wave (a `full` run only) → implementation wave → deliver. The mode is the user's request to run each feature autonomously once its brief is agreed; Gate 1 stands in for plan approval and per-step approval.

A run has one of two **shapes**, set at Gate 1:

- **lean** (two agents): a developer builds from the brief, and a reviewer checks the brief and the code together. You rule on the findings.
- **full** (six agents): a plan wave, then an implementation wave. A **wave** is three agents: an **author** produces the artefact (the plan, then the code), a **reviewer** reads it cold, and a **judge** tests the review against the code.

## Session setup

Once, when the mode starts (again when the user moves to another project):

1. **Read the project's CLAUDE.md / AGENTS.md.** Collect:
   - every check, split into **fast checks** (seconds) and the **full suite**, and every **runtime version** the project supports (its CI matrix);
   - whether CI runs on pull requests, and the delivery convention (PR or commit, branch naming, who merges);
   - whether what is written to the repository host is public;
   - the docs a change must keep in step, and the areas the project calls dangerous;
   - the **machine rules**: what an agent must never do on this machine (the user's real data and configuration, the running product and its ports, anything outside the checkout). Ask the user for what the docs do not say, and whether they run the product from the main checkout.
2. **Baseline.** Install the dependencies the project docs name and run the full suite once on `origin/<default>`, on every supported runtime version (one that is not installed here goes under "Checks that cannot run in this checkout" and is left to CI; where CI does not run either, tell the user in step 4: installing it or accepting the gap is their call, and an accepted gap is named under "Not proven" in every summary): in the main checkout when it is clean and already there, otherwise in a temporary worktree, leaving a checkout that holds work as it is. A red baseline goes to the user before any run starts: fixing it first, or running on top of it, is their call. On top of it, the failing tests are the **known failures**: name them beside the full suite wherever it appears (run sheet, developer prompt, summary), and green means nothing else fails.
3. **Session scratch.** Pick one folder outside every checkout for the session. A run's Scratch is `<session scratch>/<feature>`; the lock for full-suite runs is `<session scratch>/fullrun.lock`, one for the whole session, the baseline included.
4. **Confirm the mode** in a few lines, so the user can correct them: project, checks, runtime versions, machine rules, whether the host is public, delivery convention, baseline result, how to leave the mode. A `[~]` entry of this project in `{{PROJECTS_DIR}}/TASKS.md` is a run to resume: re-read the run sheet and the rulings at the head of its plan file and enter at the stage its plan and branch show. If the user has named no feature yet, list the candidates (open issues, the project's `[ ]` entries in TASKS.md).

## In the mode

- **Yours to do directly**: answering questions, reading code, ruling, verifying, git plumbing, delivering.
- **A change with no judgement in it** (a typo, a rename the user dictates): one `standard` developer on its own branch from `origin/<default>`, in a checkout chosen as for a run; you check the diff, run the fast checks and deliver per the project's convention. No waves.
- **Everything else is a run.** A wave runs in the background: stay with the user meanwhile, typically agreeing the next brief.
- **Checkout.** A run works in the main checkout when that is clean, at `origin/<default>`, held by no other run and not the one the user runs the product from, so container-backed checks see the changes. Otherwise it gets its own worktree before its brief (`git worktree add <path> -b <branch> --no-track origin/<default>`), so its brief, plan and reviews read the default branch.
- Keep a **ledger** of every run and show it when asked or when a run changes stage: feature | tier and shape | stage | branch or PR.
- **Rulings.** Every decision you take mid-run, and every answer of the user, goes under `## Rulings` in the run's plan file, dated, when it is made. Agents read that section, and a ruling replaces the brief's or the plan's words. After a compaction the plan file is how you resume.
- **Messages cross.** A subagent may read a message late, after the work it was meant to change. Every report, review and check run names the commit it is about; a result on a commit that has since moved does not count. Fixes go out as one batch per round, after the whole list. When a late ruling changes finished work, ask for one small follow-up batch and have only that re-checked.
- **One full-suite run at a time.** Every full-suite run on the machine, yours and each agent's, takes the session's lock first (`until mkdir <session scratch>/fullrun.lock; do sleep 20; done` in the foreground, repeated if the tool times out; the holder writes its name and commit into it and removes it after the run): suites run side by side fail tests that pass alone. A lock whose holder no longer runs is yours to remove. A test that fails under load and passes alone is a **known flaky test**: the suite counts as green when that test's file passes alone and the suite passes on one repeat; name the test in the summary. Anything else red is red.
- **Stall watch.** While agents work in the background, keep a fallback wake-up (about 25 minutes: a background `sleep` that ends, or the harness's scheduler). On it, look at what each agent last did before you message it. An agent stopped by something only the user can renew (a login, a permission) goes to the user at once.
- **A refused action stays refused.** When the permission system or the user refuses an action of yours or of a subagent, nobody retries it in another form and nobody does it for the other. Tell the user what was refused and go on with what does not need it.
- **To the user**: one line at each change of stage, with what comes next and roughly when. Plain words; what failed as plainly as what passed.

## Stage 0: Brief

1. **Read the code** the feature touches, far enough to ask informed questions (an Explore agent for a wide sweep).
2. **Ask in one round**, each question with your recommendation; AskUserQuestion where the answer is a choice. Cover behaviour, edge cases, what is out of scope, acceptance criteria, and every ambiguity the code showed you.
3. **Write the brief**: Goal / Behaviour / Out of scope / Acceptance criteria, numbered (A1, A2, …) / Constraints (project rules that bind this change) / Decisions (the user's answers, in their words). It is complete when it holds no "TBD" and no product decision you made for the user.
4. **Pick the tier and the shape** from the table below.

## Tiers

Risk sets the tier; size does not.

| Tier | When | Shape | Plan: author / reviewer / judge | Implementation: author / reviewer / judge |
|------|------|-------|------|------|
| `light` | Docs, copy, isolated UI; a failure is visible and harmless | lean | high / high / standard | standard / high / standard |
| `normal` | A feature with logic | lean; full when **important** | high / top / high | high (standard when the change is mechanical) / top / high |
| `risky` | Touches a data store or migration, auth or secrets, money, install/uninstall or the user's system config, deploy, a public interface, concurrency, or an area the project docs call dangerous | full | top / top / high | high / top / high |

`top` is the strongest model available (Fable), `high` is Opus, `standard` is Sonnet; pass it as the Agent tool's `model`.

A lean run uses the implementation column's author and reviewer, and no judge. The shape in the table is the default. A `normal` feature that is **important** runs full: the user calls it important, its design is still open after the brief, other work will build on it, or it is likely to need more than about 8 steps (a lean run has one developer and no milestones). In each of these a wrong plan would be found only in the code review. Propose lean for a `risky` change whose brief settles every design decision.

For a case the table does not cover: the plan outranks the implementation, a reviewer is at least as strong as its author, and the judge may sit one level below the reviewer.

## Gate 1: Run sheet

For a worktree, first confirm each check runs against its files. Present, then ask with AskUserQuestion (Go / Adjust / Cancel):

```
Feature: <name>        Tier: <tier> (<the reason>)        Shape: <lean | full> (<the reason>)
Brief: <the brief>
Models: <lean: developer / reviewer | full: plan <author/reviewer/judge>, implementation <author/reviewer/judge>>
Estimate: <agents, rough duration>; cheaper: <what a smaller shape or tier would leave out | nothing smaller>
Branch: <branch> from <default branch>    Checkout: <main checkout | worktree path>
Scratch: <session scratch>/<feature> (agents' copies and their evidence)
Fast checks: <commands>    Full suite: <commands> on <runtime versions> (known failures: <list | none>)
Checks that cannot run in this checkout: <list | none>
Shared ground: <other runs that touch the same files, and the order they land in | none>
Delivery: <PR to the default branch | the project's convention>    Merge: <the user | you, on the gate of Stage 3>
```

Adjust → revise and re-present. Go → save the run sheet as the head of `<project>/.claude/task/<feature>.md`, with an empty `## Rulings` under it, and register it in TASKS.md as `[~]`. Several features brought together: agree a brief and a run sheet for each in the same conversation, then start their runs in parallel. Runs that share files land in the order the run sheets name. The later one still opens its PR; once the earlier one is merged, by you or by the user, it takes in the default branch, and its re-check and the gate of Stage 3 run again on the new commit.

## Stage 1: Plan wave (full runs)

A lean run skips this stage: its brief is its plan.

1. **Planner.** `Agent(name: "planner-<feature>", model: <plan author model>, prompt: <Planner prompt>)`. It writes the plan below the run sheet and the rulings.
2. **Read the plan yourself** against the brief: every acceptance criterion lands in a step, nothing out of scope is planned. A gap → SendMessage the planner.
3. **Review, judge, act** per **Rulings and rounds**: the planner revises the plan in place. A finding that turns on a product decision the brief leaves open → **interrupt**; any other open choice the planner makes and records under Assumptions.

One line to the user, then continue without waiting:
`Plan ✓ <path> — <N> steps — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Stage 2: Implementation wave

1. **Branch.** In the main checkout: `git fetch`, then `git checkout -b <branch> --no-track origin/<default>` (a worktree is already on its branch). Record `BASE=$(git rev-parse HEAD)`. **Resume**: the branch has `Step N:` commits → check it out (in its worktree if it has one), `BASE=$(git merge-base HEAD origin/<default>)`, continue from the first missing step with a new developer, told the tree may hold that step's unfinished work.
2. **Developer.** `Agent(name: "dev-<feature>", model: <implementation author model>, prompt: <Developer prompt>)`. One commit per step. In a lean run the developer first writes its own steps under `## Steps` in the plan file, and each choice the brief left open under `## Assumptions` there. Milestones (full runs; a lean run is one milestone): cut a plan of more than about 8 steps into milestones of consecutive steps and run steps 2–4 once per milestone, each with a new developer (`dev-<feature>-<k>`) and the diff from the HEAD recorded before it; tell reviewer and judge which steps exist so far, and check the plan's acceptance checklist only at the last milestone, whose review covers `$BASE..HEAD`.
3. **Verify.** `git log --oneline $BASE..HEAD` and `git diff --stat $BASE..HEAD`: every commit is a step, every touched file belongs to the plan or the developer's steps, every acceptance criterion is done and shown by a test or a named check, and the docs the project keeps in step are updated. In a lean run, read `## Assumptions` and rule on each one (Rulings) before the review starts. Run the full suite yourself. Red, a gap, or out-of-scope edits → SendMessage the developer with the output. **Developer blocker**: in a full run a plan error → SendMessage the planner to amend the plan, read the amendment as in Stage 1 step 2, then the developer continues; in a lean run you rule, or **interrupt** when the decision is the user's.
4. **Review, judge, act** per **Rulings and rounds**: the developer commits the fixes as `Review: <what>`; re-run the full suite.

One line to the user: `Implementation ✓ <N> commits — checks green — review: <confirmed> confirmed, <rejected> rejected, <rounds> round(s)`

## Rulings and rounds

The same rules close both waves.

- **Review.** A new reviewer gets the plan file's path (run sheet, brief, rulings), the checkout and, for code, the diff command and the commit, never the author's report. A code reviewer works in a scratch copy of that commit and proves what it claims by running it: a test that fails, a deliberate break of the new code that no test notices, a request made by hand.
- **Judge (full runs).** A new judge gets the same plus the review verbatim.
- **`light` tier**: a review with no Critical and no Important needs no fix and, in a full run, no judge.
- **You are the judge of a lean run.** A finding its reviewer proved by a run stands, unless it is outside the brief. For any other Critical, open the code before you rule. Record each ruling.
- **Critical calls are yours to verify (full runs).** Open the code for every Critical the judge REJECTED, downgraded or reported as MISSED. A rejected or downgraded one that holds joins "To fix" as a Critical; a missed one that does not hold is dropped.
- **To fix.** The list (the judge's "To fix" after you verified it, or your own rulings) goes to the author by SendMessage, whole and once: same agent, context intact. The author fixes it as one batch.
- **Re-check.** After the fixes the same reviewer, context intact, takes a copy of the new commit, checks that each fix holds, runs its proofs again there and reads what the fixes touched. If that reviewer is gone (a resumed run), a new one gets the To fix list and the Re-check line of its prompt. What the re-check finds goes to the author once more, after your ruling (the judge's verdict in a full run); verify those last fixes yourself, by opening the code and running the proof again.
- **Round 2**, with a fresh reviewer (and judge, in a full run) on the whole revised artefact and the Round 2 line of their prompts filled in, runs only when the fix of a Critical replaced a large part of the artefact.
- **After the re-check or round 2**: Importants go to the author once, with no further review; one the author cannot fix is recorded as **unresolved**. A Critical still open → **interrupt**.

## Stage 3: Deliver

1. **Public text.** Where the host is public, read the diff, the commit messages and the PR text you are about to send for what must not be published: people, employers, local paths and machine names, the names of the run's agents and files, anything of the brief the user called private. Fix it now: a commit after the gate means the gate again.
2. **The gate.** The full suite green on your own run: a clean tree at the final HEAD, every supported runtime version, under the lock. A green run on an earlier commit does not count; any commit after it means the gate again.
3. **Acceptance.** Tick every acceptance criterion of the brief against the code or a check run. List what only the user can do (manual checks, production steps) and what no test can show (**not proven**: behaviour that needs the real system, a guess about another program).
4. **Deliver** per the project's convention: `git push -u origin <branch>`, `gh pr create` to the default branch, naming the issue it closes if there is one; wait for CI where the project runs it. Red CI goes back to the developer, then push again; max 2 fix rounds, then **interrupt**.
5. **Merge.** Merging stays with the user unless the run sheet says you merge. Then merge only this session's own PRs, only with the gate green on exactly the PR's head (`gh pr merge --match-head-commit <sha>`) and CI green where the project runs it. Afterwards `git diff <gated sha> <merge commit>` must show only what the default branch gained meanwhile; anything else goes to the user. Never approve a PR by someone else, and never bypass a review it requires.
6. Mark the plan `[x]` in TASKS.md.
7. **Summary:**

```
Done: <feature>  —  <tier>, <shape>, <N> commits on <branch>
PR: <url> (CI: <status | none>)
What you will see: <the change in the product, in plain words>
Checks: <each command — pass, on <runtime versions>> (known failures: <list | none>; known flaky tests met: <list | none>)
Acceptance: <each criterion — how it was verified>
Plan review: <confirmed/rejected, rounds | lean: none>    Code review: <confirmed/rejected, rounds>
Rulings: <the decisions you took mid-run>
Assumptions the author made: <list, or none>
Unresolved: <list, or none>
Not proven: <what no test shows, and how the user can check it | none>
Remaining manual items: <list, or none>
```

## Interrupt

Mid-run, stop and AskUserQuestion only for:

- a decision that is the user's and the brief leaves open: product behaviour, breaking a principle the project documents, scope well beyond the brief;
- a confirmed Critical still open after the re-check or round 2, or checks red after 2 fix rounds;
- the plan (in a lean run, the brief) contradicting the code in a way neither its author nor you can settle;
- an action the permission system or the user refused, when the run cannot finish without it;
- anything destructive or outward-facing beyond the PR: a deploy, a migration on real data, deleting data.

State what happened, what you tried, and 2–3 options with your recommendation. Everything else you decide, record under Rulings and note in the summary.

## Prompts

A subagent knows only its prompt. Keep the prompt short: the run sheet, the brief and the rulings are at the head of the plan file, so give its path and say to read it first, and name files and docs by path. Every prompt carries the Rules block; the prompts of reviewers and judges also carry the Severity block.

### Rules block

```
Read <plan path> first: the run sheet, the brief and `## Rulings` at its head. A ruling
replaces the brief's or the plan's words.
Machine rules: <the machine rules>
An action the permission system refuses stays refused: do not retry it another way;
report it.
Before any full-suite run take the lock, in the foreground:
`until mkdir <session scratch>/fullrun.lock; do sleep 20; done` (again if the tool times
out). Write your name and commit into it and remove it after the run. A lock that never
frees goes to the orchestrator.
Name the commit your report is about. Report in at most about 4,500 characters; longer
evidence goes into a file under <scratch path>, named in the report.
```

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

<Rules block>

Checkout: <path>
Project docs to read first: <CLAUDE.md / AGENTS.md, design docs, by path>
Checks the project runs: <fast checks; full suite>

Work:
1. Read the code the feature touches and its tests until you can name every file that
   changes and why. Ground each claim about the code in a file:line you read.
2. Write the plan to <plan path>, below the run sheet and the rulings already there:
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
You may receive review findings afterwards, as one list: revise the plan in place and
report what changed.
```

### Plan reviewer

```
You review an implementation plan before any code is written. Read
~/.claude/roles/software-architect.md and adopt its standards; report to the
orchestrator. Read-only: change no file except under <scratch path>.

<Rules block>

Plan: <plan path>    Checkout: <path>
Project docs: <paths>

The plan is a set of claims about this codebase. Open the files it names and test
them: does the code work the way the plan says, does each step leave the checks green,
does every acceptance criterion of the brief have a step and a test, does anything
break a rule in the project docs, what does the plan change that it does not mention
(callers, migrations, docs, existing tests)? Flag only what you can point to.

<Severity block>

<Re-check only: "The planner revised the plan for: <To fix list>. Check that each fix
holds and read what the revision touched.">
<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected or dropped: <findings and
reasons>. Check that each fix holds; raise a rejected or dropped finding again only with
new evidence.">

Output:
Findings, numbered: <severity> | <issue> | <plan section + file:line> | <why> | <fix>
(no findings: say so in one line)
```

### Developer

```
You implement <a reviewed plan | a brief>, autonomously. Read
~/.claude/roles/software-developer.md and adopt it; these instructions override its
approval-waiting rule.

<Rules block>

Plan: <plan path>   Steps to implement: <all | N–M>
Checkout: <path>, on branch <branch>
Fast checks: <commands>
Full suite: <commands> on <runtime versions> (known failures, not yours to fix: <list | none>)
<Lean only: "No plan was written: the brief is your specification. If the plan file has
no `## Steps`, write your steps there below `## Rulings` before any code, each
committable with the checks green, the docs the project keeps in step included. Write
each choice the brief left open under `## Assumptions` there as you make it, and go on.
A choice that is the user's (product behaviour, breaking a documented project
principle) is a blocker: report it instead of choosing.">
<Resume only: "Steps 1–<K> are committed; the tree may hold unfinished work of step <K+1>.">

Work, for each step in order:
1. Write the step's tests, then implement the step.
2. Run the fast checks until green.
3. Stage exactly this step's files and commit as `Step <N>: <title>`, the message
   ending with: <attribution trailer>
After the last step, run the full suite until green, then the test files you touched on
every other runtime version listed. Do not push.

Work only in this checkout and <scratch path>, with the test and development fixtures
the checks use. Needing a file the plan does not name (full runs), the plan or the brief
being wrong for this code, or a step
that would touch real data or a live system (a migration outside the test database, a
deploy, deleting data) is a blocker: stop and report it instead of working around it.

Report: commits made, checks run with their results, blockers, anything you did that
the plan or the brief did not spell out.
You may receive review findings or check failures afterwards, as one list: fix them as
one batch, commit as `Review: <what>`, rerun the full suite, report again.
```

### Code reviewer

```
You review the implementation of <a plan | a brief>. Read
~/.claude/roles/code-reviewer.md and adopt its standards; these instructions override
its wait-for-response steps, and its no-changes rule inside your copy. Report to the
orchestrator. Change no file of the checkout. Work in a copy of the commit <sha> under
<scratch path> (`git clone -q <checkout> <your folder>`, then
`git -C <your folder> checkout -q --detach <sha>`, then the dependencies as the project
docs say), where you may run and break anything. Start no containers or services from
the copy: a proof that needs them is READ, not RAN.

<Rules block>

Diff: run `git -C <checkout> diff <BASE>..<sha>`; read the surrounding code as needed.
Project docs: <paths>
<Milestone only: "Steps <N–M> are built so far; the later steps are not yet.">
<Lean only: "No plan was reviewed. Go through the brief's acceptance criteria and the
rulings one by one: built as written, built differently (how), or missing. Anything
built beyond them is a finding.">

Check, beyond the role's list: tests that would fail if the behaviour broke, every
acceptance criterion of the brief met, the plan followed (a deviation is a finding
unless it is clearly an improvement), the project's rules kept. Prove what you claim by
running it in your copy: a test that fails, a deliberate break of the new code that no
test notices (then a test is missing), an input or a request made by hand. Flag only
what you can point to in the diff, and say for each finding whether you RAN it or only
READ it.

<Severity block>

<Re-check only: "The developer fixed: <To fix list>, in <commits>, now at <sha>. Take a
copy of <sha> in a new folder, check that each fix holds, run your proofs again there
and read what the fixes touched.">
<Round 2 only: "Round 1 fixed: <To fix list>. Round 1 rejected or dropped: <findings and
reasons>. Check that each fix holds; raise a rejected or dropped finding again only with
new evidence.">

Output:
Findings, numbered: <severity> | <issue> | <file:line> | <RAN | READ> | <why> | <fix>
(no findings: say so in one line)
```

### Judge

```
You judge a review: decide which of its findings are real, and what it missed.
Read-only: change no file except under <scratch path>.

<Rules block>

Reviewed: <the plan at <plan path>, against the checkout <path> | the diff: `git -C <checkout> diff <BASE>..<sha>` (the commit the review is about), written to the plan at <plan path>>
<Milestone only: "Steps <N–M> are built so far; the later steps are not yet.">
Review, verbatim:
<the review>

For every finding, open the code it points at and test the claim yourself. A verdict
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
Verdicts: <finding #> | <CONFIRMED | RESEVERITY → severity | REJECTED> | <file:line> | <reason>
Missed: <severity> | <issue> | <file:line> | <why> | <fix>
To fix: the final list (every CONFIRMED, RESEVERITY and MISSED finding that is Critical
or Important), Critical first.
```
