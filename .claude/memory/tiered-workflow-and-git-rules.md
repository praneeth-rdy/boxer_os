---
name: tiered-workflow-and-git-rules
description: "User runs Flutter projects (boxer_os, optum_launcher) with a three-tier agent workflow, edits on the checked-out branch, no worktrees, no commit trailers"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 486e8909-b144-487a-acce-1dbd4ce07f62
  modified: 2026-08-29T11:42:20.000Z
---

The user's Flutter projects (`boxer_os`, and the reference `../optum_launcher`) follow the same
working rules, spelled out in each repo's `.claude/CLAUDE.md`:

- Three tiers: this session (Fable 5) is the Architect and never edits `lib/` or `android/`;
  `developer` agent (Opus) implements handoff packages; `assistant` agent (Sonnet) writes tests
  and runs smoke checks. Haiku is never used. `/build <goal>` runs the `tiered-build` workflow.
- Work directly on the currently checked-out branch: no worktrees, no new branches.
- Do not commit unless asked; when committing, **no `Co-Authored-By` or `Claude-Session` trailers**,
  conventional-prefix subject (`feat:`, `fix:`, `docs:`, `chore:`).
- Docs live in `docs/` (product, architecture, backlog, review-log, decisions, release) and are
  updated in the same change that makes them stale. Plain ASCII, no em-dashes, no emoji.

**Why:** the user set this up on optum_launcher (2026-08-27) and asked for boxer_os to mirror
it (2026-08-29) so conventions and agent instructions carry across projects.

**How to apply:** before any code change in these repos, write a handoff package under
`.claude/handoffs/<date>-<slug>/` and dispatch a `developer` agent; do not patch Dart yourself.
Related: [[boxer-os-project]]
