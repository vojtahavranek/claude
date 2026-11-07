---
name: complex-task-implementation
description: |
  Use when user asks to "execute complex plan", "run complex implementation",
  "parallel implement", or wants autonomous multi-agent execution.

  Uses Agent Teams for parallel execution with developer+reviewer duos.
  Each step gets a paired developer and code-reviewer teammate who
  communicate directly — quality is built in, not bolted on.

  Use when: plan has 2+ independent work streams worth running in parallel
  Sequential plans (any size): use task-implementation, which is also autonomous
---

# Complex Task Implementation Skill

## Overview

Autonomous parallel plan execution using **Agent Teams** with **developer+reviewer duos**. Each implementation step is handled by a paired developer and code-reviewer teammate who communicate directly, catching issues during implementation rather than in a post-hoc batch review.

**Philosophy**: User approves strategy upfront. For each step, a developer teammate implements while a paired reviewer teammate reviews and gives feedback inline. They iterate together until the step is clean. A lighter integration check follows each wave. Only 2 user approval gates.

**Old model** (replaced): Developers work alone → batch review after all waves → fix → re-review.
**New model**: Developer+reviewer duos per step → inline quality → light integration check per wave.

## When to Use

- Complex plan with 8+ steps
- Plan has independent work streams (parallelizable)
- User trusts the plan and wants speed
- task-preparation suggested this skill

## When NOT to Use

- Sequential plans, or few steps with little to parallelize — use task-implementation (same dev+reviewer pairing, no waves/worktrees/merges)
- Steps sharing most files — parallelism would serialize anyway

## Prerequisites

- A complete plan file (from task-preparation or manually created)
- Must be in a git repository
- Clean working tree (no uncommitted changes)
- **Agent Teams enabled**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in settings env
- Role files available: `~/.claude/roles/software-developer.md`, `~/.claude/roles/code-reviewer.md`

## Agent Architecture

| Agent | Role | Purpose | How |
|-------|------|---------|-----|
| **Team Lead** (you) | software-architect | Coordinate waves, manage shared task list, merge results, track progress | Direct (orchestrator session) |
| **Developer Teammate** | software-developer | Implement assigned step | 1 per step in wave, works in worktree |
| **Reviewer Teammate** | code-reviewer | Review paired developer's work, give feedback | 1 per step in wave, paired with developer |

Each step in a wave spawns a **duo**: one developer + one reviewer teammate. They communicate directly via Agent Teams messaging to iterate on quality without orchestrator involvement.

## Workflow

### Stage 0: Plan Intake & Dependency Analysis

**You are the orchestrator. Load the software-architect role.**

1. **Load plan file** using the same mechanism as task-implementation:
   - Direct path: `"execute complex plan: ./plans/feature.md"`
   - Name lookup: search in `.claude/task/`, `./plans/`, `~/.claude/plans/`
   - Inline: plan provided in the message

2. **Parse steps** extracting for each:
   - Step number and description
   - Files affected (created, modified)
   - Dependencies (explicit "depends on Step X" or implicit via shared files)
   - Success criteria

3. **Verify git prerequisites**:
   - Confirm we are in a git repo (`git rev-parse --is-inside-work-tree`)
   - No modified or staged **tracked** files (`git status --porcelain` ignoring untracked `??` entries — untracked files like local plan/notes directories are acceptable)
   - **If currently on the default branch (master/main): create a feature branch first** — never execute a plan directly on the default branch. Honor the plan's "Execution-model note" or branch naming if it specifies one; otherwise `feature/<plan-name>`.
   - Record base commit hash: `git rev-parse HEAD` — store for rollback
   - If tracked files are dirty, stop and ask user to commit or stash

3b. **Classify the plan's test commands as worktree-safe or main-checkout-only.** Read the plan's
   Prerequisites section and determine, per command, whether it runs against the checkout it is
   invoked from (local unit tests, linters, typecheckers — worktree-safe) or against a fixed
   environment such as a **Docker container that mounts the main checkout** (e.g.
   `docker compose exec <svc> pytest`), a running dev server, or a shared database — those are
   **main-checkout-only**: run from a worktree they silently test the MAIN tree's code, not the
   teammate's changes. Pass each duo ONLY the worktree-safe commands; main-checkout-only commands
   run at the post-merge integration check (Stage 1 Step 5 / Stage 2).

3c. **Honor the plan's own execution structure when it declares one — with a tiered backup when it
   doesn't.** Resolve the wave decomposition in this order, using the first tier that applies:
   - **Tier 1 — plan declares groups/ordering/execution-model note** (well-prepared plans do):
     ADOPT that structure and use your own dependency DAG (step 4) only as a sanity check —
     surface any contradiction between the plan's groups and detected file overlaps to the user
     at Gate 1 rather than silently recomputing.
   - **Tier 2 — no declared groups, but steps carry file lists and/or "depends on Step X"**: compute
     the waves from scratch via steps 4-5 (the standard DAG path).
   - **Tier 3 — steps lack file lists**: derive them before building the DAG — read each step's
     referenced spec/plan files and the descriptions to enumerate the files it will touch. For any
     step whose file footprint still cannot be determined confidently, treat it as overlapping with
     everything (i.e. it runs alone in its own sequential wave).
   - **Last resort — fully opaque plan**: run all steps sequentially in plan order. Slower but
     always correct; say so at Gate 1 ("no parallelism metadata — executing sequentially") so the
     user can add file lists to the plan and re-run if they want the speedup.
   Whatever the tier: **when in doubt about overlap, serialize.** A wrongly-parallelized pair costs
   a merge conflict and stale reviews; a wrongly-serialized pair only costs wall-clock time.

4. **Build dependency DAG**:
   - Steps modifying the same file → sequential (implicit dependency)
   - Explicit "depends on Step X" → edge in graph
   - Steps creating files needed by other steps → edge
   - Detect circular dependencies → error and stop

5. **Compute execution waves** (topological sort into levels):
   - Wave 1: steps with no dependencies
   - Wave N: steps whose dependencies are all in waves 1..N-1
   - Load `~/.claude/skills/complex-task-implementation/references/dependency-analysis.md` if complex dependencies detected

6. **Create task** with TaskCreate:
   - Subject: "Complex implement: [feature name]"
   - Metadata: `{ phase: "planning", totalSteps: N, totalWaves: M, currentWave: 0, baseCommit: "[hash]" }`

---

### Approval Gate 1: Execution Strategy

Present to user:

```
Execution Strategy for: [Plan Name]

Base commit: [short hash] ([branch name])
Agent Teams: Developer+Reviewer duos per step

Wave Decomposition:
  Wave 1 (parallel duos): Steps [1, 3, 5]
    - Step 1: [description] -> files: [list] -> duo: dev + reviewer
    - Step 3: [description] -> files: [list] -> duo: dev + reviewer
    - Step 5: [description] -> files: [list] -> duo: dev + reviewer

  Wave 2 (parallel duos): Steps [2, 4] (depends on Wave 1)
    - Step 2: [description] -> files: [list] -> duo: dev + reviewer
    - Step 4: [description] -> files: [list] -> duo: dev + reviewer

  Wave 3 (sequential): Step [6] (depends on Wave 2)
    - Step 6: [description] -> files: [list] -> duo: dev + reviewer

Parallelism: [M] waves instead of [N] sequential steps
Teammates: [2 * steps_in_wave] per wave (developer + reviewer each)
Files affected: [total count] ([created] new, [modified] modified)

Risks:
- [Any shared file concerns]
- [Complex dependency notes]

Quality: Each step reviewed inline by paired reviewer.
         Post-wave integration check verifies cross-step compatibility.
```

**Present options to user and wait for response:**
- **A) Approve and execute** — Execute autonomously, report at final review
- **B) Modify wave grouping** — Adjust step grouping (re-present after changes)
- **C) Switch to task-implementation** — Run sequentially instead
- **D) Cancel** — Abort execution

If B: Ask what to change, rebuild waves, re-present Gate 1.
If C: Inform user to use `"implement plan: [path]"` instead.
If D: Delete task, stop.

---

### Stage 1: Parallel Execution (Wave Loop)

Update task: `{ phase: "executing", currentWave: 1 }`

**For each wave (1 to M):**

#### Step 1: Create Shared Task List for the Wave

For each step in the wave, create two entries on the shared task list:

```
Tasks for Wave [N]:
  - "Implement Step [X]: [description]" — claimed by developer teammate
  - "Review Step [X]: [description]" — claimed by reviewer teammate
  - "Implement Step [Y]: [description]" — claimed by developer teammate
  - "Review Step [Y]: [description]" — claimed by reviewer teammate
  ...
```

#### Step 2: Spawn Developer+Reviewer Duos

For each step in the current wave, spawn **two teammates** — a developer and a reviewer. Spawn all duos for the wave in parallel.

**Developer Teammate prompt:**

```
You are a developer teammate implementing Step [X] of a plan.

FIRST: Read the role definition from ~/.claude/roles/software-developer.md and adopt that role.
IMPORTANT OVERRIDE: The role file may say "wait for user approval" before implementing.
In this context, you are working autonomously — your paired reviewer teammate serves as
the approval authority. Proceed with implementation without waiting for human approval.

CONTEXT:
- Full plan: [paste plan content or path]
- Your assigned step: Step [X]
- Step description: [description]
- Files to create/modify: [file list]
- How to implement: [technical approach from plan]
- Success criteria: [criteria]

YOUR REVIEWER: You are paired with a reviewer teammate for this step.
After implementing, message them to start their review.

SCOPE RESTRICTION:
- ONLY modify these files: [assigned file list]
- Do NOT modify any other files
- If you discover you need to change files outside your scope, note it as a blocker

EXECUTION:
1. Read existing files you need to modify
2. Implement the changes described in the step
3. Run relevant tests for your scope — ONLY the worktree-safe commands you were given.
   NEVER run container/server-backed commands (e.g. `docker compose exec ...`) from your
   worktree: they execute against the main checkout and their results say nothing about
   your changes. Those run later at the orchestrator's integration check.
4. Message your paired reviewer: "Step [X] implementation ready for review"
5. Wait for reviewer feedback
6. Fix any Critical or Important issues the reviewer raises
7. Message reviewer: "Fixes applied, ready for re-review"
8. Repeat until reviewer approves

OUTPUT (required):
Provide a summary at the end:
- Files created: [list]
- Files modified: [list]
- Tests run: [pass/fail details]
- Review iterations: [count]
- Issues found and fixed: [list]
- Blockers: [any issues preventing completion]
- Notes: [anything the orchestrator should know]
```

**Reviewer Teammate prompt:**

```
You are a code reviewer teammate for Step [X] of a plan.

FIRST: Read the role definition from ~/.claude/roles/code-reviewer.md and adopt that role.
IMPORTANT OVERRIDE: The role file may say "wait for user response" or reference human approval.
In this context, you are working autonomously with a paired developer teammate.
Communicate review feedback directly to the developer, not to a human user.

CONTEXT:
- Full plan: [paste plan content or path]
- Step being reviewed: Step [X]
- Step description: [description]
- Expected files: [file list]
- Success criteria: [criteria]

YOUR DEVELOPER: You are paired with a developer teammate for this step.
Wait for them to message you that implementation is ready before reviewing.

REVIEW PROCESS:
1. Wait for developer's "ready for review" message
2. Read all files the developer created or modified
3. Review against checklist:
   - Security vulnerabilities (injection, XSS, auth bypass, etc.)
   - Logic errors and bugs
   - Error handling gaps
   - Missing edge cases
   - Code quality (naming, structure, duplication)
   - Plan compliance (does implementation match the step's intent?)
   - Success criteria met?
4. Send feedback to developer using this format:

   Verdict: APPROVED | NEEDS FIXES

   Critical Issues: (must fix)
   - [issue] | [file:line] | [why] | [suggested fix]

   Important Issues: (should fix)
   - [issue] | [file:line] | [why] | [suggested fix]

   Suggestions: (optional, do NOT block approval)
   - [suggestion]

   What's good:
   - [praise]

5. If NEEDS FIXES: wait for developer to fix and re-review
6. If APPROVED: confirm to developer, then report completion

MAX ITERATIONS: 3 review rounds. After 3rd round, approve with remaining
issues noted as "unresolved" — they'll be caught in integration review.

OUTPUT (required):
- Review iterations: [count]
- Final verdict: APPROVED / APPROVED WITH NOTES
- Issues found: [total count by severity]
- Issues resolved: [count]
- Unresolved issues: [list, if any]
```

#### Step 3: Wait for Duos to Complete

- All duos in the wave work in parallel
- Each duo iterates internally (developer implements → reviewer reviews → developer fixes → reviewer re-reviews)
- Wait for all duos to report completion

#### Step 4: Collect & Merge

- Collect results from each duo (files changed, review results, remaining issues)
- **Merge strategy**:
  - Teammates work on isolated copies. Their changes need to be brought to main.
  - For each developer teammate with changes:
    - Merge or cherry-pick the teammate's branch into the current branch
    - If no file overlaps between teammates (expected due to scope isolation): clean merge
    - If file overlaps detected: load `~/.claude/skills/complex-task-implementation/references/merge-strategy.md` and follow conflict resolution
  - Verify merged state builds/compiles (run build command if known)

#### Step 5: Integration Check

After merging all duos in the wave, run a quick integration verification:

```bash
# Run tests (project-specific command from plan prerequisites)
# Run linting
# Run type checking
# Check for conflict markers in files
```

If integration issues found (tests fail, type errors across step boundaries):
- These are cross-step issues the individual duos couldn't catch
- Fix them directly as orchestrator or spawn a quick fix teammate
- Re-run checks until clean

#### Step 6: Progress Update

- TaskUpdate: `{ currentWave: [N], completedSteps: [count], failedSteps: [list] }`
- Output brief status to user (NOT an approval gate, just FYI):
  ```
  Wave [N/M] complete: [X] steps done, [Y] files changed
  Duo reviews: [Z] total review iterations across all duos
  Integration check: [PASS/issues found and fixed]
  Moving to Wave [N+1]...
  ```

#### Step 7: Handle Failures

- If a duo fails to complete a step:
  - Mark it as failed in tracking
  - Identify downstream steps that depend on it
  - If downstream steps exist: mark them as blocked, skip in future waves
  - If no downstream: continue (failure will be reported at Gate 2)
  - Do NOT stop the entire execution for a single step failure

**Repeat for each wave until all waves complete.**

---

### Stage 2: Integration Validation

Update task: `{ phase: "validating", validationIteration: 1 }`

Since each step was already reviewed by its paired reviewer, this stage focuses on **cross-step integration** — verifying that independently-developed pieces work together correctly.

Load `~/.claude/skills/complex-task-implementation/references/validation-loop.md` for detailed reference.

#### Integration Review (max 2 iterations)

**For iteration = 1 to 2:**

##### Step 1: Integration Review + Full Test Suite (parallel)

Spawn two teammates in parallel:

**Teammate A: Integration Reviewer**

```
You are reviewing the integration of multiple independently-implemented steps.

FIRST: Read the role definition from ~/.claude/roles/code-reviewer.md and adopt that role.

CONTEXT:
- Plan: [paste plan content]
- Base commit: [base commit hash]
- Run: git diff [base-commit]..HEAD to see all changes
- Each step was already reviewed individually by a paired reviewer.
  Your job is ONLY to check cross-step integration, NOT re-review individual step quality.
[If iteration > 1:]
- Previous integration review found: [list from previous iteration]
- Fixes applied: [list of fixes]

INTEGRATION CHECKLIST:
1. Cross-step imports/exports: Are interfaces consistent across steps?
2. Shared types: Do type definitions align between steps?
3. API contracts: Do consumers match producers across step boundaries?
4. Database/state: Are migrations, schema changes, and data flows coherent?
5. Configuration: Are all new config values, env vars, etc. consistent?
6. Plan compliance: Does the aggregate implementation match the plan's overall intent?
7. Missing glue: Is any wiring/integration code missing between steps?

OUTPUT FORMAT:
Overall: PASS | NEEDS FIXES

Integration Issues: (cross-step problems only)
- [issue] | [files involved] | [which steps conflict] | [suggested fix]

Missing Glue:
- [what needs connecting] | [between which steps]

Plan Compliance:
- [overall assessment]
```

**Teammate B: Test Runner**

```
Run the project's full test suite and quality checks. Execute these commands
(adapt to the project — check plan prerequisites for exact commands):

1. Backend tests (e.g., pytest, npm test, go test ./...)
2. Frontend tests (e.g., vitest, jest)
3. Linting (e.g., eslint, ruff, clippy)
4. Type checking (e.g., tsc --noEmit, mypy)
5. Build (e.g., npm run build, cargo build)
6. E2E tests if available

Report:
- Tests: [X passed, Y failed, Z skipped]
- Lint: [clean / N issues]
- Type check: [clean / N issues]
- Build: [success / failure]
- Failure details: [error output for any failures]
```

##### Step 2: Evaluate Results

- **If review = PASS and tests pass** → Exit loop, proceed to Gate 2
- **If review = NEEDS FIXES or tests fail** → Continue to Step 3
- **If iteration = 2 (max reached)** → Exit loop, escalate remaining issues to Gate 2

##### Step 3: Fix Integration Issues

Fix cross-step issues directly as orchestrator (these are typically small wiring fixes) or spawn a fix teammate:

```
Fix these cross-step integration issues:

FIRST: Read ~/.claude/roles/software-developer.md and adopt that role.

INTEGRATION ISSUES:
[Paste integration review output]

TEST FAILURES:
[Paste test failure details]

CONSTRAINTS:
- Fix ONLY cross-step integration issues (imports, wiring, type mismatches)
- Do NOT refactor individual step implementations
- Run affected tests after fixing
- Report: what was fixed, what remains, test results
```

##### Step 4: Update & Loop

- TaskUpdate: `{ validationIteration: [N+1] }`
- Brief status: `Integration check iteration [N]: [X] issues found, [Y] fixed. Re-checking...`
- Loop back to Step 1

---

### Approval Gate 2: Final Review

Present consolidated results:

```
Implementation Complete — Final Review

Summary:
  Steps: [X/N] completed across [M] waves
  Files: [Y] created, [Z] modified
  Duo reviews: [total review iterations across all duos]
  Integration validation: [iterations] iteration(s)

Quality:
  Per-step review: [X/N] steps approved by paired reviewer
  Integration review: [PASS / PASS WITH NOTES / NEEDS FIXES after 2 iterations]
  Tests: [X/Y passing]
  Type Check: [result or N/A]
  Lint: [result or N/A]

[If any duo had unresolved issues:]
Unresolved Per-Step Issues:
1. Step [X]: [issue — from reviewer's final notes]

[If integration issues remain:]
Unresolved Integration Issues:
1. [issue — files involved]

Changes by Wave:
  Wave 1: [summary of what was implemented]
  Wave 2: [summary]
  ...

Full Integration Review:
[Final integration reviewer output]
```

**Present options to user and wait for response:**
- **A) Accept all changes** — Mark task complete
- **B) Run another validation iteration** — Spawn integration review again
- **C) Fix specific issues manually** — User will fix, then can re-run validation
- **D) Reject and rollback** — `git reset --hard [base-commit]` (confirm before executing)

---

### Stage 3: Completion

If accepted (option A):

1. **Verify the plan's own acceptance checklist** (beyond tests): well-prepared plans carry a
   wave/final acceptance section — documentation updates (project CLAUDE.md / README / docs),
   config-var mirroring (.env.example), deploy or prod-verification steps. Complete the items that
   are completable now; list the rest (e.g. prod-only verification) explicitly as remaining manual
   steps in the summary — never silently drop them.

2. **Deliver per project conventions**: commit the changes (specific files, not `git add -A`), and
   if the project's CLAUDE.md prescribes a PR flow, push the feature branch and create the PR
   (targeting the default branch), then report the PR URL and CI status. Only skip the PR when the
   user or plan explicitly says direct delivery is fine.

3. **Generate summary**:
   ```
   Complex Implementation Complete: [Feature Name]

   Executed: [N] steps in [M] waves using developer+reviewer duos
   Quality: [total duo review iterations] inline review iterations
   Integration: [iterations] validation iteration(s), final: [PASS/PASS WITH NOTES]
   Files: [created] created, [modified] modified
   Delivery: [PR URL + CI status | committed on branch X]
   Acceptance checklist: [done items / remaining manual items]
   ```

4. **Mark task completed**: TaskUpdate with `{ phase: "completed", status: "completed" }`

5. **Update TASKS.md**: Mark the corresponding entry as `[x]` done

---

## Error Handling

### Teammate Failure
- If a developer or reviewer teammate fails, mark the step as failed
- Continue with remaining duos in the wave
- Failed steps are reported at Gate 2 for user decision

### Duo Deadlock
- If developer and reviewer can't converge after 3 review iterations, the reviewer approves with notes
- Unresolved issues escalate to integration validation
- If still unresolved, they appear at Gate 2

### Merge Conflicts
- Load `~/.claude/skills/complex-task-implementation/references/merge-strategy.md`
- Attempt automatic resolution first
- If unresolvable, pause and present the conflict to the user with options

### Git Issues
- If working tree becomes dirty unexpectedly, stop and report
- Base commit hash enables rollback at any point
- User can always choose option D at Gate 2 to rollback

### Interrupted Execution (spend limits, API errors, session death)
Teammates can die mid-wave on usage/spend limits or terminal API errors. Design for resume:
- After EACH duo completes and merges, update task metadata (`completedSteps`, per-step merge
  commit) — never batch metadata updates to the end of a wave.
- On resume (same or new session): read the task metadata + `git log [base-commit]..HEAD` to
  determine which steps' changes are already merged; respawn duos ONLY for missing steps. Do not
  re-run completed steps — their commits are the source of truth, not agent reports.
- If the interruption hit mid-duo (worktree has uncommitted work), inspect the worktree before
  discarding: salvageable work can be handed to the respawned developer as a starting diff.

### Agent Teams Unavailable
If Agent Teams is not enabled (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` not set), fall back to the Agent tool:
- Spawn developer as `Agent(subagent_type="general-purpose", isolation="worktree", prompt="...")`
- Wait for developer to complete, then spawn reviewer as `Agent(subagent_type="general-purpose", prompt="...")`  reviewing the developer's output
- Orchestrator relays reviewer feedback back to a new developer agent for fixes
- Duos still work conceptually but are sequential per step (no direct teammate messaging)
- This is slower but functionally equivalent

## Progress Tracking

Use TaskCreate/TaskUpdate throughout:

```
Phase: planning -> executing -> validating -> completed
Metadata tracked:
  - totalSteps, totalWaves
  - currentWave, completedSteps, failedSteps
  - duoReviewIterations (total across all duos)
  - validationIteration (1-2 for integration)
  - baseCommit (for rollback)
```

User can check progress anytime with `/tasks`.

## Tips

- **Duos catch issues early**: Most bugs are found during implementation, not in post-hoc review
- **Integration validation is lighter**: Expect 1 iteration (vs 2-3 in the old batch model)
- **Scope isolation prevents conflicts**: Each duo only touches assigned files
- **Rollback is always available**: Base commit hash means you can undo everything
- **Wave granularity matters**: Too many duos per wave = merge complexity. Too few = less parallelism
- **Agent Teams messaging**: Duos communicate directly — the orchestrator doesn't need to relay
- **Fallback works**: If Agent Teams is unavailable, the skill degrades gracefully to Agent tool subagents
- **Teammates inherit the session model**: run the orchestrating session on the model you want the duos to use
- **Completion signals**: teammates announce completion via idle notifications and the shared task list — treat "idle + their task marked done + expected files present in their worktree" as done, not the notification alone

---

## Changelog

- **2026-08-15 (follow-up)**: tiered wave-decomposition backup when the plan declares no groups —
  declared groups → DAG from file lists → derive file lists from referenced specs → sequential
  last resort; doubt always serializes.
- **2026-08-15 audit** (validated against live harness behavior during the SkyVest programme):
  branch-from-default guard; untracked files no longer block start; worktree-safe vs
  main-checkout-only test-command classification (container-mounted test suites were silently
  testing the wrong tree from worktrees); honor plan-declared parallel groups over recomputed DAG;
  interrupted-execution resume procedure (spend-limit agent deaths are real); Stage 3 now delivers
  per project conventions (commit → push → PR + CI) and verifies the plan's own acceptance
  checklist (docs etc.) instead of ending with uncommitted changes.
