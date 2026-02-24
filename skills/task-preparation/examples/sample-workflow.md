# Sample Workflow: Add User Authentication

This example demonstrates the complete task preparation workflow from initial request through implementation completion. It shows all stages in action, including both approval gates, complexity assessment, and the dual-architect approach.

---

## User Request

**User:** "I need to add user authentication to my Express.js app. Use task preparation skill."

---

## Initial Complexity Assessment

**Claude:** Let me assess the complexity of this task.

**Complexity Indicators Found:**
- ✓ Spans multiple layers (routes, middleware, database)
- ✓ Security implications (authentication)
- ✓ Likely 5+ files (routes, middleware, models, migrations, config)

**Assessment:** This is a complex task (3+ indicators). Not eligible for bypass.

Proceeding with full task preparation workflow.

---

## Phase A: Plan Development

### Stage 0: Task Creation

**Claude:** I've created a task to track this work:

```
Task ID: auth-impl-001
Subject: Add user authentication system
Description: Implement authentication system for Express.js app including login, registration, and session management
Status: in_progress
Metadata: { phase: "planning", step: 0 }
```

---

### Stage 1: Requirements Gathering

**Claude:** Let me gather comprehensive requirements. I'll ask questions across key categories.

**Question Batch 1:**

1. **Authentication Method**: Which authentication approach do you prefer?
   - Session-based (cookies, server-side sessions)
   - Token-based (JWT)
   - OAuth/Third-party (Google, GitHub, etc.)

2. **User Storage**: Where should user data be stored?
   - Existing database (PostgreSQL, MySQL, MongoDB)
   - New database setup needed
   - External service (Auth0, Firebase, etc.)

3. **Features Required**: Which authentication features do you need?
   - Login and logout
   - Registration (new user signup)
   - Password reset
   - Remember me functionality
   - Email verification

**User Response:**
- Authentication: Token-based (JWT)
- Storage: Existing PostgreSQL database
- Features: Login, logout, registration (no password reset or email verification yet)

---

**Question Batch 2:**

1. **Security Requirements**: What security measures are required?
   - Password hashing (bcrypt recommended)
   - Rate limiting on auth endpoints
   - HTTPS only
   - Token expiration policies

2. **Protected Routes**: Which routes need authentication?
   - Specific endpoints (list them)
   - All routes except public ones
   - Role-based access control needed?

3. **Constraints**: Any constraints or requirements?
   - Must work with existing user table, or create new?
   - Code style or patterns to follow?
   - Testing requirements?

**User Response:**
- Security: Yes to bcrypt, rate limiting, and token expiration (24h)
- Protected routes: Most API routes except `/api/auth/*` and `/api/public/*`
- Constraints: Need to create new users table; follow existing Express patterns; add basic tests

---

**Claude:** Thank you! I have a comprehensive understanding of requirements:

**Summary:**
- JWT-based authentication for Express.js app
- PostgreSQL database (new users table)
- Features: login, logout, registration
- Security: bcrypt passwords, rate limiting, 24h token expiration
- Protected routes: most APIs except auth and public endpoints
- Testing: basic unit tests required

---

### Stage 2: Architect Planning (First Pass)

**Claude:** **I am now adopting the software architect perspective.**

*[Loads ~/.claude/roles/software-architect.md]*

Let me design a high-level implementation approach.

#### High-Level Architecture

**System Components:**

```
┌─────────────────────────────────────────────┐
│                 Client                      │
│  (sends JWT in Authorization header)       │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│            Express Routes Layer             │
│  • /api/auth/register                       │
│  • /api/auth/login                          │
│  • /api/auth/logout (optional)              │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│         Authentication Middleware           │
│  • Verify JWT token                         │
│  • Extract user from token                  │
│  • Attach user to req.user                  │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│           Protected Routes Layer            │
│  • All routes except /api/auth/* and        │
│    /api/public/*                            │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│              Data Layer                     │
│  • Users table (id, email, password_hash)   │
│  • User model for database operations       │
└─────────────────────────────────────────────┘
```

#### Component Breakdown

**1. Database Schema**
- Create `users` table with columns:
  - `id` (UUID primary key)
  - `email` (unique, not null)
  - `password_hash` (not null)
  - `created_at`, `updated_at` (timestamps)

**2. User Model**
- Database interaction layer
- Methods: `create(email, passwordHash)`, `findByEmail(email)`, `findById(id)`
- Uses parameterized queries to prevent SQL injection

**3. Authentication Routes**
- `POST /api/auth/register` - Create new user, hash password, return JWT
- `POST /api/auth/login` - Verify credentials, return JWT
- No logout route needed (JWT is stateless, logout handled client-side)

**4. Authentication Middleware**
- Extract JWT from `Authorization: Bearer <token>` header
- Verify token signature and expiration
- Decode user ID from token payload
- Attach user object to `req.user`
- Return 401 if invalid or missing

**5. Rate Limiting Middleware**
- Apply to auth routes only
- Limit: 5 requests per 15 minutes per IP
- Use `express-rate-limit` library

#### Data Flow

**Registration Flow:**
1. Client sends `{ email, password }` to `/api/auth/register`
2. Validate email format and password strength
3. Check if email already exists
4. Hash password with bcrypt (10 rounds)
5. Insert user into database
6. Generate JWT with user ID payload, 24h expiration
7. Return `{ token, user: { id, email } }`

**Login Flow:**
1. Client sends `{ email, password }` to `/api/auth/login`
2. Find user by email
3. Compare password with bcrypt.compare()
4. If valid, generate JWT with user ID, 24h expiration
5. Return `{ token, user: { id, email } }`
6. If invalid, return 401 Unauthorized

**Protected Route Access:**
1. Client sends request with `Authorization: Bearer <token>` header
2. Auth middleware intercepts request
3. Verify and decode JWT
4. Fetch user from database by ID
5. Attach user to `req.user`
6. Continue to route handler
7. If no token or invalid, return 401

#### Technology Choices

- **JWT library:** `jsonwebtoken` (standard, well-maintained)
- **Password hashing:** `bcrypt` (industry standard, secure)
- **Rate limiting:** `express-rate-limit` (simple, effective)
- **Validation:** `validator` library for email validation
- **Database client:** Assume existing PostgreSQL client (pg or Sequelize)

#### Trade-Offs

**Why JWT over sessions:**
- **Pro:** Stateless, scalable, no server-side session storage
- **Pro:** Works well with mobile apps and SPAs
- **Con:** Can't revoke tokens easily (logout is client-side only)
- **Con:** Tokens can be larger than session IDs
- **Decision:** JWT chosen for scalability and modern architecture

**Why bcrypt over other hashing:**
- **Pro:** Adaptive hashing (can increase rounds as hardware improves)
- **Pro:** Built-in salt generation
- **Con:** Slower than SHA (but that's a feature for passwords)
- **Decision:** bcrypt is industry standard for password hashing

#### Integration Points

- **Existing Express app:** Middleware will be registered in main app file
- **Existing database:** New migration will add users table
- **Existing routes:** Protected routes will add auth middleware
- **Existing error handling:** Will use existing error middleware pattern

#### Initial Implementation Plan

**Phase 1: Database and Model**
1. Create database migration for users table
2. Create User model with database methods

**Phase 2: Core Authentication**
3. Create authentication utility functions (hash, compare, generate token, verify token)
4. Create auth routes (register, login)
5. Add rate limiting to auth routes

**Phase 3: Protection Middleware**
6. Create authentication middleware
7. Apply middleware to protected routes

**Phase 4: Testing**
8. Write unit tests for auth utilities
9. Write integration tests for auth routes
10. Test protected route access

---

### Stage 3: Complexity Assessment

**Claude:** Evaluating task complexity using concrete criteria:

**Complexity Indicators Present (5/7):**
1. ✓ **Multiple system layers**: Database, models, middleware, routes
2. ✓ **New external dependencies**: jsonwebtoken, bcrypt, express-rate-limit
3. ✓ **Database schema changes**: New users table migration
4. ✓ **Security implications**: Authentication and password handling
5. ✓ **5+ files affected**: migration, model, utilities, routes, middleware, tests
6. ✗ Performance-critical (not in this case)
7. ✗ Multiple team domains (single team)

**Assessment:** This is a complex task spanning multiple areas.

**Suggested Split:**

"This task is complex, spanning 5 different implementation areas. Consider splitting into:
1. **Database and User Model** - Migration and user CRUD operations
2. **Authentication Logic** - Register and login endpoints with JWT
3. **Route Protection** - Middleware and applying to existing routes
4. **Testing** - Unit and integration tests

This would allow focused implementation and easier review of each area."

**User Response:** "Let's keep it as one task but break it down into clear steps."

**Claude:** Understood. We'll proceed with the complete scope broken into atomic steps.

---

### Stage 4: Peer Review (Second Architect)

**Claude:** **I am now reviewing the plan as a second architect with a critical eye.**

*[Reloads ~/.claude/roles/software-architect.md and adopts devil's advocate perspective]*

Let me challenge the first plan and look for weaknesses.

#### Strengths

- Clear component boundaries and responsibilities
- Good choice of industry-standard libraries
- Security-conscious (bcrypt, rate limiting, parameterized queries)
- Stateless JWT approach is scalable

#### Concerns

**1. Security - Missing Input Validation (CRITICAL)**
- **Issue:** Plan mentions "validate email format" but doesn't specify password validation
- **Impact:** Weak passwords could be accepted, compromising security
- **Suggestion:** Add explicit password requirements (min 8 chars, complexity) and validation in registration

**2. Error Handling - Incomplete Strategy**
- **Issue:** No discussion of how errors are returned (status codes, error messages)
- **Impact:** Inconsistent error responses, potential information leakage
- **Suggestion:** Define error response format and what information to expose (e.g., don't reveal if email exists during login failure)

**3. Token Storage - Client-Side Guidance Missing**
- **Issue:** Plan doesn't address where client should store JWT
- **Impact:** Client might store in localStorage (vulnerable to XSS)
- **Suggestion:** Document recommendation (httpOnly cookies or secure storage) even though it's client-side

**4. Missing Edge Case - Duplicate Registration**
- **Issue:** What happens if user tries to register twice with same email?
- **Impact:** User confusion, unclear error message
- **Suggestion:** Explicit handling: return 409 Conflict with clear message "Email already registered"

**5. Rate Limiting - Too Restrictive?**
- **Issue:** 5 requests per 15 minutes might block legitimate retries (typos)
- **Impact:** User frustration
- **Suggestion:** Consider 10 requests per 15 minutes, or 5 failed attempts (not total requests)

**6. No Refresh Token Strategy**
- **Issue:** 24h expiration means user must log in daily
- **Impact:** Poor UX for long-lived sessions
- **Suggestion:** Consider refresh token pattern, or allow configurable expiration (though okay to defer this)

**7. Database Migration - No Rollback Plan**
- **Issue:** Migration up() defined but what about down()?
- **Impact:** Can't cleanly rollback if deployment fails
- **Suggestion:** Include rollback migration (DROP TABLE users)

**8. Testing - Scope Unclear**
- **Issue:** "Basic tests" is vague
- **Impact:** Might miss critical test cases
- **Suggestion:** Specify test coverage: hash/compare functions, token generation/verification, register/login endpoints, middleware, error cases

#### Questions Needing Clarification

1. **Email uniqueness**: Should email comparison be case-insensitive? (user@example.com vs USER@EXAMPLE.COM)
2. **Existing routes**: How many routes exist? Will we modify them manually or programmatically?
3. **Database client**: Are you using raw pg, Sequelize, or another ORM?

#### Revised Recommendations

**Must address:**
- Password validation requirements
- Error response format and information leakage prevention
- Duplicate email registration handling
- Migration rollback
- Specific test cases

**Should consider:**
- Rate limiting policy (5 vs. 10 requests, failed attempts only)
- Case-insensitive email handling
- Refresh token strategy (or defer to future iteration)

---

### Stage 5: Plan Refinement

**Claude:** Incorporating peer review feedback into refined plan.

#### Changes Made

**1. Password Validation (Critical Fix)**
- **Added:** Password requirements during registration
  - Minimum 8 characters
  - At least one uppercase, one lowercase, one number
  - Validation function in auth utilities
  - Return 400 Bad Request with specific message if invalid

**2. Error Response Format (Critical Fix)**
- **Added:** Consistent error response structure: `{ error: "message" }`
- **Added:** Security guidance - generic message for login failures
  - Don't reveal whether email exists
  - Return "Invalid email or password" for both cases
- **Added:** Specific error codes:
  - 400 Bad Request - validation failures
  - 401 Unauthorized - auth failures
  - 409 Conflict - duplicate email
  - 500 Internal Server Error - unexpected errors

**3. Duplicate Registration (Critical Fix)**
- **Added:** Explicit handling in registration endpoint
- **Added:** Check for existing email before hashing password (efficiency)
- **Added:** Return 409 Conflict with message "Email already registered"

**4. Database Migration Rollback (Critical Fix)**
- **Added:** Down migration: `DROP TABLE IF EXISTS users;`
- **Added:** Idempotent up migration: `CREATE TABLE IF NOT EXISTS users...`

**5. Test Specification (Critical Fix)**
- **Defined specific test cases:**
  - **Auth utilities**: hashPassword, comparePassword, generateToken, verifyToken, validatePassword
  - **Register endpoint**: success, duplicate email, weak password, invalid email, missing fields
  - **Login endpoint**: success, wrong password, non-existent user, missing fields
  - **Auth middleware**: valid token, invalid token, expired token, missing token
  - **Error cases**: malformed data, SQL injection attempts

**6. Email Case-Insensitivity (Enhancement)**
- **Added:** Normalize email to lowercase before storing and querying
- **Added:** Database unique constraint on lowercase email

**7. Rate Limiting Adjustment (Enhancement)**
- **Changed:** 10 requests per 15 minutes (from 5)
- **Rationale:** Allow for reasonable retries while still protecting from brute force

**8. Client Storage Guidance (Documentation)**
- **Added:** Comment in response recommending httpOnly cookies or secure storage
- **Note:** Implementation is client-side, but we'll document recommendation

#### Deferred Items (Not Addressing Now)

- **Refresh token strategy**: Acknowledged as future enhancement, 24h expiration acceptable for v1
- **Programmatic route protection**: Will manually add middleware to routes in this iteration

---

### Stage 6: Step Breakdown

**Claude:** Breaking down refined plan into atomic steps.

**Implementation Steps (12 total):**

**Step 1:** Create database migration for users table
- File: `migrations/001_create_users_table.sql` (or .js for migration tool)
- Changes: New file, ~15 lines
- Success criteria: Migration runs successfully, creates table with correct schema

**Step 2:** Create User model with database methods
- File: `models/User.js`
- Changes: New file, ~60 lines
- Methods: create, findByEmail, findById
- Success criteria: Model methods work with test database

**Step 3:** Create authentication utility functions
- File: `utils/auth.js`
- Changes: New file, ~80 lines
- Functions: hashPassword, comparePassword, generateToken, verifyToken, validatePassword
- Success criteria: All utility functions pass unit tests

**Step 4:** Create authentication routes (register)
- File: `routes/auth.js`
- Changes: New file, ~40 lines (registration only)
- Endpoint: POST /api/auth/register
- Success criteria: Registration creates user and returns JWT

**Step 5:** Create authentication routes (login)
- File: `routes/auth.js`
- Changes: Modify existing file, ~30 lines added
- Endpoint: POST /api/auth/login
- Success criteria: Login validates credentials and returns JWT

**Step 6:** Add rate limiting to authentication routes
- File: `routes/auth.js`
- Changes: Modify existing file, ~10 lines
- Add: express-rate-limit middleware
- Success criteria: Rate limiting blocks excessive requests

**Step 7:** Create authentication middleware
- File: `middleware/authenticate.js`
- Changes: New file, ~50 lines
- Middleware: verify JWT, attach user to req.user
- Success criteria: Middleware correctly validates tokens and rejects invalid ones

**Step 8:** Apply authentication middleware to protected routes
- Files: `routes/*.js` (multiple files, ~3-5 routes files)
- Changes: Add middleware to route definitions, ~2-5 lines per file
- Success criteria: Protected routes return 401 without valid token, work with valid token

**Step 9:** Write unit tests for auth utilities
- File: `tests/auth.utils.test.js`
- Changes: New file, ~100 lines
- Tests: All utility functions with success and error cases
- Success criteria: All tests pass

**Step 10:** Write integration tests for register endpoint
- File: `tests/auth.register.test.js`
- Changes: New file, ~80 lines
- Tests: Success, duplicate email, weak password, invalid email
- Success criteria: All tests pass

**Step 11:** Write integration tests for login endpoint
- File: `tests/auth.login.test.js`
- Changes: New file, ~70 lines
- Tests: Success, wrong password, non-existent user
- Success criteria: All tests pass

**Step 12:** Write integration tests for authentication middleware
- File: `tests/auth.middleware.test.js`
- Changes: New file, ~60 lines
- Tests: Valid token, invalid token, expired token, missing token
- Success criteria: All tests pass

**Total:** 12 atomic steps, ~8-10 files affected

---

## Approval Gate #1: Complete Plan

**Claude:** I've completed the plan with both architectural perspectives and peer review incorporated. Here's the complete plan:

**Summary:**
Add JWT-based authentication to Express.js app with PostgreSQL, including registration, login, and route protection.

**Architecture:**
- Database layer: users table with User model
- Auth utilities: password hashing, JWT generation/verification, validation
- Routes layer: /api/auth/register and /api/auth/login
- Middleware: authentication and rate limiting
- Protected routes: apply auth middleware to existing routes

**All Steps (12):**
[Shows complete list from Stage 6]

**Trade-offs:**
- JWT (stateless, scalable) vs. sessions (revocable)
- 24h token expiration (no refresh token in v1)
- Manual route protection (not programmatic)

**Risks:**
- JWT can't be revoked (mitigated: short expiration)
- Rate limiting might block legitimate users (mitigated: 10 req/15min threshold)
- Email case sensitivity could cause duplicates (mitigated: normalize to lowercase)

**Do you approve this complete plan?**
- A) Approve and proceed to execution
- B) Request modifications (specify which parts)
- C) Reject and start over

**User Response:** "A) Approve and proceed to execution"

**Claude:** Plan approved. Saving plan now.

```
TaskUpdate: { phase: "completed", planSaved: true, planPath: ".claude/task/auth-system.md" }
```

Plan saved to: `.claude/task/auth-system.md`

---

## Handoff to Execution

**This skill ends here.** The plan has been approved and saved. No code has been written.

To implement this plan step by step — with your approval before each step — use the task-implementation skill:

```
"implement plan: .claude/task/auth-system.md"
```

The task-implementation skill will:
- Read the saved plan
- Present each step to you (WHAT / HOW / WHY)
- Use AskUserQuestion and wait for your approval before executing each step
- Run tests after each step if available
- Track progress throughout

**You maintain full control at every step during execution.**

---

## Workflow Insights

**What This Example Demonstrated:**

1. **Complexity Assessment:** Task was correctly identified as complex (5 indicators)
2. **Comprehensive Planning:** Two architect perspectives caught 8 issues that strengthened the plan
3. **Approval Gate #1:** User approved the complete plan before any code was written
4. **Iterative Refinement:** Peer review led to critical security improvements (password validation, duplicate email handling, error response format)
5. **Atomic Steps:** Each step was broken down to be independently verifiable and reversible
6. **Clean Handoff:** Skill ended after plan was saved — execution is handled by task-implementation

**Benefits Realized:**
- Security issues caught in planning, before any code was written
- Clear roadmap produced and saved to disk
- Planning and execution are cleanly separated — no implementation attempted here
- Complete record of architectural decisions and trade-offs
- Plan is ready for step-by-step execution via task-implementation (with per-step approval)
