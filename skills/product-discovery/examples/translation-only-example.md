# Example: Translation-Only Mode

**Scenario**: Convert existing Product Brief to user stories
**Mode**: Translation-Only (Stage 2 only)
**Project Type**: Open Source
**Time**: 12 minutes
**Outcome**: User Stories added to existing brief

---

## Session Transcript (Abbreviated)

### Invocation

```
User: "translate product brief to user stories: ./product-briefs/plugin-api.md"
```

### Translation-Only Mode Detection

```
Claude: [Mode detection]
        - File path provided: ./product-briefs/plugin-api.md
        - Keywords detected: "translate", "product brief", "user stories"
        - Mode: translation-only
        - Skip Stage 0 and Stage 1
        - Proceed directly to Stage 2

---

[Step T.2: Validate Brief File Exists]

Claude: [Reading file: ./product-briefs/plugin-api.md]
        ✓ File found

---

[Step T.3: Validate Brief Format]

Claude: [Checking sections...]
        ✓ Section 1: User Problem & Context - Present
        ✓ Section 2: Solution Vision - Present
        ✓ Section 3: Business Validation - Present (Community Value)
        ✓ Section 5: Recommendation - Present (PROCEED)

        Brief is well-formed and ready for translation.

---

[Step T.4: Create Task]

Claude: [Task created]
        - Subject: "Translate product brief to user stories: Plugin API"
        - Mode: translation-only
        - Skipped Stage 1 (existing brief provided)

---

[Step T.5: Brief User]

Claude: Translation-only mode activated.

        I'll convert your Product Brief into user stories with acceptance
        criteria.

        Input: ./product-briefs/plugin-api.md
        Estimated time: ~10-15 minutes
        Approval gates: 3

        Loading Product Manager role...

---

[Step T.6: Jump to Stage 2]

Claude: Proceeding to Stage 2 (Product Manager Translation)...
```

---

## Stage 2: Product Manager Translation

### Product Brief Summary (What was provided)

```markdown
# Product Discovery: Plugin API System

*Status: Validated*
*Project Type: Open Source*

## Product Brief

### 1. User Problem & Context

**Target Users**: Open source developers who want to extend the
application with custom functionality

**Problem**: Application has fixed functionality with no extensibility.
Developers want to add features without forking the codebase or waiting
for core maintainers.

**Why It Matters**: Limits adoption, prevents community contributions,
forces users to fork or find alternatives.

### 2. Solution Vision

**Overview**: Plugin API that allows developers to extend application
functionality through well-defined hooks and interfaces

**Key Features**:
1. Plugin registration and lifecycle management
2. Hook system for core events
3. API for accessing core functionality
4. Plugin marketplace/registry
5. Documentation and examples

**User Journey**:
Developer identifies need for custom feature → creates plugin using API →
installs plugin → functionality available in app

### 3. Business Validation (Open Source)

**Community Value**:
- Expands functionality without core team effort
- Increases adoption (developers choose extensible platforms)
- Builds ecosystem around project
- Attracts contributors

**Ecosystem Fit**:
- Aligns with similar OSS projects (VS Code, WordPress, etc.)
- Proven pattern for extensibility

### 5. Recommendation

**Decision**: PROCEED

Plugin API is critical for project growth and community building.

---

[User Stories section empty - to be populated]
```

---

### Stage 2 Procedure

```
Claude: [Product Manager role loaded]
        [story-patterns.md auto-loaded]

        I'm now switching to Product Manager to translate this brief into
        actionable user stories.

        [Reading Product Brief internally...]

        I can see this is for an open source plugin API system. The brief
        is comprehensive with clear problem and solution. Let me define
        the MVP scope.

---

[Checkpoint #7: MVP Scope]

Claude: I've analyzed the features and propose this MVP scope:

        **Must-have (Phase 1 / MVP)**:

        1. **Plugin Registration & Lifecycle** - Foundation for everything
           - Rationale: Can't have plugins without registration system

        2. **Core Hook System** - Essential extensibility mechanism
           - Rationale: Enables plugins to extend core functionality

        3. **Basic Plugin API** - Access to core features
           - Rationale: Plugins need to interact with app

        4. **Plugin Documentation** - Critical for adoption
           - Rationale: Devs can't build plugins without docs

        5. **Example Plugins** - Accelerates developer onboarding
           - Rationale: Learning by example is fastest path

        **Nice-to-have (Phase 2+)**:

        1. **Plugin Marketplace/Registry** - Valuable but not blocking
           - Rationale: Initially can share via GitHub, add marketplace later

        2. **Plugin Dependency Management** - Complex edge case
           - Rationale: Start with independent plugins, add later

        3. **Plugin Sandboxing** - Security enhancement
           - Rationale: Trust-based initially, sandbox for production

        4. **Plugin Settings UI** - Polish feature
           - Rationale: Can use config files initially

        **Rationale**:
        MVP enables developers to create and use plugins with clear
        documentation. Phase 1 proves extensibility concept. Phase 2
        adds ecosystem features (marketplace, dependencies) once usage
        is validated.

        Does this prioritization work for you?

User: Yes, that makes sense. Let's get the core plugin system working first.

---

[Creating user stories...]

Claude: [Generating 8 user stories with acceptance criteria based on
        Product Brief and story-patterns.md reference...]

---

[Checkpoint #8: User Stories Review]

Claude: I've created 8 user stories for the MVP scope:

        **High Priority (Must-have)**:
        - Story 1: Plugin registration system
        - Story 2: Plugin lifecycle management (load, enable, disable, unload)
        - Story 3: Core event hook system
        - Story 4: Plugin API for core functionality access
        - Story 5: Plugin API documentation
        - Story 6: Example plugin implementations
        - Story 7: Plugin error handling and logging
        - Story 8: Plugin development CLI tools

        **Dependencies**:
        - Story 2 depends on Story 1 (lifecycle requires registration)
        - Story 3 depends on Story 2 (hooks require lifecycle)
        - Story 4 depends on Story 3 (API uses hooks)
        - Story 5-8 can proceed in parallel after Story 4

        Example story:

        ### Story 1: Plugin Registration System

        **As a** plugin developer
        **I want** to register my plugin with the application
        **So that** the application recognizes and can load my plugin

        **Context**: From Product Brief, plugin registration is the
        foundation of the plugin system. Without registration, plugins
        cannot be discovered or loaded. This enables the entire plugin
        ecosystem.

        **Priority**: High

        **Dependencies**: None

        **Acceptance Criteria**:
        - [ ] Plugin developer can create plugin manifest file (JSON/YAML)
        - [ ] Manifest includes plugin name, version, author, description
        - [ ] Manifest specifies entry point and dependencies
        - [ ] Application scans plugin directory on startup
        - [ ] Application validates manifest format and required fields
        - [ ] Invalid manifests logged with clear error messages
        - [ ] Registered plugins appear in plugin list
        - [ ] Plugin metadata accessible via API
        - [ ] Documentation includes manifest format specification
        - [ ] Example manifest provided in docs

        [... 7 more stories with full acceptance criteria ...]

        What would you like to do?

        A) Approve these stories
        B) Request modifications
        C) Need more detail on specific stories

User: Show me Story 3—the hook system is critical

Claude: ### Story 3: Core Event Hook System

        **As a** plugin developer
        **I want** to register callbacks for core application events
        **So that** my plugin can extend application behavior at key points

        **Context**: From Product Brief Solution Vision, the hook system is
        the primary extensibility mechanism. This allows plugins to react to
        core events (file opened, command executed, etc.) without modifying
        core code. Based on proven patterns from VS Code and WordPress.

        **Priority**: High

        **Dependencies**: Story 2 (Plugin lifecycle management)

        **Acceptance Criteria**:
        - [ ] Core defines standard hook points (onStart, onCommand, onFile, etc.)
        - [ ] Plugins can register callback functions for hooks
        - [ ] Hooks fire at appropriate points in application lifecycle
        - [ ] Multiple plugins can listen to same hook
        - [ ] Hook callbacks executed in registration order
        - [ ] Hook callbacks receive relevant context data
        - [ ] Hooks support async callbacks with await
        - [ ] Plugin errors in hooks don't crash application
        - [ ] Hook system performance overhead < 5ms per event
        - [ ] Documentation lists all available hooks with examples
        - [ ] Example plugin demonstrates hook usage
        - [ ] Hooks can be extended by plugins (plugin-defined hooks)

        Does this cover the hook system comprehensively?

User: Yes, perfect. Approve all stories.

---

[Creating Prioritized Task List...]

[Checkpoint #9: Final Output]

Claude: User stories complete! Here's what I've created:

        **Summary**:
        - 8 user stories with detailed acceptance criteria
        - 8 must-have (Phase 1), 0 nice-to-have in initial set
        - 4 prioritized tasks for architect
        - Requirements Summary added
        - Integration contract for task-preparation included

        **MVP Scope (Phase 1)**:
        - Plugin registration system
        - Lifecycle management
        - Core event hooks
        - Plugin API
        - Documentation and examples
        - Error handling and CLI tools

        **Output**:
        I'll append the User Stories section to the existing Product Brief.

        File: ./product-briefs/plugin-api.md
        - Product Brief (existing) ✓
        - User Stories (new) ✓

        What would you like to do?

        A) Approve - ready for architect
        B) Request final modifications
        C) Add more user stories

User: A - Approve. Ready for implementation planning.

---

Claude: ✅ Translation complete!

        **Output updated**:
        - ./product-briefs/plugin-api.md
          - Product Brief (existing sections preserved)
          - User Stories (new section appended)
          - Requirements Summary added
          - MVP Scope defined
          - Prioritized Task List included
          - Integration Contract added

        **Next steps**:

        → For technical planning:
          "use task preparation for plugin api"

          task-preparation will:
          - Read Requirements Summary for context
          - Use User Stories as detailed requirements
          - Create technical architecture plan
          - Output: ./plans/plugin-api.md

        **Time spent**:
        - Translation mode: 12 minutes
        - Stage 1 skipped (used existing brief)
        - Stage 2 only: 12 minutes

        ---

        Product discovery skill (translation mode) complete!
```

---

## Updated Product Brief (After Translation)

### New Section Added

```markdown
---

## User Stories

*Translated from Product Brief*
*Generated: 2026-01-28 16:45 PST*

### Requirements Summary

**Core Requirements**:
- Plugin registration and discovery mechanism
- Plugin lifecycle management (load, enable, disable, unload)
- Event hook system for extensibility
- API for plugin access to core functionality

**Developer Experience Requirements**:
- Clear, comprehensive documentation
- Example plugin implementations
- CLI tools for plugin development
- Error handling with helpful messages

**Technical Considerations**:
- Plugin isolation and error containment
- Performance overhead minimal (< 5ms per hook)
- Async/await support for hooks
- Plugin metadata validation

**Success Criteria**:
- External developer can create plugin in < 2 hours
- Plugin system doesn't degrade core performance
- Plugin errors don't crash application
- Community creates 5+ plugins in first 3 months

---

### MVP Scope

**Must-have (Phase 1 / MVP)**:
- Plugin registration system: Foundation for all plugins
- Lifecycle management: Load, enable, disable, unload
- Core event hooks: Primary extensibility mechanism
- Plugin API: Access to core functionality
- Documentation: Critical for developer adoption
- Example plugins: Accelerate learning
- Error handling: Robust plugin isolation
- Development CLI: Streamline plugin creation

**Nice-to-have (Phase 2+)**:
- Plugin marketplace/registry: Can share via GitHub initially
- Dependency management: Start with independent plugins
- Plugin sandboxing: Trust-based security initially
- Settings UI: Config files sufficient for MVP

---

### User Stories

[8 user stories with complete acceptance criteria]

Story 1: Plugin Registration System
[Full story as shown above]

Story 2: Plugin Lifecycle Management
[Full story with criteria]

Story 3: Core Event Hook System
[Full story as shown above]

Story 4: Plugin API for Core Functionality Access
[Full story with criteria]

Story 5: Plugin API Documentation
[Full story with criteria]

Story 6: Example Plugin Implementations
[Full story with criteria]

Story 7: Plugin Error Handling and Logging
[Full story with criteria]

Story 8: Plugin Development CLI Tools
[Full story with criteria]

---

### Prioritized Task List

## Prioritized Task List for Architect

These tasks are ready for technical planning. Use task-preparation skill
for detailed implementation planning.

### High Priority (Must-have / Phase 1)

**Task 1: Core Plugin Infrastructure**
- **Description**: Build registration, lifecycle, and discovery systems
- **User Stories**: Story #1, #2
- **Complexity**: Medium
- **Notes**: Foundation for everything else, consider plugin isolation strategy

**Task 2: Hook System & API**
- **Description**: Implement event hooks and core API for plugins
- **User Stories**: Story #3, #4
- **Complexity**: Medium
- **Notes**: Performance critical, async support required, error isolation

**Task 3: Documentation & Examples**
- **Description**: Write comprehensive plugin docs and example implementations
- **User Stories**: Story #5, #6
- **Complexity**: Simple
- **Notes**: Critical for adoption, include quickstart guide

**Task 4: Developer Tools & Error Handling**
- **Description**: CLI tools for plugin development and robust error handling
- **User Stories**: Story #7, #8
- **Complexity**: Simple
- **Notes**: Improves DX, makes debugging easier

### Dependencies

- Task 2 depends on Task 1 completion (hooks need lifecycle system)
- Task 3 can proceed in parallel once Task 2 is far enough along
- Task 4 can proceed in parallel with Task 2

### Notes for Technical Planning

- Consider plugin architecture: in-process vs out-of-process
- Security model: trust-based initially, plan for sandboxing later
- Performance: benchmark hook system overhead
- Testing strategy: how to test plugin system itself?
- Versioning: semantic versioning for API changes

---

### Integration Contract for task-preparation

This document is ready for technical planning.

**How to use with task-preparation**:

1. Read "Requirements Summary" for quick context
2. Review "User Stories" section for detailed requirements
3. Reference "Prioritized Task List" for suggested work breakdown
4. Use: `"use task preparation for plugin api"`

**What task-preparation receives**:
- Complete Product Brief (problem, solution, validation)
- 8 user stories with acceptance criteria
- Prioritized task list with 4 tasks
- Technical considerations and success criteria

**Expected workflow**:
1. task-preparation reads this document
2. Software Architect creates technical architecture
3. Plan considers plugin isolation, hook performance, API design
4. Implementation verified against acceptance criteria

---

*End of User Stories Section*
```

---

## Key Takeaways

### What Worked Well

✅ **Translation-only mode appropriate**: Existing brief was complete, only needed user stories

✅ **Quick turnaround**: 12 minutes to add structured requirements to existing brief

✅ **Preserved existing work**: Product Brief sections untouched, user stories appended

✅ **Complete requirements**: 8 stories with acceptance criteria ready for implementation

✅ **Clear integration path**: Output ready for task-preparation handoff

### When to Use Translation-Only Mode

**Use translation-only when**:
- You have an existing Product Brief
- Brief is complete (problem, solution, validation)
- Need to add structured user stories
- Want quick turnaround for requirements
- Brief was created in previous session
- Brief came from another source (stakeholder, PM)

**Don't use translation-only when**:
- Brief is incomplete or unclear
- Need to explore problem space
- Requirements are vague
- Want to validate idea before translation

### Time Comparison

**Translation-Only**: 12 minutes
- Stage 0: Skipped
- Stage 1: Skipped
- Stage 2: 12 minutes

**vs. Full Discovery** (Standard): ~30 minutes
- Stage 0: 3 minutes
- Stage 1: 18 minutes
- Stage 2: 10 minutes

**Time savings**: ~18 minutes when brief already exists

### Mode Detection

**System detects translation-only when**:
- User provides file path
- Keywords present: "translate", "convert", "brief to stories"
- Pattern: `"translate product brief: [path]"`

**Automatic behavior**:
- Skips Stage 0 (complexity assessment)
- Skips Stage 1 (discovery)
- Validates brief file and format
- Jumps directly to Stage 2
- Updates metadata with skip reason

### Brief Validation

**System checks for**:
- Section 1: User Problem & Context
- Section 2: Solution Vision
- Section 3: Business Validation
- Section 5: Recommendation

**If sections missing**:
- Offers to attempt translation anyway
- Suggests completing brief first
- Offers interactive completion

**Semantic flexibility**:
- Accepts alternative section names
- Looks for equivalent content
- Not rigid about exact format

### Output Integration

**Appends to existing file**:
- Preserves Product Brief sections
- Adds User Stories section
- Adds Requirements Summary
- Adds MVP Scope
- Adds Prioritized Task List
- Adds Integration Contract

**Result**: Single comprehensive document ready for architect

---

## Use Cases for Translation-Only Mode

### Use Case 1: Staged Workflow

```
Day 1: Product Owner creates brief during discovery
       → Output: ./product-briefs/feature.md

Day 2: Product Manager translates to user stories
       → "translate product brief: ./product-briefs/feature.md"
       → User stories appended

Day 3: Architect does technical planning
       → "use task preparation for feature"
```

### Use Case 2: Brief from Another Source

```
Stakeholder provides requirements document
→ Format as Product Brief (manually or with help)
→ "translate product brief: ./briefs/stakeholder-requirements.md"
→ Get structured user stories for implementation
```

### Use Case 3: Resume After Pause

```
Session 1: Complete Stage 1, create Product Brief, user pauses

Session 2: Resume and add user stories
→ "translate product brief: ./product-briefs/feature.md"
→ Complete requirements without re-doing discovery
```

### Use Case 4: Iterative Refinement

```
Initial session: Create brief, skip Stage 2
Later: Decide user stories needed after all
→ "translate product brief: ./product-briefs/feature.md"
→ Add structured requirements when ready
```

---

## Integration with Full Discovery

**Translation-only is NOT separate skill**:
- Same skill, different entry point
- Uses same Product Manager role
- Uses same story-patterns.md reference
- Outputs same format
- Integrates same way with task-preparation

**Flexibility**:
- Full discovery can become translation-only if brief exists
- Translation-only can discover if brief incomplete
- User can choose based on situation

---

*End of Translation-Only Example*
