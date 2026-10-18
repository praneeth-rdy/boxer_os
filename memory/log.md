# Work log

Newest first. One entry per work session: what changed, what it means for the next session.

## 2026-10-18 Tests: flake fixed, CI hardened, coverage run

Asked to "set up unit tests and run them on PRs": both already existed (91 test files, CI from
B-03), but the suite was red today. `home_page_test.dart` derived the legend of the week from
`DateTime.now()` and asserted with an unscoped `find.text`; this week the home quote and the
legend both name Sugar Ray Robinson. Scoped the finder; a sweep found no other date-collision
risk. CI gained a `dart format` gate and a concurrency group. Then `2026-10-18-test-coverage`
(tasks 01 to 04): tests for `notification_service`, `wake_lock_service`, `app_motion`,
`reaction_arena` and eight models with logic; `NotificationService` got the providers' `clock`
seam when the first draft of its scheduling tests probed the wall clock at 23:59 / 00:00. Three
packages ran in parallel on disjoint `test/` paths, then one full-suite smoke: 730/730. Two
decisions recorded: the clock-seam rule, and which files stay deliberately untested. Lesson for
the next run: `flutter analyze` rewrites `analysis_options.yaml` on first run; that diff is the
tool, not an agent.

## 2026-10-18 Memory folder added

Added `memory/` as the running-memory layer beside `docs/`: `current.md` (live snapshot),
`log.md` (this file), `notes/` (one topic per file). The protocol itself is tool-agnostic and
lives in `memory/README.md`, `docs/README.md` and the repo `README.md`; `AGENTS.md` is a new
pointer file for assistants that do not read `.claude/`. `.claude/CLAUDE.md`, both agent
definitions and the handoff template now reference it rather than restating it, so every tier
reads memory on entry and writes on exit. No source change; `lib/` and `android/` untouched.
