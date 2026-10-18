# Running memory

Working memory for anyone on this project, human or agent. `docs/` holds what is settled and
curated; this folder holds what is still in motion: where the work stands right now, what was
tried and did not work, device quirks, half-answered questions. Read it at the start of a
session, write to it at the end.

Anyone may write here, at any tier. `docs/` stays curated by the Architect.

## Layout

| Path | What it holds | How it is written |
|---|---|---|
| `current.md` | The live snapshot: what is in flight, the next step, what is blocked. | Overwritten. Keep it under one screen; if it is stale it is worse than empty. |
| `log.md` | Dated entries, newest first: what happened in a work session and what it means for the next one. | Appended at the top. Five to ten lines per entry. |
| `notes/<slug>.md` | One topic per file: a gotcha, a device behaviour, a dead end, an open question that is not yet a backlog item. | Created and deleted freely. Delete the file when it is promoted or no longer true. |

## How to use it

**Starting work:** read `current.md`, then the last two or three entries in `log.md`, then any
`notes/` file that names the area you are about to touch. That plus `.claude/CLAUDE.md` and
`docs/architecture.md` should be enough to begin without re-reading the codebase.

**Finishing work:** rewrite `current.md` to match reality and add one entry to `log.md`. If you
learned something a future reader would otherwise rediscover the hard way, add a `notes/` file.
If you proved something wrong, delete or correct the note that said it.

## Promotion: memory is temporary, docs are permanent

A memory entry earns its place in `docs/` once it stops changing. Move it and delete it here:

| When a note becomes | It belongs in |
|---|---|
| a fact about how the code is put together (file, prefs key, channel method) | `docs/architecture.md` |
| a design call a later reader might question | `docs/decisions.md` |
| a piece of work to schedule | `docs/backlog.md` |
| a review finding | `docs/review-log.md` |
| product direction or scope | `docs/product.md` |

Nothing is ever duplicated: once it is in `docs/`, the memory copy goes away and the note
becomes a one-line pointer, or nothing at all.

## Rules

- Facts and pointers, not narrative. File paths and IDs (`R1-05`, `C-14`), not prose summaries.
- No raw build or test output. Summarise as `file:line - message`, five lines at most.
- No secrets: no keystore passwords, no signing config, no personal data.
- Record what was verified and how (device, emulator, test), and what was only assumed.
- House style applies: no em-dashes, no emoji, plain ASCII.
- When memory and `docs/` disagree, `docs/` wins. Fix whichever one is wrong in that same session.
