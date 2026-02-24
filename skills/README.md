# Claude Code Skills System

## Overview

**Skills** are specialized workflows that Claude can execute to handle specific types of tasks. Each skill is a self-contained directory with instructions, references, and examples that guide Claude through a structured process.

**Think of skills as**:
- Specialized modes for specific workflows
- Reusable procedures with proven patterns
- Structured approaches to complex tasks
- Team-shareable best practices

## Available Skills

| Skill | Description | When to Use | Invocation |
|-------|-------------|-------------|------------|
| **task-preparation** | Architect-led planning workflow | Planning complex features, need architecture design | `"use task preparation for [feature]"` |
| **task-implementation** | Developer-focused execution | Execute existing plan step-by-step | `"implement plan: [path/name]"` |
| **complex-task-implementation** | Autonomous parallel execution | Complex plans with independent work streams | `"execute complex plan: [path]"` |

### task-preparation
**Purpose**: Comprehensive planning from requirements to implementation steps

**Workflow**:
1. Requirements gathering
2. Architecture design
3. Peer review validation
4. Step breakdown
5. Approval Gate #1 (plan approval)
6. Saves plan file for execution

**When to use**:
- Complex features requiring architecture
- Need systematic requirements gathering
- Want peer review before coding
- Multi-file changes with design decisions

**Output**: Detailed plan saved to file (project-local or global)

**Learn more**: `~/.claude/skills/task-preparation/SKILL.md`

---

### task-implementation
**Purpose**: Execute implementation plans with developer focus

**Workflow**:
1. Reads plan file
2. Adopts software-developer role
3. For each step: Present → Approve → Implement → Test → Verify
4. Tracks progress throughout
5. Generates summary

**When to use**:
- Have a complete plan ready to implement
- Want step-by-step approval control
- Need progress tracking for long implementations
- Focus on code quality and testing

**Output**: Implemented code with tests, tracked progress

**Learn more**: `~/.claude/skills/task-implementation/USAGE.md`

### complex-task-implementation
**Purpose**: Autonomous parallel plan execution with iterative validation

**Workflow**:
1. Analyzes plan dependencies, computes parallel execution waves
2. Approval Gate 1: User approves execution strategy
3. Spawns parallel agents in isolated worktrees (per wave)
4. Merges results, runs validation loop (review -> fix -> re-review)
5. Approval Gate 2: User accepts or rejects final results

**When to use**:
- Complex plan with 8+ steps
- Plan has independent work streams (parallelizable)
- User trusts the plan and wants speed
- task-preparation suggested this skill

**Comparison with task-implementation**:

| | task-implementation | complex-task-implementation |
|---|---|---|
| **Approval** | Per-step (N gates) | Strategy + final only (2 gates) |
| **Execution** | Sequential | Parallel (waves) |
| **Validation** | User verifies each step | Automated review-fix loop |
| **Best for** | Learning codebase, risky changes | Trusted plans, speed, complex work |

**Output**: Implemented code with automated review, tracked progress

**Learn more**: `~/.claude/skills/complex-task-implementation/USAGE.md`

---

## How to Use Skills

### Invocation Methods

**Natural language** (recommended):
```
"use task preparation for user authentication"
"implement plan: ./plans/feature.md"
"prepare a task to refactor database layer"
"execute plan: auth-system"
```

**Direct invocation**:
```
"/task-preparation"
"/task-implementation ./plans/feature.md"
```

### Skill Detection

Claude automatically detects when a skill should be used based on:
- Keywords in your message (defined in skill frontmatter)
- Context of the request
- Task complexity

**Skill frontmatter example**:
```yaml
---
name: task-implementation
description: |
  Use when user asks to "implement plan", "execute plan", or provides a plan file.
---
```

## Typical Workflows

### Workflow 1: Plan + Implement (Recommended)

**Best for**: Complex features, architectural decisions

```
Step 1: Planning
You: "use task preparation to add user authentication"
Claude: [Guides through requirements, architecture, peer review]
        Saves plan to: ./plans/auth-system.md

Step 2: Implementation
You: "implement plan: ./plans/auth-system.md"
Claude: [Executes step-by-step with approvals]
        Tracks progress throughout

Result: Clean separation, documented approach, quality code
```

### Workflow 2: Direct Implementation

**Best for**: Simple changes, obvious approach

```
You: "add a getUserById function to userService.js"
Claude: [Implements directly without skill overhead]

Result: Fast, no ceremony for simple tasks
```

### Workflow 3: Plan Now, Implement Later

**Best for**: Team coordination, async work

```
Step 1: Planning (Done by architect/lead)
You: "use task preparation for payment integration"
Claude: Creates plan, saves to ./plans/payment.md
You: git commit -m "Add payment integration plan"
You: git push

Step 2: Implementation (Done by developer, later)
Teammate: git pull
Teammate: "implement plan: ./plans/payment.md"
Claude: [Executes plan with progress tracking]

Result: Documented approach, team alignment, parallel work
```

## Creating Custom Skills

### Skill Structure

```
~/.claude/skills/my-skill/
├── SKILL.md                    # Main workflow (required)
│   ├── Frontmatter (name, description)
│   ├── Overview
│   ├── When to use
│   ├── Workflow stages
│   └── Integration points
│
├── USAGE.md                    # User guide (optional)
│   ├── Quick start
│   ├── Examples
│   └── Troubleshooting
│
├── references/                 # Optional resources
│   ├── best-practices.md
│   └── patterns.md
│
└── examples/                   # Optional examples
    └── workflow-example.md
```

### SKILL.md Frontmatter (Required)

```yaml
---
name: my-skill
description: |
  Trigger phrases that should invoke this skill.
  "use my-skill", "run my-skill workflow"

  Use when: [clear trigger conditions]
  Don't use: [when not to use]
---
```

### Writing Effective Skills

**1. Clear trigger conditions**:
```yaml
description: |
  Use when user asks to "implement plan", "execute plan"
  Don't use: User needs planning (use task-preparation)
```

**2. Structured workflow**:
- Define clear stages (Stage 0, 1, 2...)
- Specify tools to use at each stage
- Include decision points

**3. Role integration**:
- Specify which role to use (architect, developer, etc.)
- Load with Read tool at appropriate stage
- Apply role principles throughout

**4. Progress tracking**:
- Use TaskCreate at start
- Use TaskUpdate after major steps
- Mark completed when done

**5. Context efficiency**:
- Keep SKILL.md focused (~1,500-3,000 words)
- Put detailed references in separate files
- Load references only when needed

### Skill Best Practices

**DO**:
- ✅ Define clear trigger phrases
- ✅ Structure workflow into stages
- ✅ Include role integration
- ✅ Track progress with tasks
- ✅ Provide examples
- ✅ Document when NOT to use

**DON'T**:
- ❌ Make skills too generic
- ❌ Overlap with other skills
- ❌ Load all references by default
- ❌ Skip progress tracking
- ❌ Forget user approval gates

## Skill vs Role vs Direct Implementation

### When to Use Skills

**Use a skill when**:
- Workflow is multi-stage and structured
- Requires specific tools/patterns at each stage
- Benefits from progress tracking
- Needs approval gates
- Should be repeatable and consistent

**Examples**: task-preparation, task-implementation, code-review, testing-suite

### When to Use Roles

**Use a role when**:
- Need perspective shift without workflow
- Want consistent thinking style
- Simple invocation: "act as [role]"
- Augments normal behavior

**Examples**: software-architect, software-developer, product-manager

See: `~/.claude/roles/README.md` (if it exists) or `~/.claude/CLAUDE.md`

### When to Use Direct Implementation

**Use direct approach when**:
- Task is simple and straightforward
- No multi-stage workflow needed
- Quick fixes or obvious changes
- No approval gates needed

**Examples**: "fix this typo", "add this function", "explain this code"

## Skill System Features

### Automatic Invocation

Claude detects skills based on:
- Keywords in your message
- Task complexity
- Context clues

You don't need to explicitly invoke skills - natural language works!

### Context Management

Skills use:
- Main SKILL.md always loaded
- Optional references loaded on demand
- Examples loaded when requested
- Efficient context usage

### Progress Tracking

Skills integrate with task system:
```
/tasks          # View all tasks
/task [id]      # View specific task
```

Track long-running implementations in real-time.

### Pause and Resume

Skills support workflow interruptions:
- Pause at any approval gate
- Progress saved in task metadata
- Resume with full context

## File Organization

### Recommended Structure

**For team projects** (recommended):
```
your-project/
├── plans/                      # Implementation plans
│   ├── feature-auth.md
│   └── refactor-api.md
├── docs/
├── src/
└── tests/
```

**For personal projects**:
```
~/.claude/
├── plans/                      # Global plans
│   ├── project-a-auth.md
│   └── project-b-refactor.md
├── roles/                      # Custom roles
└── skills/                     # Custom skills
```

### Version Control

**Commit to git**:
- ✅ `plans/*.md` - Share approach with team
- ✅ Custom skills (if team-specific)
- ❌ `~/.claude/` personal configs

**.gitignore patterns**:
```gitignore
# Ignore private plans
plans/*-private.md

# Ignore personal config
.claude/
```

## Troubleshooting

### Skill Not Triggering

**Problem**: Skill doesn't invoke when expected

**Solutions**:
1. Check frontmatter trigger phrases match your request
2. Be more explicit: "use [skill-name]"
3. Verify skill directory structure is correct
4. Check SKILL.md has proper frontmatter

### Wrong Skill Triggered

**Problem**: Different skill than intended was used

**Solutions**:
1. Use explicit invocation: "/skill-name"
2. Rephrase request with specific keywords
3. Check skill descriptions for overlap

### Skill Context Too Large

**Problem**: Skill uses too much context

**Solutions**:
1. Move detailed content to references/
2. Load references only when needed
3. Keep SKILL.md focused on workflow
4. Use examples/ for detailed walkthroughs

### Task Tracking Not Working

**Problem**: Progress not visible in `/tasks`

**Solutions**:
1. Verify skill uses TaskCreate at start
2. Check TaskUpdate after each step
3. Ensure proper task metadata
4. Mark completed when done

## Advanced Topics

### Skill Composition

Skills can reference other skills:
```markdown
For planning, use task-preparation skill.
For execution, use task-implementation skill.
```

### Conditional Workflows

Skills can adapt based on:
- Project structure (package.json, requirements.txt)
- Existing tests
- User preferences
- Task complexity

### Integration with Roles

Skills can load and use roles:
```javascript
// At appropriate stage
Read({ file_path: "~/.claude/roles/software-developer.md" })
// Apply role principles throughout
```

### Custom Approval Gates

Skills can define multiple approval points:
- Gate #1: Approve overall approach
- Gate #2: Approve each step
- Gate #3: Approve before deployment

## Examples

### Example 1: Using task-preparation + task-implementation

```
# Planning phase
You: "use task preparation to add payment processing"

Claude: [Requirements gathering]
        What payment providers? [PayPal, Stripe, both]

You: Stripe

Claude: [Architecture design]
        [Peer review]
        [Step breakdown]
        Plan saved to: ./plans/payment-processing.md

# Implementation phase (hours or days later)
You: "implement plan: ./plans/payment-processing.md"

Claude: Reading plan...
        Found 8 steps.
        Creating task...

        Step 1 of 8: Create Stripe service wrapper
        [Shows approach]
        Approve?

You: A

Claude: [Implements, tests, shows results]
        Progress: 1/8 (12%)

        Step 2 of 8: Add payment routes
        ...

# Check progress anytime
You: /tasks

Output:
Task: Implement payment processing
Status: in_progress
Progress: 5/8 steps (62%)
Last updated: 3 minutes ago
```

### Example 2: Quick Implementation Without Planning

```
You: "add a logout button to the navbar"

Claude: [No skill needed - direct implementation]
        I'll add a logout button to the navbar.
        [Shows approach]
        [Implements]
        Done!
```

### Example 3: Team Workflow

```
# Architect creates plan
Architect: "use task preparation for database migration"
Claude: [Creates comprehensive plan]
        Saved to: ./plans/db-migration.md
Architect: git commit -m "Add DB migration plan"

# Developer implements later
Developer: git pull
Developer: "implement plan: ./plans/db-migration.md"
Claude: [Executes step-by-step]
        [Tracks progress]
        [Completes implementation]
Developer: git commit -m "Implement DB migration per plan"
```

## Resources

### Documentation

- **This file**: Overview of skill system
- **Individual SKILL.md**: Detailed workflow for each skill
- **USAGE.md**: Quick start guides
- **examples/**: Detailed walkthroughs
- **~/.claude/CLAUDE.md**: Global configuration and role system

### Getting Help

```
"how do skills work?"
"explain the task-implementation skill"
"show me an example of using task-preparation"
"what skills are available?"
```

Claude can explain the skill system or specific skills on request.

## Summary

**Skills provide**:
- ✅ Structured workflows for complex tasks
- ✅ Consistent, repeatable processes
- ✅ Progress tracking for long implementations
- ✅ Team-shareable best practices
- ✅ Clear approval gates and control

**Use skills when you want**:
- Systematic approach to complex work
- Separation of planning and execution
- Progress visibility
- Step-by-step control

**Skip skills when**:
- Task is simple and obvious
- No ceremony needed
- Quick fixes

The skill system gives you power and flexibility - use it when it adds value, skip it when it doesn't.
