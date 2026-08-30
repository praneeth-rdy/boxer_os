# Backlog

Prioritised. Status: todo, in progress, done (with date and handoff dir). `Rn-nn` refers to
`review-log.md`. Handoff packages carry the detailed spec; this file is the map.

Scope comes from `product.md` (V1 table). Build order follows `decisions.md`: foundation, then
the session engine and the Train tab, then the rest.

## Open decisions (settle in the first handoff package that needs each)

| ID | Decision | Options | Status |
|---|---|---|---|
| D-01 | History store for session records | `shared_preferences` JSON list (simplest, fine to a few hundred sessions); `sqflite`; `drift`. Start with the simplest that meets V1 and keep the store behind one service so it can be swapped. | decided 2026-08-29: prefs JSON list behind `HistoryStore` (run 3) |
| D-02 | Audio package for bells and cues | `audioplayers`, `just_audio`, or `SystemSound` for a first cut. Needs low latency and playback while the screen is off during a session. | decided 2026-08-29: `audioplayers` 6.7.1 + `flutter_tts` for spoken cues |
| D-03 | Keeping a session alive with the screen off | wake lock (`wakelock_plus`) keeping the screen on, or a foreground service so audio and timing survive screen-off. Wake lock first; foreground service if daily use shows the screen-on drain matters. | decided 2026-08-29: `wakelock_plus`, no foreground service |
| D-04 | Palette and typefaces | Chosen in B-01 with the session screen prototype; dark, high-contrast, one accent. | decided 2026-08-29: blackout + hot red accent, Bebas Neue + Inter (see `product.md`, Look and feel) |
| D-05 | Target segment for V1 (product question 1) | beginners / recreational / competitive amateurs / coaches | decided 2026-08-29: beginners, competitive amateurs and pros together; difficulty picker everywhere |

## Phase 0: foundation

| ID | Item | Status |
|---|---|---|
| B-01 | Replace the scaffold: `AppTheme` (tokens, dark `ThemeData`, `appVersion`), `BoxerOsApp` in `main.dart`, app shell with the four tabs (Home, Train, Skills, Progress) as placeholder pages, `SettingsProvider` (stance, level, sound on/off, haptics on/off), app label `Boxer OS`, delete `widget_test.dart` in favour of tests mirroring `lib/`. Adds `provider` and `shared_preferences`. | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-01) |
| B-02 | Models and bundled library: `Workout` (name, type, rounds, work/rest durations, cues per round), `RoundSpec`, `RoundCue`, `SessionRecord`; `lib/data/` with the twelve-workout starter library. `Combination`, `Drill` and the vocabulary move to run 2 (Skills); `JournalEntry` folds into `SessionRecord` (run 3). Unit tests for `toJson`/`fromJson` and the library's invariants. | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-02) |
| B-03 | CI: `flutter analyze`, `flutter test`, debug APK on PR. | done 2026-08-29: `.github/workflows/ci.yml` |
| B-04 | Release signing from `android/key.properties` with a debug fallback, `key.properties.example`, launcher icon, `docs/release.md` verified against the code. | done 2026-08-29: `.claude/handoffs/2026-08-29-release` (task-01) |

## Build runs

1. `2026-08-29-core-loop`: B-01, B-02, V-01, V-02, V-03, V-04 (this run).
2. `2026-08-29-skills`: V-07, V-08, V-09 (done 2026-08-29).
3. `2026-08-29-memory`: V-06, V-10, V-11, V-12, V-13 (done 2026-08-29).
5. `2026-08-29-experience`: E-01 to E-06 (done 2026-08-29).
6. `2026-08-29-reaction-drills`: E-07 (done 2026-08-29).
7. `2026-08-29-release`: B-04, R-01, R-02 (done 2026-08-29). R-03 is the owner's physical check.
8. `2026-08-30-content`: C-01 to C-07 (done 2026-08-30, device review pending).
4. Polish: B-04, R-01, R-02, R-03.

## Phase 1: V1 epics

| ID | Epic | Depends on | Status |
|---|---|---|---|
| V-01 | Session engine: `SessionProvider` runs a `Workout` (prepare, work, rest, done) on one `Timer.periodic`; pause/resume/skip/end; 10 s warning and final-30 s cue transitions; records a `SessionRecord` at the end. Pure state, fully unit-testable with `FakeAsync`. | B-01, B-02 | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-03) |
| V-02 | Cue services: bell and cue audio (D-02), haptics, wake lock (D-03); a `CueController` that listens to `SessionProvider` transitions and fires them. | V-01 | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-04) |
| V-03 | Session screen: the phone-down screen (round and phase, big countdown, current cue, pause/end pills at 64 dp+), portrait, keeps the screen on, survives backgrounding (D-03). Prototype this first. | V-01, V-02 | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-05); device check R1-05 open |
| V-04 | Train tab: workout library list by training type, workout detail, custom session builder (rounds, work, rest, warnings), quick-start timer. | B-02, V-03 | done 2026-08-29: `.claude/handoffs/2026-08-29-core-loop` (task-05); device check R1-05 open |
| V-05 | Guided sessions: per-round instructions and combination prompts from the workout definition, difficulty and stance selection before start, prompts spoken to the screen and cue channel at the right seconds. | V-03, V-04, V-07 | done 2026-08-29: cues spoken and shown per round since `2026-08-29-core-loop` (task-04/05); stance and level live in Settings and onboarding rather than a pre-start picker (decision in task-05) |
| V-06 | History and journal: `HistoryProvider` over the store (D-01); post-session sheet with rating, what worked, what needs work, sparring notes (opponent, stance); journal / history list and session detail. | V-01 | done 2026-08-29: `.claude/handoffs/2026-08-29-memory` (task-01) |
| V-07 | Skills: combination generator (stance-aware, beginner/intermediate/advanced, seeded random so a drill can be repeated), combination practice mode with a timer. | B-02 | done 2026-08-29: `.claude/handoffs/2026-08-29-skills` (task-01) |
| V-08 | Skills: reaction trainer (direction and punch/defense stimuli, reaction-time scoring, best and average per session, stored in history). | B-02, V-06 | done 2026-08-29: `.claude/handoffs/2026-08-29-skills` (task-02) |
| V-09 | Skills: footwork drills (bundled drill catalogue with cues, run on the session engine). | B-02, V-01 | done 2026-08-29: `.claude/handoffs/2026-08-29-skills` (task-03) |
| V-10 | Home: today's workout (simple rule: least-recent training type, or the last workout), start CTA, streak, weekly rounds and minutes, quick access to Timer, Combos and Reaction. | V-04, V-06 | done 2026-08-29: `.claude/handoffs/2026-08-29-memory` (task-03) |
| V-13 | Milestone badges: first session, 100 rounds, 7-day streak, reaction PB; shown on Progress. No XP or levels (decision 2026-08-29). | V-06, V-08 | done 2026-08-29: `.claude/handoffs/2026-08-29-memory` (task-02) |
| V-11 | Progress: training minutes and rounds per week, sparring vs bag vs shadow rounds, streak, session history, basic skill progression from drill history. Charts from local data. | V-06, V-07, V-08 | done 2026-08-29: `.claude/handoffs/2026-08-29-memory` (task-02) |
| V-12 | Settings and profile: stance, level, sound and haptics, about with version. | B-01 | done 2026-08-29: `.claude/handoffs/2026-08-29-memory` (task-03) |

## Phase 1b: experience (product owner asks after using runs 1 and 2)

| ID | Item | Status |
|---|---|---|
| E-01 | Bells on the media stream at full volume; explicit en-US voice; Settings "Test voice". | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-01) |
| E-02 | Boxing grammar, 60-entry named combination library, grammar-driven generator. | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-02, task-07) |
| E-03 | Combos 2.0: Library and Saved views, bookmarks, practice from saved. | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-03) |
| E-04 | Onboarding, quotes, did-you-know facts, empty states, shell tab provider. | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-04) |
| E-05 | Reminders: daily at a chosen time plus the streak nudge. | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-05) |
| E-07 | Reaction drills: Defense reaction, Go / No-go, Endurance 60 format, per-mode Progress bests, "Went the minute" badge. | done 2026-08-29: `.claude/handoffs/2026-08-29-reaction-drills` |
| E-06 | Motion pass with reduce-motion support. | done 2026-08-29: `.claude/handoffs/2026-08-29-experience` (task-06) |

## Phase 1c: content (owner asks after 0.1.0)

| ID | Item | Status |
|---|---|---|
| C-01 | 81 quotes (64 percent boxing), 40 boxing facts, per-surface rotation, tap for another. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-01) |
| C-02 | History icon, c37/c41/c57 copy, footwork drills 5 to 10. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-02) |
| C-03 | Legends: 12 stories with license-checked Commons photos. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-03) |
| C-04 | Legends screens, Home feature, Skills card. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-04) |
| C-05 | Boxing calendar (39 dates), page, Home card, 09:00 reminder. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-05) |
| C-06 | Reaction drills: Peripheral, Colour call, Sequence, Sound. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-06) |
| C-07 | PolyForm Noncommercial license, privacy policy, About screen, url_launcher. | done 2026-08-30: `.claude/handoffs/2026-08-30-content` (task-07) |
| C-08 | Corner tab (legends, calendar, quotes and facts library), legend cards with text below the photo, calendar detail sheet. | done 2026-08-30: `task-08`, device checked |
| C-09 | Legend photo crops and focal points, HD re-export, archive galleries (34 photos), own quotes only, Corner and Legends icons. | done 2026-08-30: `task-09`, device checked |
| C-10 | Gym Wall: quote, legend and tagline posters set as home or lock wallpaper via `boxer_os/wallpaper`. | done 2026-08-30: `task-10`, lock screen verified on the device (the phone's text-only launcher cannot show a home wallpaper) |
| C-11 | Credit string cleanup and full-bleed archive strip. | done 2026-08-30: `task-11`, `task-12` |
| C-12 | Gym Wall: Moments (34 archive photos) and Inspiration (14 atmosphere photos) posters. | done 2026-08-30: `task-13` |
| C-13 | Gym Wall Live: live wallpaper cycling pre-rendered posters on every screen-on; shuffle all or pick a few. | done 2026-08-30: `task-14`; verified on the Vivo phone: three wakes, three posters, both screens |
| C-14 | Live wallpaper page copy for OEM apply screens, status refresh on resume; "Live wallpaper" naming. | done 2026-08-30: `task-15`, `task-16` |

## Phase 2: release readiness

| ID | Item | Status |
|---|---|---|
| R-01 | README with screenshots, install steps, and the local-first promise. | done 2026-08-29: `.claude/handoffs/2026-08-29-release` (task-02) |
| R-02 | Play Console prep: data-safety form (everything on-device), permission notes, screenshots from a device. | done 2026-08-29: `docs/release.md` Play Console notes; store set via `tool/store_assets.py` |
| R-03 | Device check on a physical phone: bells audible over gym noise, haptics through a glove, screen legible at arm's length, session survives a screen-off and a phone call. | todo |
