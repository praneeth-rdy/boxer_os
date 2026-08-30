# Run 8: Content (2026-08-30)

## Goal

The owner's second content round after using 0.1.0: a much larger, still verifiable quote and
fact library that rotates per surface; a Legends feature (boxers' stories with license-checked
photos, pull quotes and takeaways); a boxing calendar with a page and a Home card; new
reaction drills that train speed with or without boxing context; footwork drills expanded; the
History icon and two combination copy fixes; and the legal layer: PolyForm Noncommercial
license, privacy policy, and an About screen.

Assets already in the repo: `assets/legends/*.jpg` (12 photos, credits in the task-03
package), `LICENSE` (PolyForm Noncommercial 1.0.0).

## Packages, in order

| # | File | Title | Worker | Tests |
|---|---|---|---|---|
| 01 | `task-01.md` | Quotes and facts 2.0 with per-surface rotation | developer | assistant |
| 02 | `task-02.md` | History icon, combination copy, footwork drills expansion | developer | assistant |
| 03 | `task-03.md` | Legends content and model | developer | assistant |
| 04 | `task-04.md` | Legends screens and entry points | developer | assistant |
| 05 | `task-05.md` | Boxing calendar: data, page, Home card, reminder | developer | assistant |
| 06 | `task-06.md` | Reaction drills 3: four speed drills | developer | assistant |
| 07 | `task-07.md` | License, privacy policy, About screen | developer | assistant |

Sequential (`main.dart`, Home, Settings and Skills hub are shared). `buildApk: true`
(new dependency `url_launcher`).

## Done means

- Home, Progress and onboarding show different quotes on the same day; the library holds 80+
  quotes with at least 60 percent from boxers and 40 boxing-only facts.
- Legends: 12 stories readable end to end with photos and credits; entry from Home and Skills.
- Calendar: a page of the year's dates, a Home card on event days, an optional morning
  reminder.
- Four new reaction drills run, score and appear in Progress.
- About screen with developer, brand, logo, version, copyright, license, privacy link, credits.
