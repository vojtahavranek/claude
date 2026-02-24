---
name: complex-task-implementation
description: |
  Use when user asks to "execute complex plan", "run complex implementation",
  "parallel implement", or wants autonomous multi-agent execution.

  Parallel agents in isolated worktrees. Minimal user interruption.
  Strong iterative validation: code review -> fix -> re-review until clean.

  Use when: Complex plan with independent work streams, user trusts the plan
  Don't use: Simple plans (use task-implementation), user wants step-by-step control
---

# Complex Task Implementation Skill

## Overview

Autonomous parallel plan execution with iterative validation. Replaces per-step user approval with a **review-fix-re-review loop** using specialized agents.

**Philosophy**: User approves strategy upfront, agents implement in parallel, automated code review catches issues, fix agents resolve them, and user does final acceptance. Only 2 approval gates instead of N.

## When to Use

- Complex plan with 8+ steps
- Plan has independent work streams (parallelizable)
- User trusts the plan and wants speed
- task-preparation suggested this skill

## When NOT to Use

- Simple plans (< 5 steps) - use task-implementation
- User wants per-step approval control - use task-implementation
- Learning a new codebase (step-by-step is better)
- High-risk changes needing careful human review at each step

## Prerequisites

- A complete plan file (from task-preparation or manually created)
- Must be in a git repository
- Clean working tree (no uncommitted changes)
- Role files available: `~/.claude/roles/software-developer.md`, `~/.claude/roles/code-reviewer.md`

## Agent Architecture

| Agent Type | Role | Purpose | Isolation |
|------------|------|---------|-----------|
| **Implementation Agent** | software-developer | Write code for assigned step(s) | `isolation: "worktree"` |
| **Review Agent** | code-reviewer | Review all changes, categorize issues | No worktree (reads main) |
| **Fix Agent** | software-developer | Fix issues identified by reviewer | No worktree (works on main) |
| **Orchestrator** (you) | software-architect | Coordinate waves, merge, run tests, track progress | Direct |

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
   - Working tree must be clean (`git status --porcelain` should be empty)
   - Record base commit hash: `git rev-parse HEAD` - store this for rollback capability
   - If working tree is dirty, stop and ask user to commit or stash

4. **Build dependency DAG**:
   - Steps modifying the same file -> sequential (implicit dependency)
   - Explicit "depends on Step X" -> edge in graph
   - Steps creating files needed by other steps -> edge
   - Detect circular dependencies -> error and stop

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

Wave Decomposition:
  Wave 1 (parallel): Steps [1, 3, 5]
    - Step 1: [description] -> files: [list]
    - Step 3: [description] -> files: [list]
    - Step 5: [description] -> files: [list]

  Wave 2 (parallel): Steps [2, 4] (depends on Wave 1)
    - Step 2: [description] -> files: [list]
    - Step 4: [description] -> files: [list]

  Wave 3 (sequential): Step [6] (depends on Wave 2)
    - Step 6: [description] -> files: [list]

Parallelism: [M] waves instead of [N] sequential steps
Files affected: [total count] ([created] new, [modified] modified)

Risks:
- [Any shared file concerns]
- [Complex dependency notes]

Validation: After all waves, automated code review -> fix -> re-review loop (max 3 iterations)
```

**Use AskUserQuestion** with options:
- **A) Approve and execute** - Execute autonomously, report at final review
- **B) Modify wave grouping** - Adjust step grouping (re-present after changes)
- **C) Switch to task-implementation** - Use per-step approval instead
- **D) Cancel** - Abort execution

If B: Ask what to change, rebuild waves, re-present Gate 1.
If C: Inform user to use `"implement plan: [path]"` instead.
If D: Delete task, stop.

---

### Stage 1: Parallel Execution (Wave Loop)

Update task: `{ phase: "executing", currentWave: 1 }`

**For each wave (1 to M):**

#### Step 1: Spawn Implementation Agent Team

For each step in the current wave, spawn a `general-purpose` agent with `isolation: "worktree"`:

**Agent prompt template:**
```
You are implementing Step [X] of a plan.

FIRST: Read the role definition from ~/.claude/roles/software-developer.md and adopt that role.

CONTEXT:
- Full plan: [paste plan content or path]
- Your assigned step: Step [X]
- Step description: [description]
- Files to create/modify: [file list]
- How to implement: [technical approach from plan]
- Success criteria: [criteria]

SCOPE RESTRICTION:
- ONLY modify these files: [assigned file list]
- Do NOT modify any other files
- If you discover you need to change files outside your scope, note it as a blocker

EXECUTION:
1. Read existing files you need to modify
2. Implement the changes described in the step
3. Run relevant tests for your scope (if test commands are known)
4. Verify your changes meet the success criteria

OUTPUT (required):
Provide a summary at the end:
- Files created: [list]
- Files modified: [list]
- Tests run: [pass/fail details]
- Blockers: [any issues preventing completion]
- Notes: [anything the orchestrator should know]
```

**Spawn all agents for the wave in parallel** using multiple Task tool calls in a single message. Use `run_in_background: true` for all but the last agent if the wave has many steps, or spawn all in parallel.

#### Step 2: Collect & Merge

- Wait for all agents in the wave to complete
- Collect results from each agent (files changed, test results, issues)
- **Merge strategy**:
  - Worktree agents work on isolated copies. Their changes need to be brought to main.
  - If agents returned with changes in their worktrees, the worktree path and branch are provided in the result.
  - For each agent with changes:
    - Cherry-pick or merge the agent's branch into the current branch
    - If no file overlaps between agents (expected): clean merge
    - If file overlaps detected: load `~/.claude/skills/complex-task-implementation/references/merge-strategy.md` and follow conflict resolution
  - Verify merged state builds/compiles (run build command if known)

#### Step 3: Progress Update

- TaskUpdate: `{ currentWave: [N], completedSteps: [count], failedSteps: [list] }`
- Output brief status to user (NOT an approval gate, just FYI):
  ```
  Wave [N/M] complete: [X] steps done, [Y] files changed
  [Any notable issues]
  Moving to Wave [N+1]...
  ```

#### Step 4: Handle Failures

- If a step in the wave failed:
  - Mark it as failed in tracking
  - Identify downstream steps that depend on it
  - If downstream steps exist: mark them as blocked, skip in future waves
  - If no downstream: continue (the failure will be addressed in validation)
  - Do NOT stop the entire execution for a single step failure

**Repeat for each wave until all waves complete.**

---

### Stage 2: Validation Loop

Update task: `{ phase: "validating", validationIteration: 1 }`

**This is the core quality mechanism.** It replaces per-step user approval.

Load `~/.claude/skills/complex-task-implementation/references/validation-loop.md` for detailed reference.

#### The Loop: Review -> Fix -> Re-review (max 3 iterations)

**For iteration = 1 to 3:**

##### Step 1: Code Review + Test Execution (parallel)

Spawn two agents in parallel:

**Agent A: Code Reviewer** (`general-purpose`, NO worktree)

```
You are reviewing code changes for a complex implementation.

FIRST: Read the role definition from ~/.claude/roles/code-reviewer.md and adopt that role.

CONTEXT:
- Plan: [paste plan content]
- Base commit: [base commit hash]
- Run: git diff [base-commit]..HEAD to see all changes
- This is validation iteration [N] of max 3
[If iteration > 1:]
- Previous review found these issues: [list from previous iteration]
- Fix agent addressed: [list of fixes applied]
- Check if previous issues are resolved AND look for new issues

REVIEW CHECKLIST:
1. Security vulnerabilities (injection, XSS, auth bypass, etc.)
2. Logic errors and bugs
3. Error handling gaps
4. Missing edge cases
5. Code quality (naming, structure, duplication)
6. Cross-step integration (do changes from different steps work together?)
7. Plan compliance (does implementation match the plan's intent?)

OUTPUT FORMAT (use exactly this structure):
Overall: [PASS | PASS WITH NOTES | NEEDS FIXES]

Critical Issues: (must fix - security, bugs, data corruption)
- [issue] | [file:line] | [why it matters] | [suggested fix]

Important Issues: (should fix - error handling, edge cases, quality)
- [issue] | [file:line] | [why it matters] | [suggested fix]

Suggested: (nice to have - style, refactoring)
- [suggestion]

Auto-fixable: (issues that can be fixed without architectural changes)
- [issue] | [file:line] | [fix description]

Praise:
- [what was done well]
```

**Agent B: Test Runner** (`Bash` subagent_type)

```
Run the project's test suite and quality checks. Execute these commands (skip any that don't apply):

1. Run tests (try in order: npm test, npx vitest run, pytest, php artisan test, go test ./..., cargo test)
2. Run linting (try: npm run lint, npx eslint ., flake8, phpstan)
3. Run type checking (try: npx tsc --noEmit, mypy ., phpstan analyse)

Report results as:
- Tests: [X passed, Y failed, Z skipped] or [not available]
- Lint: [clean / N issues] or [not available]
- Type check: [clean / N issues] or [not available]
- Failure details: [for any failures, show the error output]
```

##### Step 2: Evaluate Results

After both agents complete:

- **If review = PASS and tests pass** -> Exit loop, proceed to Gate 2
- **If review = PASS WITH NOTES (only Suggested items) and tests pass** -> Exit loop, note suggestions for Gate 2
- **If review = NEEDS FIXES or tests fail** -> Continue to Step 3
- **If iteration = 3 (max reached)** -> Exit loop, escalate all remaining issues to Gate 2

##### Step 3: Fix Agent

Spawn `general-purpose` agent (NO worktree - works on main directly):

```
You are fixing issues found during code review.

FIRST: Read the role definition from ~/.claude/roles/software-developer.md and adopt that role.

ISSUES TO FIX:
[Paste full review output from Step 1]

TEST FAILURES:
[Paste test failure details from Step 1]

PRIORITIES:
1. Fix ALL Critical issues (mandatory)
2. Fix ALL Important issues (mandatory)
3. Fix Auto-fixable Suggested issues (style, formatting)
4. Fix test failures
5. Do NOT fix Suggested items requiring architectural changes

After fixing:
- Run the affected tests to verify fixes
- Report: what was fixed, what remains unfixed (with reason), test results after fixes
```

##### Step 4: Update & Loop

- TaskUpdate: `{ validationIteration: [N+1] }`
- Brief status: `Validation iteration [N]: [X] issues found, [Y] fixed. Re-reviewing...`
- Loop back to Step 1 with fresh Review Agent

---

### Approval Gate 2: Final Review

Present consolidated results:

```
Implementation Complete - Validation Results

Summary:
  Steps: [X/N] completed across [M] waves
  Files: [Y] created, [Z] modified
  Validation: [iterations] iteration(s)

Quality:
  Code Review: [PASS / PASS WITH NOTES / NEEDS FIXES after 3 iterations]
  Tests: [X/Y passing]
  Type Check: [result or N/A]
  Lint: [result or N/A]

[If PASS WITH NOTES:]
Suggestions (optional improvements):
1. [suggestion from reviewer]

[If issues remain after 3 iterations:]
Unresolved Issues:
1. [Critical/Important: description - file:line]

Changes by Wave:
  Wave 1: [summary of what was implemented]
  Wave 2: [summary]
  ...

Full Review Details:
[Final review agent output]
```

**Use AskUserQuestion** with options:
- **A) Accept all changes** - Mark task complete
- **B) Run another validation iteration** - Spawn fix + review agents again
- **C) Fix specific issues manually** - User will fix, then can re-run validation
- **D) Reject and rollback** - `git reset --hard [base-commit]` (confirm before executing)

---

### Stage 3: Completion

If accepted (option A):

1. **Generate summary**:
   ```
   Complex Implementation Complete: [Feature Name]

   Executed: [N] steps in [M] waves
   Validation: [iterations] iteration(s), final status: [PASS/PASS WITH NOTES]
   Files: [created] created, [modified] modified
   Duration: [time from start]

   Next steps:
   - Review the full diff: git diff [base-commit]..HEAD
   - Commit changes: git add -A && git commit -m "[message]"
   - Create PR if needed
   ```

2. **Mark task completed**: TaskUpdate with `{ phase: "completed", status: "completed" }`

3. **Update TASKS.md**: Mark the corresponding entry as `[x]` done

---

## Error Handling

### Agent Failure
- If an implementation agent fails completely, mark the step as failed
- Continue with remaining steps in the wave
- Failed steps are reported at Gate 2 for user decision

### Merge Conflicts
- Load `~/.claude/skills/complex-task-implementation/references/merge-strategy.md`
- Attempt automatic resolution first
- If unresolvable, pause and ask user via AskUserQuestion

### Git Issues
- If working tree becomes dirty unexpectedly, stop and report
- Base commit hash enables rollback at any point
- User can always choose option D at Gate 2 to rollback

### Validation Loop Stuck
- Max 3 iterations prevents infinite loops
- If same issues persist across iterations, they are escalated (not retried)
- Track issue persistence: if an issue appears in iteration N and N+1, flag it as potentially unfixable by automation

## Progress Tracking

Use TaskCreate/TaskUpdate throughout:

```
Phase: planning -> executing -> validating -> completed
Metadata tracked:
  - totalSteps, totalWaves
  - currentWave, completedSteps, failedSteps
  - validationIteration (1-3)
  - baseCommit (for rollback)
```

User can check progress anytime with `/tasks`.

## Tips

- **Trust but verify**: The skill trusts the plan but validates the implementation thoroughly
- **Speed vs safety**: Parallel execution is fast, but the validation loop ensures quality
- **Rollback is always available**: Base commit hash means you can always undo everything
- **Wave granularity matters**: Too many steps per wave = merge risk. Too few = less parallelism
- **Agent scope isolation**: Each agent only touches its assigned files - this prevents conflicts
