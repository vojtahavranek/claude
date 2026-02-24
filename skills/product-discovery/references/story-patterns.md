# Story Patterns Reference

**Auto-loaded during Stage 2 (Product Manager Translation)**

This reference provides templates, patterns, and best practices for writing effective user stories with acceptance criteria. Use these patterns to create clear, testable, valuable stories ready for implementation.

---

## User Story Format

### Template

```markdown
### Story [N]: [Clear, Concise Title]

**As a** [specific user type/persona]
**I want** [specific goal/capability/action]
**So that** [clear benefit/value/outcome]

**Context**: [Why this story matters, additional background, connection to product brief]

**Priority**: High / Medium / Low

**Dependencies**: [Other story IDs this depends on, or "None"]
```

### Components Explained

**Story Number**: Sequential numbering for easy reference
- Start at 1
- Increment for each story
- Use for dependency references

**Title**: Brief, action-oriented summary
- 3-7 words typically
- Start with verb when possible
- Clear at a glance

**As a**: Specific user type or persona
- Not vague ("user" is too generic)
- Use personas from Product Brief
- Consider multiple stories for different user types

**I want**: Specific goal or capability
- Action-oriented
- Concrete, not abstract
- User's perspective, not technical implementation

**So that**: Clear user benefit or value
- Why does user want this?
- What's the outcome or value?
- Connect to problem from Product Brief
- Must be meaningful (not just restating "I want")

**Context**: Additional background
- Why this story matters
- Connection to Product Brief
- Business context
- Technical considerations (user-facing)
- Helps implementer understand "why"

**Priority**: Relative importance
- High: Must-have for MVP, critical value, dependency for others
- Medium: Important but deferrable
- Low: Nice-to-have, enhancement

**Dependencies**: Story prerequisites
- List story numbers this depends on
- "None" if independent
- Minimize dependencies for parallel work

---

## Good vs Bad Examples

### Example 1: User Authentication

#### ❌ Bad
```markdown
### Story 1: Login

**As a** user
**I want** to login
**So that** I can use the system

**Priority**: High
```

**Problems**:
- User type too vague
- "I want" not specific (how? with what?)
- "So that" just restates "I want"
- No context
- No acceptance criteria
- Not testable

#### ✅ Good
```markdown
### Story 1: User Login with Email and Password

**As a** returning customer
**I want** to log in using my email address and password
**So that** I can access my account and view my order history

**Context**: This is the foundational authentication story from the Product Brief's Solution Vision. It enables users to access personalized features while maintaining account security. This must work before any authenticated features can be implemented.

**Priority**: High

**Dependencies**: None

**Acceptance Criteria**:
- [ ] User sees login form with email and password fields
- [ ] System validates email format and shows error for invalid emails
- [ ] Successful login with correct credentials redirects to dashboard
- [ ] Failed login shows clear error message without exposing security details
- [ ] Login form displays loading state during authentication
- [ ] "Remember me" checkbox keeps user logged in for 30 days
- [ ] User can navigate to "Forgot Password" from login page
- [ ] System rate-limits login attempts to prevent brute force attacks
- [ ] Login works on all supported browsers and devices
```

**Improvements**:
- Specific user type (returning customer)
- Specific interaction method (email and password)
- Clear value (access account and order history)
- Rich context explaining why and how it fits
- Complete acceptance criteria covering happy path, errors, edge cases

### Example 2: Data Export

#### ❌ Bad
```markdown
### Story 5: Export

**As a** user
**I want** to export data
**So that** I can export data

**Priority**: Medium
```

**Problems**:
- Circular "so that" (just repeats "I want")
- No format specified
- No context about what data
- Vague user type

#### ✅ Good
```markdown
### Story 5: Export Report Data to CSV

**As a** financial analyst
**I want** to export my current report data to a CSV file
**So that** I can analyze trends in Excel and share findings with my team

**Context**: From Product Brief Section 2, users need to integrate report data with their existing Excel workflows. CSV is the preferred format per user interviews. This is a Phase 1 feature as it's critical for analyst workflows.

**Priority**: Medium

**Dependencies**: Story 3 (Report generation must work first)

**Acceptance Criteria**:
- [ ] Export button visible on all report pages
- [ ] Clicking export downloads CSV file with report name and timestamp
- [ ] CSV includes all visible report data with proper formatting
- [ ] Date fields use ISO 8601 format (YYYY-MM-DD)
- [ ] Numeric fields preserve precision (no rounding errors)
- [ ] CSV handles special characters (commas, quotes) correctly
- [ ] Large reports (>10,000 rows) export successfully
- [ ] User sees progress indicator for large exports
- [ ] Export respects current filter/sort settings
- [ ] File download works in all supported browsers
```

**Improvements**:
- Specific user persona (financial analyst)
- Specific format (CSV, not just "export")
- Clear value (analyze in Excel, share with team)
- Context explaining why CSV and why Phase 1
- Comprehensive acceptance criteria including edge cases

### Example 3: Notifications

#### ❌ Bad
```markdown
### Story 8: Notifications System

**As a** user
**I want** a notifications system
**So that** I get notifications

**Priority**: High
```

**Problems**:
- Too broad (entire system in one story)
- Circular reasoning in "so that"
- Not implementable as single story
- No specific notification types
- No delivery mechanism specified

#### ✅ Good - Split into Multiple Stories

```markdown
### Story 8: Email Notification for Order Status Changes

**As a** customer who placed an order
**I want** to receive email notifications when my order status changes
**So that** I stay informed about my order without checking the website repeatedly

**Context**: From Product Brief, customers expressed frustration with manually checking order status. Email is the preferred notification channel (per user survey). This addresses the "order tracking anxiety" problem identified in user interviews.

**Priority**: High

**Dependencies**: Story 7 (Order status tracking)

**Acceptance Criteria**:
- [ ] Customer receives email when order is confirmed
- [ ] Customer receives email when order ships with tracking number
- [ ] Customer receives email when order is delivered
- [ ] Emails sent within 5 minutes of status change
- [ ] Email includes order number, status, and relevant details
- [ ] Email links back to order details page
- [ ] Unsubscribe link included in footer per compliance requirements
- [ ] Email templates are mobile-responsive
- [ ] Failed email sends are retried up to 3 times
- [ ] System logs all notification attempts for troubleshooting
```

```markdown
### Story 9: In-App Notification Badge for New Messages

**As a** logged-in user
**I want** to see a notification badge when I have unread messages
**So that** I don't miss important communications while using the app

**Context**: Complements email notifications (Story 8) with in-app awareness. Users should see immediate feedback without leaving the application. This addresses the "fear of missing messages" identified in Product Brief.

**Priority**: Medium

**Dependencies**: None (independent of Story 8)

**Acceptance Criteria**:
- [ ] Badge appears on messages icon when new message arrives
- [ ] Badge shows count of unread messages (up to 99, then "99+")
- [ ] Badge updates in real-time without page refresh
- [ ] Badge clears when user views all messages
- [ ] Badge persists across sessions until messages read
- [ ] Badge visible on all pages where header appears
- [ ] Badge styling follows design system
- [ ] Screen readers announce "X new messages" for accessibility
```

**Improvements**:
- Split large story into focused, implementable pieces
- Each story has clear scope and value
- Stories can be worked on independently (or sequentially if dependencies exist)
- Specific delivery mechanisms (email vs in-app)
- Clear, testable criteria for each

---

## Acceptance Criteria Best Practices

### What Makes Good Acceptance Criteria?

**Testable**: Clear pass/fail determination
- ✅ "User sees confirmation message after successful save"
- ❌ "System works correctly"

**Specific**: Concrete, not vague
- ✅ "Response time under 2 seconds for 95% of requests"
- ❌ "System is fast"

**Complete**: Covers success AND failure paths
- ✅ Include happy path, errors, edge cases
- ❌ Only test successful scenarios

**User-focused**: Behavior, not implementation
- ✅ "User can filter results by date range"
- ❌ "API endpoint accepts start_date and end_date parameters"

**Independent**: Each criterion standalone testable
- ✅ Separate criteria for separate behaviors
- ❌ Compound criteria testing multiple things

### Format

Use checkbox format for tracking:
```markdown
**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] [Criterion 3]
```

### What to Include

**1. Primary Success Scenarios**
What happens when things work correctly:
```markdown
- [ ] User can enter task title and description
- [ ] Clicking "Save" creates new task in list
- [ ] New task appears at top of list
```

**2. Edge Cases**
Boundary conditions, empty states, limits:
```markdown
- [ ] Empty title shows validation error
- [ ] Title longer than 200 characters is truncated with "..."
- [ ] User sees "No tasks yet" message when list is empty
- [ ] List handles 1000+ tasks without performance degradation
```

**3. Error Handling**
What happens when operations fail:
```markdown
- [ ] Network error shows "Failed to save, please try again" message
- [ ] Failed save preserves user's input (doesn't lose data)
- [ ] User can retry save after error
- [ ] System logs error details for troubleshooting
```

**4. User Feedback**
Confirmations, messages, loading states:
```markdown
- [ ] Success message "Task created" appears after save
- [ ] Loading spinner shows during save operation
- [ ] Disabled state on "Save" button prevents double-submit
- [ ] Success message auto-dismisses after 3 seconds
```

**5. Data Validation**
Input requirements, format checks:
```markdown
- [ ] Email field validates email format
- [ ] Invalid email shows "Please enter a valid email" error
- [ ] Phone number accepts only digits and formatting characters
- [ ] Date picker prevents selection of past dates
```

**6. Performance** (if relevant)
Response time, load handling:
```markdown
- [ ] Search results appear within 2 seconds
- [ ] Page handles 100 simultaneous users without degradation
- [ ] Images lazy-load as user scrolls
```

**7. Accessibility** (if applicable)
Screen reader support, keyboard navigation:
```markdown
- [ ] All form fields have labels for screen readers
- [ ] User can complete entire flow with keyboard only
- [ ] Focus indicators visible when tabbing through form
- [ ] Error messages announced by screen readers
```

**8. Cross-browser/device** (if relevant)
```markdown
- [ ] Feature works in Chrome, Firefox, Safari, Edge
- [ ] Mobile layout adapts for screens 320px and wider
- [ ] Touch interactions work on mobile devices
```

### Common Pitfalls to Avoid

❌ **Too vague**: "System works correctly"
- ✅ Instead: Specify what "works" means

❌ **Implementation details**: "API returns 200 status code"
- ✅ Instead: Focus on user-observable behavior

❌ **Compound criteria**: "User can save, edit, and delete tasks"
- ✅ Instead: Separate criterion for each action

❌ **Missing error cases**: Only happy path tested
- ✅ Instead: Include error scenarios

❌ **Not testable**: "User has good experience"
- ✅ Instead: Define observable behaviors that constitute "good experience"

---

## Story Splitting Techniques

### When to Split a Story

**Story is too large** when:
- Would take more than 1-2 weeks to implement
- Touches too many parts of the system
- Has too many acceptance criteria (>15)
- Involves multiple user types
- Mixes multiple workflows

**Benefits of splitting**:
- Easier to estimate
- Faster feedback loops
- Parallel work possible
- Clearer acceptance criteria
- Reduced risk

### Splitting by Workflow Steps

**Before (too large)**:
```markdown
### Story: Task Management

**As a** user
**I want** to manage tasks
**So that** I can track my work
```

**After (split by workflow)**:
```markdown
### Story 1: Create Task
**As a** user
**I want** to create a new task with title and description
**So that** I can capture work that needs to be done

### Story 2: View Task List
**As a** user
**I want** to view my list of tasks
**So that** I can see what work is pending

### Story 3: Edit Task
**As a** user
**I want** to edit an existing task
**So that** I can update details as work evolves

### Story 4: Complete Task
**As a** user
**I want** to mark a task as complete
**So that** I can track what's finished

### Story 5: Delete Task
**As a** user
**I want** to delete a task
**So that** I can remove work that's no longer relevant
```

### Splitting by User Type

**Before (too broad)**:
```markdown
### Story: Dashboard Access

**As a** user
**I want** to access the dashboard
**So that** I can see relevant information
```

**After (split by user type)**:
```markdown
### Story 1: Admin Dashboard
**As an** administrator
**I want** to access an admin dashboard with system metrics
**So that** I can monitor system health and user activity

### Story 2: Manager Dashboard
**As a** team manager
**I want** to access a dashboard showing my team's performance
**So that** I can track progress and identify issues

### Story 3: User Dashboard
**As a** standard user
**I want** to access a personal dashboard with my tasks and notifications
**So that** I can focus on my own work
```

### Splitting by CRUD Operations

**Before (too much in one story)**:
```markdown
### Story: User Profile Management

**As a** user
**I want** to manage my profile
**So that** my information is accurate
```

**After (split by operation)**:
```markdown
### Story 1: View Profile
**As a** user
**I want** to view my profile information
**So that** I can see what information is stored

### Story 2: Edit Profile
**As a** user
**I want** to edit my profile information
**So that** I can keep it up to date

### Story 3: Upload Profile Photo
**As a** user
**I want** to upload a profile photo
**So that** others can recognize me

### Story 4: Delete Account
**As a** user
**I want** to delete my account
**So that** my information is removed when I no longer use the service
```

### Splitting by Complexity Layers

**Before (MVP + advanced features mixed)**:
```markdown
### Story: Search Functionality

**As a** user
**I want** to search with filters, sorting, and saved searches
**So that** I can find what I need
```

**After (split by complexity)**:
```markdown
### Story 1: Basic Search
**As a** user
**I want** to search by keyword
**So that** I can find relevant items quickly

### Story 2: Filter Search Results
**As a** user
**I want** to filter search results by category and date
**So that** I can narrow down to exactly what I need

### Story 3: Sort Search Results
**As a** user
**I want** to sort search results by relevance, date, or name
**So that** I can order results based on my preference

### Story 4: Save Search Queries
**As a** power user
**I want** to save frequently-used search queries
**So that** I don't have to recreate complex searches
```

---

## Dependency Identification

### Types of Dependencies

**Technical dependencies**: Story B requires Story A's implementation
```markdown
### Story 2: User Login
**Dependencies**: Story 1 (User registration must exist first)
```

**Data dependencies**: Story B needs data from Story A
```markdown
### Story 5: Order History Display
**Dependencies**: Story 4 (Order creation must work to have history)
```

**Workflow dependencies**: Story B is next step after Story A
```markdown
### Story 8: Payment Processing
**Dependencies**: Story 7 (Shopping cart checkout)
```

### Minimizing Dependencies

**Prefer independent stories** for parallel work:
- Can be developed simultaneously
- Reduces bottlenecks
- Allows team scaling

**When dependencies unavoidable**:
- Document clearly
- Consider implementation order
- Flag to architect for planning

**Example: Reducing dependencies**

❌ **Before (tightly coupled)**:
```markdown
Story 1: Create user account (depends on email verification)
Story 2: Email verification (depends on email service)
Story 3: Email service setup (depends on infrastructure)
```

✅ **After (reduced coupling)**:
```markdown
Story 1: Create user account (basic registration, no email yet)
Story 2: Email service integration (independent setup)
Story 3: Add email verification to registration (depends on 1 and 2)
```

---

## Priority Assignment Guidelines

### High Priority

**Criteria**:
- Must-have for MVP
- Delivers core user value
- Dependency for other stories
- High user impact
- Solves critical problem from Product Brief

**Example**:
```markdown
**Priority**: High

This is foundational authentication—nothing else works without it.
Critical to core value proposition from Product Brief.
```

### Medium Priority

**Criteria**:
- Important but deferrable to Phase 2
- Enhances core functionality
- Moderate user impact
- Improves experience but not essential

**Example**:
```markdown
**Priority**: Medium

Nice-to-have for better UX but MVP can function without it.
Can be added in Phase 2 based on user feedback.
```

### Low Priority

**Criteria**:
- Nice-to-have enhancement
- Minimal immediate impact
- Could be indefinitely deferred
- Luxury feature

**Example**:
```markdown
**Priority**: Low

Enhancement that adds polish but not critical for launch.
Revisit after MVP based on usage patterns.
```

---

## MVP Scope Definition

### Must-Have (Phase 1 / MVP)

**Characteristics**:
- Essential for delivering core value
- Solves the main user problem from Product Brief
- Part of minimum viable user journey
- Required for product to be useful
- Foundation for other features

**Questions to ask**:
- Can we launch without this?
- Does this solve the core problem?
- Is this part of the minimum user journey?
- Do other features depend on this?

### Nice-to-Have (Phase 2+)

**Characteristics**:
- Valuable enhancement
- Improves experience
- Can be added iteratively
- Not blocking core functionality
- Based on user feedback

**Questions to ask**:
- Can this wait until after launch?
- Would users still get value without this?
- Can we validate MVP before building this?
- Is this an optimization of existing functionality?

### Example MVP Breakdown

**Feature**: Task Management Application

**Must-Have (MVP)**:
- Create task with title and description
- View task list
- Mark task complete
- Delete task
- Basic sorting (by date created)

**Rationale**: These are the minimum capabilities for a functional task manager. Users can capture, view, complete, and remove tasks—the core user journey.

**Nice-to-Have (Phase 2+)**:
- Task categories/tags
- Due date reminders
- Recurring tasks
- Task sharing/collaboration
- Advanced filtering
- Task templates
- Mobile app
- Calendar view
- Task comments/notes
- File attachments

**Rationale**: All valuable features, but MVP proves core value first. Add based on user feedback and usage patterns.

---

## Integration with Product Brief

### Tracing Stories to Brief

**Each story should connect to Product Brief**:

```markdown
**Context**: From Product Brief Section 2 (Solution Vision), users need
to [specific capability]. This addresses the [problem] identified in user
interviews. This is a Phase 1 feature because [rationale].
```

**Benefits**:
- Maintains alignment with discovery
- Helps implementers understand "why"
- Validates story is necessary
- Provides business context

### Using Brief Sections

**Section 1 (User Problem & Context)**:
- Informs "As a" user type
- Provides context for "So that" value
- Validates story necessity

**Section 2 (Solution Vision)**:
- Source for story ideas
- Defines key features to story-fy
- Describes user journey to break down

**Section 3 (Business Validation)**:
- Justifies priority levels
- Explains urgency
- Provides ROI context

**Section 4 (Estimated Scope)**:
- Helps with story complexity estimation
- Identifies unknowns needing investigation
- Highlights dependencies

---

## Tips for Writing Great Stories

### Do

✅ **Focus on user value**: Every story delivers something users care about
✅ **Be specific**: Concrete details over vague descriptions
✅ **Include rich context**: Help implementers understand "why"
✅ **Write testable criteria**: Clear pass/fail conditions
✅ **Cover error cases**: Not just happy paths
✅ **Use personas**: Specific user types from Product Brief
✅ **Keep appropriately sized**: Not too large, not too granular
✅ **Minimize dependencies**: Enable parallel work where possible
✅ **Reference Product Brief**: Maintain traceability

### Don't

❌ **Write technical stories**: Focus on user outcomes, not implementation
❌ **Make circular "so that"**: Must provide real user value, not restate "I want"
❌ **Forget error handling**: Include failure scenarios in acceptance criteria
❌ **Be vague**: "User has good experience" is not testable
❌ **Mix multiple features**: Keep stories focused on single capability
❌ **Ignore edge cases**: Include boundary conditions and empty states
❌ **Skip context**: Always explain why story matters
❌ **Create artificial dependencies**: Only add if truly required

---

## Story Quality Checklist

Before finalizing stories, verify:

**User Story Structure**:
- [ ] "As a [specific user type]" - not generic "user"
- [ ] "I want [concrete goal]" - specific capability
- [ ] "So that [real value]" - meaningful benefit, not circular
- [ ] Context explains why and connects to Product Brief
- [ ] Priority assigned (High/Medium/Low) with rationale
- [ ] Dependencies documented (or "None")

**Acceptance Criteria**:
- [ ] Formatted as checkboxes for tracking
- [ ] Covers primary success scenarios
- [ ] Includes edge cases and boundary conditions
- [ ] Addresses error handling
- [ ] Specifies user feedback (messages, loading states)
- [ ] Defines data validation rules (if applicable)
- [ ] Includes performance requirements (if relevant)
- [ ] Considers accessibility (if applicable)
- [ ] All criteria are testable (clear pass/fail)
- [ ] All criteria are specific (not vague)

**Story Quality**:
- [ ] Story is appropriately sized (1-2 weeks max)
- [ ] Story is independent (or dependencies documented)
- [ ] Story delivers user value (not just technical work)
- [ ] Story is implementable (not too abstract)
- [ ] Story connects to Product Brief
- [ ] Priority makes sense for MVP scope
- [ ] Title is clear and descriptive

---

## Using This Reference

**During Stage 2 (Product Manager Translation)**:

1. **Use template for all stories**: Consistent structure
2. **Reference good examples**: Model after patterns shown
3. **Apply splitting techniques**: When stories too large
4. **Follow criteria guidelines**: Complete, testable criteria
5. **Check quality checklist**: Before finalizing
6. **Maintain traceability**: Connect to Product Brief

**This reference is auto-loaded** at Stage 2 start. You don't need to read it manually during translation invocation.

---

*End of Story Patterns Reference*
