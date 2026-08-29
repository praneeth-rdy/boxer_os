# Decisions

Newest first. One entry per decision that a later reader might want to revisit.

## 2026-08-29 Build order: training screen first

The concept document's own advice: prototype the session screen before anything else, because
"a boxer at the gym at 6:00 AM finishing a 45-minute session without looking at the phone" is
the scenario the whole product is judged on. The backlog therefore runs foundation -> models and
library -> session engine -> Train tab, and only then Home, Skills, Progress and Journal.

## 2026-08-29 Local-first, no backend in V1

From the product concept: workouts bundled, history and preferences on the device, analytics
computed locally, no account. Cloud sync is an ecosystem idea, not a V1 constraint. Nothing in
the data model should assume a server, but the models are plain immutable Dart with `toJson`
so a sync layer can be added later without a rewrite.

## 2026-08-29 Same stack as Optum Launcher: `provider` + `shared_preferences`

The sibling project (`../optum_launcher`) settled on `provider` (ChangeNotifier) for state and
`shared_preferences` for preferences, with services as the platform boundary. Boxer OS keeps the
same layering so the conventions, test patterns and agent instructions carry over unchanged.
The history store is a separate decision (backlog D-01) because session records outgrow prefs.

## 2026-08-29 Android-only repository

The scaffold was created for Android only. Boxer OS is Android-first; iOS is not ruled out, but
no platform folder is kept for it until someone builds on it (`flutter create .` regenerates).

## 2026-08-29 Knowledge base lives in `docs/`, conventions stay in `.claude/CLAUDE.md`

`CLAUDE.md` is loaded into every session and holds only what every task needs: commands,
conventions, the tiered workflow. Everything that describes the state of the code (architecture,
findings, plan) lives in `docs/` so it can grow without bloating every prompt, and is updated by
the task that changes it. Copied from Optum Launcher.

## 2026-08-29 Three-tier agent workflow

Architect (Fable 5) plans and reviews; `developer` (Opus) writes all Dart/Kotlin; `assistant`
(Sonnet) writes tests and runs checks. Haiku is not used. Work happens on the checked-out branch,
no worktrees, the user commits, commit messages carry no trailers. See `.claude/CLAUDE.md`.
