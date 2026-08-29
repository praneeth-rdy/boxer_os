# Run 6: Reaction drills (2026-08-29)

## Goal

Three more ways to train reaction, picked by the product owner: **Defense reaction** (an
incoming punch is named, tap the right defense), **Go / No-go** (tap on mint, hold on red), and
the **Endurance 60** format (sixty seconds of continuous trials in any mode, with the decay of
reaction time shown afterwards). Results persist like today's and feed Progress.

Builds on run 2 (`ReactionProvider`, `ReactionArena`, `ReactionPage`), run 3 (history,
Progress reaction section) and run 5 (motion tokens, if landed). Rejected for now: combination
memory, ears-only, two-player, rhythm tap, custom presets.

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Reaction models and engine: modes, formats, scoring | developer | assistant |
| 02 | `task-02.md` | Reaction screens and Progress trend | developer | assistant |

Sequential. `buildApk: false`.

## Done means

- Mode picker offers Tap, Direction, Defense, Go / No-go, with a Standard / Endurance format
  toggle; each runs, scores and saves; Progress shows per-mode bests and the endurance decay.
- Old stored results (no `format`) still load.
