# Run 5: Experience (2026-08-29)

## Goal

Everything the product owner asked for after using runs 1 and 2 on the phone: louder bells on
the media stream, a US-English voice that says "jab" properly (with a test button), a real
combination library with a boxing grammar behind the generator, bookmarks and practice from
saved combos, reminders (daily plus a streak nudge), first-launch onboarding, designed empty
states with real attributed quotes, and a motion pass that makes the app feel alive without
turning it into a toy.

Builds on runs 1 to 3. Assets already in the repo: regenerated `assets/audio/*.wav` (0.95 peak),
`assets/icon/` (the "1-2" mark, applied by run 4).

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Bells on the media stream, US voice, test button | developer | assistant |
| 02 | `task-02.md` | Combination library and the boxing-grammar generator | developer | assistant |
| 03 | `task-03.md` | Combos 2.0 screens: library, saved, practice | developer | assistant |
| 04 | `task-04.md` | Onboarding, quotes and empty states | developer | assistant |
| 05 | `task-05.md` | Reminders | developer | assistant |
| 06 | `task-06.md` | Motion pass | developer | assistant |

Sequential. `buildApk: true` (new plugins, manifest changes).

## Done means

- Bells are loud at media volume; "jab, cross, lead hook" sounds right from Settings > Test voice.
- Combos: 60 named combinations browsable by difficulty and style, every generated combination
  obeys the grammar, bookmarks survive a restart, practice runs from saved combos.
- First launch shows onboarding once; Home and Progress never look blank; quotes are real and
  attributed.
- Reminders fire at the chosen time and the streak nudge only on days without a session.
- Animations respect the system's reduce-motion setting.
