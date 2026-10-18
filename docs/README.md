# Boxer OS knowledge base

This folder is the settled knowledge of the project. It exists so that nobody (human or agent)
has to re-review the codebase from scratch: read these files first, then the code.

Two layers, and the difference matters:

- **`docs/` (this folder) is long-term memory.** Curated, reviewed, true for as long as it is
  not corrected. Nothing lands here until it has stopped changing.
- **`memory/` is running memory.** Where the work stands today, what was tried, device quirks,
  open questions. Anyone may write to it; entries are promoted into `docs/` or deleted.
  `memory/README.md` has the full protocol.

Both layers are tool-agnostic: they are written for a human, for Claude Code, for Codex, for any
assistant. Claude Code wiring (agent definitions, handoff packages, the tiered workflow) lives
in `.claude/`. Codex project configuration and setup live in `.codex/`; `AGENTS.md` is its
instruction entry point. Both tools use the same `memory/` and `docs/`.

| File | What it holds | Who updates it, when |
|---|---|---|
| `product.md` | What the app is for, who it is for, principles, core loop, information architecture, module list, V1 scope, roadmap, open product questions. | Architect when the product direction changes. |
| `architecture.md` | Target layout, module map, data flow, persistence, native bridge, styling. The canonical description of how the code is put together. | Whoever changes structure (new file, new prefs key, new channel method). Developer agents update it in the same task. |
| `backlog.md` | Prioritised list of work with status, plus open decisions. The plan. | Architect at planning and review time. Mark items done when the diff lands. |
| `review-log.md` | Dated review findings with status (open / fixed / refuted / wontfix) and a pointer to the fix. | Architect after each review round. Do not re-report an item already listed. |
| `decisions.md` | Short design decisions and the reason, newest first. | Architect when a choice is made that a later reader might question. |
| `release.md` | Signing setup and the Play release checklist. | Whoever changes the release process. |

## Reading order for anyone new, human or agent

1. The repo `README.md` (what the app is, how to run it, the layout of the repo).
2. `memory/current.md`, then the last two or three entries in `memory/log.md`: where the work
   actually stands right now.
3. `docs/product.md`, then `docs/architecture.md`.
4. `docs/backlog.md` and `docs/review-log.md` for what is known to be wrong or planned.
5. Any `memory/notes/` file that names the area you are about to touch.
6. Only then the source files the task touches.

If your tool reads a conventions file of its own (`.claude/CLAUDE.md`, `AGENTS.md`, editor
rules), read it too: it carries the coding conventions and the commands.

## Finishing a piece of work

Whoever did the work, with whatever tool:

1. Rewrite `memory/current.md` so it matches reality, and add one dated entry to `memory/log.md`.
2. If the change added, removed, or renamed a file, a prefs key, or a channel method, fix the
   matching row in `docs/architecture.md` in the same change.
3. If a design call was made that a later reader might question, add it to `docs/decisions.md`.
4. Mark the backlog item in `docs/backlog.md` done, with the date.
5. Leave the change unstaged. The owner reviews and commits.

## Rules

- Keep entries short and factual. Link to files with paths, not prose descriptions.
- When something in `architecture.md` is no longer true, fix it in the same change that made it untrue.
- Before starting a review, read `review-log.md`. Reviews add new dated sections; they do not repeat open items.
- Handoff packages under `.claude/handoffs/` are the detailed spec for a change; the backlog links to them.
- A fact lives in exactly one place. When something moves from `memory/` to `docs/`, delete the
  memory copy.
- No em-dashes, no emoji, plain ASCII.
