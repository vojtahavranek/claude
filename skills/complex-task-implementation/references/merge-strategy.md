# Merge Strategy Reference

Loaded when merging agent worktree results or handling merge conflicts.

## Git Worktree Basics

Each implementation agent runs with `isolation: "worktree"`, which creates a temporary git worktree - an isolated copy of the repository on a separate branch. The agent makes changes in this isolated copy without affecting the main working tree.

When an agent completes with changes:
- The Task tool returns the worktree path and branch name
- Changes exist on that branch but are not yet on the main branch
- The worktree is preserved (not auto-cleaned) because changes were made

## Merge Process

### Step 1: Verify No Overlaps

Before merging, check if any two agents in the same wave modified the same file:

```bash
# For each agent's branch, get list of changed files
git diff --name-only main..[agent-branch-1]
git diff --name-only main..[agent-branch-2]
# Compare lists for overlaps
```

### Step 2: Non-Overlapping Changes (Expected Case)

When agents modified different files (the normal case due to scope restriction):

**Option A: Sequential merge (simple)**
```bash
# Merge each agent's branch sequentially
git merge [agent-branch-1] --no-edit
git merge [agent-branch-2] --no-edit
```

**Option B: Cherry-pick (more controlled)**
```bash
# Cherry-pick each agent's commits
git cherry-pick [agent-commit-1]
git cherry-pick [agent-commit-2]
```

Prefer Option A for cleaner history. Use Option B when you need granular control.

### Step 3: Overlapping Changes (Conflict Case)

If two agents modified the same file (should be rare due to dependency analysis):

1. **Attempt auto-merge**: Git may resolve automatically if changes are in different sections
   ```bash
   git merge [agent-branch] --no-edit
   # If succeeds: continue
   # If fails: conflict resolution needed
   ```

2. **If auto-merge fails**:
   - Check the conflict markers in the file
   - If changes are clearly complementary (different functions, different sections): resolve by keeping both
   - If changes are contradictory: escalate to user

3. **Escalation to user**:
   ```
   Merge conflict detected in: [file]

   Agent A (Step X) changed: [description]
   Agent B (Step Y) changed: [description]

   These changes conflict. How should I resolve?
   A) Keep Agent A's changes (Step X)
   B) Keep Agent B's changes (Step Y)
   C) Let me resolve manually
   ```

## Post-Merge Verification

After merging all agents in a wave:

1. **Check build** (if build command is known):
   ```bash
   npm run build  # or equivalent
   ```

2. **Quick test** (if test command is known):
   ```bash
   npm test  # or equivalent
   ```

3. **Verify file integrity**:
   - All expected files exist
   - No conflict markers remain (`<<<<<<<`, `=======`, `>>>>>>>`)

## Worktree Cleanup

After successfully merging an agent's changes:

```bash
# The worktree should be auto-cleaned by the Task tool
# If manual cleanup needed:
git worktree remove [worktree-path]
git branch -d [agent-branch]
```

## Rollback Strategy

If merge produces broken state:

```bash
# Rollback to pre-merge state
git reset --hard HEAD~[number-of-merges]

# Or rollback to base commit (nuclear option)
git reset --hard [base-commit]
```

## Best Practices

1. **Scope isolation prevents most conflicts**: Each agent only touches assigned files
2. **Merge one at a time**: Even if non-overlapping, merge sequentially to catch issues early
3. **Verify after each merge**: Quick build/test check catches integration issues
4. **Keep base commit**: Always have the escape hatch of rolling back to base
5. **Order matters**: Merge agents in step order (Step 1 before Step 3) for cleaner history
