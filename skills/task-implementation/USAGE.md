# Task Implementation — Usage

```
"implement plan: <name>"          # looks in <project>/.claude/task/<name>.md
"implement plan: ./path/plan.md"
```

What happens:
1. **Gate 1** — you approve the strategy: branch, steps, review depth per step
   (`full` = dev + reviewer subagents, `light` = dev only, `inline` = orchestrator does it),
   which checks run.
2. **Autonomous loop** — per step: dev subagent implements → orchestrator checks scope and
   re-runs fast checks → reviewer subagent reviews the staged diff → fixes (max 2 rounds) →
   commit `Step N: <title>`. You get one status line per step.
3. **Final** — full check suite from the project's CLAUDE.md, a whole-branch review,
   plan acceptance items, push + PR.
4. **Gate 2** — summary with PR link, check results, anything unresolved.

It only stops mid-run for real blockers: scope outside the plan, unresolved Critical
review issues, checks still red after fixes, or the plan contradicting the code.

**Resume**: re-run the same command on the plan's branch; `Step N:` commits mark done steps.

**Parallel work streams?** Use `"execute complex plan: <path>"` (complex-task-implementation).
