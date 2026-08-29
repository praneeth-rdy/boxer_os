# Review log

Every finding ever raised, with status. Read this before reviewing; add a new dated section for
new findings only. Status values: open, planned (links a handoff task), fixed (links the handoff
dir that fixed it), refuted, wontfix.

IDs are stable: `R1-nn` is the first review round.

## 2026-08-29 Round 0: scaffold

No code review yet: the repository is a `flutter create` scaffold. `flutter analyze` baseline
is 0 issues. The first review round happens after backlog B-01 lands.

## 2026-08-29 Round 1: core loop (`.claude/handoffs/2026-08-29-core-loop`, tasks 01 to 05)

| ID | Finding | Status |
|---|---|---|
| R1-01 | `SessionProvider.resume()` rebuilt `phaseSeconds` from the remaining seconds (as task-03 specified), so the session progress bar emptied after every pause. Shift the deadline instead. | fixed: `2026-08-29-core-loop/task-06` |
| R1-02 | `cueToSpeech` replaced every hyphen, turning the library cues `push-ups`, `pull-ups` and `med-ball slams` into "push, ups". Expand hyphens only inside punch chains. | fixed: `2026-08-29-core-loop/task-06` |
| R1-03 | `AudioService.init()` ran lazily on the first play, so the opening bell paid the audio-context setup. Initialise from the `CueController` constructor. | fixed: `2026-08-29-core-loop/task-06` |
| R1-04 | `docs/architecture.md` still said the audio assets were "not played yet" after task-04. | fixed: Architect edit, same day |
| R1-05 | On-device check incomplete: the phone's proximity sensor reported "covered" during the run, so only the Train tab was captured. Session screen, bells, haptics and TTS still need a physical check. | open: needs the phone face-up |

## 2026-08-29 Round 2: skills (`.claude/handoffs/2026-08-29-skills`, tasks 01 to 03)

Device walkthrough (19 screens, I2214): no overflow, no clipped text, clean logcat. Session
screen, end dialog, complete state, Skills hub, Combos, Reaction and Footwork all match spec.

| ID | Finding | Status |
|---|---|---|
| R2-01 | Beginner combinations reach 13 distinct notations over 20 seeds, not the 15 the package asked for: three punches and 2 to 3 moves cannot spread further. Threshold set to 10 for beginner in the tests; vocabulary unchanged on purpose. | wontfix (spec) |
| R2-02 | Alternation and the `1-1` repeat rule apply per punch chain, so `4, slip, 4` is reachable. Boxing-plausible; left as is. | wontfix |
| R2-03 | `ReactionPage` defers `cancel()` to a post-frame callback in `dispose` because notifying during unmount asserts. Correct; noted so nobody "simplifies" it. | refuted |

## 2026-08-29 Round 3: memory (`.claude/handoffs/2026-08-29-memory`, tasks 01 to 03)

Device check: empty states, Settings and the journal sheet captured; the history views could
not be reached because skipped rounds do not count (by design) and the walkthrough only skipped.

| ID | Finding | Status |
|---|---|---|
| R3-01 | Home streak strip wraps the "No streak yet" message into three lines beside the weekly caption. Two-row layout. | planned: `2026-08-29-experience/task-04` |
| R3-02 | Skipping the last round reaches `_finish(completed: true)`, so a record can be `completed` with zero rounds ("SESSION COMPLETE, 0/3"). `completed` must require every round. | fixed: `2026-08-29-memory/task-04` |
| R3-03 | Journal hint text in `chalkMuted` reads like an entry. Use `chalkFaint`. | fixed: `2026-08-29-memory/task-04` |
| R3-04 | Empty Progress and Journal states are plain ("No sessions yet"). Designed empty states with messaging arrive with E-04. | planned: `2026-08-29-experience/task-04` |
| R3-05 | Progress header's "Journal" is a bare red `TextButton` and does not read as tappable (owner feedback). Replace with an outlined pill (book icon, chevron) under the header; underline the remaining text link on Home. | planned: `2026-08-29-experience/task-06` |

## 2026-08-29 Round 5: experience (`.claude/handoffs/2026-08-29-experience`, tasks 01 to 06)

| ID | Finding | Status |
|---|---|---|
| R5-01 | The boxing grammar in task-02 rejected five correct library combinations (`1-2-1`, `1-1b`, `1-2-3-2b`, `1-2, pull, 3-2`, `1, slip, 1, slip, 2`); the developer rightly refused to edit either side. Rules relaxed and two table rows extended; the high-low jab is exempted like the double jab. | fixed: `task-07` |
| R5-02 | Task-05 needed core library desugaring and multidex in `build.gradle.kts` for flutter_local_notifications 22; not in the package's file list, added by the developer with a comment. Accepted. | refuted |
| R5-03 | `StatTile.value` became an `int` for `CountUpText`; `session_detail_page.dart` was updated outside task-06's file list. Accepted; the rating tile uses `StatTile.text`. | refuted |
| R5-04 | Settings: after granting the notification permission, the "Daily reminder" switch stays off until tapped a second time (device walkthrough). | fixed: `task-08` + `task-09` |
| R5-05 | Progress stat tiles: "ROUNDS THIS WEEK" and "MINUTES THIS WEEK" wrap to three lines in a three-tile row. Use "WEEK ROUNDS", "WEEK MINUTES", "DAY STREAK". | fixed: `task-09` |
| R5-06 | The streak-nudge switch does not go through the notification permission flow, so it can be turned on with notifications denied and never fire. Share the daily reminder's flow. | fixed: `task-09` |

## 2026-08-29 Round 6: reaction drills (`.claude/handoffs/2026-08-29-reaction-drills`)

431/431 tests, analyze clean, no fix rounds. Accepted developer decisions: a false alarm
consumes the trial; half averages use symmetric halves; standard-format `durationSeconds`
excludes the final feedback tail; the old "average of bests" caption under the Progress chart
was replaced by the per-mode BEST tiles. No findings.
| R5-07 | The outlined "Journal" pill (R3-05 fix) reads as old-school and off-system (owner feedback). Replace with the Skills-hub card row (`SkillCard`) with a sessions-logged caption. | fixed: `task-10`; wording changed to "History" in `task-11` |

## 2026-08-29 Round 7: release (`.claude/handoffs/2026-08-29-release`)

Signing verified with `apksigner` for both the debug fallback and an upload key; the corner-ropes
adaptive icon confirmed on the device; README with six device screenshots; Play Console notes
with the merged permission list. No findings. Owner follow-ups still open: R-03 physical check
(bells over gym noise, haptics through a glove, phone call mid-round) and confirming the "jab"
pronunciation after the en-US voice fix.
