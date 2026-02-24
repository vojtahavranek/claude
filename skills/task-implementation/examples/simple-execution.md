# Simple Execution Workflow Example

This example shows a complete task-implementation workflow from start to finish, demonstrating all three stages with realistic interactions.

## Scenario

User has a plan from task-preparation to add a user profile endpoint to an Express API. The plan includes 3 steps and tests exist in the project.

## Complete Workflow

### User Invocation

```
User: "implement plan: user-profile-endpoint"
```

---

### Stage 0: Plan Intake and Initialization

**Claude reads the plan file:**

```markdown
Reading ~/.claude/plans/user-profile-endpoint.md...

Plan found:
# Implementation Plan: User Profile Endpoint

## Summary
Add GET /api/users/:id endpoint to retrieve user profile data.

## Steps

### Step 1: Create user controller
- Files: src/controllers/userController.js (new file)
- What: Implement getUserProfile function
- Success: Controller exports getUserProfile function

### Step 2: Add route
- Files: src/routes/userRoutes.js (modify)
- What: Add GET /api/users/:id route
- Success: Route registered and responds

### Step 3: Write tests
- Files: tests/user.test.js (new file)
- What: Test endpoint with valid/invalid IDs
- Success: All tests passing
```

**Claude assesses test environment:**

```
Checking test setup...
✓ Found: package.json with jest
✓ Test command: npm test
✓ Existing tests: tests/auth.test.js

Test environment ready.
```

**Claude creates task:**

```javascript
TaskCreate({
  subject: "Implement user profile endpoint",
  description: "Add GET /api/users/:id endpoint with controller, route, and tests",
  activeForm: "Implementing user profile endpoint",
  metadata: {
    phase: "execution",
    totalSteps: 3,
    currentStep: 0,
    source: "task-implementation"
  }
})
```

**Claude adopts developer role:**

```
Reading ~/.claude/roles/software-developer.md...

I'm now acting as software-developer to implement this plan.

I'll focus on:
- Clean, readable code
- Proper error handling
- Following existing patterns
- Testing each step
- Getting your approval before implementing
```

---

### Stage 1: Execute Steps

#### Step 1 - Create User Controller

**Claude presents:**

```
Step 1 of 3: Create user controller

Files to be affected:
- src/controllers/userController.js (new file, ~30 LOC)

What I will do:
- Create getUserProfile function that:
  - Accepts userId parameter
  - Queries database for user
  - Returns user data or 404

How I will implement it:
- Use async/await pattern like other controllers
- Add error handling for invalid IDs and not found
- Return standardized JSON response
- Follow the pattern I see in authController.js

Why this approach:
- Matches existing controller structure in this project
- Consistent error handling with rest of API
- Async pattern allows database queries

Success criteria:
- Controller exports getUserProfile function
- Function signature matches route needs
```

**Claude requests approval:**

```
Approve execution of this step?
A) Approve and execute
B) Skip this step
C) Modify approach
D) Pause and resume later
```

**User responds:**

```
User: A
```

**Claude implements:**

```javascript
// Creating src/controllers/userController.js...

const User = require('../models/User');

/**
 * Get user profile by ID
 * @route GET /api/users/:id
 */
async function getUserProfile(req, res) {
  try {
    const userId = req.params.id;

    // Validate ID format
    if (!userId || userId.length === 0) {
      return res.status(400).json({
        error: 'User ID is required'
      });
    }

    // Query database
    const user = await User.findById(userId);

    if (!user) {
      return res.status(404).json({
        error: 'User not found'
      });
    }

    // Return profile data (excluding sensitive fields)
    return res.status(200).json({
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt
    });

  } catch (error) {
    console.error('Error fetching user profile:', error);
    return res.status(500).json({
      error: 'Failed to retrieve user profile'
    });
  }
}

module.exports = { getUserProfile };
```

**Claude runs tests (if applicable):**

```bash
# No specific tests for this yet, will test after route is connected
```

**Claude shows results:**

```
Results for Step 1:

What changed:
- Created: src/controllers/userController.js (32 LOC)

Verification:
✓ Success criteria met: Controller exports getUserProfile function
✓ Function signature ready for routing
✓ Code follows project patterns

Quality notes:
- Error handling added for: missing ID, invalid ID, not found, server errors
- Input validation included
- Follows async/await pattern from authController.js
- Excludes sensitive data (password hash)

Next step preview:
Step 2: Add route to connect controller to API endpoint
```

**Claude updates progress:**

```javascript
TaskUpdate({
  taskId: "...",
  metadata: {
    currentStep: 1,
    skippedSteps: []
  }
})
```

---

#### Step 2 - Add Route

**Claude presents:**

```
Step 2 of 3: Add route

Files to be affected:
- src/routes/userRoutes.js (modify existing, +3 LOC)

What I will do:
- Import getUserProfile from userController
- Add GET /api/users/:id route
- Connect route to controller function

How I will implement it:
- Follow Express routing pattern
- Use router.get() with :id parameter
- Connect to getUserProfile controller

Why this approach:
- Standard Express routing
- Consistent with other routes in this file
- RESTful endpoint structure

Success criteria:
- Route registered and responds to requests
- Controller function properly connected
```

**Claude requests approval:**

```
Approve execution of this step?
A) Approve and execute
B) Skip this step
C) Modify approach
D) Pause and resume later
```

**User responds:**

```
User: A
```

**Claude implements:**

```javascript
// Modifying src/routes/userRoutes.js...

// Added import
const { getUserProfile } = require('../controllers/userController');

// Added route (after existing routes)
router.get('/users/:id', getUserProfile);
```

**Claude runs tests:**

```bash
$ npm test -- src/routes

PASS  tests/routes.test.js
  User Routes
    ✓ GET /api/users/:id returns user data (45ms)
    ✓ GET /api/users/:id returns 404 for invalid ID (12ms)

Tests: 2 passed, 2 total
```

**Claude shows results:**

```
Results for Step 2:

What changed:
- Modified: src/routes/userRoutes.js (+3 LOC)

Verification:
✓ Success criteria met: Route registered and responds
✓ Tests: 2/2 passing (existing route tests)
✓ Endpoint accessible at GET /api/users/:id

Quality notes:
- Route follows RESTful convention
- Properly connected to controller
- Existing tests pass

Next step preview:
Step 3: Write comprehensive tests for the new endpoint
```

---

#### Step 3 - Write Tests

**Claude presents:**

```
Step 3 of 3: Write tests

Files to be affected:
- tests/user.test.js (new file, ~60 LOC)

What I will do:
- Create test suite for user profile endpoint
- Test valid user ID (200 response)
- Test invalid user ID (404 response)
- Test missing ID (400 response)
- Test server error handling

How I will implement it:
- Use Jest + Supertest (like other test files)
- Mock database calls
- Test all success and error paths
- Check response status and body structure

Why this approach:
- Matches existing test patterns in this project
- Covers all code paths in controller
- Verifies error handling works

Success criteria:
- All tests passing
- Coverage for normal and edge cases
```

**Claude requests approval:**

```
Approve execution of this step?
A) Approve and execute
B) Skip this step
C) Modify approach
D) Pause and resume later
```

**User responds:**

```
User: A
```

**Claude implements:**

```javascript
// Creating tests/user.test.js...

const request = require('supertest');
const app = require('../src/app');
const User = require('../src/models/User');

jest.mock('../src/models/User');

describe('User Profile Endpoint', () => {
  describe('GET /api/users/:id', () => {
    it('should return user profile for valid ID', async () => {
      const mockUser = {
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        createdAt: '2024-01-01'
      };

      User.findById.mockResolvedValue(mockUser);

      const response = await request(app)
        .get('/api/users/123')
        .expect(200);

      expect(response.body).toEqual(mockUser);
    });

    it('should return 404 for non-existent user', async () => {
      User.findById.mockResolvedValue(null);

      const response = await request(app)
        .get('/api/users/999')
        .expect(404);

      expect(response.body.error).toBe('User not found');
    });

    it('should return 400 for missing ID', async () => {
      const response = await request(app)
        .get('/api/users/')
        .expect(400);

      expect(response.body.error).toBe('User ID is required');
    });

    it('should handle database errors gracefully', async () => {
      User.findById.mockRejectedValue(new Error('DB connection failed'));

      const response = await request(app)
        .get('/api/users/123')
        .expect(500);

      expect(response.body.error).toBe('Failed to retrieve user profile');
    });
  });
});
```

**Claude runs tests:**

```bash
$ npm test -- tests/user.test.js

PASS  tests/user.test.js
  User Profile Endpoint
    GET /api/users/:id
      ✓ should return user profile for valid ID (34ms)
      ✓ should return 404 for non-existent user (8ms)
      ✓ should return 400 for missing ID (6ms)
      ✓ should handle database errors gracefully (12ms)

Tests: 4 passed, 4 total
Coverage: 100% of userController.js
```

**Claude shows results:**

```
Results for Step 3:

What changed:
- Created: tests/user.test.js (58 LOC)

Verification:
✓ Success criteria met: All tests passing
✓ Tests: 4/4 passing (100% of new tests)
✓ Coverage: 100% of new controller code

Quality notes:
- All code paths tested
- Edge cases covered (null, error, invalid input)
- Uses mocking to isolate unit tests
- Follows existing test patterns

Implementation complete!
```

**Claude updates progress:**

```javascript
TaskUpdate({
  taskId: "...",
  metadata: {
    currentStep: 3,
    skippedSteps: []
  }
})
```

---

### Stage 2: Completion and Summary

**Claude offers full test run:**

```
All steps completed! Would you like me to run the full test suite?
```

**User responds:**

```
User: Yes
```

**Claude runs full tests:**

```bash
$ npm test

PASS  tests/auth.test.js
PASS  tests/user.test.js
PASS  tests/routes.test.js

Test Suites: 3 passed, 3 total
Tests: 12 passed, 12 total
Coverage: 94.3% statements, 89.1% branches
```

**Claude generates summary:**

```
Implementation Complete!

Summary:
- Total steps: 3
- Completed: 3
- Skipped: 0
- Tests: 12/12 passing ✓

Files changed:
- Created: src/controllers/userController.js (32 LOC)
- Modified: src/routes/userRoutes.js (+3 LOC)
- Created: tests/user.test.js (58 LOC)

What was accomplished:
- User profile endpoint implemented at GET /api/users/:id
- Error handling for invalid IDs and server errors
- Comprehensive test coverage (4 new tests, all passing)
- 100% coverage of new controller code
```

**Claude suggests next steps:**

```
Suggestions:
- Test the endpoint manually with curl or Postman
- Consider rate limiting for production
- Review changes before committing
```

**Claude marks task completed:**

```javascript
TaskUpdate({
  taskId: "...",
  status: "completed",
  metadata: {
    phase: "completed",
    completedSteps: 3,
    skippedSteps: [],
    totalSteps: 3
  }
})
```

---

## Example: Error Handling

**Scenario: Syntax error during Step 1**

**Claude implements controller but makes a typo:**

```javascript
// Typo: "respone" instead of "response"
return respone.status(200).json({ ... });
```

**Error occurs when trying to verify:**

```
ERROR during Step 1 execution:

Error type: Runtime Error
Error message: ReferenceError: respone is not defined

Probable cause:
Typo in variable name - should be "response" not "respone"

What would you like to do?
A) Retry with fix (I'll correct the typo to "response")
B) Retry after you manually fix something
C) Skip this step and continue
D) Abort workflow (stop here)
```

**User responds:**

```
User: A
```

**Claude fixes and retries:**

```
Implementing fix: Correcting typo "respone" → "response"...

Fixed! Re-verifying step...

Results for Step 1:
✓ Success criteria met
✓ No errors
```

---

## Example: Skip Step

**Scenario: User wants to skip Step 2**

**Claude presents Step 2:**

```
Step 2 of 3: Add route
...
Approve execution?
```

**User responds:**

```
User: B (Skip this step)
```

**Claude handles skip:**

```
Skipping Step 2 as requested.

Note: Step 2 skipped - route not added to userRoutes.js

Moving to Step 3...
```

**In final summary:**

```
Summary:
- Total steps: 3
- Completed: 2
- Skipped: 1 (Step 2: Add route)
```

---

## Key Takeaways

**This example demonstrates**:

1. **Clear three-stage workflow**: Intake → Execute → Complete
2. **Approval before each step**: User maintains control
3. **Detailed presentation**: WHAT/HOW/WHY before approval
4. **Quality focus**: Error handling, testing, patterns
5. **Test integration**: Run tests, show results, verify
6. **Clear results**: Show what changed, verify criteria
7. **Error recovery**: Catch errors, offer fixes, retry
8. **Flexible handling**: Skip steps, pause, modify approach
9. **Comprehensive summary**: Track progress, show outcomes
10. **Simple suggestions**: Practical next steps, not pushy

**User experience**:
- Full visibility into each step
- Control at every decision point
- Clear feedback on results
- Confidence in code quality
- Tests verify correctness
