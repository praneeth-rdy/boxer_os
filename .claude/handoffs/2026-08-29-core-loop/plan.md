# Run 1: core loop (2026-08-29)

## Goal

Turn the `flutter create` scaffold into the first usable Boxer OS: the design system, the app
shell, the workout models and bundled library, the session engine, the cue services (bells,
haptics, spoken cues, wake lock), the phone-down session screen and the Train tab. After this run
a boxer can pick a workout or set a quick timer, put the phone down, and complete a full session
guided by bells, buzzes and spoken combinations.

Product answers this run builds on: `docs/product.md` ("Answered questions", "Look and feel")
and `docs/decisions.md` (2026-08-29 entries). Assets already in the repo: `assets/fonts/`
(Bebas Neue, Inter 400/500/600/700, OFL) and `assets/audio/` (`bell_start.wav`,
`bell_end.wav`, `beep_warning.wav`, `beep_final.wav`, `tick_cue.wav`).

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Design system, app shell, settings | developer | assistant |
| 02 | `task-02.md` | Models and the bundled workout library | developer | assistant |
| 03 | `task-03.md` | Session engine | developer | assistant |
| 04 | `task-04.md` | Cue services and the cue controller | developer | assistant |
| 05 | `task-05.md` | Session screen and Train tab | developer | assistant |

Sequential: 02 depends on 01 (enums, theme), 03 on 02, 04 on 03, 05 on all.

## Done means

- `flutter analyze` 0 issues, `flutter test` green, `flutter build apk --debug` succeeds.
- On the attached device: app launches to the shell, Train tab lists 12 workouts, quick timer
  starts a session, the session screen shows the countdown at arm's-length size, the bell rings at
  round start and end, the phone buzzes, cues are spoken, the screen stays on, pause/end work,
  the complete screen shows rounds and minutes.
- `docs/architecture.md` module map, persistence and native bridge sections describe the code
  as it now is.
