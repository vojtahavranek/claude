# Requirements Gathering Templates

This reference provides structured question templates for systematically gathering requirements across different task types. Use these templates to ensure comprehensive information gathering in Stage 1 of the task preparation workflow.

## Core Question Categories

These categories apply to ALL task types:

### 1. Goal and Objective
- What is the primary goal or objective of this task?
- Why is this needed? What problem does it solve?
- What does success look like?
- Are there any business or user requirements driving this?

### 2. Scope and Components
- What files, directories, or components are involved?
- What parts of the system will be affected?
- Are there any areas that should NOT be touched?
- Is this a new feature, modification, refactoring, or fix?

### 3. Constraints and Requirements
- Are there performance requirements? (latency, throughput, resource usage)
- Are there compatibility requirements? (browsers, versions, platforms)
- Are there security or privacy requirements?
- Are there coding style or pattern requirements to follow?
- Are there testing requirements? (unit, integration, e2e)

### 4. Expected Behavior
- What should happen when this is complete?
- How should it behave in success scenarios?
- How should it handle errors or edge cases?
- Are there specific inputs and expected outputs?

### 5. Examples and References
- Are there existing patterns or code to follow?
- Are there similar features in the codebase?
- Are there external references (docs, RFCs, designs)?
- Can you provide example usage or test cases?

### 6. Context and Background
- Is there existing code that needs to be understood first?
- Are there dependencies on other features or systems?
- Is there historical context or previous attempts?
- What's the current state vs. desired state?

## Task-Type-Specific Templates

### API Implementation

**Specific questions:**
- What HTTP method(s) should be supported? (GET, POST, PUT, DELETE, PATCH)
- What is the endpoint path? (e.g., `/api/users/:id`)
- What are the request parameters? (path params, query params, body)
- What should the response format be? (JSON schema, status codes)
- What authentication/authorization is required?
- What validation rules apply to inputs?
- How should rate limiting or caching work?
- Are there specific error responses required?

**Complexity indicators:**
- Multiple endpoints or resources
- Complex validation or business logic
- Integration with external services
- Data transformations or aggregations
- Transactions or multi-step operations

### UI/Frontend Feature

**Specific questions:**
- What framework/library is being used? (React, Vue, vanilla JS, etc.)
- What should the UI look like? (mockup, wireframe, description)
- What user interactions are needed? (click, hover, input, drag, etc.)
- What state needs to be managed?
- How should it integrate with existing UI?
- What accessibility requirements apply? (ARIA, keyboard nav, screen readers)
- What responsive behavior is needed? (mobile, tablet, desktop)
- Are there animations or transitions?

**Complexity indicators:**
- Multiple components or pages
- Complex state management
- Real-time updates or WebSocket integration
- Cross-browser compatibility challenges
- Accessibility requirements
- Performance optimization needs (large lists, heavy rendering)

### Database Schema or Migration

**Specific questions:**
- What database system is being used? (PostgreSQL, MySQL, MongoDB, etc.)
- What tables/collections need to be created or modified?
- What columns/fields are needed? (name, type, constraints)
- What indexes are required?
- What relationships exist? (foreign keys, references)
- Are there data migrations needed for existing data?
- What's the rollback strategy?
- Are there backward compatibility requirements?

**Complexity indicators:**
- Multiple related tables
- Data migrations affecting large datasets
- Complex constraints or triggers
- Performance-sensitive queries
- Schema changes affecting many parts of codebase

### Refactoring

**Specific questions:**
- What code needs to be refactored?
- What's the problem with the current implementation?
- What's the desired structure or pattern?
- Must behavior remain exactly the same? (pure refactor vs. with changes)
- Are there tests to verify behavior preservation?
- What's the rollout strategy? (all at once, incremental)
- Are there breaking changes for consumers?

**Complexity indicators:**
- Large codebase or many files
- Lacks existing tests
- Public API with external consumers
- Performance-critical code
- Complex business logic

### Bug Fix

**Specific questions:**
- What is the observed incorrect behavior?
- What is the expected correct behavior?
- How can the bug be reproduced? (steps, conditions, environment)
- What error messages or logs are relevant?
- When did this start happening? (recent change, always broken)
- Does it affect all users or specific scenarios?
- What's the severity and urgency?
- Are there any workarounds?

**Complexity indicators:**
- Intermittent or hard-to-reproduce bugs
- Affects multiple components
- Root cause unclear
- Requires debugging or investigation
- Security implications

### Integration with External Service

**Specific questions:**
- What service are we integrating with? (API, SDK, library)
- What's the authentication mechanism? (API key, OAuth, etc.)
- What operations need to be supported? (read, write, both)
- What's the expected data format? (JSON, XML, protobuf, etc.)
- What error handling is needed? (retries, fallbacks, circuit breakers)
- What are the rate limits or quotas?
- How should failures be handled?
- Are there webhook or callback requirements?

**Complexity indicators:**
- Complex authentication flows
- Bidirectional integration (webhooks)
- Real-time or streaming data
- Transaction or consistency requirements
- Error recovery and resilience needs

### Performance Optimization

**Specific questions:**
- What specific performance issue exists? (slow response, high memory, etc.)
- What are the current metrics? (baseline)
- What are the target metrics? (goal)
- Have you profiled or identified bottlenecks?
- What constraints exist? (can't change X, must maintain Y)
- Are there trade-offs to consider? (memory vs. speed, complexity vs. performance)
- How will improvements be measured?

**Complexity indicators:**
- System-wide performance issues
- Requires algorithmic changes
- Needs caching or indexing strategies
- Database query optimization
- Large-scale data processing

## Complexity Detection Questions

Ask these follow-up questions to assess complexity:

1. **Scope**: "Does this change affect multiple system layers or just one area?"
2. **Dependencies**: "Will this require new libraries, services, or infrastructure?"
3. **Data**: "Are there database schema changes or data migrations?"
4. **Security**: "Does this involve authentication, authorization, or sensitive data?"
5. **Performance**: "Is this in a performance-critical code path?"
6. **Scale**: "How many files will need non-trivial changes (>20 lines)?"
7. **Teams**: "Does this span multiple team domains (frontend, backend, DevOps, etc.)?"

**If 3+ indicators are present**, the task is complex and should be considered for splitting.

## Question Asking Strategy

**Batch questions appropriately:**
- Ask 1-4 questions at a time
- Group related questions together
- Don't overwhelm with 10+ questions at once

**Adapt based on responses:**
- If user provides detailed answers, fewer follow-ups needed
- If answers are vague, ask clarifying questions
- If uncertainty remains, ask specific yes/no questions

**Prioritize critical information:**
- Start with goal, scope, and constraints
- Move to detailed requirements
- End with nice-to-have context

**Recognize when enough is enough:**
- Diminishing returns after comprehensive coverage
- Some details can be discovered during planning
- Avoid analysis paralysis

## Templates for Common Scenarios

### Quick Feature Addition
```
1. What is the feature and why is it needed?
2. What files or components should be modified?
3. Are there existing patterns or code to follow?
4. Any constraints or requirements? (performance, style, compatibility)
```

### Complex System Change
```
1. What's the high-level goal and why?
2. What parts of the system are involved?
3. What are the key requirements and constraints?
4. Are there dependencies on other features or systems?
5. What's the expected behavior in success and error cases?
6. Are there examples or references to follow?
7. What should NOT be changed?
```

### Investigation or Unclear Requirements
```
1. What problem are you trying to solve?
2. What have you tried so far?
3. What would ideal success look like?
4. Are there constraints or must-haves?
5. Are there examples of what you want?
```

---

## Usage in Task Preparation Workflow

**When to load this reference:**
- Stage 1: Requirements Gathering
- When encountering unfamiliar task types
- When user requests comprehensive requirements checklist

**How to use:**
1. Identify the task type (API, UI, database, refactoring, bug fix, etc.)
2. Start with core question categories (always applicable)
3. Add task-type-specific questions
4. Use complexity detection questions for assessment
5. Batch questions appropriately (1-4 at a time)
6. Adapt based on user responses

**Remember:** The goal is comprehensive understanding, not interrogation. Balance thoroughness with user experience.
