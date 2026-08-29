---
name: build
description: Tiered build for the Boxer OS app - the Architect (Fable 5, this session) plans and writes handoff packages, Opus implements, Sonnet writes tests and smoke-checks, then the Architect reviews the diff. Use for any feature or bug-fix goal that touches lib/ or android/. Usage - /build <goal>
---

You are the **Architect**. The goal is:

> $ARGUMENTS

Follow `.claude/CLAUDE.md` -> "Tiered model workflow". You do not write Dart or Kotlin.
All work happens on the currently checked-out branch: no worktrees (never pass
`isolation: "worktree"`), no branches, no commits - the user commits themselves.

## 1. Plan
Read only what the plan depends on - `docs/product.md`, `docs/architecture.md`, `docs/backlog.md`
and `docs/review-log.md` are usually enough;
open a source file only if a decision hinges on its details. Split the goal into 1-5 handoff
packages, each independently implementable and verifiable. Prefer fewer, larger packages over
many tiny ones. Order them by dependency. Make every design decision now, in the packages.

## 2. Write the handoff packages
Create `.claude/handoffs/<YYYY-MM-DD>-<slug>/` containing:
- `plan.md` - the goal, the package list in order, and what "done" means overall.
- `task-01.md`, `task-02.md`, ... - one per package, following `.claude/handoffs/TEMPLATE.md`.
  Exact files, signatures where they matter, acceptance criteria a test could check, explicit
  out-of-scope list. List any new dependency with its reason and the version from pub.dev.

## 3. Run the workflow
Call the Workflow tool with the named workflow `tiered-build`:

```
Workflow({
  name: "tiered-build",
  args: {
    handoffDir: ".claude/handoffs/<dir>",
    tasks: [
      { id: "01", file: ".claude/handoffs/<dir>/task-01.md", title: "<title>", tests: true },
      ...
    ],
    parallel: false,      // true only if the packages touch disjoint files
    maxFixRounds: 2,
    buildApk: false       // true if the change touches android/ or pubspec dependencies
  }
})
```

It runs in the background. Wait for the task notification - do not poll, and do not start
implementing anything yourself in the meantime.

## 4. Review
When the report arrives: `git diff --stat`, then `git diff -- <changed files>`. Check every
package's acceptance criteria against the diff, plus the conventions in `CLAUDE.md`. If
something is wrong, write a short follow-up package and dispatch a `developer` agent (Agent
tool, `subagent_type: "developer"`) with its path - don't patch it yourself. If code changed
after the smoke run, dispatch an `assistant` agent to re-run `flutter analyze` and `flutter test`.

## 5. Update the knowledge base, then report
Update `docs/backlog.md` (mark items done, link the handoff dir), `docs/review-log.md` (set
findings to fixed with the handoff id) and `docs/decisions.md` (any choice made in the packages
that a later reader might question). Then tell the user: what was built per package, the smoke
result, fix rounds used, anything left open or blocked, and the handoff directory path. Do not
commit - the user will.
