---
name: product-discovery
description: |
  Use this skill to discover, validate, and translate user needs into actionable
  user stories. Invocation: "use product discovery for [idea]", "product discovery:
  [concept]", "discover product: [feature]", "translate product brief to user
  stories: [path]".

  Two modes:
  - Full Discovery: Product Owner discovery → optional Product Manager translation
  - Translation Only: Convert existing brief to user stories

  This is DISCOVERY AND REQUIREMENTS only. Does NOT plan technical implementation.
  For technical planning, use task-preparation skill.

  Use when: Raw idea, feature request, unclear requirements, or translating brief
  Don't use: For technical planning or implementation
---

# Product Discovery Skill

## Overview

The product-discovery skill automates the Product Owner → Product Manager workflow, taking raw ideas through structured discovery to validated user stories ready for technical planning.

**Purpose**: Discover user problems, visualize solutions, validate viability, and translate into actionable requirements—all before technical planning begins.

**Two Operating Modes**:

1. **Full Discovery Mode**: Complete Product Owner discovery followed by optional Product Manager translation
   - Stage 0: Initialization & complexity assessment
   - Stage 1: Product Owner discovery (fluid conversation)
   - Stage 2: Product Manager translation (optional)

2. **Translation-Only Mode**: Convert existing Product Brief to user stories
   - Skip directly to Stage 2
   - Requires existing Product Brief file path

**What This Skill Does NOT Do**:
- Technical architecture planning (use task-preparation)
- Implementation (use task-implementation)
- Code reviews or technical decisions

**Integration**: Output integrates seamlessly with task-preparation skill for subsequent technical planning.

---

## When to Use This Skill

### Use When

- **Raw idea**: "I want to add [vague feature]"
- **Feature request**: User feedback or stakeholder request needs exploration
- **Unclear requirements**: Problem space needs discovery
- **Translating brief**: Existing Product Brief needs user stories
- **Validation needed**: Need to confirm idea is viable before technical work
- **Novel features**: New functionality without established patterns
- **Complex user problems**: Multiple stakeholders or unclear user needs

### Don't Use When

- **Technical planning**: Use task-preparation instead
- **Implementation**: Use task-implementation instead
- **Bug fixes**: Usually don't need product discovery
- **Clear requirements**: If you already have detailed user stories
- **Pure research**: Use explore agent instead

---

## Prerequisites

### Required Files

**Role Definitions** (loaded automatically):
- `~/.claude/roles/product-owner.md` - Stage 1 discovery perspective
- `~/.claude/roles/product-manager.md` - Stage 2 translation perspective

**Reference Templates** (auto-loaded):
- `~/.claude/skills/product-discovery/references/discovery-questions.md` - Stage 1
- `~/.claude/skills/product-discovery/references/story-patterns.md` - Stage 2

**Fallback**: If files missing, skill uses inline guidance with warning to user.

### User Requirements

- Willingness to engage in exploratory conversation (Stage 1)
- Ability to articulate problem (even vaguely)
- Availability for approval gates (9 total, can pause anytime)

---

## Stage 0: Initialization & Complexity Assessment

**Duration**: 2-5 minutes
**Purpose**: Determine operating mode, assess complexity, set expectations, create task tracking

### Procedure

#### Step 0.1: Detect Operating Mode

Analyze user invocation:

**Translation-Only Mode Triggers**:
- User provides file path: `"translate product brief: ./path/to/brief.md"`
- User references existing brief: `"convert this brief to user stories"`
- Pattern match: "translate", "convert", "brief to stories" + file path

**If Translation-Only**:
- Set mode: `translation-only`
- Skip to Stage 2 (Section: Stage 2 Procedure)
- Do NOT execute remaining Stage 0 steps

**Full Discovery Mode** (default):
- Set mode: `full-discovery`
- Continue with Stage 0 procedure

#### Step 0.2: Parse User Request (Full Discovery Only)

Extract from user message:
- **Feature/idea name**: Core concept being explored
- **Initial context**: Any problem description, user mentions, constraints
- **Urgency indicators**: Timeline, priority signals

Store for use throughout skill execution.

#### Step 0.3: Ask Project Type (Full Discovery Only)

Business validation varies by project type. Ask user:

```
Quick context: What type of project is this?

A) Business/Product - Revenue model, paying customers, market considerations
B) Internal tool - Company/team use, no external customers, efficiency focus
C) Personal/Side project - Hobby, learning, experimentation (skip business validation)
D) Open source - Community-driven, contributor appeal, ecosystem fit
```

**Why This Matters**:
- **Business/Product**: Full business validation (market fit, competitive analysis, pricing)
- **Internal tool**: Organizational value, ROI, adoption challenges
- **Personal/Side**: Skip business validation, focus on personal value
- **Open source**: Community value, contributor appeal

Store: `projectType = "business" | "internal" | "personal" | "opensource"`

#### Step 0.4: Assess Complexity (Full Discovery Only)

Analyze user request to estimate complexity:

**Complexity Factors**:
- Feature scope (single feature vs system)
- User segment clarity (clear vs multiple/unclear)
- Problem definition (well-defined vs exploratory)
- Solution clarity (clear vision vs open-ended)
- Dependencies (standalone vs interconnected)
- Business complexity (simple value prop vs complex validation)

**Complexity Levels**:

**Quick** (10-15 minutes total):
- Simple, focused feature
- Clear user need
- Obvious solution direction
- Minimal business validation
- Example: "Add dark mode toggle"

**Standard** (25-35 minutes total):
- Medium feature with some unknowns
- Need to explore problem space
- Multiple solution options possible
- Business validation needed
- Example: "Payment processing integration"

**Deep** (40-55 minutes total):
- Complex feature or system
- Multiple user segments
- Significant unknowns
- Deep business validation required
- Example: "Multi-tenant collaboration system"

**Present Assessment to User**:

```
I've analyzed '[feature]' and this looks like [Standard] complexity.

Complexity characteristics:
- [Reason 1, e.g., "Multiple user segments to consider"]
- [Reason 2, e.g., "Solution approach needs exploration"]
- [Reason 3, e.g., "Business validation important"]

Does [Standard] complexity sound right?

Quick (10-15 min) - Simple feature, clear requirements
Standard (25-35 min) - Medium feature, some exploration needed
Deep (40-55 min) - Complex feature, thorough discovery required

[Allow user to confirm or override]
```

Store: `complexityLevel = "quick" | "standard" | "deep"`

#### Step 0.5: Set Time Expectations (Full Discovery Only)

Based on confirmed complexity level, present time breakdown:

```
Time expectations for [Standard] complexity:

Stage 1 (Product Owner Discovery): ~15-20 minutes
- Fluid conversation exploring problem, solution, validation
- 6 approval checkpoints (4 critical, 2 lightweight)

Stage 2 (User Stories - optional): ~10-15 minutes
- Translate brief into user stories
- 3 approval checkpoints

Total: ~25-35 minutes with 9 approval points

Notes:
- You can pause at any approval gate
- Lightweight gates allow quick iteration
- Critical gates require explicit approval
- Actual time varies based on conversation depth

Ready to start?
```

Wait for user confirmation before proceeding.

#### Step 0.6: Create Task with Metadata

Use TaskCreate to initialize tracking:

```javascript
TaskCreate({
  subject: "Product discovery: [feature-name]",
  description: "[User's initial request verbatim]",
  activeForm: "Discovering product: [feature-name]",
  metadata: {
    skill: "product-discovery",
    mode: "full-discovery", // or "translation-only"
    phase: "initialization",
    complexityLevel: "quick" | "standard" | "deep",
    projectType: "business" | "internal" | "personal" | "opensource",
    stage: 0,
    startTime: "[ISO timestamp]",
    pivotCount: 0
  }
})
```

#### Step 0.7: Set Task to In Progress

```javascript
TaskUpdate({
  taskId: "[task-id-from-create]",
  status: "in_progress"
})
```

#### Step 0.8: Brief User on Workflow

```
I'll guide you through Product Owner discovery to deeply understand the user problem and solution vision. After that, you can choose whether to translate the Product Brief into user stories (Product Manager stage).

Let's start with discovery!
```

Proceed to Stage 1.

---

## Stage 1: Product Owner Discovery

**Duration**: 10-35 minutes (varies by complexity)
**Purpose**: Understand user problem, visualize solution, validate viability through fluid discovery conversation
**Approval Gates**: 6 total (4 critical, 2 lightweight)

### Key Characteristics

- **Fluid themes, not rigid substages**: Conversation flows naturally
- **User-centric exploration**: Empathy and understanding prioritized
- **Iterative refinement**: Ideas evolve through dialogue
- **Pivot-friendly**: Up to 2 pivots allowed when direction changes
- **Approval-driven**: Regular checkpoints ensure alignment

### Three Discovery Themes

Discovery conversation covers these themes in whatever order emerges naturally:

1. **Problem Understanding**: WHO/WHAT/WHY/WHEN/WHERE
2. **Solution Exploration**: Vision, features, journey, delight
3. **Validation**: Business case (contextual by project type)

### Procedure

#### Step 1.1: Load Product Owner Role & References

**Load role definition**:
```javascript
Read({ file_path: "~/.claude/roles/product-owner.md" })
```

**Load discovery reference**:
```javascript
Read({ file_path: "~/.claude/skills/product-discovery/references/discovery-questions.md" })
```

**If files missing**: Use inline Product Owner guidance, warn user files not found.

**Announce role adoption**:
```
I'm now acting as Product Owner to explore this idea with you. I'll ask questions to understand the user problem, help visualize the solution, and assess viability. Let's have a fluid conversation—jump between topics as needed.
```

**Apply Product Owner mindset**:
- Empathetic and user-centric
- Curious and exploratory
- Creative and solution-oriented
- Gently challenging assumptions
- Focused on user value

**Update task metadata**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  metadata: {
    phase: "discovery",
    stage: 1
  }
})
```

#### Step 1.2: Engage in Fluid Discovery Conversation

Cover all three themes through natural dialogue. Let conversation flow—user may describe solution before problem (that's fine, circle back).

**Theme 1: Problem Understanding**

Explore using discovery-questions.md as guide:

- **WHO**: User identification
  - Who experiences this problem?
  - What are their roles, contexts, behaviors?
  - Are there multiple user segments?
  - What's their current environment/workflow?

- **WHAT**: Problem definition
  - What problem are they experiencing?
  - What pain points frustrate them?
  - What needs aren't being met?
  - How severe is this problem?

- **WHY**: Impact and importance
  - Why does this problem matter to users?
  - What's the impact when problem occurs?
  - How frequently does this happen?
  - What are consequences of not solving it?

- **WHEN/WHERE**: Context
  - When does this problem occur?
  - Where are users when problem happens?
  - What triggers the problem?
  - What environmental factors matter?

- **HOW**: Current solutions
  - How do users solve this today?
  - What workarounds exist?
  - What alternatives are available?
  - Why aren't current solutions sufficient?

**Conversation Style**:
- Ask Socratic questions
- Listen actively and deeply
- Follow threads of interest
- Circle back to fill gaps
- Validate understanding frequently

**Theme 2: Solution Exploration**

Help articulate and refine the vision:

- **Initial vision**:
  - What does user imagine for solution?
  - How would this work in their mind?
  - What's the ideal experience?

- **Concrete interactions**:
  - Make abstract ideas tangible
  - Describe specific user actions
  - Walk through actual scenarios
  - Identify touchpoints

- **User journey**:
  - Before: How do users start?
  - During: What's the experience?
  - After: What's the outcome?
  - Integration with existing workflow?

- **Delight factors**:
  - What makes this valuable?
  - What would excite users?
  - What's the "wow" moment?
  - How is this better than alternatives?

- **Key features**:
  - What capabilities are essential?
  - What's must-have vs nice-to-have?
  - What's in scope vs out of scope?
  - Any phasing considerations?

**Creative collaboration**:
- Suggest improvements from user perspective
- Offer alternative approaches
- Challenge assumptions gently: "What if...?"
- Build on user's ideas

**Theme 3: Validation** (contextual by project type)

Adapt validation depth based on `projectType` from Stage 0:

**For Business/Product projects**:
- **Market fit**:
  - Who would pay for this?
  - Why would they pay?
  - How much might they pay?
  - How many potential customers?

- **Competitive landscape**:
  - What alternatives exist?
  - How is this differentiated?
  - Why would users choose this?
  - What's the unique value proposition?

- **Business viability**:
  - Does this align with business goals?
  - What's the revenue potential?
  - What are the costs/risks?
  - Is this strategically important?

**For Internal tool projects**:
- **Organizational value**:
  - Which teams benefit?
  - What efficiency gains?
  - What productivity improvements?
  - What's the ROI?

- **Adoption challenges**:
  - Will teams actually use this?
  - What's required for adoption?
  - Any training needed?
  - Integration with existing tools?

**For Personal/Side projects**:
- **Personal value**:
  - Why does this matter to you?
  - What will you learn?
  - What problem does it solve for you?

- **Skip detailed business validation**

**For Open source projects**:
- **Community value**:
  - Who in the community needs this?
  - What problem does it solve?
  - How does it fit the ecosystem?

- **Contributor appeal**:
  - Would others contribute?
  - Is the scope manageable?
  - Are there similar projects?

**Complexity Adjustments**:

**Quick mode** (Simple features):
- Cover themes lightly
- Fewer probing questions
- Focus on essentials
- 10-15 minutes total

**Standard mode** (Medium features):
- Balanced coverage
- Normal questioning depth
- Explore key areas thoroughly
- 15-20 minutes total

**Deep mode** (Complex features):
- Comprehensive exploration
- Deep probing questions
- Thorough validation
- Multiple scenarios considered
- 25-35 minutes total

#### Step 1.3: Approval Checkpoints During Discovery

Present findings at natural transition points. Allow iteration.

**APPROVAL CHECKPOINT #1** - After Problem Understanding

Present summary:
```
Let me check if I understand the problem correctly:

WHO: [User segments and context]
WHAT: [Problem description]
WHY: [Impact and importance]
WHEN/WHERE: [Context and triggers]
HOW: [Current solutions and limitations]

Does this capture the core user need? Any corrections or additions?
```

**User responses**:
- Confirm → Continue
- Modify → Adjust understanding, re-present
- Add details → Incorporate, re-present

This is a **lightweight gate** - quick iteration expected.

**APPROVAL CHECKPOINT #2** - After Solution Visualization

Present solution vision:
```
Here's what I'm hearing for the solution:

Vision: [High-level description]

Key Features:
1. [Feature with user benefit]
2. [Feature with user benefit]
3. [Feature with user benefit]

User Journey:
- Before: [Starting point]
- During: [Experience]
- After: [Outcome]

Delight Factors: [What makes this valuable]

Does this match your vision? Any changes or additions?
```

**User responses**:
- Confirm → Continue
- Refine → Iterate on solution, re-present
- Major change → Might trigger pivot (see Step 1.5)

This is a **lightweight gate** - refinement expected.

**APPROVAL CHECKPOINT #3** - After Validation Theme

Present validation assessment:
```
Here's the validation analysis:

[Content varies by project type - see Theme 3 above]

For [projectType] project:
[Specific validation points]

Risks/Considerations:
- [Known risk or uncertainty]
- [Dependency or constraint]

Does this validation make sense? Any additional considerations?
```

**User responses**:
- Confirm → Continue
- Add concerns → Document, may affect viability
- Challenge assumption → Discuss, may affect direction

This is a **lightweight gate** - validation may be partial at this stage.

#### Step 1.4: Check Discovery Coverage (Internal)

Before moving to viability assessment, internally verify all themes sufficiently explored:

**Coverage Checklist**:
- ✓ **Problem Understanding**: Do we know WHO, WHAT, WHY clearly?
- ✓ **Solution Exploration**: Can we describe the user experience concretely?
- ✓ **Validation**: Have we assessed viability for this project type?

**If gaps exist**:
- Identify missing information
- Ask targeted follow-up questions
- Fill gaps before proceeding

**If coverage complete**:
- Proceed to Step 1.5 (Viability Assessment)

Do NOT announce this internal check to user—seamlessly ask follow-ups if needed.

#### Step 1.5: Assess Viability → PROCEED / PIVOT / STOP

Analyze all discovery inputs and determine recommendation.

**PROCEED Criteria**:
- ✓ Clear, validated user problem
- ✓ Viable solution vision that addresses problem
- ✓ Makes sense for project type
- ✓ No critical blockers identified
- ✓ User seems committed
- → Ready to create Product Brief

**PIVOT Criteria**:
- Initial direction won't work BUT
- Better alternative emerged during discovery
- User need is real but different than initially thought
- Solution approach needs fundamental change
- → Document findings, restart discovery with new direction

**STOP Criteria**:
- No clear user problem identified
- Solution doesn't address real user need
- Not viable for project type (e.g., no market, no organizational buy-in)
- Competitive/technical constraints too severe
- User uncertain or uncommitted
- → Document learnings, exit gracefully

**APPROVAL CHECKPOINT #4** - Viability Recommendation (CRITICAL GATE)

This is the **most critical decision point**. Present recommendation with clear rationale:

```
Based on our discovery, my recommendation: [PROCEED / PIVOT / STOP]

Rationale:
[Clear explanation of why this recommendation]

Key findings:
- [Finding 1 that supports recommendation]
- [Finding 2 that supports recommendation]
- [Finding 3 or concern if applicable]

What would you like to do?

A) Proceed to Product Brief
   → Continue with current direction
   → Create structured Product Brief document
   → Option to add user stories (Stage 2)

B) Pivot to different approach [only if pivot count < 2]
   → Document current findings
   → Restart discovery with new direction
   → Explore alternative solution or problem

C) Stop and document learnings
   → Create Product Brief with "Not Viable" status
   → Capture what we learned
   → Exit gracefully

D) Continue exploring
   → Ask more questions
   → Deepen understanding of specific areas
   → Defer decision

[If pivot count >= 2, hide option B and add note:]
Note: Already pivoted [N] times. Continued exploration recommended via option D, or choose direction (A or C).
```

**Handle User Choice**:

**Choice A - PROCEED**:
- Continue to Step 1.6 (File Location Preference)

**Choice B - PIVOT** (if allowed):
- Check pivot count:
  ```javascript
  if (pivotCount >= 2) {
    // Deny pivot, explain limit
    "We've already pivoted twice. Continuing to pivot suggests the idea needs more offline clarification. Options: Continue with current direction (A), Keep exploring (D), or Stop (C)."
    // Re-present choice without B
  } else {
    // Allow pivot
    pivotCount++
    // Update metadata
    TaskUpdate({
      taskId: "[task-id]",
      metadata: { pivotCount: pivotCount }
    })

    // Document pivot
    "Pivot #[N]: Changing from [old direction] to [new direction] because [reason]"

    // Restart discovery themes with new direction
    // Return to Step 1.2 with pivot context
  }
  ```

**Choice C - STOP**:
- Proceed to create Product Brief with "Not Viable" status
- Skip to Step 1.7 but modify template (see STOP handling)
- Mark recommendation as STOP
- Exit after brief created

**Choice D - Continue Exploring**:
- Ask what area needs more exploration
- Return to relevant theme (Problem/Solution/Validation)
- Resume discovery conversation
- Return to this checkpoint when ready

**Pivot Tracking in Metadata**:
```javascript
{
  pivotCount: 0,  // Increment each pivot
  pivotHistory: [
    {
      from: "initial direction description",
      to: "new direction description",
      reason: "why pivot happened",
      timestamp: "ISO timestamp"
    }
  ]
}
```

#### Step 1.6: Ask File Location Preference

**APPROVAL CHECKPOINT #5** - File Output Configuration

Ask user where to save output:

```
Where would you like me to save the output?

A) Single file: ./product-briefs/[feature-name].md (recommended)
   → Product Brief + User Stories in one document
   → Easier to share and reference
   → Choose this if unsure

B) Separate files:
   → ./product-briefs/[feature-name]-brief.md (Product Brief only)
   → ./product-briefs/[feature-name]-stories.md (User Stories, if Stage 2)
   → Better for version control of each artifact

C) Custom location: [you specify]
   → Provide your own path(s)
   → Useful for project-specific structure

Default: Option A (single file)
```

**Store user choice**:
```javascript
{
  outputMode: "single" | "separate" | "custom",
  briefPath: "path/to/brief.md",
  storiesPath: "path/to/stories.md" // if separate mode
}
```

**Create directory if needed**:
```javascript
Bash({ command: "mkdir -p [directory]" })
```

#### Step 1.7: Create Product Brief

Generate comprehensive Product Brief document with 5 sections.

**Product Brief Template**:

```markdown
# Product Discovery: [Feature Name]

*Generated: [YYYY-MM-DD HH:MM timezone]*
*Complexity: [Simple/Medium/Complex]*
*Project Type: [Business/Internal/Personal/OpenSource]*
*Status: [Validated / Pivot Recommended / Not Viable]*

---

## Product Brief

### 1. User Problem & Context

**Target Users**: [WHO needs this]

[Describe user segments, roles, personas, and context]

**Problem Statement**: [WHAT pain point or need]

[Clear articulation of the core problem users experience]

**User Context**: [Current workflow and environment]

[Describe when/where the problem occurs, what users are trying to accomplish, environmental factors]

**Why It Matters**: [Impact and importance]

[Explain the impact on users, frequency of occurrence, severity, consequences of not solving]

**Current Solutions**: [How users solve this now]

[Describe existing workarounds, alternatives, competitive solutions, and why they're insufficient]

---

### 2. Solution Vision

**Overview**: [High-level user-facing description]

[Describe what we're building from the user's perspective—the experience, not the technology]

**Key Features**:

1. **[Feature Name]**: [User benefit and description]
2. **[Feature Name]**: [User benefit and description]
3. **[Feature Name]**: [User benefit and description]
[Add more as needed]

**User Journey**: [Step-by-step experience]

**Before using the feature**:
[Starting point, what triggers the need]

**During interaction**:
[Step-by-step user experience, key interactions, what user sees/does]

**After completion**:
[Outcome, what user accomplished, follow-up actions]

**Delight Factors**: [What makes this valuable]

[Describe what makes this solution exciting, valuable, or better than alternatives]
[What's the "wow" moment for users?]

---

### 3. Business Validation

[Content varies by project type—adapt from Theme 3 validation]

**For Business/Product Projects**:

**Market Fit**:
- Target market: [Who would pay]
- Value proposition: [Why they'd pay]
- Pricing considerations: [How much]
- Market size: [Potential customers]

**Competitive Positioning**:
- Existing alternatives: [What else is out there]
- Differentiation: [How we're different]
- Competitive advantage: [Why choose us]

**Business Case**:
- Revenue potential: [Expected value]
- Strategic alignment: [Business goals]
- Risks: [Known concerns]

**For Internal Tool Projects**:

**Organizational Value**:
- Benefiting teams: [Who uses this]
- Efficiency gains: [Productivity improvements]
- ROI estimate: [Cost savings or value]

**Adoption Considerations**:
- User adoption: [Will teams use it?]
- Training needs: [What's required]
- Integration: [Existing tools/workflows]
- Rollout plan: [How to deploy]

**For Personal/Side Projects**:

**Personal Value**:
- Why this matters: [Personal motivation]
- Learning goals: [Skills to develop]
- Problem it solves: [Your use case]

[Business validation skipped for personal projects]

**For Open Source Projects**:

**Community Value**:
- Target community: [Who needs this]
- Problem addressed: [Community pain point]
- Ecosystem fit: [How it fits existing tools]

**Contributor Appeal**:
- Contribution potential: [Will others help?]
- Scope manageability: [Is it feasible?]
- Similar projects: [Alternatives in ecosystem]

**Risks & Considerations**: [All project types]

[Document known risks, open questions, dependencies, constraints, uncertainties]

---

### 4. Estimated Scope

*Note: This is a product-level estimate based on discovery conversation, not technical analysis. The Software Architect will provide detailed technical estimates during planning.*

**Complexity Assessment**: [Simple / Medium / Complex]

[Explain why this complexity level based on discovery insights]

**Estimated Effort**:

[Choose one based on product assessment]
- **Small** (< 3 days): [Reasoning]
- **Medium** (1-2 weeks): [Reasoning]
- **Large** (2+ weeks): [Reasoning]
- **Unknown** (needs technical investigation): [Why uncertain]

**Key Unknowns**:

[Technical uncertainties identified during discovery]
- [Unknown 1, e.g., "API rate limits unclear"]
- [Unknown 2, e.g., "Database schema changes needed?"]
- [Unknown 3, e.g., "Third-party service reliability"]

**Dependencies**:

[External factors this feature depends on]
- [Dependency 1, e.g., "Requires updated authentication system"]
- [Dependency 2, e.g., "Needs integration with Payment API"]
- [Dependency 3, e.g., "Blocked until User Profiles v2 ships"]

**Assumptions**:

[Key assumptions made during estimation]
- [Assumption 1, e.g., "Existing UI components can be reused"]
- [Assumption 2, e.g., "No major database migration required"]

---

### 5. Recommendation

**Decision**: [PROCEED / PIVOT / STOP]

**Rationale**: [Why this recommendation]

[Explain the reasoning behind the recommendation based on discovery findings]

**Next Steps**:

[For PROCEED]
- Review and approve this Product Brief
- Optionally translate to user stories (Stage 2)
- Begin technical planning with task-preparation skill
- Use: "use task preparation for [feature]"

[For PIVOT]
- Review pivot rationale
- Decide on new direction
- Restart discovery with updated focus
- Or pause for offline clarification

[For STOP]
- Review learnings captured here
- Consider alternative approaches offline
- Re-engage when direction is clearer

---

### Discovery History

[Only include if pivots occurred]

**Initial Direction**: [Original idea]

[Brief description of where we started]

**Pivot #1**: [Timestamp]

Changed from: [Old direction]
Changed to: [New direction]
Reason: [Why pivot happened]

**Pivot #2**: [Timestamp] [if applicable]

Changed from: [Previous direction]
Changed to: [Current direction]
Reason: [Why second pivot happened]

**Final Direction**: [Current approach]

[Summary of final validated direction]

---

## User Stories

[This section is empty after Stage 1]
[Populated in Stage 2 if user chooses to translate to user stories]
[If user skips Stage 2, this section remains empty]

*To add user stories: Continue to Product Manager translation (Stage 2)*

---

*End of Product Brief*
```

**Special Handling for STOP Recommendation**:

If user chose STOP at Checkpoint #4, modify template:
- Status: "Not Viable"
- Section 2 (Solution Vision): Include attempted solution for reference
- Section 3 (Business Validation): Emphasize why not viable
- Section 4 (Scope): Mark as "Not Estimated - Not Viable"
- Section 5 (Recommendation): Emphasize learnings and alternative paths
- Add "Learnings" subsection to capture valuable insights

#### Step 1.8: Save Product Brief

Write Product Brief to file system:

```javascript
Write({
  file_path: briefPath, // from Step 1.6
  content: [generated Product Brief markdown]
})
```

**Update task metadata**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  metadata: {
    phase: "brief-created",
    outputFiles: [briefPath]
  }
})
```

#### Step 1.9: Product Brief Review & Stage 2 Decision

**APPROVAL CHECKPOINT #6** - Product Brief Review & Stage 2 Choice (CRITICAL GATE)

Present the Product Brief for review and ask about Stage 2:

```
I've created the Product Brief and saved it to: [file path]

Please review the key sections:

**User Problem**: [1-sentence summary]
**Solution Vision**: [1-sentence summary]
**Recommendation**: [PROCEED/PIVOT/STOP]

[For PROCEED recommendation]
The brief is ready for technical planning. Now you have a choice:

What would you like to do next?

A) Continue to user stories (Stage 2: ~10-15 minutes)
   → I'll translate this brief into actionable user stories
   → Stories include acceptance criteria
   → Output integrates with task-preparation skill
   → Recommended for medium/complex features

B) Skip user stories - brief is sufficient
   → Product Brief is enough for now
   → Developer/architect can work from brief directly
   → Good for simple features or if you'll write stories later

C) Request modifications to brief
   → Make changes to any section
   → Re-present for review
   → Continue when ready

D) Pause and resume later
   → Save progress and exit
   → Resume discovery when ready
   → Task remains available

[For STOP recommendation]
Product Brief documents the learnings from our discovery. Since the recommendation is STOP, I won't proceed to user stories.

What would you like to do?

A) Accept and exit
   → Brief documents why not viable
   → Learnings captured for future reference

B) Request modifications
   → Adjust the assessment
   → Consider alternative framing

C) Override to PROCEED
   → Continue despite concerns
   → Option to do Stage 2

[For PIVOT recommendation - rare at this point]
Since we've recommended PIVOT, would you like to:

A) Accept and restart discovery
B) Override to PROCEED anyway
C) Convert to STOP
```

**Handle User Choice**:

**Choice A (Continue to Stage 2)**:
- Proceed to Stage 2 Procedure (Section: Stage 2)
- Keep task active

**Choice B (Skip Stage 2)**:
- Add note to brief that Stage 2 skipped
- Proceed to Step 1.10 (Wrap Up)

**Choice C (Modifications)**:
- Ask what to change
- Update Product Brief
- Re-write file
- Return to this checkpoint

**Choice D (Pause)**:
- Update task status to "pending"
- Add metadata: `{ paused: true, pausedAt: "stage-1-complete" }`
- Exit skill gracefully
- User can resume later

#### Step 1.10: Wrap Up Stage 1 (if Stage 2 skipped)

**If user chose to skip Stage 2**:

1. **Mark task as completed**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  status: "completed",
  metadata: {
    phase: "completed",
    stage: 1,
    recommendation: "PROCEED" | "STOP",
    skippedStage2: true
  }
})
```

2. **Suggest next steps**:

```
✅ Product discovery (Stage 1) complete!

Output: [file path]

Next steps:

For technical planning:
→ "use task preparation for [feature]"
→ Task-preparation will read the Product Brief and create implementation plan

For direct implementation (simple features):
→ Share Product Brief with developer
→ Developer can implement from Solution Vision and Scope sections

For adding user stories later:
→ "translate product brief to user stories: [file path]"
→ Runs Stage 2 translation on existing brief

---

*Product discovery skill exiting. Good luck with [feature]!*
```

3. **Exit skill**

**If user chose to continue to Stage 2**:
- Do NOT wrap up
- Proceed directly to Stage 2 Procedure

---

## Stage 2: Product Manager Translation (OPTIONAL)

**Duration**: 10-20 minutes
**Purpose**: Convert validated Product Brief into actionable user stories with acceptance criteria
**Approval Gates**: 3 total (2 lightweight, 1 critical)

**Entry Conditions**:
- User chose to continue from Stage 1 (Checkpoint #6), OR
- User invoked translation-only mode with existing brief path

### Procedure

#### Step 2.1: Load Product Manager Role & References

**Load role definition**:
```javascript
Read({ file_path: "~/.claude/roles/product-manager.md" })
```

**Load story patterns reference**:
```javascript
Read({ file_path: "~/.claude/skills/product-discovery/references/story-patterns.md" })
```

**If files missing**: Use inline Product Manager guidance, warn user files not found.

**Announce role switch**:
```
I'm now switching to Product Manager to translate this brief into actionable user stories. I'll focus on user value, write clear acceptance criteria, and prioritize for implementation.
```

**Apply Product Manager mindset**:
- Story-driven and outcome-focused
- Clear and structured communication
- Scope-conscious (MVP vs nice-to-have)
- Testable acceptance criteria
- Implementation-ready tasks

**Update task metadata**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  metadata: {
    phase: "translation",
    stage: 2
  }
})
```

#### Step 2.2: Review Product Brief (Internal)

**Load Product Brief**:

**If coming from Stage 1**:
- Product Brief already in memory
- briefPath from Stage 1

**If translation-only mode**:
- User provided brief path
- Read file:
  ```javascript
  Read({ file_path: "[user-provided-path]" })
  ```

**Validate brief has required sections**:
- Section 1: User Problem & Context
- Section 2: Solution Vision
- Section 3: Business Validation
- Section 5: Recommendation

**If missing sections**:
```
This Product Brief is missing required sections:
[List missing sections]

A well-formed Product Brief needs these sections for translation to user stories. Would you like me to:

A) Attempt translation with available information
B) Help you complete the Product Brief first
C) Exit and fix the brief manually
```

**If brief is complete**:
- Internalize key information:
  - Target users (Section 1)
  - Problem being solved (Section 1)
  - Solution vision (Section 2)
  - Key features (Section 2)
  - User journey (Section 2)
  - Project type (header metadata)
- Proceed to Step 2.3

#### Step 2.3: Define MVP Scope

Analyze features from Section 2 (Key Features) and determine prioritization.

**Prioritization Criteria**:

**Must-have (Phase 1 / MVP)**:
- Essential for delivering core user value
- Solves the main user problem
- Part of the minimum viable user journey
- Dependency for other features
- High user impact

**Nice-to-have (Phase 2+)**:
- Valuable but deferrable
- Enhancement to core functionality
- Lower user impact
- Can be added iteratively
- Not blocking other features

**Consider**:
- Minimum viable functionality (what's truly required?)
- User value vs. implementation complexity
- Dependencies between features (prerequisites?)
- Risk mitigation (start simple, add later)

**APPROVAL CHECKPOINT #7** - MVP Scope Definition

Present prioritization to user:

```
I've analyzed the features and propose this MVP scope:

**Must-have (Phase 1 / MVP)**:
1. [Feature Name]: [Why essential - core value, dependency, critical user need]
2. [Feature Name]: [Why essential]
3. [Feature Name]: [Why essential]

**Nice-to-have (Phase 2+)**:
1. [Feature Name]: [Why deferrable - enhancement, lower priority, can add later]
2. [Feature Name]: [Why deferrable]

**Rationale**:
[Explain the thinking - minimum viable user journey, risk mitigation, dependency order]

Does this prioritization work for you?

[Allow user to confirm or adjust]
```

**Handle user feedback**:
- Confirm → Proceed to Step 2.4
- Move features → Adjust priorities, re-present
- Add features → Discuss and categorize, re-present
- Remove features → Update scope, re-present

This is a **lightweight gate** - quick adjustment expected.

**Store MVP scope**:
```javascript
{
  mvpFeatures: ["feature1", "feature2", ...],
  phase2Features: ["feature3", "feature4", ...]
}
```

#### Step 2.4: Write User Stories

For each **must-have feature** (MVP scope), create one or more user stories.

**User Story Format** (from story-patterns.md):

```markdown
### Story [N]: [Clear, Concise Title]

**As a** [specific user type/persona]
**I want** [specific goal/capability/action]
**So that** [clear benefit/value/outcome]

**Context**: [Why this story matters, additional background, connection to product brief]

**Priority**: High / Medium / Low

**Dependencies**: [List other story IDs this depends on, if any. Use "None" if independent]
```

**Writing Guidelines**:

- **User-focused**: Frame from user's perspective, not technical implementation
- **Specific**: Concrete goal, not vague aspiration
- **Valuable**: Clear benefit in "so that" clause
- **Sized appropriately**: Should be implementable in reasonable time (if too large, split)
- **Independent where possible**: Minimize dependencies for parallel work
- **Context-rich**: Reference product brief, explain why it matters

**Example**:
```markdown
### Story 1: User Login with Email and Password

**As a** returning customer
**I want** to log in with my email and password
**So that** I can access my account and order history

**Context**: This is the foundational authentication story from the Product Brief's Solution Vision. It enables users to access personalized features and maintains account security.

**Priority**: High

**Dependencies**: None
```

**Splitting Stories**:

If a feature is too large for a single story, split by:
- **Workflow steps**: Separate creation, editing, deletion
- **User types**: Different personas with different needs
- **CRUD operations**: Create, Read, Update, Delete as separate stories
- **Complexity layers**: Basic functionality first, advanced features later

**Story Numbering**:
- Number sequentially: Story 1, Story 2, Story 3...
- Reference dependencies by number: "Dependencies: Story 1, Story 2"

**Typical Story Count**:
- Simple feature: 1-3 stories
- Medium feature: 3-7 stories
- Complex feature: 8-15 stories

#### Step 2.5: Define Acceptance Criteria

For each user story, add testable acceptance criteria.

**Acceptance Criteria Format**:

```markdown
**Acceptance Criteria**:
- [ ] [Success condition 1 - what "done" looks like]
- [ ] [Success condition 2 - another success scenario]
- [ ] [Edge case handling - what happens in non-happy-path]
- [ ] [Error scenario - what happens when things go wrong]
- [ ] [Performance/quality requirement if relevant]
```

**Writing Guidelines**:

- **Testable**: Clear pass/fail criteria (can verify "done")
- **Specific**: Concrete, not vague ("User sees confirmation message" not "Good UX")
- **Complete**: Covers success paths AND error handling
- **Checkboxes**: Use `- [ ]` format for tracking during implementation
- **Non-technical**: Focus on behavior, not implementation details

**What to Include**:

1. **Primary success scenarios**: What happens when things work correctly
2. **Edge cases**: Boundary conditions, empty states, maximum values
3. **Error handling**: What happens when operations fail, validation errors
4. **User feedback**: Confirmations, error messages, loading states
5. **Data validation**: Input requirements, format checks
6. **Performance** (if relevant): Response time, load handling

**Example**:
```markdown
**Acceptance Criteria**:
- [ ] User can enter email and password in login form
- [ ] System validates email format and displays error if invalid
- [ ] Successful login redirects user to dashboard
- [ ] Failed login displays clear error message without exposing security details
- [ ] Login form shows loading state during authentication
- [ ] "Remember me" option persists session for 30 days
- [ ] User can navigate to "Forgot Password" flow from login page
- [ ] System prevents brute force attacks with rate limiting
```

**Common Pitfalls to Avoid**:
- ❌ Vague: "System works correctly"
- ❌ Technical: "POST request to /api/login returns 200"
- ❌ Implementation: "Use JWT tokens for authentication"
- ✅ Good: "User sees confirmation message after successful login"

#### Step 2.6: Review & Iterate User Stories

**APPROVAL CHECKPOINT #8** - User Stories Review

Present all user stories with acceptance criteria:

```
I've created [N] user stories for the MVP scope:

**Summary**:
- Story 1: [Title] - [1 sentence description]
- Story 2: [Title] - [1 sentence description]
- Story 3: [Title] - [1 sentence description]
[... list all stories]

**Dependencies**:
[If any dependencies exist, show the dependency graph]

[Optionally show 1-2 full stories as examples]

What would you like to do?

A) Approve these stories
   → Continue to prioritized task list
   → Finalize output

B) Request modifications
   → Add new stories
   → Remove stories
   → Change acceptance criteria
   → Adjust priorities

C) Need more detail on specific stories
   → Show full story with criteria
   → Explain rationale
```

**Handle user feedback**:

**Choice A (Approve)**:
- Proceed to Step 2.7

**Choice B (Modifications)**:
- Ask what to change
- Make updates:
  - Add stories: Follow Step 2.4-2.5 for new stories
  - Remove stories: Delete and renumber if needed
  - Change criteria: Update acceptance criteria
  - Adjust priorities: Update priority field
- Re-present at this checkpoint

**Choice C (Details)**:
- Show requested stories in full
- Explain rationale
- Return to choice prompt

This is a **lightweight gate** - iteration expected.

#### Step 2.7: Create Prioritized Task List

Break user stories into architect-ready tasks for handoff to task-preparation skill.

**Task List Format**:

```markdown
## Prioritized Task List for Architect

These tasks are ready for technical planning. Use task-preparation skill for detailed implementation planning.

### High Priority (Must-have / Phase 1)

**Task 1: [Task Title]**
- **Description**: [What needs to be built]
- **User Stories**: Story #1, Story #2
- **Complexity**: Simple / Medium / Complex
- **Notes**: [Any technical hints from discovery, dependencies, or considerations]

**Task 2: [Task Title]**
- **Description**: [What needs to be built]
- **User Stories**: Story #3
- **Complexity**: Medium
- **Notes**: [Notes]

### Medium Priority (Nice-to-have / Phase 2+)

**Task 3: [Task Title]**
- **Description**: [What needs to be built]
- **User Stories**: Story #4, Story #5
- **Complexity**: Simple
- **Notes**: [Notes]

### Dependencies

[If applicable, list task dependencies]
- Task 2 depends on Task 1 completion
- Task 3 can proceed in parallel with Task 2
- Task 4 blocked until external API integration complete

### Notes for Technical Planning

[Additional context for the architect]
- [Technical consideration from discovery]
- [Known constraint or requirement]
- [Integration point or dependency]
```

**Task Creation Guidelines**:

- **Group related stories**: Combine stories that belong to same technical component
- **Logical boundaries**: Tasks should align with architectural components
- **Reasonable size**: Each task should be plannable (not too large, not too granular)
- **Clear descriptions**: Architect should understand what to build
- **Complexity hints**: Based on product assessment, not technical analysis

**Complexity Assessment** (product perspective):
- **Simple**: Single story, straightforward functionality, minimal unknowns
- **Medium**: Multiple stories, some complexity, few unknowns
- **Complex**: Many stories, significant functionality, multiple unknowns

**Typical Task Count**:
- Simple feature: 1-2 tasks
- Medium feature: 2-4 tasks
- Complex feature: 4-8 tasks

#### Step 2.8: Append to Product Brief or Save Separately

Based on user's choice in Stage 1 (Checkpoint #5), either append to existing file or create new file.

**If Single File Mode** (append to existing Product Brief):

1. **Read existing brief**:
   ```javascript
   Read({ file_path: briefPath })
   ```

2. **Locate "## User Stories" section** (should be empty after Stage 1)

3. **Replace empty section with full content**:

```markdown
---

## User Stories

*Translated from Product Brief*
*Generated: [YYYY-MM-DD HH:MM timezone]*

### Requirements Summary

**Core Requirements**:
- [Requirement 1 extracted from Solution Vision]
- [Requirement 2]
- [Requirement 3]

**User Experience Requirements**:
- [UX requirement 1]
- [UX requirement 2]

**Technical Considerations** (from Estimated Scope section):
- [Known constraint or dependency]
- [Integration point]
- [Unknown that architect should investigate]

**Success Criteria**:
- [Measurable outcome 1 from Business Validation]
- [Measurable outcome 2]

---

### MVP Scope

**Must-have (Phase 1 / MVP)**:
- [Feature 1]: [Rationale]
- [Feature 2]: [Rationale]
- [Feature 3]: [Rationale]

**Nice-to-have (Phase 2+)**:
- [Feature 4]: [Rationale]
- [Feature 5]: [Rationale]

---

### User Stories

[All user stories with acceptance criteria from Step 2.4-2.5]

Story 1: [Title]
[Full story content]

Story 2: [Title]
[Full story content]

[Continue for all stories...]

---

### Prioritized Task List

[Task list from Step 2.7]

---

### Integration Contract for task-preparation

This document is ready for technical planning.

**How to use with task-preparation**:

1. Read "Requirements Summary" for quick context
2. Review "User Stories" section for detailed requirements
3. Reference "Prioritized Task List" for suggested work breakdown
4. Use: `"use task preparation for [feature]"`

**What task-preparation receives**:
- Complete Product Brief (Sections 1-5)
- User Stories with acceptance criteria
- Prioritized task list with complexity hints
- All discovery insights and validation

**Expected workflow**:
1. task-preparation reads this document
2. Software Architect creates technical implementation plan
3. Plan references user stories for requirements
4. Implementation verified against acceptance criteria

---

*End of User Stories Section*
```

4. **Write updated file**:
   ```javascript
   Edit({
     file_path: briefPath,
     old_string: "## User Stories\n\n[This section is empty after Stage 1]...",
     new_string: "[Full User Stories section content]"
   })
   ```

**If Separate Files Mode** (create new stories file):

1. **Create new file** at storiesPath (from Stage 1 Step 1.6)

2. **Content**:

```markdown
# User Stories: [Feature Name]

*Translated from Product Brief: [brief-file-name.md]*
*Generated: [YYYY-MM-DD HH:MM timezone]*

[Same content as above: Requirements Summary, MVP Scope, User Stories, Task List, Integration Contract]

---

**Related Document**: [Link to Product Brief]

See [brief-file-name.md] for complete product context including user problem, solution vision, and business validation.

---

*End of User Stories Document*
```

3. **Write file**:
   ```javascript
   Write({
     file_path: storiesPath,
     content: "[Full content]"
   })
   ```

**If Translation-Only Mode** (no brief path from Stage 1):

Default to creating separate stories file in same directory as input brief:
- Input: `/path/to/feature-brief.md`
- Output: `/path/to/feature-stories.md`

**Update task metadata**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  metadata: {
    outputFiles: [briefPath, storiesPath] // or just briefPath if single file
  }
})
```

#### Step 2.9: Final Output Review

**APPROVAL CHECKPOINT #9** - Final Output Approval (CRITICAL GATE)

Present complete output for final review:

```
User stories complete! Here's what I've created:

**Output Files**:
- [File path 1]
[- File path 2 if separate files]

**Summary**:
- [N] user stories created
- [M] must-have (Phase 1), [K] nice-to-have (Phase 2)
- [P] prioritized tasks for architect
- Acceptance criteria defined for all stories
- Integration contract included for task-preparation

**MVP Scope**:
- [Feature 1], [Feature 2], [Feature 3]

**Next Steps**:
Ready for technical planning with task-preparation skill

---

What would you like to do?

A) Approve - ready for architect
   → Stories are final
   → Proceed to technical planning
   → Output saved and complete

B) Request final modifications
   → Adjust stories or criteria
   → Change prioritization
   → Add/remove content

C) Add more user stories
   → Expand scope
   → Cover additional scenarios
   → Add Phase 2 stories
```

**Handle user choice**:

**Choice A (Approve)**:
- Proceed to Step 2.10 (Wrap Up)

**Choice B (Modifications)**:
- Ask what to change
- Make updates
- Re-write files
- Return to this checkpoint

**Choice C (Add Stories)**:
- Ask what to add
- Follow Step 2.4-2.5 for new stories
- Update files
- Return to this checkpoint

This is a **CRITICAL GATE** - final approval before completion.

#### Step 2.10: Wrap Up Stage 2

1. **Mark task as completed**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  status: "completed",
  metadata: {
    phase: "completed",
    stage: 2,
    recommendation: "PROCEED",
    nextSteps: "Use task-preparation with user stories"
  }
})
```

2. **Present completion message**:

```
✅ Product discovery complete!

**Outputs created**:
- Product Brief: [file path]
[- User Stories: [file path] if separate]

**What you have**:
- Complete Product Brief with user problem, solution vision, and validation
- [N] user stories with acceptance criteria
- Prioritized task list for architect
- Integration contract for task-preparation

**Next steps**:

→ For technical planning:
  "use task preparation for [feature]"

  task-preparation will:
  - Read the Requirements Summary for quick context
  - Use User Stories as detailed requirements
  - Reference Prioritized Task List for work breakdown
  - Create technical implementation plan

→ For direct implementation (simple features):
  Share user stories with developer
  Developer implements against acceptance criteria

---

*Product discovery skill complete. Good luck with [feature]!*
```

3. **Exit skill**

---

## Translation-Only Mode (Stage 0 Variant)

**Entry**: User invokes with existing Product Brief file path

**Invocation Patterns**:
- `"translate product brief to user stories: [path]"`
- `"convert product brief: [path]"`
- `"user stories from brief: [path]"`

### Procedure

#### Step T.1: Detect Translation-Only Mode

Check user invocation for:
- File path provided
- Keywords: "translate", "convert", "brief to stories"

If detected:
- Set mode: `translation-only`
- Extract briefPath from user message
- Skip to Step T.2

#### Step T.2: Validate Brief File Exists

```javascript
Read({ file_path: briefPath })
```

**If file not found**:
```
I couldn't find the Product Brief at: [path]

Please check:
- File path is correct
- File exists
- You have read permissions

Or use full discovery mode: "use product discovery for [feature]"
```
Exit skill.

**If file found**:
- Continue to Step T.3

#### Step T.3: Validate Brief Format

Check that brief contains required sections:
- Section 1: User Problem & Context
- Section 2: Solution Vision
- Section 3: Business Validation (or equivalent)
- Section 5: Recommendation

**If sections missing**:
```
This Product Brief is missing required sections for translation:
[List missing sections]

A well-formed Product Brief needs:
- Section 1: User Problem & Context
- Section 2: Solution Vision
- Section 3: Business Validation
- Section 5: Recommendation

Would you like me to:

A) Attempt translation with available information
   → May result in incomplete user stories

B) Exit so you can complete the brief
   → Run full discovery: "use product discovery for [feature]"

C) Help you complete the brief interactively
   → Fill in missing sections through conversation
```

Handle choice and proceed accordingly.

**If brief is complete**:
- Continue to Step T.4

#### Step T.4: Create Task for Translation

```javascript
TaskCreate({
  subject: "Translate product brief to user stories: [feature]",
  description: "Translation-only mode - converting existing Product Brief to user stories",
  activeForm: "Translating product brief: [feature]",
  metadata: {
    skill: "product-discovery",
    mode: "translation-only",
    phase: "translation",
    stage: 2,
    skippedStage: 1,
    reason: "existing-brief-provided",
    inputFile: briefPath,
    startTime: "[ISO timestamp]"
  }
})
```

Set to in_progress:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  status: "in_progress"
})
```

#### Step T.5: Brief User

```
Translation-only mode: I'll convert your Product Brief into user stories with acceptance criteria.

Input: [briefPath]
Estimated time: ~10-15 minutes
Approval gates: 3

Loading Product Manager role...
```

#### Step T.6: Jump to Stage 2

Proceed directly to **Stage 2: Product Manager Translation**
- Start at Step 2.1 (Load PM Role)
- Brief already loaded from Step T.2
- Follow Stage 2 procedure normally
- Exit after Step 2.10

---

## Approval Gates Summary

**Total: 9 approval checkpoints**

### Stage 1: Product Owner Discovery (6 gates)

1. **Problem Understanding** (Lightweight) - Step 1.3
   - Quick check on problem summary
   - Iteration expected

2. **Solution Visualization** (Lightweight) - Step 1.3
   - Validate solution vision
   - Refinement expected

3. **Validation Theme** (Lightweight) - Step 1.3
   - Confirm business/organizational validation
   - May be partial at this stage

4. **Viability Recommendation** (CRITICAL) - Step 1.5
   - PROCEED / PIVOT / STOP decision
   - Most important gate
   - Determines next steps

5. **File Location Preference** (Decision Point) - Step 1.6
   - Choose output format
   - Configuration choice

6. **Product Brief Review & Stage 2 Choice** (CRITICAL) - Step 1.9
   - Approve Product Brief content
   - Decide whether to continue to Stage 2
   - Major decision point

### Stage 2: Product Manager Translation (3 gates)

7. **MVP Scope** (Lightweight) - Step 2.3
   - Confirm must-have vs nice-to-have
   - Quick prioritization check

8. **User Stories Review** (Lightweight) - Step 2.6
   - Validate stories and criteria
   - Iteration expected

9. **Final Output** (CRITICAL) - Step 2.9
   - Final approval before completion
   - Last chance for changes

### Gate Types

**Critical Gates** (4 total):
- Require explicit approval with options
- Major decision points
- Clear consequences
- Gates: #4, #6, #9

**Lightweight Gates** (5 total):
- Quick validation checkpoints
- Iteration encouraged
- Fast approval expected
- Gates: #1, #2, #3, #5, #7, #8

---

## Role Integration

### Stage 1: Product Owner Role

**When**: Start of Stage 1 (Step 1.1)

**Load**:
```javascript
Read({ file_path: "~/.claude/roles/product-owner.md" })
Read({ file_path: "~/.claude/skills/product-discovery/references/discovery-questions.md" })
```

**Announce**:
```
I'm now acting as Product Owner to explore this idea with you.
```

**Perspective Applied**:
- Empathetic and user-centric
- Exploratory and curious
- Creative solution-oriented
- Gently challenging
- Focused on user value

**If role file missing**:
Use inline guidance:
```
[Acting as Product Owner]
- Focus on understanding user needs
- Ask WHO/WHAT/WHY/WHEN/WHERE/HOW questions
- Explore problem space thoroughly
- Validate solution addresses real user need
- Consider business viability

[Warning: product-owner.md not found, using inline guidance]
```

### Stage 2: Product Manager Role

**When**: Start of Stage 2 (Step 2.1)

**Load**:
```javascript
Read({ file_path: "~/.claude/roles/product-manager.md" })
Read({ file_path: "~/.claude/skills/product-discovery/references/story-patterns.md" })
```

**Announce**:
```
I'm now switching to Product Manager to translate this brief into actionable user stories.
```

**Perspective Applied**:
- Story-driven and outcome-focused
- Clear and structured
- Scope-conscious (MVP thinking)
- Testable criteria focused
- Implementation-ready

**If role file missing**:
Use inline guidance:
```
[Acting as Product Manager]
- Translate requirements to user stories
- Write clear acceptance criteria
- Prioritize for MVP
- Focus on user value and outcomes
- Create testable, implementable stories

[Warning: product-manager.md not found, using inline guidance]
```

---

## Edge Cases & Special Handling

### Edge Case 1: Translation-Only Mode

**Trigger**: User provides existing brief path

**Behavior**:
- Skip Stage 0 complexity assessment
- Skip Stage 1 entirely
- Load brief and validate format
- Jump directly to Stage 2
- Follow normal Stage 2 procedure
- Update metadata: `{ skippedStage: 1, reason: "existing-brief-provided" }`

**See**: Translation-Only Mode section for detailed procedure

### Edge Case 2: STOP Recommendation

**Trigger**: Discovery reveals idea is not viable

**Behavior**:
- Explain rationale clearly and respectfully
- Document learnings in Product Brief
- Set Status: "Not Viable"
- Modify Product Brief template:
  - Include attempted solution for reference
  - Emphasize why not viable in Section 3
  - Section 4 Scope: "Not Estimated - Not Viable"
  - Section 5: Emphasize learnings
  - Add "Learnings" subsection
- Suggest pivot options if within limit
- Mark task completed: `{ recommendation: "STOP" }`
- Exit gracefully with emphasis on learning value

**Messaging**:
```
Based on our discovery, I recommend STOP for these reasons:
[Clear, respectful explanation]

This doesn't mean the idea is bad—it means:
[Reframe positively: needs different approach, timing, scope, etc.]

Learnings captured:
[What we discovered that's valuable]

Would you like to:
A) Accept and document learnings
B) Pivot to different approach [if count < 2]
C) Continue exploring despite concerns
```

### Edge Case 3: PIVOT Scenario

**Trigger**: Discovery reveals current direction won't work but alternative exists

**Behavior**:
- Document current findings in notes
- Identify what's changing (problem/solution/user)
- Return to discovery themes with new direction
- Increment pivot counter: `pivotCount++`
- **Enforce max 2 pivots per session**
- Track pivot history in metadata

**Pivot Tracking**:
```javascript
{
  pivotCount: 2,
  pivotHistory: [
    {
      from: "Initial direction description",
      to: "New direction after first pivot",
      reason: "Rationale for pivot",
      timestamp: "2026-01-28T10:30:00Z"
    },
    {
      from: "First pivot direction",
      to: "Second pivot direction",
      reason: "Rationale for second pivot",
      timestamp: "2026-01-28T11:15:00Z"
    }
  ]
}
```

**Max Pivot Enforcement**:
```
We've already pivoted [N] times:

Pivot 1: Changed from [X] to [Y] because [reason]
Pivot 2: Changed from [Y] to [Z] because [reason]

This suggests the idea needs more offline clarification before discovery can be productive.

Your options:
A) Continue with current direction ([Z])
B) Keep exploring this direction (ask more questions)
C) Stop and clarify offline
D) Pause and resume later

[Do NOT offer additional pivot option]
```

**Include in Product Brief**:
- Section: "Discovery History"
- Document all pivots with rationale
- Show progression from initial to final direction

### Edge Case 4: Messy Discovery Conversation

**Trigger**: User jumps between topics, revisits ideas, iterates frequently

**Behavior**: This is EXPECTED and ENCOURAGED

**Handling**:
- Embrace the messiness
- Allow jumping between themes
- Don't force linear structure
- Circle back to fill gaps when natural
- Validate understanding frequently
- Use checkpoints to consolidate learning
- Document learnings even from rejected ideas

**Mindset**: Discovery is inherently exploratory and non-linear. Fluid conversation = deep understanding.

### Edge Case 5: User Pauses Mid-Discovery

**Trigger**: User needs to pause during discovery

**Behavior**:
- Update task status appropriately
- Save any partial progress in metadata
- Document where we stopped
- Provide resume instructions

**Pause Handling**:
```javascript
TaskUpdate({
  taskId: "[task-id]",
  status: "pending",
  metadata: {
    paused: true,
    pausedAt: "stage-1-checkpoint-3", // or specific step
    partialFindings: {
      problemUnderstanding: "[Summary of what we know]",
      solutionDirection: "[Current thinking]",
      questionsRemaining: ["Question 1", "Question 2"]
    }
  }
})
```

**Resume Message**:
```
Paused product discovery at [checkpoint/step].

To resume:
- Continue this conversation: "continue product discovery"
- Start fresh: "use product discovery for [feature]"
- Translate existing brief: "translate product brief: [path]"

Current progress saved in task: [task-id]
Use /tasks to see status.
```

### Edge Case 6: Incomplete Brief in Translation-Only Mode

**Trigger**: User provides brief missing required sections

**Behavior**:
- Validate brief format at Step T.3
- Offer options: attempt anyway, exit, or help complete
- If helping complete: conduct mini-discovery for missing sections
- Use Product Owner role for discovery parts

**Messaging**: See Step T.3 in Translation-Only Mode section

### Edge Case 7: Brief Format Variations

**Trigger**: User's brief doesn't match expected template exactly

**Behavior**:
- Look for semantic equivalents:
  - "User Problem" = "Problem Statement" = "Customer Need"
  - "Solution Vision" = "Proposed Solution" = "Product Vision"
  - "Validation" = "Business Case" = "Justification"
- Extract information from available sections
- If critical info missing, ask targeted questions
- Don't be rigid about section names

---

## Task Tracking Metadata

**Simplified, essential tracking only.**

### Stage 0 (Initialization)
```javascript
{
  skill: "product-discovery",
  mode: "full-discovery" | "translation-only",
  phase: "initialization",
  complexityLevel: "quick" | "standard" | "deep",
  projectType: "business" | "internal" | "personal" | "opensource",
  stage: 0,
  startTime: "2026-01-28T10:00:00Z",
  pivotCount: 0
}
```

### Stage 1 (Discovery)
```javascript
{
  skill: "product-discovery",
  mode: "full-discovery",
  phase: "discovery",
  complexityLevel: "standard",
  projectType: "business",
  stage: 1,
  pivotCount: 0,
  pivotHistory: [], // Populated if pivots occur
  startTime: "2026-01-28T10:05:00Z"
}
```

### After Stage 1 (Brief Created)
```javascript
{
  skill: "product-discovery",
  mode: "full-discovery",
  phase: "brief-created",
  stage: 1,
  outputFiles: ["./product-briefs/feature.md"],
  recommendation: "PROCEED" | "PIVOT" | "STOP",
  startTime: "2026-01-28T10:05:00Z"
}
```

### Stage 2 (Translation)
```javascript
{
  skill: "product-discovery",
  mode: "full-discovery",
  phase: "translation",
  complexityLevel: "standard",
  projectType: "business",
  stage: 2,
  outputFiles: ["./product-briefs/feature.md"],
  startTime: "2026-01-28T10:25:00Z"
}
```

### Completion
```javascript
{
  skill: "product-discovery",
  mode: "full-discovery",
  phase: "completed",
  stage: 1 | 2, // 1 if Stage 2 skipped, 2 if completed
  outputFiles: ["./product-briefs/feature.md", "./product-briefs/feature-stories.md"],
  recommendation: "PROCEED" | "STOP",
  nextSteps: "Use task-preparation with user stories",
  skippedStage2: true | false,
  startTime: "2026-01-28T10:05:00Z",
  endTime: "2026-01-28T10:45:00Z",
  duration: "40 minutes"
}
```

### Paused State
```javascript
{
  skill: "product-discovery",
  phase: "discovery" | "translation",
  stage: 1 | 2,
  paused: true,
  pausedAt: "stage-1-checkpoint-3",
  partialFindings: {
    problemUnderstanding: "Summary",
    solutionDirection: "Current thinking",
    questionsRemaining: ["Q1", "Q2"]
  }
}
```

---

## Output Artifacts

### Product Brief Template

See **Step 1.7: Create Product Brief** for complete template.

**Key Sections**:
1. User Problem & Context
2. Solution Vision
3. Business Validation (contextual by project type)
4. Estimated Scope (NEW - product-level effort estimate)
5. Recommendation (PROCEED/PIVOT/STOP)

**Additional Sections** (if applicable):
- Discovery History (if pivots occurred)
- User Stories (if Stage 2 completed)

### User Stories Template

See **Step 2.8: Append to Product Brief or Save Separately** for complete template.

**Key Sections**:
- Requirements Summary (for architect quick scan)
- MVP Scope (must-have vs nice-to-have)
- User Stories (with acceptance criteria)
- Prioritized Task List (for architect)
- Integration Contract for task-preparation

---

## Integration Contract for task-preparation

**Output Format Guarantee**:

Product-discovery output (when Stage 2 completed) contains:

```markdown
# Product Discovery: [Feature]

## Product Brief
[5 sections: Problem, Solution, Validation, Scope, Recommendation]

## User Stories
### Requirements Summary
[Bullet list for quick architect scan]

### MVP Scope
[Must-have vs nice-to-have]

### User Stories
[Stories with acceptance criteria]

### Prioritized Task List
[Ordered tasks with complexity hints]

### Integration Contract for task-preparation
[Usage instructions]
```

**task-preparation Integration Workflow**:

```
1. User completes product-discovery:
   → Output: ./product-briefs/feature.md

2. User invokes task-preparation:
   "use task preparation for feature"

3. task-preparation behavior:
   - Look for ./product-briefs/feature.md
   - Read "Requirements Summary" (quick context)
   - Read "User Stories" section (detailed requirements)
   - Use as input for technical planning
   - Create: ./plans/feature.md

4. If User Stories missing (Stage 2 skipped):
   - Read Product Brief directly
   - Extract requirements from Solution Vision
   - Proceed with technical planning
```

**Requirements Summary Format** (for task-preparation):

```markdown
### Requirements Summary

**Core Requirements**:
- [Functional requirement 1]
- [Functional requirement 2]

**User Experience Requirements**:
- [UX requirement 1]
- [UX requirement 2]

**Technical Considerations**:
- [Known constraint or dependency]
- [Integration point]

**Success Criteria**:
- [Measurable outcome 1]
- [Measurable outcome 2]
```

**Standalone Usage** (without task-preparation):

User can also use output directly:
- Developer reads User Stories section
- Implements based on acceptance criteria
- No formal technical planning
- Appropriate for simple features

---

## Tips and Best Practices

### For Effective Discovery

**Be Open**:
- Don't filter your thoughts
- Share half-formed ideas
- Mention concerns and uncertainties
- Describe the problem even if solution is unclear

**Let Conversation Flow**:
- Jump between topics as they occur to you
- Revisit earlier points with new insights
- Don't worry about order
- Trust the process

**Embrace Iteration**:
- Expect to refine ideas multiple times
- Pivots are valuable learning
- Rejected ideas inform final direction

**Be Specific**:
- Use concrete examples
- Describe real user scenarios
- Name actual people or personas
- Provide context and details

**Challenge Assumptions**:
- Question your own assumptions
- Be open to alternative approaches
- Consider "what if" scenarios

### For Quality User Stories

**Focus on Value**:
- Every story should have clear user benefit
- "So that" clause should be meaningful
- If no value, question if it's needed

**Keep Stories Sized Right**:
- Should be implementable in reasonable time
- If too large, split by workflow or user type
- If too small, consider combining

**Make Criteria Testable**:
- Use concrete, verifiable conditions
- Cover success AND error cases
- Think about how to demo "done"

**Minimize Dependencies**:
- Independent stories = parallel work
- Dependencies create bottlenecks
- Only add dependency if truly required

### For Smooth Workflow

**Use Appropriate Complexity**:
- Quick mode for simple features (save time)
- Standard mode for most features (balanced)
- Deep mode when unknowns are significant

**Pause When Needed**:
- Discovery works best with focus
- Pause at any approval gate
- Resume when you have clarity

**Leverage Pivots Wisely**:
- First pivot: Expected exploration
- Second pivot: Signals deeper uncertainty
- At limit: Time for offline clarification

**Choose Right Output Mode**:
- Single file: Easiest for most use cases
- Separate files: Better for version control
- Custom: Match your project structure

---

## Workflow Summary

**Full Discovery Mode**:
```
Invocation → Stage 0 (Complexity) → Stage 1 (Discovery) → Product Brief
                                                              ↓
                                      Optional → Stage 2 (Translation) → User Stories
                                                                           ↓
                                                              task-preparation
```

**Translation-Only Mode**:
```
Invocation with brief path → Stage 2 (Translation) → User Stories
                                                         ↓
                                              task-preparation
```

**Approval Gate Flow**:
```
Stage 1: Problem ✓ → Solution ✓ → Validation ✓ → Viability (CRITICAL) ✓
         → File Choice ✓ → Brief Review (CRITICAL) ✓

Stage 2: MVP Scope ✓ → Stories ✓ → Final Output (CRITICAL) ✓
```

**Time Expectations**:
- Quick (Simple): 10-15 min total
- Standard (Medium): 25-35 min total
- Deep (Complex): 40-55 min total

---

## Success Criteria

Product-discovery skill is functioning correctly when:

- ✅ User can invoke: "use product discovery for [feature]"
- ✅ User can invoke translation-only: "translate product brief: [path]"
- ✅ Stage 0 shows time expectations upfront
- ✅ Stage 0 suggests complexity level (user can override)
- ✅ Business validation contextual by project type
- ✅ Stage 1 uses fluid discovery themes (not rigid)
- ✅ Product Owner role loads in Stage 1
- ✅ discovery-questions.md auto-loads in Stage 1
- ✅ Stage 2 is optional (user chooses after brief)
- ✅ Product Manager role loads in Stage 2
- ✅ story-patterns.md auto-loads in Stage 2
- ✅ Product Brief generated with 5 sections including Scope
- ✅ User Stories generated with Requirements Summary
- ✅ Output saved per user choice (single/separate/custom)
- ✅ Task tracking with simplified metadata
- ✅ All 9 approval gates work (4 critical, 5 lightweight)
- ✅ STOP scenario handled gracefully with learnings
- ✅ PIVOT limited to max 2 with tracking and history
- ✅ Integration contract defined for task-preparation
- ✅ Output integrates smoothly with task-preparation

---

*End of Product Discovery Skill Definition*
