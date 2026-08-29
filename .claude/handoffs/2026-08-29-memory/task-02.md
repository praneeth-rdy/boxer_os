# Task 02 - Progress tab, journal list, milestones

- **Run:** `.claude/handoffs/2026-08-29-memory/`
- **Depends on:** task-01
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The Progress tab: this week's rounds and minutes, the streak, a 7-day minutes chart, the
week's split by training type, the reaction-time trend, milestone badges, and a link to the
journal, a newest-first list of sessions with a read-only detail page and delete.

## Context the worker needs
- `HistoryProvider`, `TrainingStats`, date helpers from task-01. `ReactionResult` from run 2.
- Charts are drawn with plain widgets (`Row` of `Expanded` bars); no chart package.
- `docs/product.md` "Answered questions" 4 (actionable metrics only) and 8 (streak plus a
  small set of milestone badges, no XP).

## Files
- `lib/models/milestone.dart` - create - `Milestone`.
- `lib/utils/milestones.dart` - create - `computeMilestones`.
- `lib/widgets/stat_tile.dart` - create - `StatTile`.
- `lib/widgets/bar_chart.dart` - create - `BarChart`.
- `lib/widgets/milestone_badge.dart` - create - `MilestoneBadge`.
- `lib/widgets/session_tile.dart` - create - `SessionTile`.
- `lib/pages/progress_page.dart` - rewrite.
- `lib/pages/journal_page.dart` - create.
- `lib/pages/session_detail_page.dart` - create.
- `docs/architecture.md` - modify - rows.

## Spec

### `Milestone`
`const Milestone({required String id, required String title, required String description, required IconData icon, required bool achieved})`.

### `computeMilestones(TrainingStats stats, List<ReactionResult> reactions)` -> `List<Milestone>`
Fixed order, always all seven returned with `achieved` set:
| id | title | achieved when |
|---|---|---|
| `first_session` | First bell | `totalSessions >= 1` |
| `ten_sessions` | Ten sessions | `totalSessions >= 10` |
| `hundred_rounds` | 100 rounds | `totalRounds >= 100` |
| `five_hundred_rounds` | 500 rounds | `totalRounds >= 500` |
| `streak_seven` | 7-day streak | `streakDays >= 7` |
| `reaction_250` | Under 250 ms | any `reactions.bestMillis` `< 250` |
| `all_types` | Full arsenal | `lastTrainedByType` covers shadow, heavy bag, footwork, conditioning and sparring |
Icons: `Icons.notifications_active_rounded`, `Icons.repeat_rounded`, `Icons.sports_mma_rounded`,
`Icons.military_tech_rounded`, `Icons.local_fire_department_rounded`, `Icons.bolt_rounded`,
`Icons.grid_view_rounded`.

### `StatTile`
`const StatTile({required String value, required String label, Color? accent})`: `surface`
card, `radiusMd`, padding `spaceMd`, value in `displayMedium` (coloured `accent` when given),
label uppercase `label`. Used in `Row`s of `Expanded`s with `spaceSm` gaps.

### `BarChart`
`const BarChart({required List<int> values, required List<String> labels, Color color = AppTheme.accent, double height = 120})`.
A `Row` of `Expanded` columns; each bar is a `FractionallySizedBox` with `heightFactor =
value / max` (max at least 1) on a `line`-coloured track, `radiusSm` top corners, the label in
`caption` under it. Bars for the current day (last) use `color`, earlier ones
`color.withValues(alpha: 0.55)`. Empty values render an empty track.

### `MilestoneBadge`
`const MilestoneBadge({required Milestone milestone})`: 96 dp wide column, a 56 dp circle
(`accent` at 0.18 alpha with `accent` icon when achieved; `surfaceRaised` with `chalkFaint`
icon when not), title in `caption` centred, 2 lines max. Unachieved badges are at 0.6 alpha.

### `SessionTile`
`const SessionTile({required SessionRecord record, required VoidCallback onTap})`: like
`WorkoutTile`: name in `title`, second line `caption` "{type.label} · {roundsCompleted} rounds ·
{workMinutes} min" plus " · ended early" when not completed; right side the rating as
"{rating}/5" in `displaySmall` or "--" in `chalkFaint`.

### `ProgressPage` (rewrite, `Consumer<HistoryProvider>`)
Compute `stats = TrainingStats.fromSessions(history.sessions, now: DateTime.now())` once per
build. `ListView` padded `spaceLg`:
1. `SectionHeader(title: 'Progress', eyebrow: 'ROUNDS, MINUTES, STREAK', trailing: TextButton
   'Journal')` pushing `JournalPage`.
2. Row of three `StatTile`s: `weekRounds` "ROUNDS THIS WEEK", `weekMinutes` "MINUTES THIS WEEK",
   `streakDays` "DAY STREAK" (accent `rest` when `> 0`).
3. Eyebrow "LAST 7 DAYS", `BarChart(values: minutesByDay, labels: weekday initials ending today)`.
4. Eyebrow "THIS WEEK BY TYPE": one row per entry of `weekRoundsByType` sorted by rounds
   descending: type label in `body`, a thin `FractionallySizedBox` bar (`rest` colour) scaled
   to the largest entry, rounds in `bodyStrong`. If empty: `bodyMuted` "No rounds yet this week."
5. Eyebrow "REACTION", if `history.reactions` is non-empty: `BarChart` of the last 10
   `bestMillis` (oldest to newest, labels blank, colour `warning`) with a `caption` line
   "Best {min} ms · average of bests {avg} ms"; else `bodyMuted` "Run the reaction trainer to
   see a trend."
6. Eyebrow "MILESTONES", a horizontal `SingleChildScrollView` `Row` of `MilestoneBadge`s.
7. Eyebrow "ALL TIME": row of `StatTile`s `totalSessions` SESSIONS, `totalRounds` ROUNDS,
   `totalMinutes` MINUTES.
Empty history (no counted sessions): after the header show a `surface` card with "No
sessions yet" in `displayMedium` and "Finish a session to start your record." in `bodyMuted`,
then still render the milestones row (all unachieved). Skip sections 3 to 5 and 7.

### `JournalPage`
Transparent `AppBar` with back; `SectionHeader(title: 'Journal', eyebrow: 'SESSION HISTORY')`;
sessions grouped by day: a `label` header ("TODAY", "YESTERDAY", else "MON 24 AUG" via manual
formatting, no `intl`), then `SessionTile`s; tap pushes `SessionDetailPage(id)`. Empty: `bodyMuted`
"Nothing logged yet."

### `SessionDetailPage`
`const SessionDetailPage({required String id})`, reads `history.findSession(id)` (if null,
"Session not found"). Transparent app bar with back and a delete icon (`Icons.delete_outline_rounded`)
that confirms via `AlertDialog` ("Delete this session?") then `deleteSession` and pops. Body:
eyebrow type + date/time, name in `displayLarge`, stat cells (rounds "{c}/{p}", minutes,
rating "{r}/5" or "--"), then, for each non-null text: eyebrow ("WHAT WORKED", "WHAT NEEDS
WORK", "OPPONENT" with the stance label appended) and the text in `body`. Ended-early
sessions show "Ended early" in `caption` under the name.

### docs/architecture.md
Rows for every new file; "Navigation" gains Journal and detail routes.

## Out of scope
- Editing a saved session. Home and Settings (task-03).
- Any new dependency (no `intl`, no chart package).

## Acceptance criteria
- [ ] `computeMilestones` returns seven entries in order; the thresholds above flip each one.
- [ ] Progress with empty history shows "No sessions yet" and seven unachieved badges; with
      two sessions this week shows the correct rounds, minutes and streak tiles.
- [ ] Journal lists sessions newest first under day headers; detail shows the journal texts;
      delete removes the record from the provider.
- [ ] `BarChart` with all-zero values renders without error; the last bar is the accent colour.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/utils/milestones_test.dart`, `test/pages/progress_page_test.dart`,
  `test/pages/journal_page_test.dart`, `test/pages/session_detail_page_test.dart`,
  `test/widgets/bar_chart_test.dart`. Seed `HistoryProvider` via `SharedPreferences.
  setMockInitialValues({'session_records': jsonEncode([...])})` or `addSession` on a loaded
  provider.
