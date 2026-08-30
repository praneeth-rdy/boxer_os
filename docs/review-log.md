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

## 2026-08-30 Round 8: content (`.claude/handoffs/2026-08-30-content`, tasks 01 to 07)

553/553 tests, analyze clean, APK built, no fix rounds.

| ID | Finding | Status |
|---|---|---|
| R8-01 | Task-03's acceptance criteria contradicted its own copy (300-character floor, "quote author matches the legend"); the developer typed the copy exactly and reported PARTIAL rather than pad the stories. Tests written to the corrected rules (140 to 700 characters; legends with quotes of their own must use at least one). | fixed: assistant tests, same day |
| R8-02 | Story page facts strip scaled long values to caption size and inverted the label/value hierarchy on the device. Replaced by wrapping chips. | fixed: `task-08` |
| R8-03 | `url_launcher` also needed a `mailto` VIEW query in the manifest for the Contact row on Android 11+; added by the developer beyond the package. Accepted. | refuted |
| R8-04 | Sound reaction mode plays its beep regardless of the Sound cue setting, because the beep is the stimulus, not a cue. Accepted. | refuted |
| R8-05 | Legends and the calendar were reachable from the Skills hub, which is for drills (owner). Moved to a new fifth tab, Corner. | fixed: `task-08` |
| R8-06 | Country and division eyebrow over the legend photos was unreadable on light backgrounds (owner); the label also collided with the name (device). Text moved to a solid block under the photo; story hero is photo only. | fixed: `task-08` |
| R8-07 | Calendar rows were not tappable (owner). Rows and the Today card open a detail sheet with "Read the legend" for 35 of 39 entries. | fixed: `task-08` |
| R8-08 | Device pass after task-08 (18 screens): five tab labels fit, Corner sections, legend cards and story hero, calendar sheet and "Read the legend", Quotes filter, Facts, Skills with three cards, About with credits all correct; logcat clean. The privacy link opened the GitHub app (installed on the phone) rather than a browser; expected, and it will resolve to the file once the repository is public. | closed |

## 2026-08-30 Round 9: photos and Gym Wall (`2026-08-30-content`, tasks 09 and 10)

623/623 tests, analyze clean, debug APK 179 MB (release will be smaller; the 24 MB of legend
assets is the price of HD photos, decision recorded).

| ID | Finding | Status |
|---|---|---|
| R9-01 | Two Commons author strings came through as "AnonymousUnknown author" transcription artifacts and would show in credits. | fixed: `task-11` |
| R9-02 | `PosterPage` captures the visible preview's `RepaintBoundary` instead of an `Offstage` copy (an offstage boundary never paints). Correct; noted so nobody "fixes" it back. | refuted |
| R9-03 | The archive strip scrolled inside the story page's side padding, clipping photos at the left margin (developer note). Strip now bleeds to the screen edge with inner padding. | fixed: `task-12` |
| R9-04 | Walkthrough reported Frazier, Robinson and Pacquiao cards "cropped to the chin". The captures show those cards scrolled half off the top of the screen; cards in full view (Foreman, Louis, Mayweather, Kom) frame faces correctly at 1:1. Ali, Frazier and Mayweather galleries, the viewer and the hero all verified. | refuted |
| R9-05 | Device pass after tasks 09 to 12: archive strip edge to edge, Gym Wall grid, legend and quote posters render with credit, "Set as lock screen" changed the lock screen; home-screen change could not be seen because the phone's launcher draws no wallpaper. Logcat clean. | closed |

## 2026-08-30 Round 10: Gym Wall content and live wallpaper (tasks 13 and 14)

673/673 tests, analyze clean, APK built. Accepted developer calls: the live picker intent is
started inside try/catch instead of `resolveActivity` (package visibility on Android 11+); a
cancelled render leaves a partial folder and the service paints ink for missing frames until
the next full render. Device check pending.
| R10-01 | First device pass reported the live wallpaper "never activates": the agent tapped Apply on Vivo's preview but not the "Apply to" sheet that follows. Re-tested by the Architect: applying to both screens binds `GymWallService` (`dumpsys wallpaper`: `SET_LIVE`, `mWhich=3`) and three sleep/wake cycles showed three different posters. Page copy updated to name both steps. | fixed: `task-16` |
| R10-02 | No `GymWall` draw-timing lines in logcat; draws are visibly instant on the device, so the timing criterion is dropped. | wontfix |
| R10-03 | "Auto-shuffle" renamed "Live wallpaper" (Android's own term); two provider error strings reworded to "poster selection". | fixed: `task-15`, wording follow-up |
