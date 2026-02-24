---
name: task-preparation
description: |
  This skill should be used when the user asks to "prepare a task",
  "use task preparation", "structured planning", "architect-led planning",
  "plan a task", "create implementation plan", or wants a comprehensive
  planning workflow that includes requirements gathering, architectural
  planning, peer review validation, and detailed step breakdown.

  This is a PLANNING-ONLY skill. It does NOT implement code. It creates
  a detailed plan and saves it to a file for later execution (use
  task-implementation skill to execute the plan).

  Do NOT use for trivial tasks (typo fixes, single-line changes, obvious bugs).
  Use for non-trivial features, refactorings, or complex implementations.
---

# Task Preparation Skill

## Overview

This skill implements a structured, architect-led workflow for **planning** non-trivial software engineering tasks. It guides you through a comprehensive process from requirements gathering to a detailed, approved implementation plan.

**PLANNING ONLY - NO IMPLEMENTATION**

This skill creates plans, it does NOT implement code. For execution, use the **task-implementation** skill.

**What this skill does:**
- Gathers comprehensive requirements systematically
- Leverages software architect perspective for planning
- Provides peer review validation through second architect review
- Breaks down work into atomic, manageable steps
- **Saves plan to file** for later execution
- Stops at Approval Gate #1 (plan approval)

**What makes it different:**
Unlike direct implementation, this skill ensures you and I are aligned on the approach BEFORE any code is written. It prevents wasted effort, catches design flaws early, and produces a documented plan that can be shared with your team.

**Single-Phase Structure:**
- **Phase A: Plan Development** - Requirements → Architecture → Review → Steps → Approval → Save Plan
- **Phase B removed** - Use task-implementation skill for execution

## When to Use This Skill

**Use this skill for:**
- Non-trivial features requiring architectural decisions
- Complex refactorings affecting multiple components
- Multi-component or multi-layer changes
- Tasks where multiple approaches are possible
- Security-sensitive implementations
- Performance-critical changes
- Anything requiring 5+ steps or touching 5+ files

**Do NOT use for:**
- Trivial tasks (typo fixes, single-line changes)
- Obvious bug fixes with clear solutions
- Simple, well-defined single-file changes
- Tasks explicitly marked as "quick fix" by user

**When in doubt:** This skill includes complexity assessment and will offer a bypass option for simple tasks, so you can safely invoke it and let the skill decide.

## Prerequisites

Before using this skill, ensure:

1. **Role system is set up**: `~/.claude/roles/software-architect.md` should exist
   - If missing, the skill uses fallback inline guidance with a warning
2. **Task management tools available**: TaskCreate and TaskUpdate tools must be accessible
3. **User availability**: User must be available to provide approvals at key points:
   - Approve complete plan at Approval Gate #1
   - May need to clarify requirements or make architectural decisions
4. **Time commitment**: Planning is thorough - expect meaningful interaction
5. **Plan storage location**: Plans are saved inside the project they belong to:
   - Default: `.claude/task/[name].md` in the project directory (recommended)
   - Custom: Any path you specify

## Initial Complexity Assessment

Before starting the full workflow, I will assess whether the task is simple enough to bypass the comprehensive process.

**Simple Task Indicators (3+ suggests bypass):**
- Single file modification
- Less than 50 lines of code changes
- No architectural decisions needed
- Clear, well-defined requirements
- No new external dependencies
- No security or authentication implications
- Standard pattern application (following existing code style)

**If task appears simple:**
I will present: "This looks like a straightforward task. Would you like to:
- **A) Skip the full workflow and implement directly** (faster, no formal plan)
- **B) Use the structured planning workflow anyway** (more thorough, documented plan)"

**If you choose A:** We skip to direct implementation without creating a formal plan.

**If you choose B OR task is complex:** We proceed with the full planning workflow (Phase A).

## Phase A: Plan Development

This phase focuses entirely on understanding, planning, and validating the approach. **No implementation happens in Phase A.** It ends with Approval Gate #1 where you approve the complete plan.

### Stage 0: Task Creation

**Purpose:** Create a task to track this work throughout the workflow.

**Procedure:**
1. I will use TaskCreate to create a task from your request
2. Set task subject to summarize the goal (e.g., "Add user authentication system")
3. Set task description with the full context of your request
4. Set initial status to `in_progress`
5. Add metadata: `{ phase: "planning", step: 0 }`

**This gives you:** Visibility into progress and a record of the work being done.

### Stage 1: Requirements Gathering

**Purpose:** Systematically collect comprehensive information about what you need.

**Procedure:**
1. I will use AskUserQuestion to gather requirements across key categories:
   - **Goal and Objective**: What are we trying to achieve and why?
   - **Scope and Components**: What files, systems, or components are involved?
   - **Constraints**: Are there performance, compatibility, or style requirements?
   - **Expected Behavior**: What should happen? What should NOT happen?
   - **Examples or References**: Are there existing patterns to follow?
   - **Exclusions**: What should NOT be changed or touched?

2. If I need structured question templates for specific task types (e.g., API implementation, UI feature, refactoring), I will load `references/requirements-gathering.md` for guidance.

3. I will ask questions in batches (1-4 at a time) to avoid overwhelming you.

4. I will clarify ambiguities and validate assumptions before proceeding.

**Output:** A comprehensive understanding of requirements, constraints, and success criteria.

### Stage 2: Architect Planning (First Pass)

**Purpose:** Design a high-level implementation approach from an architectural perspective.

**Role Adoption Procedure:**
1. I will use the Read tool to load: `~/.claude/roles/software-architect.md`
2. If the file is not found, I will use fallback inline architect guidance (see below) and warn you
3. I will explicitly state: **"I am now adopting the software architect perspective"**
4. I will follow the role's communication style:
   - **High-level thinking** - System structure before implementation details
   - **Trade-off analysis** - Discuss pros and cons of different approaches
   - **Visual thinking** - Describe component boundaries and data flow
   - **Question-driven** - Ask about constraints, goals, and non-functional requirements
5. I will apply architectural priorities:
   - System design and component relationships
   - Scalability and maintainability considerations
   - Pattern identification and reuse
   - Non-functional requirements (performance, security, reliability)
   - Integration points with existing system
6. I will create a comprehensive implementation plan covering:
   - **High-level architecture** - System boundaries, major components
   - **Component structure** - Interfaces, responsibilities, dependencies
   - **Data flow** - How information moves through the system
   - **Integration points** - How new code connects to existing system
   - **Trade-offs** - Alternative approaches and why this one was chosen
   - **Technology choices** - Libraries, patterns, tools and rationale
7. I will format the plan with clear sections and visual descriptions (using text/diagrams)

**Fallback Architect Guidance (if role file missing):**
If `~/.claude/roles/software-architect.md` doesn't exist, I will:
- Focus on system design over implementation details
- Consider how components fit together and interact
- Think about scalability, maintainability, and future evolution
- Identify applicable design patterns and architectural styles
- Discuss trade-offs explicitly (no approach is perfect)
- Warn you that the role file is missing and fallback guidance is being used

**Output:** A high-level implementation plan with architectural reasoning.

### Stage 3: Complexity Assessment

**Purpose:** Evaluate whether the task is complex enough to warrant splitting into multiple tasks.

**Complexity Indicators (3+ suggests splitting):**
1. Changes span **3+ distinct system layers** (UI, API, business logic, database, cache, messaging, etc.)
2. Requires **new external dependencies** or third-party service integrations
3. Involves **data migrations or schema changes**
4. Has **security or authentication implications**
5. Affects **performance-critical code paths**
6. **5+ files** require non-trivial modifications (>20 lines each)
7. **Multiple team domains** affected (frontend, backend, DevOps, mobile, etc.)

**If 3+ indicators are present:**
I will suggest: "This task is complex, spanning [X areas]. Consider splitting into:
1. [Focused task 1 with clear scope]
2. [Focused task 2 with clear scope]
3. [Focused task 3 with clear scope]"

**You can choose:**
- Accept the suggestion and pick one subtask to focus on
- Decline and continue with the full scope
- Modify the split to better match your priorities

**Output:** Either confirmation to proceed as-is, or a refined scope focusing on one subtask.

### Stage 4: Peer Review (Second Architect - Plan Agent)

**Purpose:** Challenge the first plan to find weaknesses, gaps, and improvements through independent review.

**Critical Review Procedure:**

1. **Prepare context package** for independent review:
   - User requirements from Stage 1
   - Architectural plan from Stage 2
   - Complexity assessment from Stage 3

2. **Spawn Plan agent** using Task tool:
   - Use `subagent_type: "Plan"` for independent architect review
   - Provide comprehensive prompt with complete context
   - Include the initial plan for critical analysis
   - Request systematic review using validation framework

3. **Plan agent performs independent review:**
   - Agent loads `~/.claude/roles/software-architect.md` for architect perspective
   - Agent loads `references/validation-framework.md` for review criteria
   - Agent challenges assumptions and identifies risks
   - Agent suggests alternatives and improvements
   - Agent returns structured critical review

4. **Collect review results:**
   - Receive Plan agent's independent critical analysis
   - Extract actionable feedback and concerns
   - Pass structured review to Stage 5 for plan refinement

**What the review agent evaluates:**
- **Assumptions**: Are they valid and well-justified?
- **Failure modes**: What could go wrong with this approach?
- **Alternatives**: Are there simpler or better approaches?
- **Engineering level**: Is it over-engineered? Under-engineered?
- **Edge cases**: What error scenarios were missed?
- **Integration**: Are integration points clearly defined?
- **Risks**: What are the biggest concerns and mitigations?
- **Security**: Any vulnerabilities or attack vectors?
- **Consistency**: Does it align with existing patterns?
- **Testability**: Can this be effectively tested?
- **Complexity**: Unnecessary complexity or technical debt?

**Why sub-agent approach:**
- ✅ True independent perspective (no bias from creating the plan)
- ✅ Fresh eyes catch issues self-review might miss
- ✅ More authentic "second architect" review
- ✅ Better quality feedback at modest cost increase

**Output:** Independent critical review identifying strengths, concerns, critical issues, and questions.

#### Example: Task Tool Invocation for Peer Review

**CRITICAL**: The prompt to the Plan agent must be extremely explicit. Don't assume the agent knows what to do - provide complete step-by-step instructions.

**Example invocation:**

```javascript
Task({
  subagent_type: "Plan",
  description: "Review architectural plan",
  prompt: `You are a second software architect performing independent peer review of an initial architectural plan.

## Context

**User Requirements:**
${fullRequirementsFromStage1}

**Initial Architectural Plan (to review):**
${fullPlanFromStage2}

**Complexity Assessment:**
${complexityAssessmentFromStage3}

## Your Task (follow these steps exactly)

1. **Load the software architect role:**
   - Read ~/.claude/roles/software-architect.md
   - Adopt the architect perspective and thinking style

2. **Load the review framework:**
   - Read references/validation-framework.md (in the skill directory)
   - Use it as a systematic checklist for review

3. **Perform critical review systematically:**
   - Challenge assumptions - are they valid and well-justified?
   - Identify failure modes - what could go wrong?
   - Find simpler alternatives - is this over-engineered?
   - Check edge cases - what error scenarios were missed?
   - Verify integration points - are they clearly defined?
   - Assess risks - what are the biggest concerns?
   - Evaluate security - any vulnerabilities or attack vectors?
   - Test consistency - does it match existing patterns?
   - Check testability - can this be effectively tested?
   - Review complexity - unnecessary complexity or technical debt?

4. **Be constructive but critical:**
   - Find real issues, not nitpicks
   - Provide specific, actionable suggestions
   - Explain the impact of each concern
   - Acknowledge strengths where appropriate

## Required Output Format

**Strengths:**
- [What's good about this plan - 2-3 items]

**Concerns:**
- **Category:** [e.g., Security, Performance, Error Handling]
  **Issue:** [Specific problem identified]
  **Impact:** [Why this matters]
  **Suggestion:** [How to fix or improve]

**Critical Issues:**
- [Must-fix problems before proceeding]

**Questions:**
- [Areas needing clarification from the user or first architect]

Be thorough, specific, and actionable in your review. This is an independent peer review - you have not seen this plan before and should approach it with fresh eyes.
`
})
```

**Key success factors:**
1. **Complete context** - Include full requirements and plan
2. **Explicit instructions** - Numbered steps the agent must follow
3. **Specific framework** - Reference validation-framework.md
4. **Required format** - Structured output template
5. **Clear role** - Agent understands it's an independent reviewer

### Stage 5: Plan Refinement

**Purpose:** Incorporate peer review feedback to strengthen the plan.

**Procedure:**
1. I will analyze the second architect's feedback
2. Identify valid concerns and actionable suggestions
3. Revise the plan to address:
   - Critical risks or flaws
   - Missing error handling or edge cases
   - Architectural improvements
   - Simpler alternatives (if truly better)
4. Resolve conflicts between first and second perspectives
5. Document decisions and rationale for changes (or why feedback was not incorporated)

**Output:** A refined, strengthened implementation plan incorporating peer review.

### Stage 6: Step Breakdown

**Purpose:** Divide the plan into atomic, manageable steps for controlled execution.

**Step Granularity Rules:**

Each step must be:
- **Single file or closely related files** (max 3 files that change together)
- **One logical unit of change** (e.g., "Add middleware" not "Implement auth system")
- **Independently verifiable** (has clear success criteria or test)
- **Quick to review** (takes less than 5 minutes to understand and verify)
- **Atomic** (makes sense on its own, not partial work that leaves things broken)
- **Reversible** (can be undone without cascading problems)

**Good Step Examples:**
- ✓ "Create authentication middleware in src/middleware/auth.js"
- ✓ "Add user table migration and User model (2 files: migrations/001_users.sql, models/User.js)"
- ✓ "Implement login endpoint in src/routes/auth.js with JWT token generation"
- ✓ "Add authentication middleware to protected routes in src/app.js"
- ✓ "Write unit tests for authentication middleware"

**Bad Step Examples:**
- ✗ "Implement authentication" (too vague, too large, not atomic)
- ✗ "Change line 42 in config.js" (too small, not a logical unit)
- ✗ "Update all files for new feature" (not atomic, unclear)
- ✗ "Refactor codebase" (no clear scope or success criteria)

**Procedure:**
1. I will break the refined plan into 5-15 atomic steps (if more than 15, the task may be too complex - suggest splitting)
2. Order steps logically (dependencies first, integration last)
3. For each step, document:
   - **Description**: What will be done
   - **Files affected**: Specific file paths
   - **Estimated impact**: Lines of code, whether it's new or modified
   - **Success criteria**: How to verify it worked

**Output:** A numbered list of atomic steps ready for execution.

## Approval Gate #1: Complete Plan

**Purpose:** Get your explicit approval of the complete plan. This is the final stage of this skill.

**What I will present:**
1. **Summary** - High-level overview of the approach
2. **Architecture** - Component structure, data flow, integration points
3. **Complete step list** - All steps with descriptions, files, and impact
4. **Trade-offs** - Why this approach over alternatives
5. **Risks** - Known risks and mitigation strategies

**How I will ask for approval:**

I will use AskUserQuestion with these options:
- **Approve and save plan** - Plan looks good, save to file
- **Request modifications** - Specify which parts need changes
- **Reject and start over** - Fundamental issues, need new approach

**If you request modifications:**
1. I will gather your specific feedback on which parts to change
2. I will revise the affected sections (may re-run architect planning if fundamental)
3. I will re-present only the changed sections
4. I will ask for approval again

**If you approve:**
1. **Save the plan to the project's task folder:**
   - Default: `[project-root]/.claude/task/[name].md`
   - Ask the user only if the project root is unclear or they want a custom path

2. **Save the plan file** with this structure:
   ```markdown
   # Implementation Plan: [Feature Name]

   ## Summary
   [High-level description and objectives]

   ## Architecture Overview
   [Component structure, data flow, integration points]

   ## Prerequisites
   - Test command: [command to run tests]
   - Existing tests: [Yes/No, location]
   - Testing framework: [jest/pytest/etc.]

   ## Implementation Steps

   ### Step 1: [Description]
   **Files**:
   - path/to/file.js (new/modify, ~N LOC)

   **What to implement**:
   [Detailed description]

   **How to implement**:
   [Technical approach, patterns, libraries]

   **Success criteria**:
   [How to verify it works]

   **Complexity**: Low/Medium/High

   ### Step 2: [...]
   ...
   ```

3. **Update task metadata** to `{ phase: "completed", planSaved: true, planPath: "[path]" }`

4. **Inform user** (complexity-aware suggestion):

   Analyze the plan to determine implementation recommendation:
   - Count total steps
   - Count independent work streams (steps with no mutual file dependencies)
   - Check complexity assessment from Stage 3 (number of indicators)

   **If plan has 8+ steps AND 2+ independent work streams AND complexity assessment had 3+ indicators:**
   ```
   Plan saved to: [path]

   This plan has [N] steps with [M] independent work streams suitable for parallel execution.

   To implement:
   - Parallel (faster, autonomous with validation loop): "execute complex plan: [path]"
   - Step-by-step (controlled, per-step approval): "implement plan: [path]"
   ```

   **Otherwise:**
   ```
   Plan saved to: [path]

   To implement this plan, use:
   "implement plan: [path]"

   Or with task-implementation skill:
   "/task-implementation [path]"
   ```

**This skill ends here.** Use task-implementation or complex-task-implementation skill to execute the plan.

### Tracking in TASKS.md

After saving the plan, register it in the centralized task tracker. This is mandatory.

**Location**: `{{PROJECTS_DIR}}/TASKS.md`

**Add the task** under the appropriate project section:
```markdown
### [project-name]
- [ ] [Feature name from plan] (plan: .claude/task/[name].md)
```

Update the "Last updated" date at the top of the file.

## Role Integration Details

**How roles are loaded:**
1. I use the Read tool to load: `~/.claude/roles/software-architect.md`
2. I parse the role definition to understand:
   - Perspective and thinking style
   - Communication patterns
   - Priorities and focus areas
3. I explicitly state when I'm adopting a role
4. I maintain the role's perspective until the stage is complete

**Fallback if role missing:**
- If `~/.claude/roles/software-architect.md` doesn't exist, I use inline fallback guidance
- I warn you that the role file is missing
- I still apply architectural thinking, but without customized role instructions

**Perspective adoption:**
- When I say "I am now adopting the software architect perspective", I shift my thinking to:
  - System design over implementation details
  - Long-term maintainability over quick fixes
  - Component relationships and boundaries
  - Trade-offs and alternatives
- When I review as "second architect", I adopt a critical, devil's advocate mindset:
  - Challenge assumptions
  - Look for flaws and risks
  - Suggest alternatives
  - Play "what could go wrong"

**Communication style changes:**
- **First architect**: Explanatory, design-focused, "here's how we could structure this..."
- **Second architect**: Critical, probing, "but what if...", "have you considered..."

## Error Handling

**Planning phase issues:**
If issues arise during planning (missing context, unclear requirements, etc.):

1. **Ask clarifying questions** - Use AskUserQuestion to gather needed information
2. **Explore codebase** - Read relevant files to understand current implementation
3. **Present options** - When multiple approaches exist, present trade-offs

**Plan rejection:**
If you reject the plan at Approval Gate #1:
- I will ask for specific feedback on what needs to change
- I may need to revisit earlier stages (requirements, architecture)
- I will revise and re-present for approval

**Workflow interruption:**
- You can pause at any time during planning
- Progress is tracked via TaskUpdate metadata
- To resume, say "continue task preparation" or reference the task ID
- I will resume from where we left off

## Tips and Best Practices

**For users:**
- **Be specific in requirements** - The better your answers in Stage 1, the better the plan
- **Trust the process** - The workflow is comprehensive for a reason; shortcuts reduce quality
- **Use modification options** - If something doesn't look right at approval gates, request changes
- **Don't rush approvals** - Take time to review plans and steps; catching issues early saves time
- **Split complex tasks** - If complexity assessment suggests splitting, seriously consider it

**For maintaining planning quality:**
- Approval Gate #1 is a quality checkpoint
- Ensures we're building the right thing BEFORE any code is written
- Saying "no" or "modify" at the gate is valuable feedback, not a problem
- A good plan prevents wasted implementation effort

**When to suggest splitting tasks:**
- If the plan has 15+ steps, it's likely too complex for one task
- If multiple unrelated features are bundled together
- If the task spans multiple system boundaries with no shared context
- Splitting allows focused effort and easier review

**Keep steps atomic:**
- One logical change per step
- If you're tempted to say "Step 5a, 5b, 5c", those should be separate steps
- Small steps mean small mistakes (if any), easier review, clearer progress

**Document decisions:**
- During planning, I'll document why certain approaches were chosen
- All decisions and trade-offs will be captured in the plan file
- This creates a record for implementation and future reference

## Reference Loading Triggers

I will load additional reference files when needed:

**Load `references/requirements-gathering.md` when:**
- "If you need question templates for [specific task type]..."
- Encountering unfamiliar task types requiring structured questions
- User requests comprehensive requirements checklist

**Load `references/validation-framework.md` when:**
- "If uncertain about review criteria..."
- Second architect review needs comprehensive checklist
- Evaluating architectural quality or identifying pitfalls

**Load `examples/sample-workflow.md` when:**
- "If you want to see a complete example..."
- User asks "how does this work in practice?"
- Demonstrating the workflow end-to-end

**You don't need to request these** - I'll load them automatically when the trigger conditions are met.

---

## Workflow Summary

**Complete Planning Workflow (Planning Only - No Implementation)**

1. **Create task** - Initialize task tracking
2. **Gather requirements** - Systematic questions about what to build
3. **Architect planning** (first pass) - Design approach, architecture, components
4. **Assess complexity** - Suggest splits if needed
5. **Peer review** (Plan agent) - Independent critical review via sub-agent, identify risks
6. **Refine plan** - Incorporate feedback
7. **Break down into steps** - Atomic, numbered implementation steps
8. **→ APPROVAL GATE #1: User approves complete plan**
9. **Ask where to save plan** - Project-local, global, or custom path
10. **Save plan file** - Structured markdown with all details
11. **Complete task** - Mark done, provide next steps

**Skill ends here.** For implementation, use:
```
"implement plan: [path to saved plan]"
```

**You maintain full control** through Approval Gate #1 and the ability to request modifications at any point.

**Let's plan quality software together.**
