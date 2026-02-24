---
name: task-implementation
description: |
  Use when user asks to "implement plan", "execute plan", or provides a plan file.

  Reads saved plan and implements step-by-step with user approval.
  Uses software-developer role, runs tests when available.

  Use when: User has complete plan ready to implement
  Don't use: User needs planning (use task-preparation)
---

# Task Implementation Skill

## Overview

This skill executes implementation plans step-by-step with user approval at each stage. It focuses purely on **execution**, not planning.

**Key characteristics**:
- Execution-only (no planning or architecture design)
- Uses software-developer role throughout
- Approval required before each step
- Runs tests when available
- Flexible with plan formats
- Simple error handling
- **Tracks progress** via task system for visibility

**Complementary skill**: Use `task-preparation` for planning and architecture design. This skill picks up where that ends.

## How to Use This Skill

**Invocation**: Just tell me to implement or execute a plan:
```
"implement plan: feature-name"
"execute plan: /path/to/plan.md"
"implement this plan: [paste plan content]"
"/task-implementation /path/to/plan.md"
```

**Plan storage**: Plans are stored in the project's `.claude/task/` folder:
- **Default**: `.claude/task/feature-name.md` inside the project directory
- **Custom**: Any absolute or relative path you specify

When you use `task-preparation`, it will ask you where to save the plan. Then use that same path with this skill.

## When to Use This Skill

**Use when**:
- User says "implement plan: [name]" or "execute plan: [path]"
- User provides a complete implementation plan
- Focus should be on code quality and execution
- User wants step-by-step control

**Don't use when**:
- User needs planning or architecture (use task-preparation)
- Trivial single-step tasks (direct implementation is faster)
- User wants to explore or research (use explore agent)

## Prerequisites

**Required**:
- A plan file with implementation steps (from task-preparation or user-provided)
- Plan location can be:
  - Project-local: `./plans/feature.md` (recommended for team collaboration)
  - Global: `~/.claude/plans/feature.md` (personal plans)
  - Custom: Any path you specify

**Minimal plan format**:
```markdown
# Plan: [Name]

## Steps

### Step 1: [Description]
- Files: path/to/file.js
- What: [What to implement]

### Step 2: [Description]
...
```

If information is missing (test command, success criteria), use common sense or ask user.

## Progress Tracking

**This skill tracks progress throughout** using the task system:

- ✅ **Task created** at Stage 0 with total steps
- ✅ **Task updated** after each step with current progress
- ✅ **Task completed** when all steps done
- ✅ **Resume capability** - can pause and resume later

**User benefit**: You can see exactly where we are in the implementation at any time with `/tasks`.

## Three-Stage Workflow

### Stage 0: Plan Intake and Initialization

**1. Load the plan**:

**If user provides full path**:
- `"implement plan: /path/to/plan.md"` → Read from that path
- `"implement plan: ./plans/feature.md"` → Read from project directory

**If user provides just a name**:
- `"implement plan: feature-name"` → Look in the current project first:
  - Check `.claude/task/feature-name.md` in the project directory
  - If not found, ask the user for the path
- Then read from the resolved path

**If user provides inline plan**:
- Parse directly from message content

**2. Parse the plan**:
- Extract steps (numbered list)
- Note files to modify/create
- Identify what needs to be done
- If format unclear, ask user for clarification

**3. Assess test environment** (optional):
- Check for package.json (jest, mocha, vitest)
- Check for requirements.txt (pytest)
- Check for Cargo.toml (cargo test)
- Ask user: "What command runs tests?" if not obvious
- Note: No tests? That's okay, we'll suggest adding them later

**4. Create task**:
```javascript
TaskCreate({
  subject: "Implement [feature name from plan]",
  description: "[Plan summary]",
  activeForm: "Implementing [feature name]",
  metadata: {
    phase: "execution",
    totalSteps: N,
    currentStep: 0,
    source: "task-implementation"
  }
})
```

**5. Adopt developer role**:
- Read `~/.claude/roles/software-developer.md`
- Explicitly state: "I'm now acting as software-developer to implement this plan."
- Apply developer mindset: clean code, proper error handling, testing

### Stage 1: Execute Steps (Main Loop)

**For each step in the plan**:

#### 1. Present the Step and Request Approval

**CRITICAL**: This is a single atomic action. Present the step details, then call AskUserQuestion. Do NOT proceed to section 2 (Execute) until the user has responded. Do not assume or guess the user's answer.

Show the step details to the user, then STOP and wait for explicit approval:

```
Step X of Y: [Description]

Files to be affected:
- path/to/file1.js (new file, ~50 LOC)
- path/to/file2.js (modify existing)

What I will do:
- [Detailed implementation approach]
- [Specific functions/classes to add or modify]
- [Key logic to implement]

How I will implement it:
- [Concrete technical approach]
- [Libraries/patterns I'll use]
- [Structure and organization]

Why this approach:
- [Rationale for technical choices]
- [How it fits with existing code]

Success criteria:
- [How we'll verify it works]
```

**STOP here. Use the AskUserQuestion tool now.** Ask the user:
- "Approve execution of Step X of Y: [Description]?"
- Options: Approve and execute | Skip this step | Modify approach | Pause and resume later

Do not call Write, Edit, or Bash until the user has responded via AskUserQuestion. Handle the response in section 2 below.

#### 2. Execute (Only If Approved)

**If user chooses A (Approve)**:

- Use Write tool for new files
- Use Edit tool for modifications
- Apply software-developer principles:
  - Clean, readable code
  - Proper error handling (try-catch, validation)
  - Input validation at boundaries
  - Security best practices (no SQL injection, XSS, etc.)
  - Follow existing code patterns
  - DRY without over-abstraction
  - Clear variable/function names

**If user chooses B (Skip)**:
- Document the skip
- Update metadata: add step number to skippedSteps
- Move to next step

**If user chooses C (Modify)**:
- Listen to user's alternative approach
- Re-present step with new approach
- Request approval again

**If user chooses D (Pause)**:
- Update task status to paused
- Document progress (completed steps, current step)
- Exit gracefully
- User can resume later by re-invoking skill

#### 3. Run Tests (If Available)

**After implementing, if tests exist**:

```bash
# Run relevant tests
npm test -- path/to/relevant.test.js

# Or run full suite
npm test
```

**Show results**:
- Pass/fail count
- Failed test details if any
- Coverage change if available

**Handle test failures**:
- Show error details
- Offer to fix the implementation
- User can choose: fix and retry, or skip and continue
- Don't block forever - user decides whether to proceed

**If no tests**:
- Note: "No tests found for this code"
- Continue without blocking
- Will suggest adding tests in Stage 2

#### 4. Verify Success Criteria

Check the success criteria from the step:
- Does it work as intended?
- Can we verify the outcome?
- Manual verification if needed (read files, check structure)

#### 5. Show Results

```
Results for Step X:

What changed:
- Created: path/to/file1.js (~52 LOC)
- Modified: path/to/file2.js (+18 LOC)

Verification:
✓ Success criteria met: [criteria from plan]
✓ Tests: [5/5 passing] or [No tests available]
✓ Code follows project patterns

Quality notes:
- Added error handling for [scenarios]
- Input validation included
- Follows existing [pattern] style

Next step preview:
Step X+1: [Brief description of next step]
```

#### 6. Update Progress (IMPORTANT: Always do this)

**CRITICAL**: Update task after EVERY step to maintain progress visibility.

```javascript
TaskUpdate({
  taskId: [ID],
  metadata: {
    currentStep: X,
    skippedSteps: [array of skipped step numbers],
    completedSteps: [array of completed step numbers],
    lastUpdated: new Date().toISOString()
  }
})
```

**Why this matters**:
- User can check progress anytime with `/tasks`
- Implementation can take hours/days - task tracking provides visibility
- Supports pause/resume workflow
- Shows exactly what's done and what's remaining

**User can check progress**: Type `/tasks` to see current status at any time.

#### 7. Handle Errors

**If step execution fails**:

```
ERROR during Step X execution:

Error type: [Syntax/Runtime/Test Failure/Tool Error]
Error message: [Full error text]

Probable cause:
[Analysis of what went wrong]

What would you like to do?
A) Retry with fix (I'll implement: [specific fix])
B) Retry after you manually fix something
C) Skip this step and continue
D) Abort workflow (stop here)
```

**Recovery actions**:
- **A**: Implement fix, re-execute, verify
- **B**: Wait for user, re-execute, verify
- **C**: Document skip, move to next step
- **D**: Mark task paused, document progress, exit

**Repeat loop** for all remaining steps.

### Stage 2: Completion and Summary

**1. Optional full test run**:
If tests exist, offer to run full suite:
```bash
npm test --coverage  # or equivalent
```

Show coverage if available.

**2. Generate summary**:

```
Implementation Complete!

Summary:
- Total steps: N
- Completed: X
- Skipped: Y (steps: [numbers])
- Tests: [status]

Files changed:
- Created: [list]
- Modified: [list]

What was accomplished:
- [Key outcome 1]
- [Key outcome 2]
- [Key outcome 3]
```

**3. Suggest next steps** (simple, not pushy):

**If no tests or low coverage**:
```
Testing suggestions:
- Consider adding tests for [specific areas]
- No test framework? Consider jest (JS) or pytest (Python)
- Tests would help catch regressions
```

**If everything looks good**:
```
Suggestions:
- Test the implementation manually
- Consider adding documentation if needed
- Review the changes before committing
```

**4. Mark task completed**:

```javascript
TaskUpdate({
  taskId: [ID],
  status: "completed",
  metadata: {
    phase: "completed",
    completedSteps: X,
    skippedSteps: [array],
    totalSteps: N
  }
})
```

**5. Update TASKS.md**:

Mark the task as complete in the centralized task tracker:

**File**: `{{PROJECTS_DIR}}/TASKS.md`

Change the task under the project section:
```
- [~] [Feature name]  →  - [x] [Feature name]
```

Update the "Last updated" date at the top of the file.

## Software-Developer Role Integration

**Load once at Stage 0**:
```javascript
Read({ file_path: "~/.claude/roles/software-developer.md" })
```

**Apply throughout all stages**:
- **Clean code**: Readable, maintainable, well-organized
- **Error handling**: Try-catch blocks, validation, helpful messages
- **Security**: Input sanitization, no injection vulnerabilities
- **Testing**: Run tests, verify implementations
- **Pragmatism**: Balance quality with simplicity
- **Patterns**: Follow existing code conventions

**CRITICAL approval discipline** (from developer role):
- NEVER write code without approval
- Present detailed plan BEFORE each step
- Explain WHAT, HOW, and WHY
- Wait for explicit user approval
- Only then implement

## Working with Plan Formats

**This skill is flexible** - we work with whatever plan we get.

**Ideal format** (from task-preparation):
- Summary
- Numbered steps
- Files per step
- What to implement
- Success criteria

**Minimal acceptable**:
- Step descriptions
- Files to change
- Basic "what to do"

**If information is missing**:
- Use common sense for obvious cases
- Ask user if unclear
- Don't be picky about format
- Focus on getting work done

**Examples of accepted inputs**:
- `~/.claude/plans/feature-name.md` (saved by task-preparation)
- `/path/to/custom-plan.md` (user file)
- Inline markdown in user message
- Simple numbered list with file paths

## Testing Integration

**Philosophy**: Run tests when available, but don't block forever.

**Stage 0: Assess test environment**:
- Look for test frameworks
- Identify test command
- Note existing tests

**Stage 1: Run tests after each step**:
- If tests exist, run them
- Show results
- If tests fail, offer to fix
- User decides whether to proceed

**Stage 2: Suggest improvements**:
- Identify gaps in test coverage
- Recommend test frameworks if none
- Suggest specific tests to add
- Keep it simple, not pushy

**Never**:
- Block forever on test failures
- Force user to add tests
- Auto-install testing tools
- Make tests mandatory

## Error Handling

**Types of errors**:
1. **Syntax errors**: Show error, offer fix, retry
2. **Runtime errors**: Analyze cause, suggest fix
3. **Test failures**: Show details, offer to fix or skip
4. **Tool errors**: Explain issue, try alternative approach

**Recovery flow**:
1. Capture error with full details
2. Diagnose probable cause
3. Suggest specific fixes
4. Offer 4 options: retry with fix, retry after user fix, skip, abort
5. Respect user choice
6. Continue or exit appropriately

**Keep it simple**:
- Don't over-analyze
- Offer practical solutions
- Let user decide whether to proceed
- Document issues in summary

## Task Management (Critical for Long Implementations)

**Why task tracking matters**:
- Implementation can take **hours or days** for complex features
- User needs visibility into progress at any time
- Supports natural workflow interruptions (meetings, breaks, other work)
- Enables pause/resume without losing context
- Shows exactly what's done and what remains

**TaskCreate at Stage 0** (Always do this first):
```javascript
TaskCreate({
  subject: "Implement [feature name from plan]",
  description: "[Plan summary with key objectives]",
  activeForm: "Implementing [feature name]",
  metadata: {
    phase: "execution",
    totalSteps: N,
    currentStep: 0,
    completedSteps: [],
    skippedSteps: [],
    source: "task-implementation",
    planPath: "[path to plan file]"
  }
})
```

**TaskUpdate after EVERY step** (Never skip this):
```javascript
TaskUpdate({
  taskId: [ID],
  status: "in_progress",
  metadata: {
    currentStep: X,
    completedSteps: [1, 2, 3, ...],
    skippedSteps: [5, ...],
    lastUpdated: new Date().toISOString()
  }
})
```

**TaskUpdate on completion**:
```javascript
TaskUpdate({
  taskId: [ID],
  status: "completed",
  metadata: {
    phase: "completed",
    completedSteps: X,
    skippedSteps: [array],
    totalSteps: N
  }
})
```

**TaskUpdate on pause**:
```javascript
TaskUpdate({
  taskId: [ID],
  status: "paused",
  metadata: {
    phase: "paused",
    currentStep: X,
    nextStep: X+1,
    completedSteps: [array],
    skippedSteps: [array]
  }
})
```

**User can check progress anytime**: `/tasks` shows current status, which step, progress percentage.

## Pause and Resume

**User chooses "Pause" during any step**:
1. Update task to paused status
2. Document progress:
   - Steps completed: [list]
   - Current step: [number and description]
   - Steps remaining: [count]
3. Save state in task metadata
4. Exit gracefully

**To resume**:
- User re-invokes skill with same plan
- Read task metadata to find last completed step
- Continue from next step
- Maintain full context from plan

## Tips and Best Practices

**For optimal results**:

1. **Trust the plan**: Don't re-plan or redesign during execution
2. **Approve deliberately**: Review each step before approving
3. **Fix issues promptly**: Don't accumulate broken steps
4. **Run tests regularly**: Catch issues early
5. **Skip strategically**: Some steps might not apply anymore
6. **Pause when needed**: Take breaks on complex implementations

**For Claude executing this skill**:

1. **Always load developer role** at Stage 0
2. **Never skip approval** - always wait for user choice
3. **Be explicit about what you'll do** - WHAT/HOW/WHY every time
4. **Show clear results** - user should see what changed
5. **Handle errors gracefully** - offer options, don't give up
6. **Keep it simple** - don't over-engineer, trust the plan
7. **Respect user decisions** - if they want to skip or proceed despite issues, that's okay

## Reference Materials

**Load when needed**:

- `references/best-practices.md` - Code quality reminders, common patterns, security tips
  - Load when: Implementing complex logic, uncertain about approach

**Example workflow**:

- `examples/simple-execution.md` - Complete workflow example
  - Load when: User asks how the skill works, or you need a reference

**Don't load by default** - only when actually needed to save context.

## Workflow Summary

```
User: "implement plan: feature-name"
  ↓
Stage 0: Plan Intake
  - Read ~/.claude/plans/feature-name.md
  - Parse 5 steps
  - Check for tests (found: npm test)
  - Create task
  - Adopt software-developer role
  ↓
Stage 1: Execute Steps (5 iterations)
  For each step:
    1. Present step and request approval via AskUserQuestion (STOP until user responds)
    2. If approved: Implement code
    3. Run tests (if available)
    4. Verify success criteria
    5. Show results
    6. Update progress
  ↓
Stage 2: Completion
  - Run full test suite (optional)
  - Generate summary
  - Suggest next steps
  - Mark task completed
  ↓
Done!
```

## Integration Points

- `~/.claude/plans/[name].md` - Read plan created by task-preparation
- `~/.claude/roles/software-developer.md` - Primary role for implementation
- TaskCreate - Create execution task at Stage 0
- TaskUpdate - Update progress after steps, mark completed
- AskUserQuestion - Request approval at each step
- Write/Edit - Implement code changes
- Bash - Run tests and verify

## Complementary Skills

**task-preparation** (planning):
- Creates the plans this skill executes
- Handles requirements, architecture, design
- Stops at Approval Gate #1 (plan approval)
- Saves plans to user-specified location (project-local, global, or custom)

**task-implementation** (this skill):
- Executes saved plans
- Handles code implementation
- Approval Gate #2 (per-step approval)
- Runs tests and verifies quality

**Clear separation**: No overlap, complementary workflow.
