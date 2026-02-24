# Example: Quick Feature Discovery

**Feature**: Add Dark Mode Toggle
**Complexity**: Quick (10-15 minutes)
**Project Type**: Personal/Side Project
**Outcome**: Product Brief only (Stage 2 skipped)

---

## Session Transcript (Abbreviated)

### Invocation

```
User: "use product discovery for dark mode toggle"
```

### Stage 0: Initialization

```
Claude: Quick context: What type of project is this?
        A) Business/Product
        B) Internal tool
        C) Personal/Side project
        D) Open source

User: C - Personal side project

Claude: I've analyzed "dark mode toggle" and this looks like Quick complexity.

        Characteristics:
        - Simple, focused feature
        - Clear user need
        - Straightforward solution

        Does Quick complexity sound right?

        Quick (10-15 min) - Simple feature, clear requirements
        Standard (25-35 min) - Medium feature, some exploration
        Deep (40-55 min) - Complex feature, thorough discovery

User: Yes, Quick is right

Claude: Time expectations for Quick complexity:

        Stage 1 (Product Owner Discovery): ~10-12 minutes
        - Quick conversation covering problem, solution, validation
        - 6 approval checkpoints

        Stage 2 (User Stories - optional): ~5-8 minutes
        - Translate brief into user stories

        Total: ~10-20 minutes

        You can pause at any approval gate.
        Ready to start?

User: Yes

Claude: I'll guide you through Product Owner discovery. Let's explore!
```

### Stage 1: Product Owner Discovery

```
Claude: [Product Owner role loaded]

        I'm now acting as Product Owner to explore this idea with you.
        Let's have a fluid conversation about dark mode.

        Who would use this dark mode feature?

User: Me, when I'm working on my web app at night

Claude: What problem are you experiencing when using the app at night?

User: The bright white background hurts my eyes in a dark room, and it's
      hard to focus for long periods

Claude: That makes sense. How often does this happen?

User: Pretty much every evening when I code. I often work 7pm-midnight.

Claude: What do you currently do to deal with the bright screen?

User: I've tried lowering my monitor brightness, but then the text is
      hard to read. Sometimes I use a browser extension for other sites,
      but it doesn't work well with my app.

Claude: What would the ideal dark mode experience look like for you?

User: Just a simple toggle in the header. Click it, everything switches
      to dark colors. Colors should be easy on the eyes but still readable.

Claude: How would you know if the dark mode was successful?

User: If I can work in the evening without eye strain and without
      adjusting my monitor settings.

---

[Checkpoint #1: Problem Understanding]

Claude: Let me check if I understand the problem correctly:

        WHO: You (the developer), working in evening/night
        WHAT: Bright white background causes eye strain in dark room
        WHY: Makes it hard to focus for extended coding sessions
        WHEN: Evening sessions (7pm-midnight)
        HOW: Currently use monitor brightness or browser extensions,
             neither works well

        Does this capture the core user need?

User: Yes, exactly

---

[Checkpoint #2: Solution Visualization]

Claude: Here's what I'm hearing for the solution:

        Vision: Simple dark mode toggle that switches app to
        dark color scheme

        Key Features:
        1. Toggle button in header - one click activation
        2. Dark color palette - easy on eyes, still readable
        3. Persists choice - remembers preference across sessions

        User Journey:
        - Before: User opens app in evening, bright white screen
        - During: User clicks dark mode toggle in header
        - After: App switches to dark colors, easier on eyes

        Delight Factors:
        - Instant relief from eye strain
        - No need for external tools
        - Remembers preference automatically

        Does this match your vision?

User: Yes, that's perfect. The persistence is important so I don't have
      to toggle it every time.

---

[Checkpoint #3: Validation]

Claude: Here's the validation analysis:

        For Personal/Side project:

        Personal Value:
        - Solves your immediate eye strain problem
        - Improves your evening coding experience
        - Makes the app more comfortable to use

        Learning Goals:
        - Implementing theme switching
        - CSS variables or theme systems
        - Persisting user preferences

        Scope: Seems manageable for a side project - fairly straightforward
        feature with clear requirements.

        Does this validation make sense?

User: Yes, and I've been wanting to learn about CSS variables anyway

---

[Checkpoint #4: Viability Recommendation - CRITICAL]

Claude: Based on our discovery, my recommendation: PROCEED

        Rationale:
        - Clear, validated personal need
        - Solution directly addresses problem
        - Feasible for side project
        - Good learning opportunity
        - No major technical barriers

        Key findings:
        - You experience this problem daily during evening coding
        - Current workarounds are insufficient
        - Simple solution will provide immediate value

        What would you like to do?

        A) Proceed to Product Brief
        B) Pivot to different approach
        C) Stop and document learnings
        D) Continue exploring

User: A - Proceed

---

[Checkpoint #5: File Location]

Claude: Where would you like me to save the output?

        A) Single file: ./product-briefs/dark-mode.md (recommended)
        B) Separate files: brief and stories separately
        C) Custom location

        Default: Option A (single file)

User: A is fine

Claude: [Creating Product Brief...]

---

[Checkpoint #6: Product Brief Review & Stage 2 Choice - CRITICAL]

Claude: I've created the Product Brief and saved it to:
        ./product-briefs/dark-mode.md

        Please review the key sections:

        User Problem: Eye strain from bright white background during
                      evening coding sessions

        Solution Vision: Simple header toggle that switches to dark color
                         palette with preference persistence

        Recommendation: PROCEED

        The brief is ready. Now you have a choice:

        What would you like to do next?

        A) Continue to user stories (Stage 2: ~5-8 minutes)
           → Translate brief into actionable user stories
           → Good for structured implementation

        B) Skip user stories - brief is sufficient
           → Product Brief is enough for this simple feature
           → You can implement directly from the brief

        C) Request modifications to brief

        D) Pause and resume later

User: B - The brief is enough for this simple feature

Claude: ✅ Product discovery (Stage 1) complete!

        Output: ./product-briefs/dark-mode.md

        Next steps:

        For implementation:
        → The Solution Vision section has everything you need
        → Key Features lists the capabilities to build
        → Estimated Scope section has technical considerations

        For adding user stories later (if needed):
        → "translate product brief to user stories: ./product-briefs/dark-mode.md"

        ---

        Product discovery skill complete. Good luck with dark mode!
```

---

## Output: Product Brief

**File**: `./product-briefs/dark-mode.md`

```markdown
# Product Discovery: Dark Mode Toggle

*Generated: 2026-01-28 14:30 PST*
*Complexity: Simple*
*Project Type: Personal/Side Project*
*Status: Validated*

---

## Product Brief

### 1. User Problem & Context

**Target Users**: Developer (self) working on personal web app

Primary user is the developer working on evening coding sessions, typically
7pm-midnight in a dark room environment.

**Problem Statement**: Bright white background causes eye strain during
evening coding sessions

The bright white background of the web app causes significant eye strain
when working in a dark room during evening hours. This makes it difficult
to maintain focus during extended coding sessions.

**User Context**: Evening coding sessions in dark room

Developer works on the web app regularly in the evening (7pm-midnight) in
a dark room setting. The ambient lighting is low, creating high contrast
between the bright screen and dark environment.

**Why It Matters**: Impacts comfort and productivity during evening work

Eye strain reduces comfort and makes it hard to maintain focus during
multi-hour evening coding sessions. This is a daily occurrence, affecting
productivity and enjoyment of the development work.

**Current Solutions**: Monitor brightness adjustment or browser extensions

Current workarounds include:
- Lowering monitor brightness (makes text hard to read)
- Browser extensions for dark mode (don't work well with custom web app)

Neither solution is satisfactory—both have significant drawbacks.

---

### 2. Solution Vision

**Overview**: Simple dark mode toggle with persistent preference

A header-based toggle button that instantly switches the web app to a
dark color palette. The preference is automatically saved and remembered
across sessions, so the user doesn't need to toggle it repeatedly.

**Key Features**:

1. **Header Toggle Button**: One-click activation in app header
   - User benefit: Instant, convenient access to dark mode

2. **Dark Color Palette**: Eye-friendly dark theme with good readability
   - User benefit: Reduced eye strain while maintaining text legibility

3. **Preference Persistence**: Remembers user's choice across sessions
   - User benefit: No need to re-enable dark mode on each visit

**User Journey**:

**Before using the feature**:
User opens web app in the evening and is immediately hit with bright
white background. Eyes hurt, needs to adjust monitor or suffer through it.

**During interaction**:
1. User notices dark mode toggle in header
2. Clicks toggle button
3. App instantly switches to dark color palette
4. Colors are easy on eyes, text remains readable
5. User continues coding comfortably

**After completion**:
Eye strain is eliminated. User can work comfortably for extended periods.
On next visit, dark mode is still enabled automatically.

**Delight Factors**:

- Instant relief from eye strain with single click
- No need for external tools or workarounds
- "It just remembers" - no repeated toggling
- Polished, native experience integrated into app

---

### 3. Business Validation

**For Personal/Side Projects**:

**Personal Value**:
- Solves immediate, daily eye strain problem
- Improves comfort during evening coding sessions
- Makes the app more pleasant to use
- Enables longer, more productive work sessions

**Learning Goals**:
- Implement theme switching mechanism
- Learn CSS variables or theme system architecture
- Understand preference persistence (localStorage)
- Practice user-centric feature development

[Business validation skipped for personal project]

**Risks & Considerations**:

- Need to test dark colors for sufficient contrast/readability
- Should ensure all UI elements adapt properly to dark theme
- Consider accessibility (some users need high contrast)
- Color choices matter for eye comfort

---

### 4. Estimated Scope

*Note: Product-level estimate based on discovery. Technical details to
be determined during implementation.*

**Complexity Assessment**: Simple

Simple, focused feature with clear requirements and straightforward
implementation. No complex dependencies or unknowns.

**Estimated Effort**: Small (< 3 days)

Likely implementable in a few hours to a day, depending on app size and
number of components needing theme support.

**Key Unknowns**:

- How many components need dark mode styling?
- Which CSS approach? (CSS variables, CSS-in-JS, preprocessor)
- Any third-party components that need theme support?

**Dependencies**:

- None - standalone feature

**Assumptions**:

- App has relatively simple UI (not hundreds of components)
- Modern browser environment supports localStorage
- CSS skills sufficient for color palette creation

---

### 5. Recommendation

**Decision**: PROCEED

**Rationale**:

Clear, validated personal need with daily impact. Solution directly
addresses the problem with minimal complexity. Feasible for side project
scope. Good learning opportunity for theme systems. No significant risks
or blockers.

**Next Steps**:

- Review and approve this Product Brief ✓
- Implement directly from brief (sufficient for simple feature)
- OR translate to user stories if preferred for structured approach
- Consider: Choose color palette, decide on CSS approach, implement
  toggle mechanism, add persistence

---

## User Stories

[This section is empty - user chose to skip Stage 2]

*Product Brief is sufficient for implementation of this simple feature*

---

*End of Product Brief*
```

---

## Key Takeaways

### What Worked Well

✅ **Quick complexity appropriate**: 12-minute discovery was sufficient for simple feature

✅ **Fluid conversation**: Covered all themes naturally without rigid structure

✅ **Lightweight checkpoints**: Quick validation at each step kept momentum

✅ **Skip Stage 2 decision**: Brief was sufficient; user stories would be overkill

✅ **Clear output**: Product Brief has everything needed for implementation

### Complexity Characteristics

**Quick mode (10-15 min)**:
- Simple, focused feature
- Single user (developer themselves)
- Clear problem and solution
- Minimal validation needed
- No complex dependencies

**Time breakdown**:
- Stage 0: 2 minutes
- Stage 1: 10 minutes
- Stage 2: Skipped
- **Total: 12 minutes**

### When to Use Quick Mode

Use Quick complexity for:
- Simple UI features
- Personal projects with clear needs
- Single-user scenarios
- Obvious solutions
- Minimal dependencies
- Features you've implemented before

---

*End of Quick Feature Example*
