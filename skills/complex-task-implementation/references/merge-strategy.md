# Merge Strategy Reference

Loaded when merging teammate results or handling merge conflicts.

## Git Worktree Basics

Each developer teammate works in an isolated copy of the repository (worktree or separate branch). The teammate makes changes without affecting the main working tree.

When a developer teammate completes their step (after duo review approval):
- Their changes exist on a separate branch, not yet on the main branch
- The worktree is preserved because changes were made
- The orchestrator merges results after all duos in the wave complete

## Merge Process

### Step 1: Verify No Overlaps

Before merging, check if any two developer teammates in the same wave modified the same file:

```bash
# For each teammate's branch, get list of changed files
git diff --name-only main..[teammate-branch-1]
git diff --name-only main..[teammate-branch-2]
# Compare lists for overlaps
```

### Step 2: Non-Overlapping Changes (Expected Case)

When teammates modified different files (the normal case due to scope restriction):

**Option A: Sequential merge (simple)**
```bash
# Merge each teammate's branch sequentially
git merge [teammate-branch-1] --no-edit
git merge [teammate-branch-2] --no-edit
```

**Option B: Cherry-pick (more controlled)**
```bash
# Cherry-pick each teammate's commits
git cherry-pick [teammate-commit-1]
git cherry-pick [teammate-commit-2]
```

Prefer Option A for cleaner history. Use Option B when you need granular control.

### Step 3: Overlapping Changes (Conflict Case)

If two teammates modified the same file (should be rare due to dependency analysis):

1. **Attempt auto-merge**: Git may resolve automatically if changes are in different sections
   ```bash
   git merge [teammate-branch] --no-edit
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

   Developer A (Step X) changed: [description]
   Developer B (Step Y) changed: [description]

   These changes conflict. How should I resolve?
   A) Keep Developer A's changes (Step X)
   B) Keep Developer B's changes (Step Y)
   C) Let me resolve manually
   ```

## Post-Merge Verification

After merging all teammates in a wave:

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

After successfully merging a teammate's changes:

```bash
# The worktree should be auto-cleaned
# If manual cleanup needed:
git worktree remove [worktree-path]
git branch -d [teammate-branch]
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

1. **Scope isolation prevents most conflicts**: Each developer teammate only touches assigned files
2. **Merge one at a time**: Even if non-overlapping, merge sequentially to catch issues early
3. **Verify after each merge**: Quick build/test check catches integration issues
4. **Keep base commit**: Always have the escape hatch of rolling back to base
5. **Order matters**: Merge teammates in step order (Step 1 before Step 3) for cleaner history
6. **Duo review before merge**: Each teammate's code is already reviewed by their paired reviewer before merging
