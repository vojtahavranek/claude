# Example: Parallel Execution with Validation

Complete walkthrough of a multi-wave execution with 2 validation iterations.

## Scenario

**Plan**: Add user authentication to an Express.js API
**Steps**: 8 steps, analyzed into 3 waves

## Stage 0: Dependency Analysis

### Step Analysis

| Step | Description | Creates/Modifies | Dependencies |
|------|-------------|-----------------|--------------|
| 1 | Create User model | `src/models/user.ts` (new) | None |
| 2 | Create auth middleware | `src/middleware/auth.ts` (new) | Step 1 (imports User type) |
| 3 | Add password hashing utility | `src/utils/crypto.ts` (new) | None |
| 4 | Create auth service | `src/services/auth.ts` (new) | Steps 1, 3 |
| 5 | Add JWT configuration | `src/config/jwt.ts` (new) | None |
| 6 | Create auth routes | `src/routes/auth.ts` (new) | Steps 2, 4, 5 |
| 7 | Add auth tests | `tests/auth.test.ts` (new) | Steps 4, 6 |
| 8 | Update app.ts to mount routes | `src/app.ts` (modify) | Step 6 |

### Computed Waves

```
Wave 1 (parallel - 3 agents): Steps 1, 3, 5
  No dependencies, all create independent files

Wave 2 (parallel - 2 agents): Steps 2, 4
  Step 2 depends on Step 1 (User type)
  Step 4 depends on Steps 1, 3 (User model + crypto)

Wave 3 (parallel - 3 agents): Steps 6, 7, 8
  Step 6 depends on Steps 2, 4, 5
  Step 7 depends on Steps 4, 6
  Step 8 depends on Step 6
```

## Approval Gate 1

```
Execution Strategy for: User Authentication

Base commit: a1b2c3d (main)

Wave Decomposition:
  Wave 1 (3 steps, parallel):
    Step 1: Create User model         -> src/models/user.ts (new)
    Step 3: Password hashing utility   -> src/utils/crypto.ts (new)
    Step 5: JWT configuration          -> src/config/jwt.ts (new)

  Wave 2 (2 steps, parallel):
    Step 2: Auth middleware            -> src/middleware/auth.ts (new)
      depends on: Step 1
    Step 4: Auth service               -> src/services/auth.ts (new)
      depends on: Steps 1, 3

  Wave 3 (3 steps, parallel):
    Step 6: Auth routes                -> src/routes/auth.ts (new)
      depends on: Steps 2, 4, 5
    Step 7: Auth tests                 -> tests/auth.test.ts (new)
      depends on: Steps 4, 6
    Step 8: Mount routes               -> src/app.ts (modify)
      depends on: Step 6

Parallelism: 3 waves instead of 8 sequential steps
Files: 7 new, 1 modified

Risks:
- Step 8 modifies existing file (src/app.ts) - will verify after merge
- Steps 7 depends on Step 6 (in same wave) - will be handled sequentially within wave
```

**User selects: A) Approve and execute**

> Note: Steps 6 and 7 are in the same wave but 7 depends on 6. The orchestrator should detect this and either move Step 7 to a Wave 4 or execute it sequentially within Wave 3 after Step 6 completes. In practice, the wave computation algorithm would place Step 7 in Wave 4 because its dependency (Step 6) is in Wave 3.

**Corrected waves after proper topological sort:**
```
Wave 1: Steps 1, 3, 5
Wave 2: Steps 2, 4
Wave 3: Steps 6, 8
Wave 4: Step 7
```

## Stage 1: Execution

### Wave 1 (Steps 1, 3, 5 - parallel)

Three agents spawned simultaneously:
- Agent 1 (worktree): Creates `src/models/user.ts` with User interface and schema
- Agent 3 (worktree): Creates `src/utils/crypto.ts` with bcrypt wrapper
- Agent 5 (worktree): Creates `src/config/jwt.ts` with JWT secret and options

All complete successfully. Merge sequentially:
```bash
git merge agent-step-1-branch --no-edit  # Clean
git merge agent-step-3-branch --no-edit  # Clean
git merge agent-step-5-branch --no-edit  # Clean
```

Status: `Wave 1/4 complete: 3 steps done, 3 files created`

### Wave 2 (Steps 2, 4 - parallel)

Two agents spawned:
- Agent 2 (worktree): Creates auth middleware, imports User type from Step 1's output
- Agent 4 (worktree): Creates auth service, imports User model and crypto utilities

Both complete. Merge:
```bash
git merge agent-step-2-branch --no-edit  # Clean
git merge agent-step-4-branch --no-edit  # Clean
```

Status: `Wave 2/4 complete: 5 steps done, 5 files created`

### Wave 3 (Steps 6, 8 - parallel)

Two agents spawned:
- Agent 6 (worktree): Creates auth routes, uses middleware and service
- Agent 8 (worktree): Modifies app.ts to mount auth routes

Both complete. Merge:
```bash
git merge agent-step-6-branch --no-edit  # Clean
git merge agent-step-8-branch --no-edit  # Clean
```

Status: `Wave 3/4 complete: 7 steps done, 6 files created, 1 modified`

### Wave 4 (Step 7)

One agent spawned:
- Agent 7 (worktree): Creates auth tests using actual service and route implementations

Completes and merge:
```bash
git merge agent-step-7-branch --no-edit  # Clean
```

Status: `Wave 4/4 complete: 8/8 steps done. Moving to validation...`

## Stage 2: Validation

### Iteration 1

**Review Agent findings:**
```
Overall: NEEDS FIXES

Critical Issues:
- [C-1] JWT secret hardcoded as "secret123" | src/config/jwt.ts:3 |
  Security vulnerability, secret should come from environment variable |
  Use process.env.JWT_SECRET with fallback error

Important Issues:
- [I-1] No password length validation in auth service | src/services/auth.ts:15 |
  Allows empty or very short passwords |
  Add minimum length check (8 chars)
- [I-2] Missing error handling in login route | src/routes/auth.ts:28 |
  Unhandled promise rejection if DB query fails |
  Add try-catch wrapper

Suggested:
- [S-1] Consider adding rate limiting to auth routes

Auto-fixable:
- [C-1] Replace hardcoded secret with env variable
- [I-1] Add password validation check
- [I-2] Add try-catch to route handler

Praise:
- Clean separation of concerns between model, service, and routes
- Good use of TypeScript types throughout

Integration Check:
- Imports between files are consistent
- Type definitions align across modules

Plan Compliance:
- Implementation matches plan intent
- JWT approach is well-structured
```

**Test Runner results:**
```
Tests: 5 passed, 2 failed
- FAIL: "should reject invalid credentials" - Expected 401, got 500 (unhandled error)
- FAIL: "should hash password on registration" - Timeout (missing await)
Lint: clean
Type check: clean
```

**Evaluation**: NEEDS FIXES -> continue to fix agent

**Fix Agent actions:**
- Fixed C-1: Replaced hardcoded JWT secret with `process.env.JWT_SECRET`
- Fixed I-1: Added password length validation (min 8 chars)
- Fixed I-2: Added try-catch to login route handler
- Fixed test failure 1: The try-catch fix resolves the 500 -> 401 issue
- Fixed test failure 2: Added missing `await` on hash function call

### Iteration 2

**Review Agent findings (fresh reviewer):**
```
Overall: PASS WITH NOTES

Critical Issues: None

Important Issues: None

Suggested:
- [S-1] Consider adding rate limiting to auth routes (persists from iteration 1)
- [S-2] JWT_SECRET error message could include documentation link

Auto-fixable: None

Praise:
- All critical and important issues from iteration 1 are properly resolved
- Error handling is now comprehensive
- Security improvement with env-based JWT secret is well done

Integration Check: All good
Plan Compliance: Matches plan intent
```

**Test Runner results:**
```
Tests: 7 passed, 0 failed
Lint: clean
Type check: clean
```

**Evaluation**: PASS WITH NOTES + tests pass -> Exit loop

## Approval Gate 2

```
Implementation Complete - Validation Results

Summary:
  Steps: 8/8 completed across 4 waves
  Files: 7 created, 1 modified
  Validation: 2 iterations

Quality:
  Code Review: PASS WITH NOTES
  Tests: 7/7 passing
  Type Check: clean
  Lint: clean

Suggestions (optional improvements):
1. Consider adding rate limiting to auth routes
2. JWT_SECRET error message could include documentation link

Changes by Wave:
  Wave 1: User model, crypto utilities, JWT config
  Wave 2: Auth middleware, auth service
  Wave 3: Auth routes, app.ts route mounting
  Wave 4: Auth test suite

Auto-fixes Applied (during validation):
- Replaced hardcoded JWT secret with environment variable
- Added password length validation
- Added error handling to login route
- Fixed missing await in password hashing
```

**User selects: A) Accept all changes**

## Stage 3: Completion

```
Complex Implementation Complete: User Authentication

Executed: 8 steps in 4 waves
Validation: 2 iterations, final status: PASS WITH NOTES
Files: 7 created, 1 modified
Tests: 7/7 passing

Next steps:
- Review the full diff: git diff a1b2c3d..HEAD
- Commit changes: git add -A && git commit -m "Add user authentication"
- Create PR if needed
```

Task marked as completed. TASKS.md updated.
