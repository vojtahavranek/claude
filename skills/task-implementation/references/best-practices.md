# Implementation Best Practices

Quick reference for code quality during implementation. Load this when uncertain about implementation approach or dealing with complex logic.

## Code Quality Principles

### 1. Correctness
**Priority: Get it working right**

- Handle edge cases: null, undefined, empty arrays, zero, negative numbers
- Validate inputs at boundaries (user input, external APIs, file systems)
- Return appropriate values for all code paths
- Consider error conditions explicitly

**Example edge cases to check**:
```javascript
// Array operations
if (arr.length === 0) { /* handle empty */ }

// Null checks
if (value === null || value === undefined) { /* handle */ }

// Numeric bounds
if (count < 0) { /* invalid */ }
```

### 2. Readability
**Others (including you tomorrow) should understand it**

- Use descriptive names: `getUserById` not `get`, `maxRetries` not `n`
- Keep functions focused: one clear purpose per function
- Limit nesting: 3 levels max, extract to functions if deeper
- Add comments only for non-obvious logic: "why" not "what"

**Good naming**:
```javascript
// Clear intent
const activeUsers = users.filter(u => u.isActive);
const hasPermission = user.roles.includes('admin');

// Not this
const x = users.filter(u => u.a);
const check = user.r.includes('admin');
```

### 3. Error Handling
**Fail gracefully, help debug**

- Catch errors at appropriate levels
- Provide helpful error messages
- Log enough context for debugging
- Don't swallow errors silently

**Good patterns**:
```javascript
try {
  const data = await fetchUserData(userId);
  return processData(data);
} catch (error) {
  logger.error(`Failed to fetch user ${userId}:`, error);
  throw new Error(`Unable to load user data: ${error.message}`);
}
```

**Bad patterns**:
```javascript
try {
  // ...
} catch (error) {
  // Silent failure - bad!
}
```

### 4. Input Validation
**Trust no one, validate at boundaries**

- Validate user input before processing
- Check types and formats
- Sanitize for security (see Security section)
- Provide clear error messages

**Example**:
```javascript
function createUser(name, email) {
  // Validate inputs
  if (!name || typeof name !== 'string') {
    throw new Error('Name must be a non-empty string');
  }

  if (!email || !email.includes('@')) {
    throw new Error('Valid email required');
  }

  // Now safe to process
  return { name: name.trim(), email: email.toLowerCase() };
}
```

### 5. Security
**Prevent common vulnerabilities**

**SQL Injection Prevention**:
```javascript
// Good: Parameterized query
db.query('SELECT * FROM users WHERE id = ?', [userId]);

// Bad: String concatenation
db.query(`SELECT * FROM users WHERE id = ${userId}`); // NO!
```

**XSS Prevention**:
```javascript
// Good: Escape user content
const escaped = escapeHtml(userContent);

// Bad: Direct insertion
element.innerHTML = userContent; // NO!
```

**Common security practices**:
- Never trust user input
- Use parameterized queries (SQL)
- Escape output (HTML)
- Don't log sensitive data (passwords, tokens)
- Use HTTPS for sensitive data
- Validate file uploads (type, size)

### 6. Don't Over-Engineer
**Solve today's problem, not tomorrow's hypothetical**

- Three similar lines? That's okay - don't force abstraction
- One-time operation? Don't create a helper class
- Clear requirements? Implement directly
- Uncertain future? Wait until needed

**When to abstract**:
- Actually repeated 3+ times (not "might be")
- Clear pattern emerges naturally
- Simplifies rather than complicates

**When not to**:
- "We might need this later"
- "This could be configurable"
- "Let's make it flexible"

### 7. Follow Existing Patterns
**Consistency over perfection**

- Match existing code style
- Use established libraries and utilities
- Follow project conventions
- Don't reinvent what exists

**Before writing**:
- Check if similar functionality exists
- Use existing utilities/helpers
- Match naming conventions
- Follow file organization

## Common Patterns

### Async Operations
```javascript
// Modern async/await
async function loadData() {
  try {
    const response = await fetch('/api/data');
    return await response.json();
  } catch (error) {
    console.error('Load failed:', error);
    throw error;
  }
}
```

### Array Operations
```javascript
// Functional style
const activeAdmins = users
  .filter(u => u.isActive)
  .filter(u => u.role === 'admin')
  .map(u => u.name);
```

### Null Safety
```javascript
// Optional chaining
const city = user?.address?.city;

// Nullish coalescing
const count = value ?? 0;
```

### Configuration
```javascript
// Environment variables
const config = {
  port: process.env.PORT || 3000,
  dbUrl: process.env.DATABASE_URL,
  apiKey: process.env.API_KEY
};
```

## Testing Mindset

**Write testable code**:
- Pure functions when possible (same input → same output)
- Inject dependencies (don't hardcode)
- Separate logic from I/O
- Keep functions small and focused

**Consider test scenarios while implementing**:
- Normal case
- Edge cases (empty, null, boundary values)
- Error cases (invalid input, network failure)

## Performance Considerations

**When to optimize**:
- After measuring (don't guess)
- When there's a real problem
- In hot paths (frequently called)

**When not to**:
- Premature optimization
- Hypothetical future scale
- Without profiling data

**Common sense optimizations** (basically free):
- Use appropriate data structures (Set for lookup, Map for key-value)
- Avoid unnecessary loops
- Cache expensive computations if called repeatedly in same request
- Don't fetch data you don't need

## Common Pitfalls to Avoid

1. **Modifying function parameters**: Clone before mutating
2. **Floating promises**: Always await or handle
3. **Race conditions**: Be careful with async state updates
4. **Memory leaks**: Clean up listeners, intervals, connections
5. **Magic numbers**: Use named constants
6. **Deep nesting**: Extract functions
7. **God functions**: Split large functions into smaller ones
8. **Tight coupling**: Depend on interfaces, not implementations

## When to Load References

**Load implementation-guidelines.md when**:
- Implementing complex business logic
- Uncertain about error handling approach
- Dealing with security-sensitive code
- Need reminder on validation patterns

**Load testing-strategy.md when**:
- Writing tests for implemented code
- Test failures need debugging
- Unclear what test coverage is needed

**Load code-review-checklist.md when**:
- About to review complex implementation
- Need systematic quality check
- Before marking complex step complete

## Quick Decision Framework

**Should I add error handling?**
→ Can this fail? Yes = add handling

**Should I validate this input?**
→ Does it come from outside (user, API, file)? Yes = validate

**Should I write a helper function?**
→ Is it used 3+ times? Yes = extract. Otherwise = inline

**Should I add comments?**
→ Is the "why" non-obvious? Yes = comment. Otherwise = no

**Should I optimize this?**
→ Have I measured it's slow? Yes = optimize. Otherwise = keep simple

## Summary

**Priorities** (in order):
1. **Correct**: Works for all inputs
2. **Secure**: No vulnerabilities
3. **Readable**: Others understand it
4. **Maintainable**: Easy to change later
5. **Simple**: No unnecessary complexity
6. **Performant**: Fast enough (measure first)

**Remember**: Good enough today beats perfect never. Ship working code, iterate based on real feedback.
