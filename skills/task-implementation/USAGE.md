# Task Implementation Skill - Usage Guide

## Quick Start

### 1. Prepare a Plan

First, create an implementation plan. You can:

**Option A: Use task-preparation skill**
```
"use task preparation to add user authentication"
```
This will guide you through requirements, architecture, and save a plan file.

**Option B: Write a plan manually**
Create a markdown file with steps:
```markdown
# Plan: Add User Profile Feature

## Steps

### Step 1: Create user model
- Files: src/models/User.js
- What: Create User schema with name, email, profile fields

### Step 2: Add profile routes
- Files: src/routes/profileRoutes.js
- What: GET/PUT endpoints for profile management

### Step 3: Write tests
- Files: tests/profile.test.js
- What: Test profile retrieval and updates
```

### 2. Decide Where to Store Plans

**Recommended: Project-local** (best for team collaboration)
```
./plans/feature-name.md
```
Commit to git so team can see plans.

**Alternative: Global** (personal plans across projects)
```
~/.claude/plans/feature-name.md
```

### 3. Invoke the Skill

**With file path:**
```
"implement plan: ./plans/user-profile.md"
"execute plan: /path/to/plan.md"
```

**With just a name** (will ask where plans are stored):
```
"implement plan: user-profile"
```

**With inline plan:**
```
"implement this plan:
[paste plan content]"
```

## What Happens During Implementation

### Stage 0: Setup (~1 minute)
- Reads and parses your plan
- Checks for test environment
- Creates a task for progress tracking
- Adopts software-developer role

### Stage 1: Step-by-Step Execution (main work)
**For each step:**

1. **Presents what will be done**
   - Shows files to change
   - Explains implementation approach
   - States why this approach makes sense

2. **Requests your approval**
   - A) Approve and execute
   - B) Skip this step
   - C) Modify approach
   - D) Pause and resume later

3. **Implements (if approved)**
   - Writes clean, well-tested code
   - Follows best practices
   - Adds error handling

4. **Runs tests**
   - Executes relevant tests
   - Shows pass/fail results
   - Offers to fix failures

5. **Shows results**
   - What files changed
   - Verification status
   - Quality notes

6. **Updates progress**
   - Task tracking updated
   - Check anytime with `/tasks`

### Stage 2: Completion (~1 minute)
- Runs full test suite (optional)
- Generates summary
- Suggests next steps

## Tracking Progress

**Implementation can take hours or days**. Track progress anytime:

```
/tasks
```

Shows:
- Current step number
- Steps completed/remaining
- Overall progress
- Task status

## Pause and Resume

**Need to stop?**
When asked for approval, choose: **D) Pause**

**Resume later:**
```
"resume implementing [feature-name]"
"continue implementation of [task]"
```

The skill will pick up where you left off.

## Example Session

```
You: "implement plan: ./plans/user-auth.md"

Claude: Reading ./plans/user-auth.md...
        Found plan with 5 steps.
        Test command: npm test
        Creating task...

        I'm now acting as software-developer to implement this plan.

        Step 1 of 5: Create authentication middleware

        Files to be affected:
        - src/middleware/auth.js (new file, ~40 LOC)

        What I will do:
        - Create JWT verification middleware
        - Check Authorization header
        - Validate token and extract user ID

        How I will implement it:
        - Use jsonwebtoken library
        - Return 401 for invalid/missing tokens
        - Attach user to req.user for downstream use

        Why this approach:
        - Standard JWT pattern in Express
        - Matches pattern used in similar projects

        Approve execution of this step?
        A) Approve and execute
        B) Skip this step
        C) Modify approach
        D) Pause and resume later

You: A

Claude: [Implements code...]

        Results for Step 1:
        ✓ Created: src/middleware/auth.js (42 LOC)
        ✓ Tests: 3/3 passing
        ✓ Success criteria met

        Quality notes:
        - Error handling added for expired tokens
        - Input validation for Authorization header
        - Follows existing middleware pattern

        Progress: 1/5 steps complete (20%)

        Step 2 of 5: Add login endpoint
        ...
```

## Plan Storage Recommendations

### For Team Projects (Recommended)
```
your-project/
├── plans/
│   ├── feature-auth.md
│   ├── feature-profiles.md
│   └── refactor-database.md
├── src/
└── tests/
```

**Benefits:**
- Team can see planned work
- Plans are version-controlled
- Easy to reference in PRs
- Maintains project history

**Add to .gitignore if plans contain sensitive info:**
```
# .gitignore
plans/*-private.md
```

### For Personal Projects
```
~/.claude/plans/
├── project-a-feature.md
├── project-b-refactor.md
└── learning-experiment.md
```

**Benefits:**
- Centralized location
- Works across all projects
- Private by default

## Tips for Best Results

1. **Clear plan structure**: Number your steps, specify files, state objectives
2. **Atomic steps**: Each step should be reviewable in < 5 minutes
3. **Approve deliberately**: Review the approach before approving
4. **Run tests**: Keep tests passing as you go
5. **Check progress**: Use `/tasks` to see where you are
6. **Pause when needed**: Long implementations can span multiple sessions
7. **Store plans in repo**: Share plans with team, track in git

## Troubleshooting

**"Plan not found"**
- Check the path is correct (absolute or relative)
- Use `ls plans/` to verify file exists
- Try full path: `/absolute/path/to/plan.md`

**"Can't parse plan"**
- Verify markdown structure (numbered steps, files listed)
- See minimal format in SKILL.md
- Ask: "what's wrong with my plan format?"

**"Tests failing"**
- Choose option to fix and retry
- Or skip and continue (fix later)
- Check test command is correct

**"Lost progress"**
- Check `/tasks` for task status
- Task tracking saves progress
- Can resume from last completed step

## Integration with task-preparation

**Recommended workflow:**

```
1. Plan phase:
   You: "use task preparation for user authentication"
   Claude: [Guides through requirements, architecture, planning]
           [Saves plan to ./plans/auth-system.md]

2. Execution phase:
   You: "implement plan: ./plans/auth-system.md"
   Claude: [Reads plan, executes step-by-step with approvals]

3. Result:
   - Clean separation of planning and execution
   - Documented plan (shareable with team)
   - Approved implementation approach
   - Tracked progress
   - Tested code
```

## Questions?

Read the full skill documentation:
- `~/.claude/skills/task-implementation/SKILL.md` - Complete workflow
- `~/.claude/skills/task-implementation/references/best-practices.md` - Code quality tips
- `~/.claude/skills/task-implementation/examples/simple-execution.md` - Detailed example

Or just ask: "How does task implementation work?"
