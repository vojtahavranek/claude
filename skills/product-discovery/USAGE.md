# Product Discovery - Quick Start Guide

## What is Product Discovery?

A skill that transforms raw ideas into validated user stories through structured discovery conversations. Goes from "I have this idea..." to "Here are the user stories ready for implementation."

**Two modes**:
- **Full Discovery**: Product Owner exploration → Optional user story translation
- **Translation Only**: Convert existing Product Brief to user stories

**Not for**: Technical planning (use task-preparation) or implementation (use task-implementation)

---

## Quick Start

### Full Discovery

Start from a raw idea:

```
"use product discovery for dark mode feature"
"product discovery: payment processing"
"discover product: user notifications"
```

### Translation Only

Convert existing brief to stories:

```
"translate product brief to user stories: ./product-briefs/auth.md"
"convert product brief: ./briefs/payment-system.md"
```

### Resume from Pause

Continue where you left off:

```
"continue product discovery"
[Reference previous conversation context]
```

---

## What Happens During Discovery

### Stage 0: Initialization (2-5 min)

**What happens**:
- System detects mode (full vs translation-only)
- You specify project type (business/internal/personal/opensource)
- System suggests complexity level (quick/standard/deep)
- Time expectations set upfront
- Task tracking initialized

**Example**:
```
You: "use product discovery for collaborative whiteboard"

System: "I've analyzed this and it looks like Medium complexity.
         Expected time: ~25-35 minutes with 9 approval points.
         Ready to start?"
```

**Your input**: Confirm complexity, answer project type question

### Stage 1: Product Owner Discovery (10-35 min)

**What happens**:
- System adopts Product Owner role
- Fluid discovery conversation covering three themes:
  1. **Problem Understanding**: WHO/WHAT/WHY/WHEN/WHERE/HOW
  2. **Solution Exploration**: Vision, features, journey, delight
  3. **Validation**: Business case (contextual by project type)

**Conversation style**:
- Natural flow (jump between topics)
- Socratic questions
- Creative collaboration
- Gentle challenge of assumptions
- Iterative refinement

**Checkpoints**:
- Problem understanding summary → approve/refine
- Solution vision summary → approve/refine
- Validation assessment → approve/refine
- **Viability recommendation (CRITICAL)** → PROCEED/PIVOT/STOP
- File location choice → single file/separate/custom
- **Product Brief review (CRITICAL)** → approve/modify/skip Stage 2

**Output**: Product Brief with 5 sections:
1. User Problem & Context
2. Solution Vision
3. Business Validation (contextual)
4. Estimated Scope (NEW - product-level estimate)
5. Recommendation

**Pivot handling**:
- Up to 2 pivots allowed per session
- Pivot when direction changes fundamentally
- History tracked in Product Brief

### Stage 2: Product Manager Translation (10-20 min) - OPTIONAL

**What happens**:
- System switches to Product Manager role
- Reads Product Brief (from Stage 1 or provided file)
- Defines MVP scope (must-have vs nice-to-have)
- Writes user stories with acceptance criteria
- Creates prioritized task list for architect

**Checkpoints**:
- MVP scope approval → approve/adjust
- User stories review → approve/modify
- **Final output approval (CRITICAL)** → approve/modify/add

**Output**: User Stories section including:
- Requirements Summary (for architect quick scan)
- MVP Scope breakdown
- User Stories with acceptance criteria
- Prioritized Task List
- Integration Contract for task-preparation

---

## Approval Gates Explained

**9 total checkpoints** (4 critical, 5 lightweight)

### Critical Gates (require explicit approval)

**Gate #4: Viability Recommendation**
- Most important decision point
- Choose: PROCEED / PIVOT / STOP / Continue Exploring
- Determines next steps

**Gate #6: Product Brief Review & Stage 2 Choice**
- Approve Product Brief content
- Decide: Continue to user stories / Skip Stage 2 / Modify / Pause

**Gate #9: Final Output Approval**
- Last review before completion
- Approve final user stories and task list

### Lightweight Gates (quick validation)

**Gates #1-3, #5, #7-8**: Problem understanding, solution vision, validation, file choice, MVP scope, stories review
- Quick check-ins
- Fast iteration expected
- Keep conversation flowing

**You can pause at ANY gate** and resume later.

---

## Complexity Levels

### Quick (10-15 minutes total)

**Use for**:
- Simple, focused features
- Clear user need
- Obvious solution
- Minimal validation needed

**Examples**:
- "Add dark mode toggle"
- "Export data to CSV"
- "Add search to table"

**Discovery**:
- Cover themes lightly
- Fewer probing questions
- Focus on essentials

### Standard (25-35 minutes total)

**Use for**:
- Medium features with some unknowns
- Need to explore problem space
- Multiple solution approaches possible
- Business validation important

**Examples**:
- "Payment processing integration"
- "User notification system"
- "Dashboard with analytics"

**Discovery**:
- Balanced coverage
- Normal questioning depth
- Thorough key area exploration

### Deep (40-55 minutes total)

**Use for**:
- Complex features or systems
- Multiple user segments
- Significant unknowns
- Deep validation required

**Examples**:
- "Multi-tenant collaboration system"
- "Real-time data synchronization"
- "Advanced permission system"

**Discovery**:
- Comprehensive exploration
- Deep probing questions
- Multiple scenarios considered
- Thorough validation

**System suggests complexity** based on analysis, but **you can override**.

---

## Project Types & Business Validation

Discovery adapts validation depth to your project type:

### Business/Product
**Validation includes**:
- Market fit (who pays, why, how much)
- Competitive positioning
- Value proposition
- Revenue potential

**Use when**: Building product with paying customers

### Internal Tool
**Validation includes**:
- Organizational value
- Efficiency/productivity gains
- Adoption considerations
- ROI estimate

**Use when**: Building for company/team use

### Personal/Side Project
**Validation includes**:
- Personal value and motivation
- Learning goals
- **Skips detailed business validation**

**Use when**: Hobby, learning, experimentation

### Open Source
**Validation includes**:
- Community value
- Ecosystem fit
- Contributor appeal

**Use when**: Building for open source community

---

## Tracking Progress

### View Tasks

```bash
/tasks
```

Shows:
- Current phase and stage
- Complexity level
- Project type
- Progress through workflow
- Output files when complete

### Task Metadata

Tracks essential information:
- `mode`: full-discovery or translation-only
- `phase`: initialization, discovery, translation, completed
- `stage`: 0, 1, or 2
- `complexityLevel`: quick, standard, or deep
- `projectType`: business, internal, personal, opensource
- `pivotCount`: Number of pivots taken
- `outputFiles`: Paths to generated files
- `recommendation`: PROCEED, PIVOT, or STOP

---

## Example Session (Abbreviated)

```
You: "use product discovery for user authentication"

System: [Stage 0]
        "Quick context: What type of project?
         A) Business/Product
         B) Internal tool
         C) Personal/Side
         D) Open source"

You: "B - Internal tool"

System: "This looks like Standard complexity (25-35 min).
         Does that sound right?"

You: "Yes"

System: [Stage 1 - Product Owner]
        "I'm now acting as Product Owner.
         Let's explore this idea together.

         Who are the users who need authentication?"

You: "Internal employees accessing the admin portal"

System: "What problem are they experiencing with current access?"

You: "Currently everyone shares one admin password,
      which is insecure and we can't audit actions"

[... discovery conversation continues ...]

System: [Checkpoint #4 - Viability]
        "Based on our discovery, my recommendation: PROCEED

         Rationale: Clear security need, organizational value...

         What would you like to do?
         A) Proceed to Product Brief
         B) Pivot to different approach
         C) Stop and document learnings
         D) Continue exploring"

You: "A"

System: [Checkpoint #5]
        "Where would you like me to save the output?
         A) Single file (recommended)
         B) Separate files
         C) Custom location"

You: "A"

System: [Creates Product Brief]
        [Checkpoint #6]
        "I've created the Product Brief.

         What would you like to do?
         A) Continue to user stories (Stage 2)
         B) Skip user stories
         C) Request modifications
         D) Pause"

You: "A"

System: [Stage 2 - Product Manager]
        "I'm now switching to Product Manager.

         Here's my proposed MVP scope:
         Must-have: Login, logout, password reset
         Nice-to-have: SSO integration, 2FA

         Does this work?"

You: "Yes"

System: [Creates user stories]
        [Checkpoint #9]
        "User stories complete!
         - 5 user stories created
         - Acceptance criteria defined
         - Task list ready for architect

         What would you like to do?
         A) Approve - ready for architect
         B) Request modifications
         C) Add more stories"

You: "A"

System: "✅ Product discovery complete!

         Output: ./product-briefs/user-authentication.md

         Next steps:
         → 'use task preparation for user authentication'

         Product discovery skill complete!"
```

---

## Output File Recommendations

### Single File (Recommended)

```
./product-briefs/feature-name.md
```

**Contains**:
- Product Brief (5 sections)
- User Stories (if Stage 2 completed)
- All in one document

**Pros**:
- Easier to share
- Single source of truth
- Simpler to reference
- Less file management

**Use when**: Most situations, default choice

### Separate Files

```
./product-briefs/feature-name-brief.md
./product-briefs/feature-name-stories.md
```

**Contains**:
- Brief and stories in separate files
- Cross-referenced

**Pros**:
- Better version control
- Separate artifact evolution
- Cleaner git diffs

**Use when**: Team prefers separate artifacts, using version control extensively

### Custom Location

```
[your-specified-path]/[your-filename].md
```

**Use when**: Project has specific structure, want different naming, storing elsewhere

---

## Tips for Best Results

### Be Open and Exploratory

- Share half-formed ideas
- Don't filter thoughts
- Mention uncertainties
- Describe problem even if solution unclear

### Let Conversation Flow

- Jump between topics naturally
- Revisit earlier points with new insights
- Don't worry about order
- Trust the fluid process

### Embrace Iteration

- Refine ideas multiple times
- Pivots are valuable (up to 2)
- Rejected ideas inform final direction
- Learning happens through exploration

### Be Specific

- Use concrete examples
- Describe real user scenarios
- Name actual people/personas
- Provide context and details

### Challenge Your Assumptions

- Question your own thinking
- Be open to alternatives
- Consider "what if" scenarios
- Let Product Owner perspective guide you

### Pause When Needed

- Discovery works best with focus
- Pause at any approval gate
- Resume when you have clarity
- No penalty for pausing

### Choose Right Complexity

- Quick: Save time on simple features
- Standard: Balanced for most features
- Deep: When unknowns are significant
- Override if system's suggestion doesn't fit

### Use Pivots Wisely

- First pivot: Expected exploration
- Second pivot: Signals deeper uncertainty
- At limit: Time for offline clarification
- Pivot history captured in brief

---

## Integration with task-preparation

### Handoff Workflow

```
1. Complete product-discovery
   → Output: ./product-briefs/payment-system.md
   → Contains: Product Brief + User Stories (if Stage 2 done)

2. Invoke task-preparation
   → "use task preparation for payment system"

3. task-preparation behavior
   → Looks for ./product-briefs/payment-system.md
   → Reads "Requirements Summary" (quick context)
   → Reads "User Stories" (detailed requirements)
   → Creates technical implementation plan
   → Output: ./plans/payment-system.md

4. Implementation
   → "implement plan: ./plans/payment-system.md"
   → Step-by-step execution
```

### What Architect Receives

**From product-discovery output**:
- Complete Product Brief
  - User problem and context
  - Solution vision and key features
  - Business validation
  - Product-level scope estimate
  - Recommendation
- User Stories with acceptance criteria (if Stage 2 completed)
- Requirements Summary (for quick scanning)
- Prioritized Task List (suggested work breakdown)
- Integration Contract (usage instructions)

**Architect uses this to**:
- Understand user needs deeply
- Design technical architecture
- Create detailed implementation plan
- Reference acceptance criteria for verification

### If Stage 2 Skipped

task-preparation can still work with Product Brief only:
- Reads Product Brief directly
- Extracts requirements from Solution Vision
- Creates user stories if needed
- Proceeds with technical planning

---

## Common Questions

### When should I use product-discovery?

**Use when**:
- Raw idea needs exploration
- Requirements unclear
- Want to validate before technical work
- Novel feature without patterns
- Multiple stakeholders or users

**Don't use when**:
- Need technical planning (use task-preparation)
- Need implementation (use task-implementation)
- Clear requirements already exist
- Bug fix or simple change

### Can I skip Stage 2?

**Yes!** Stage 2 is optional.

**Skip when**:
- Product Brief sufficient for your needs
- Simple feature with clear direction
- Plan to write user stories manually later
- Want to iterate on brief first

**Do Stage 2 when**:
- Want user stories with acceptance criteria
- Medium/complex features
- Multiple developers involved
- Using task-preparation next

### What if I need to pivot?

**Pivoting is normal** and encouraged when discovery reveals better direction.

- First pivot: Expected, no concerns
- Second pivot: Signals need for deeper clarity
- After 2 pivots: System suggests offline clarification or committing to direction
- Pivot history captured in Product Brief

### How do I resume after pausing?

**Continue the conversation**:
- Reference previous discussion
- System has context from task metadata
- Picks up where you left off

**Or start fresh**:
- New invocation
- Optionally reference previous output

### What if my brief doesn't match the template?

**System is flexible**:
- Looks for semantic equivalents
- Extracts information from available sections
- Asks targeted questions if critical info missing
- Not rigid about section names

### Can I use this for non-software products?

**Yes, with adaptations**:
- Discovery themes still apply
- Validation adjusts to product type
- User stories may need different format
- Focus on user value remains central

---

## Next Steps

### After Product Discovery

**For technical planning**:
```
"use task preparation for [feature]"
```

**For direct implementation** (simple features):
- Share Product Brief with developer
- Implement from Solution Vision

**To add user stories later**:
```
"translate product brief to user stories: [path]"
```

### Learn More

**Read the full skill definition**:
```
~/.claude/skills/product-discovery/SKILL.md
```

**Reference materials**:
```
~/.claude/skills/product-discovery/references/discovery-questions.md
~/.claude/skills/product-discovery/references/story-patterns.md
```

**Examples**:
```
~/.claude/skills/product-discovery/examples/
```

**Related roles**:
```
~/.claude/roles/product-owner.md
~/.claude/roles/product-manager.md
```

**Ask Claude**:
```
"how does product discovery work?"
"what's the difference between product discovery and task preparation?"
"show me an example of product discovery output"
```

---

## Summary

**product-discovery** = Raw idea → Validated requirements

**Two modes**:
- Full Discovery (Stage 1 + optional Stage 2)
- Translation Only (Stage 2 from existing brief)

**Three complexity levels**:
- Quick (10-15 min)
- Standard (25-35 min)
- Deep (40-55 min)

**Four project types**:
- Business/Product
- Internal tool
- Personal/Side
- Open source

**Nine approval gates**:
- 4 critical decisions
- 5 lightweight check-ins

**Output**:
- Product Brief (5 sections)
- User Stories (optional, with acceptance criteria)
- Ready for task-preparation

**Use when**: Need to discover, validate, and translate user needs before technical work begins.

---

*For detailed workflow, see SKILL.md*
*For examples, see examples/ directory*
*For reference templates, see references/ directory*
