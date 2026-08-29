# Backlog

Prioritised. Status: todo, in progress, done (with date and handoff dir). `Rn-nn` refers to
`review-log.md`. Handoff packages carry the detailed spec; this file is the map.

Scope comes from `product.md` (V1 table). Build order follows `decisions.md`: foundation, then
the session engine and the Train tab, then the rest.

## Open decisions (settle in the first handoff package that needs each)

| ID | Decision | Options | Status |
|---|---|---|---|
| D-01 | History store for session records | `shared_preferences` JSON list (simplest, fine to a few hundred sessions); `sqflite`; `drift`. Start with the simplest that meets V1 and keep the store behind one service so it can be swapped. | open |
| D-02 | Audio package for bells and cues | `audioplayers`, `just_audio`, or `SystemSound` for a first cut. Needs low latency and playback while the screen is off during a session. | open |
| D-03 | Keeping a session alive with the screen off | wake lock (`wakelock_plus`) keeping the screen on, or a foreground service so audio and timing survive screen-off. Wake lock first; foreground service if daily use shows the screen-on drain matters. | open |
| D-04 | Palette and typefaces | Chosen in B-01 with the session screen prototype; dark, high-contrast, one accent. | open |
| D-05 | Target segment for V1 (product question 1) | beginners / recreational / competitive amateurs / coaches | open |

## Phase 0: foundation

| ID | Item | Status |
|---|---|---|
| B-01 | Replace the scaffold: `AppTheme` (tokens, dark `ThemeData`, `appVersion`), `BoxerOsApp` in `main.dart`, app shell with the four tabs (Home, Train, Skills, Progress) as placeholder pages, `SettingsProvider` (stance, level, sound on/off, haptics on/off), app label `Boxer OS`, delete `widget_test.dart` in favour of tests mirroring `lib/`. Adds `provider` and `shared_preferences`. | todo |
| B-02 | Models and bundled library: `Workout` (name, type, rounds, work/rest durations, cues per round), `RoundSpec`, `SessionRecord`, `Combination`, `Drill`, `JournalEntry`; `lib/data/` with the starter workout library (one per training type) and the punch/defense vocabulary. Unit tests for `toJson`/`fromJson` and the library's invariants. | todo |
| B-03 | CI: `flutter analyze`, `flutter test`, debug APK on PR. | done 2026-08-29: `.github/workflows/ci.yml` |
| B-04 | Release signing from `android/key.properties` with a debug fallback, `key.properties.example`, launcher icon, `docs/release.md` verified against the code. | todo |

## Phase 1: V1 epics

| ID | Epic | Depends on | Status |
|---|---|---|---|
| V-01 | Session engine: `SessionProvider` runs a `Workout` (prepare, work, rest, done) on one `Timer.periodic`; pause/resume/skip/end; 10 s warning and final-30 s cue transitions; records a `SessionRecord` at the end. Pure state, fully unit-testable with `FakeAsync`. | B-01, B-02 | todo |
| V-02 | Cue services: bell and cue audio (D-02), haptics, wake lock (D-03); a `CueController` that listens to `SessionProvider` transitions and fires them. | V-01 | todo |
| V-03 | Session screen: the phone-down screen (round and phase, big countdown, current cue, pause/end pills at 64 dp+), portrait, keeps the screen on, survives backgrounding (D-03). Prototype this first. | V-01, V-02 | todo |
| V-04 | Train tab: workout library list by training type, workout detail, custom session builder (rounds, work, rest, warnings), quick-start timer. | B-02, V-03 | todo |
| V-05 | Guided sessions: per-round instructions and combination prompts from the workout definition, difficulty and stance selection before start, prompts spoken to the screen and cue channel at the right seconds. | V-03, V-04, V-07 | todo |
| V-06 | History and journal: `HistoryProvider` over the store (D-01); post-session sheet with rating, what worked, what needs work, sparring notes (opponent, stance); journal / history list and session detail. | V-01 | todo |
| V-07 | Skills: combination generator (stance-aware, beginner/intermediate/advanced, seeded random so a drill can be repeated), combination practice mode with a timer. | B-02 | todo |
| V-08 | Skills: reaction trainer (direction and punch/defense stimuli, reaction-time scoring, best and average per session, stored in history). | B-02, V-06 | todo |
| V-09 | Skills: footwork drills (bundled drill catalogue with cues, run on the session engine). | B-02, V-01 | todo |
| V-10 | Home: today's workout (simple rule: least-recent training type, or the last workout), start CTA, streak, weekly rounds and minutes, quick access to Timer, Combos and Reaction. | V-04, V-06 | todo |
| V-11 | Progress: training minutes and rounds per week, sparring vs bag vs shadow rounds, streak, session history, basic skill progression from drill history. Charts from local data. | V-06, V-07, V-08 | todo |
| V-12 | Settings and profile: stance, level, sound and haptics, about with version. | B-01 | todo |

## Phase 2: release readiness

| ID | Item | Status |
|---|---|---|
| R-01 | README with screenshots, install steps, and the local-first promise. | todo |
| R-02 | Play Console prep: data-safety form (everything on-device), permission notes, screenshots from a device. | todo |
| R-03 | Device check on a physical phone: bells audible over gym noise, haptics through a glove, screen legible at arm's length, session survives a screen-off and a phone call. | todo |
