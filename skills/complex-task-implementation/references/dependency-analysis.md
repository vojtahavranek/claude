# Dependency Analysis Reference

Loaded when plan has complex inter-step dependencies.

## Building the Dependency DAG

### Step 1: Extract File Lists

For each step in the plan, identify:
- **Creates**: files that will be created (new files)
- **Modifies**: files that will be modified (existing files)
- **Reads**: files that are read but not modified (imports, references)

### Step 2: Identify Dependencies

#### Implicit Dependencies (from file analysis)

Two steps have an implicit dependency when:

1. **Write-Write conflict**: Both steps modify the same file
   - Step A modifies `src/api.ts`, Step B modifies `src/api.ts`
   - Result: A -> B (sequential, order from plan)

2. **Write-Read dependency**: One step creates/modifies a file another step reads
   - Step A creates `src/types.ts`, Step B imports from `src/types.ts`
   - Result: A -> B (A must complete first)

3. **Create-Modify dependency**: One step creates a file another step modifies
   - Step A creates `src/service.ts`, Step B adds methods to `src/service.ts`
   - Result: A -> B

#### Explicit Dependencies

Found in plan text as:
- "depends on Step X"
- "after Step X is complete"
- "requires Step X"
- "builds on Step X"

### Step 3: Detect Circular Dependencies

Perform cycle detection on the DAG (DFS with coloring).

If circular dependency found:
- Report the cycle to the user: "Steps X -> Y -> Z -> X form a circular dependency"
- Suggest resolution: merge the steps or clarify ordering
- Stop and wait for user input

## Wave Computation Algorithm

### Topological Sort into Levels

```
Algorithm: ComputeWaves(steps, dependencies)

1. Build adjacency list and in-degree count for each step
2. Initialize queue with all steps having in-degree 0 (no dependencies)
3. wave = 1
4. While queue is not empty:
   a. current_wave = all steps currently in queue
   b. Assign all current_wave steps to wave number
   c. For each step in current_wave:
      - For each step that depends on it:
        - Decrement in-degree
        - If in-degree becomes 0, add to next_queue
   d. queue = next_queue
   e. wave++
5. If any steps not assigned to a wave: circular dependency exists
```

### Example

Given steps 1-6 with dependencies:
- Step 2 depends on Step 1
- Step 4 depends on Step 3
- Step 6 depends on Steps 2 and 4
- Steps 1, 3, 5 have no dependencies

Result:
- Wave 1: Steps 1, 3, 5 (parallel)
- Wave 2: Steps 2, 4 (parallel, after Wave 1)
- Wave 3: Step 6 (after Wave 2)

## Handling Ambiguous Cases

### File Created in One Step, Possibly Read in Another

When it's unclear whether a step reads a file created by another:
- **Conservative approach**: Assume dependency (safer, less parallel)
- **Aggressive approach**: No dependency unless explicit (faster, riskier)

**Default**: Conservative. The step creating the file goes in an earlier wave.

### Shared Directory but Different Files

Steps touching different files in the same directory are NOT dependent:
- Step A creates `src/components/Button.tsx`
- Step B creates `src/components/Modal.tsx`
- No dependency (different files)

### Test Files

Test files that test code from a specific step depend on that step:
- Step A modifies `src/auth.ts`
- Step B creates `tests/auth.test.ts`
- B depends on A

## Presenting to User

When presenting waves at Approval Gate 1, show:

```
Wave 1 (3 steps, parallel):
  Step 1: Create user model          -> src/models/user.ts (new)
  Step 3: Add validation utilities   -> src/utils/validate.ts (new)
  Step 5: Create test fixtures       -> tests/fixtures/ (new)

Wave 2 (2 steps, parallel):
  Step 2: Add user service           -> src/services/user.ts (new)
    depends on: Step 1 (uses user model)
  Step 4: Add API routes             -> src/routes/users.ts (new)
    depends on: Step 1 (uses user model)

Wave 3 (1 step):
  Step 6: Integration tests          -> tests/integration/ (new)
    depends on: Steps 2, 4
```

This gives the user clear visibility into parallelism and ordering rationale.
