# Boxer OS knowledge base

This folder is the running memory of the project. It exists so that nobody (human or agent)
has to re-review the codebase from scratch: read these files first, then the code.

| File | What it holds | Who updates it, when |
|---|---|---|
| `product.md` | What the app is for, who it is for, principles, core loop, information architecture, module list, V1 scope, roadmap, open product questions. | Architect when the product direction changes. |
| `architecture.md` | Target layout, module map, data flow, persistence, native bridge, styling. The canonical description of how the code is put together. | Whoever changes structure (new file, new prefs key, new channel method). Developer agents update it in the same task. |
| `backlog.md` | Prioritised list of work with status, plus open decisions. The plan. | Architect at planning and review time. Mark items done when the diff lands. |
| `review-log.md` | Dated review findings with status (open / fixed / refuted / wontfix) and a pointer to the fix. | Architect after each review round. Do not re-report an item already listed. |
| `decisions.md` | Short design decisions and the reason, newest first. | Architect when a choice is made that a later reader might question. |
| `release.md` | Signing setup and the Play release checklist. | Whoever changes the release process. |

## Reading order for a new agent

1. `.claude/CLAUDE.md` (conventions, commands, tiered workflow).
2. `docs/product.md`, then `docs/architecture.md`.
3. `docs/backlog.md` and `docs/review-log.md` for what is known to be wrong or planned.
4. Only then the source files the task touches.

## Rules

- Keep entries short and factual. Link to files with paths, not prose descriptions.
- When something in `architecture.md` is no longer true, fix it in the same change that made it untrue.
- Before starting a review, read `review-log.md`. Reviews add new dated sections; they do not repeat open items.
- Handoff packages under `.claude/handoffs/` are the detailed spec for a change; the backlog links to them.
- No em-dashes, no emoji, plain ASCII.
