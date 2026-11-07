# Example: Parallel Execution with Developer+Reviewer Duos

Complete walkthrough of a multi-wave execution using Agent Teams with duos.

## Scenario

**Plan**: Add user authentication to an Express.js API
**Steps**: 8 steps, analyzed into 4 waves
**Agent Teams**: Enabled, developer+reviewer duos per step

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
Wave 1 (3 duos, parallel): Steps 1, 3, 5
  No dependencies, all create independent files

Wave 2 (2 duos, parallel): Steps 2, 4
  Step 2 depends on Step 1 (User type)
  Step 4 depends on Steps 1, 3 (User model + crypto)

Wave 3 (1 duo): Step 6
  Step 6 depends on Steps 2, 4, 5

Wave 4 (2 duos, parallel): Steps 7, 8
  Step 7 depends on Steps 4, 6
  Step 8 depends on Step 6
```

## Approval Gate 1

```
Execution Strategy for: User Authentication

Base commit: a1b2c3d (main)
Agent Teams: Developer+Reviewer duos per step

Wave Decomposition:
  Wave 1 (3 duos, parallel):
    Step 1: Create User model         -> src/models/user.ts (new)      -> duo: dev + reviewer
    Step 3: Password hashing utility   -> src/utils/crypto.ts (new)     -> duo: dev + reviewer
    Step 5: JWT configuration          -> src/config/jwt.ts (new)       -> duo: dev + reviewer

  Wave 2 (2 duos, parallel):
    Step 2: Auth middleware            -> src/middleware/auth.ts (new)   -> duo: dev + reviewer
      depends on: Step 1
    Step 4: Auth service               -> src/services/auth.ts (new)    -> duo: dev + reviewer
      depends on: Steps 1, 3

  Wave 3 (1 duo):
    Step 6: Auth routes                -> src/routes/auth.ts (new)      -> duo: dev + reviewer
      depends on: Steps 2, 4, 5

  Wave 4 (2 duos, parallel):
    Step 7: Auth tests                 -> tests/auth.test.ts (new)      -> duo: dev + reviewer
      depends on: Steps 4, 6
    Step 8: Mount routes               -> src/app.ts (modify)           -> duo: dev + reviewer
      depends on: Step 6

Parallelism: 4 waves instead of 8 sequential steps
Teammates: 8 duos (16 teammates total, max 6 active at once in Wave 1)
Files: 7 new, 1 modified

Risks:
- Step 8 modifies existing file (src/app.ts) — will verify after merge

Quality: Each step reviewed inline by paired reviewer.
         Post-wave integration check verifies cross-step compatibility.
```

**User selects: A) Approve and execute**

## Stage 1: Execution

### Wave 1 (Steps 1, 3, 5 — 3 duos in parallel)

**6 teammates spawned**: 3 developers + 3 reviewers

#### Duo for Step 1 (User Model)

```
Developer 1:
  - Creates src/models/user.ts with User interface, schema, password field
  - Messages Reviewer 1: "Step 1 implementation ready for review"

Reviewer 1:
  - Reads src/models/user.ts
  - Feedback:
    Verdict: NEEDS FIXES
    Important Issues:
    - [I-1] Password field should be excluded from default serialization |
      src/models/user.ts:15 | Leaks hashed password in API responses |
      Add toJSON method or select exclusion

Developer 1:
  - Adds toJSON() method that omits password
  - Messages Reviewer 1: "Fixes applied, ready for re-review"

Reviewer 1:
  - Re-reviews: toJSON properly excludes password
  - Verdict: APPROVED
  - Report: 2 review rounds, 1 important issue found and resolved
```

#### Duo for Step 3 (Crypto Utility)

```
Developer 3:
  - Creates src/utils/crypto.ts with bcrypt wrapper
  - Messages Reviewer 3: "Ready for review"

Reviewer 3:
  - Reviews crypto.ts
  - Verdict: APPROVED (clean implementation, proper async bcrypt usage)
  - Report: 1 review round, no issues
```

#### Duo for Step 5 (JWT Config)

```
Developer 5:
  - Creates src/config/jwt.ts with JWT secret and token options
  - Messages Reviewer 5: "Ready for review"

Reviewer 5:
  - Reviews jwt.ts
  - Feedback:
    Verdict: NEEDS FIXES
    Critical Issues:
    - [C-1] JWT secret hardcoded as "secret123" | src/config/jwt.ts:3 |
      Security vulnerability | Use process.env.JWT_SECRET with error if missing

Developer 5:
  - Replaces hardcoded secret with process.env.JWT_SECRET
  - Adds startup validation that throws if env var is missing
  - Messages Reviewer 5: "Fixed"

Reviewer 5:
  - Re-reviews: env-based secret with proper validation
  - Verdict: APPROVED
  - Report: 2 review rounds, 1 critical issue found and resolved
```

#### Wave 1 Merge & Integration Check

All 3 duos complete. Merge sequentially:
```bash
git merge step-1-branch --no-edit  # Clean
git merge step-3-branch --no-edit  # Clean
git merge step-5-branch --no-edit  # Clean
```

Integration check: No cross-step dependencies in Wave 1 (all independent files). Tests pass.

**Status**: `Wave 1/4 complete: 3 steps done, 3 files created. 5 duo review rounds total. Integration: PASS. Moving to Wave 2...`

### Wave 2 (Steps 2, 4 — 2 duos in parallel)

**4 teammates spawned**: 2 developers + 2 reviewers

#### Duo for Step 2 (Auth Middleware)

```
Developer 2:
  - Creates src/middleware/auth.ts, imports User type from Step 1
  - Messages Reviewer 2: "Ready for review"

Reviewer 2:
  - Verdict: APPROVED (clean, proper JWT verification, correct User type usage)
  - Report: 1 review round, no issues
```

#### Duo for Step 4 (Auth Service)

```
Developer 4:
  - Creates src/services/auth.ts, imports User model and crypto utilities
  - Messages Reviewer 4: "Ready for review"

Reviewer 4:
  - Feedback:
    Verdict: NEEDS FIXES
    Important Issues:
    - [I-1] No password length validation | src/services/auth.ts:15 |
      Allows empty passwords | Add minimum 8 chars check
    - [I-2] Missing await on hash function | src/services/auth.ts:22 |
      Returns Promise instead of hash | Add await

Developer 4:
  - Adds password validation, fixes missing await
  - Messages Reviewer 4: "Fixed both"

Reviewer 4:
  - Re-reviews: both issues resolved
  - Verdict: APPROVED
  - Report: 2 review rounds, 2 important issues found and resolved
```

#### Wave 2 Merge & Integration Check

```bash
git merge step-2-branch --no-edit  # Clean
git merge step-4-branch --no-edit  # Clean
```

Integration check:
- Step 2 imports User type from Step 1's output ✓
- Step 4 imports User model from Step 1 and crypto from Step 3 ✓
- All imports resolve correctly, tests pass.

**Status**: `Wave 2/4 complete: 5 steps done, 5 files created. Integration: PASS. Moving to Wave 3...`

### Wave 3 (Step 6 — 1 duo)

```
Duo Step 6: Developer creates auth routes using middleware (Step 2), service (Step 4),
            and JWT config (Step 5). Reviewer approves after 1 round. Clean.
```

Merge & integration check: Routes correctly import from all prior steps. PASS.

**Status**: `Wave 3/4 complete: 6 steps done, 6 files created. Integration: PASS. Moving to Wave 4...`

### Wave 4 (Steps 7, 8 — 2 duos in parallel)

```
Duo Step 7: Developer creates auth tests using actual service and route implementations.
            7 tests written. Reviewer suggests adding edge case test for expired JWT.
            Developer adds it. 8 tests total. Approved in round 2.
Duo Step 8: Developer modifies app.ts to mount routes, reviewer catches missing
            error handler middleware — fixed in round 2. Approved.
```

Merge: clean. Integration: all 8 tests pass, routes mounted correctly.

**Status**: `Wave 4/4 complete: 8/8 steps done. All duos approved. Moving to final validation...`

## Stage 2: Integration Validation

### Iteration 1

**Integration Reviewer** checks cross-step compatibility:
```
Overall: PASS

Integration Issues: None
Missing Glue: None

Plan Compliance:
- All 8 steps implemented as specified
- JWT approach properly uses env-based configuration
- Tests cover main flows

Note: All critical issues (hardcoded JWT secret, missing password validation,
missing await) were caught and fixed by per-step reviewers during implementation.
```

**Test Runner**:
```
Tests: 8 passed, 0 failed
Lint: clean
Type check: clean
```

**Evaluation**: PASS + tests pass → Exit loop, proceed to Gate 2

> **Note**: In the old model without duos, the JWT secret and password validation
> issues would have been found in post-hoc batch review (iteration 1), fixed
> (iteration 2), re-reviewed (iteration 2 passes). That's 2 validation iterations
> plus 9+ agent invocations. With duos, the integration validation passed in
> 1 iteration with 2 agent invocations because issues were already fixed inline.

## Approval Gate 2

```
Implementation Complete — Final Review

Summary:
  Steps: 8/8 completed across 4 waves
  Files: 7 created, 1 modified
  Duo reviews: 12 review rounds across 8 duos (avg 1.5 rounds/step)
  Integration validation: 1 iteration

Quality:
  Per-step review: 8/8 steps approved by paired reviewer
  Integration review: PASS
  Tests: 8/8 passing
  Type Check: clean
  Lint: clean

Issues caught by duos during implementation:
  - Critical: 1 (hardcoded JWT secret — Step 5)
  - Important: 4 (password serialization, validation, missing await, error handler)
  - All resolved before integration validation

Changes by Wave:
  Wave 1: User model, crypto utilities, JWT config
  Wave 2: Auth middleware, auth service
  Wave 3: Auth routes, app.ts route mounting
  Wave 4: Auth test suite (8 tests)
```

**User selects: A) Accept all changes**

## Stage 3: Completion

```
Complex Implementation Complete: User Authentication

Executed: 8 steps in 4 waves using developer+reviewer duos
Quality: 12 inline review rounds, 5 issues caught and fixed during implementation
Integration: 1 iteration, PASS
Files: 7 created, 1 modified
Tests: 8/8 passing

Next steps:
- Review the full diff: git diff a1b2c3d..HEAD
- Stage and commit changes (prefer adding specific files over git add -A)
- Create PR if needed
```

Task marked as completed. TASKS.md updated.

## Comparison: Old Model vs Duo Model (This Example)

| Metric | Old (batch review) | New (duos) |
|--------|-------------------|------------|
| Implementation agents | 8 (1 per step) | 16 (2 per step: dev + reviewer) |
| Post-hoc review iterations | 2 (found 3 critical/important, fixed, re-reviewed) | 1 (PASS — issues already fixed) |
| Issues caught | 3 (all in batch review after all code written) | 5 (caught inline, including 2 extras) |
| When issues found | After all 8 steps complete | During each step's implementation |
| Total agent invocations | 8 impl + 6 validation = 14 | 16 impl + 2 validation = 18 |
| Quality confidence | Medium (batch reviewer has broad but shallow context) | High (each reviewer has deep context for their step) |
| Fix risk | Higher (fixing in bulk can introduce regressions) | Lower (fixes are scoped to one step) |
