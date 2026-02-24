# Validation Framework for Architectural Review

This reference provides a comprehensive checklist and framework for Stage 4 (Peer Review) of the task preparation workflow. Use this when performing the second architect review to ensure thorough, critical evaluation of the initial plan.

## Devil's Advocate Mindset

When reviewing as the second architect, adopt a deliberately critical perspective:

**Your role:**
- Challenge assumptions, not to be difficult, but to strengthen the plan
- Look for flaws, gaps, and risks that were missed
- Suggest alternatives, even if the first plan is good
- Play "what could go wrong" scenarios
- Be constructive, not destructive (criticize to improve, not to tear down)

**What you're NOT doing:**
- Nitpicking minor details or style preferences
- Rejecting plans just to be contrary
- Focusing only on negatives (acknowledge strengths too)
- Being vague ("this doesn't feel right" - be specific)

**What you ARE doing:**
- Identifying concrete risks and weaknesses
- Suggesting specific improvements or alternatives
- Testing assumptions with probing questions
- Ensuring the plan is robust and well-thought-out

## Comprehensive Review Checklist

### 1. Assumptions and Validity

**Question: What assumptions were made, and are they valid?**

**Check for:**
- Unstated assumptions about user behavior, system state, or environment
- Assumptions about existing code or dependencies
- Assumptions about performance characteristics
- Assumptions about data volume, traffic, or scale

**Probing questions:**
- "The plan assumes X - is that always true?"
- "What happens if Y is not the case?"
- "Have we verified that Z works as expected?"

**Red flags:**
- "This should work..." without verification
- Assumptions about third-party behavior without checking docs
- Assuming existing code is correct when it hasn't been reviewed

### 2. Failure Modes and Error Scenarios

**Question: What could go wrong with this approach?**

**Check for:**
- Missing error handling for expected failures
- Unhandled edge cases
- Race conditions or concurrency issues
- Partial failure scenarios (what if step 3 fails after step 2 succeeded?)
- Network failures, timeouts, or service unavailability
- Invalid or malicious input handling

**Probing questions:**
- "What happens when the API call fails?"
- "What if the database is temporarily unavailable?"
- "How do we handle invalid user input?"
- "What if two requests happen simultaneously?"

**Red flags:**
- Happy-path-only planning
- No discussion of error handling strategy
- Ignoring async/concurrency implications

### 3. Simpler Alternatives

**Question: Are there simpler or better alternatives?**

**Check for:**
- Over-engineered solutions (using complex patterns when simple code suffices)
- Premature optimization
- Unnecessary abstractions or indirection
- Could existing functionality be reused instead of building new?
- Is a library/framework needed or would vanilla code work?

**Probing questions:**
- "Could we solve this with a simpler approach?"
- "Do we need this abstraction right now?"
- "Is there existing code that does something similar?"
- "Are we optimizing before we have performance data?"

**Red flags:**
- Creating frameworks for one-time use
- Adding layers of abstraction without clear benefit
- "We might need it later" reasoning
- Solving hypothetical future problems

### 4. Engineering Level: Over vs. Under

**Question: Is it over-engineered or under-engineered?**

**Over-engineering indicators:**
- More than 3 levels of abstraction for simple logic
- Extensive configuration for straightforward features
- Design patterns where simple functions suffice
- Flexibility for scenarios that will never happen
- Building generic solutions for specific problems

**Under-engineering indicators:**
- No error handling
- No input validation
- Hard-coded values that should be configurable
- No tests for critical logic
- Ignoring security implications
- No consideration for scale or growth

**Probing questions:**
- "Is this complexity justified by the requirements?"
- "Are we handling the security/scale implications adequately?"
- "Do we have enough error handling and validation?"

**Red flags:**
- Either extreme - complexity without justification, or naivety about risks

### 5. Edge Cases and Corner Scenarios

**Question: What edge cases or error scenarios were missed?**

**Check for:**
- Empty collections or null values
- Boundary conditions (0, -1, max int, empty string)
- Unicode, special characters, or encoding issues
- Time zones, daylight saving, or date edge cases
- Very large or very small inputs
- Concurrent modifications
- Missing or malformed data

**Probing questions:**
- "What happens with an empty list?"
- "What if the user provides 1 million items?"
- "How do we handle special characters or unicode?"
- "What about time zone differences?"

**Red flags:**
- Testing only with happy-path data
- No discussion of boundary conditions
- Assuming data is always well-formed

### 6. Integration Points and Boundaries

**Question: Are integration points clearly and correctly defined?**

**Check for:**
- Clear interfaces between new and existing code
- Defined data contracts (inputs, outputs, formats)
- Handling version compatibility
- Migration strategy from old to new
- Backward compatibility requirements
- Impact on existing consumers

**Probing questions:**
- "How does this integrate with the existing system?"
- "What's the interface contract?"
- "Will this break existing code?"
- "How do we migrate existing usage?"

**Red flags:**
- Vague "it'll plug in somehow" descriptions
- No discussion of backward compatibility
- Undefined data contracts
- No migration or rollout strategy

### 7. Risks and Mitigation

**Question: What are the risks and how can we mitigate them?**

**Risk categories:**
- **Technical risks**: Implementation complexity, unknowns, dependencies
- **Security risks**: Vulnerabilities, attack vectors, data exposure
- **Performance risks**: Scalability, resource usage, bottlenecks
- **Operational risks**: Deployment, monitoring, rollback
- **Business risks**: User impact, downtime, data loss

**For each risk, check:**
- Is the risk identified?
- Is the impact assessed?
- Is there a mitigation strategy?
- Is there a fallback or rollback plan?

**Probing questions:**
- "What's the biggest risk in this approach?"
- "What happens if we need to rollback?"
- "How will we know if this causes problems in production?"
- "What's our plan if X goes wrong?"

**Red flags:**
- No risk discussion
- Risks mentioned but not addressed
- No rollback or recovery plan
- "It'll be fine" confidence without evidence

### 8. Consistency with Existing Architecture

**Question: Does it align with existing system architecture and patterns?**

**Check for:**
- Following established patterns and conventions
- Consistency with existing code style
- Using the same libraries/frameworks as the rest of the codebase
- Matching the existing architecture layers
- Compatibility with team standards and practices

**Probing questions:**
- "Does this match how we've solved similar problems before?"
- "Are we introducing a new pattern when an existing one works?"
- "Is this consistent with our architecture principles?"
- "Will this create technical debt or inconsistency?"

**Red flags:**
- Introducing new patterns without justification
- Inconsistent with codebase conventions
- Creating architectural divergence
- "Better" solutions that break consistency

### 9. Security Considerations

**Question: Are there security vulnerabilities or attack vectors?**

**Check for:**
- Input validation and sanitization
- Authentication and authorization
- SQL injection, XSS, CSRF vulnerabilities
- Sensitive data handling (encryption, logging)
- Rate limiting and DoS protection
- Least privilege principles
- Secure defaults

**Probing questions:**
- "How do we validate user input?"
- "Is this endpoint authenticated?"
- "Are we logging sensitive data?"
- "Could this be exploited for XSS/SQL injection?"
- "What permissions are required?"

**Red flags:**
- No mention of security for sensitive operations
- Trusting user input without validation
- Logging passwords or tokens
- Missing authentication/authorization
- Privileged operations without checks

### 10. Scalability and Performance

**Question: Are there potential scalability bottlenecks?**

**Check for:**
- N+1 queries or inefficient database access
- Loading large datasets into memory
- Unbounded loops or recursion
- Synchronous operations that should be async
- Missing indexes or caching
- Resource leaks

**Probing questions:**
- "How does this perform with 1000x the data?"
- "Are we loading too much into memory?"
- "Should this operation be async?"
- "Do we need caching or indexing?"

**Red flags:**
- No discussion of performance implications
- Algorithms with poor complexity (O(n²) when O(n) possible)
- Loading entire datasets when pagination needed
- Blocking operations in critical paths

### 11. Testability

**Question: Can this be tested effectively?**

**Check for:**
- Clear units that can be tested in isolation
- Dependency injection for mocking
- Observable outputs and side effects
- Test data requirements
- Test coverage strategy

**Probing questions:**
- "How will we test this?"
- "Can we mock the dependencies?"
- "What test cases are needed?"
- "Is this too tightly coupled to test?"

**Red flags:**
- Tight coupling making tests difficult
- No discussion of testing strategy
- Untestable side effects
- Heavy reliance on external services without mocking

### 12. Technical Debt

**Question: Are we introducing technical debt?**

**Check for:**
- Shortcuts or hacks planned
- TODOs or deferred work
- Temporary solutions that will become permanent
- Compromises due to time pressure
- Areas that will need refactoring

**Probing questions:**
- "What's the long-term maintainability?"
- "Are we creating future work?"
- "What's the 'right' solution vs. what's proposed?"
- "Will we actually come back to fix this?"

**Red flags:**
- Extensive TODOs or future work
- "We'll refactor this later"
- Workarounds without plan to fix properly
- Compromise decisions without trade-off analysis

## Common Architectural Pitfalls

Watch for these frequent mistakes:

### 1. Premature Abstraction
- Creating generic solutions before understanding specific needs
- **Fix**: Start concrete, abstract only when patterns emerge (Rule of Three)

### 2. God Objects/Functions
- Single component doing too many things
- **Fix**: Single Responsibility Principle - split by concern

### 3. Tight Coupling
- Components that can't be changed independently
- **Fix**: Dependency injection, interfaces, event-driven communication

### 4. Leaky Abstractions
- Implementation details bleeding through interfaces
- **Fix**: Hide implementation, expose only essential contract

### 5. Inconsistent Patterns
- Solving same problem different ways in different places
- **Fix**: Follow established patterns, document when diverging

### 6. Missing Error Boundaries
- Errors propagating uncontrolled through system
- **Fix**: Define error handling at component boundaries

### 7. State Management Chaos
- Unclear where state lives and how it flows
- **Fix**: Single source of truth, clear data flow

### 8. No Versioning Strategy
- Breaking changes without compatibility plan
- **Fix**: Semantic versioning, migration paths, deprecation notices

## Review Output Format

Structure your review with:

### Strengths
- What's good about the plan
- Sound decisions and approaches
- Acknowledge good thinking

### Concerns
For each concern:
1. **Category**: (e.g., Security, Performance, Error Handling)
2. **Issue**: Specific problem identified
3. **Impact**: Why this matters (risk, complexity, maintainability)
4. **Suggestion**: Concrete improvement or alternative

### Critical Issues
- Must-fix issues before proceeding
- Fundamental flaws requiring plan revision

### Nice-to-Haves
- Improvements that would strengthen the plan but aren't critical
- Optimizations or enhancements to consider

### Questions
- Things that need clarification
- Areas where more information is needed

## Balancing Criticism with Pragmatism

**Don't let perfect be the enemy of good:**
- Not every plan needs to be perfect
- Some technical debt is acceptable if acknowledged
- Quick wins can be more valuable than perfect architecture
- Context matters - prototypes have different standards than production

**But don't compromise on:**
- Security for sensitive operations
- Data integrity and correctness
- Critical error handling
- Clearly bad architectural decisions

**The goal:** Strengthen the plan, not make it perfect. Identify real risks and issues, suggest concrete improvements, but recognize when good enough is good enough.

---

## Usage in Task Preparation Workflow

**When to load this reference:**
- Stage 4: Peer Review (Second Architect)
- When uncertain about review criteria
- When evaluating architectural quality

**How to use:**
1. Work through the checklist systematically
2. Use probing questions to challenge the plan
3. Identify issues using the red flags
4. Check for common pitfalls
5. Structure review output clearly
6. Balance criticism with pragmatism

**Remember:** The goal is to strengthen the plan through constructive criticism, not to reject it. Be thorough, be critical, but be helpful.
