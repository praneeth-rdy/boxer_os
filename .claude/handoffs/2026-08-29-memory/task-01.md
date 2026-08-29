# Task 01 - History store, provider, stats and the journal sheet

- **Run:** `.claude/handoffs/2026-08-29-memory/`
- **Depends on:** run 2 complete
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Sessions and reaction results persist on the device. The session-complete screen becomes the
journal: rate the session, note what worked and what needs work, add opponent notes for
sparring, save. A `TrainingStats` helper turns history into the numbers Home and Progress show.

## Context the worker needs
- `docs/decisions.md` "Providers read `shared_preferences` directly; only history gets a
  service" and backlog D-01.
- `lib/models/session_record.dart` (extend), `lib/models/reaction_result.dart` (run 2),
  `lib/pages/session_complete_page.dart` (rewrite), `lib/pages/reaction_page.dart` (save the
  result), `lib/main.dart` (add the provider).
- `.claude/CLAUDE.md` "Conventions": storage errors never reach the UI.

## Files
- `lib/models/session_record.dart` - modify - journal fields.
- `lib/services/history_store.dart` - create - `HistoryStore`.
- `lib/providers/history_provider.dart` - create - `HistoryProvider`.
- `lib/utils/date_helpers.dart` - create - `startOfDay`, `isSameDay`, `startOfWeek`.
- `lib/utils/training_stats.dart` - create - `TrainingStats`.
- `lib/widgets/rating_input.dart` - create - `RatingInput`.
- `lib/widgets/journal_field.dart` - create - `JournalField`.
- `lib/pages/session_complete_page.dart` - rewrite - the journal sheet.
- `lib/pages/reaction_page.dart` - modify - save the result on completion.
- `lib/main.dart` - modify - `HistoryProvider` created, loaded and provided.
- `docs/architecture.md` - modify - rows, persistence keys and the history schema.

## Spec

### `SessionRecord` changes
Replace `notes` with three nullable strings `whatWorked`, `whatNeedsWork`, `opponent`, and add
`Stance? opponentStance`. JSON keys `what_worked`, `what_needs_work`, `opponent`,
`opponent_stance` (enum name), all omitted when null. `copyWith` covers `rating` and the four
new fields (pass `null` to leave unchanged; no need to unset). Update the existing tests that
reference `notes`. No stored data exists yet, so no migration.

### `HistoryStore` (`lib/services/history_store.dart`)
Plain class, `HistoryStore({SharedPreferences? prefs})` (injectable for tests, otherwise
`getInstance()` lazily). Keys as `static const`: `sessionsKey = 'session_records'`,
`reactionsKey = 'reaction_results'`; each holds a JSON-encoded list of maps.
`Future<List<SessionRecord>> loadSessions()`, `Future<bool> saveSessions(List<SessionRecord>)`,
`Future<List<ReactionResult>> loadReactions()`, `Future<bool> saveReactions(List<ReactionResult>)`.
Malformed JSON or a failing read returns an empty list; a failing write returns false. Skip an
individual entry that fails to parse rather than dropping the whole list.

### `HistoryProvider`
```dart
class HistoryProvider extends ChangeNotifier {
  HistoryProvider({HistoryStore? store});
  bool get isLoaded; String? get error;
  List<SessionRecord> get sessions;        // newest first, unmodifiable
  List<ReactionResult> get reactions;      // newest first
  Future<void> load();
  Future<void> addSession(SessionRecord record);        // replaces an entry with the same id
  Future<void> updateSession(SessionRecord record);     // same as add; kept for readability
  Future<void> deleteSession(String id);
  Future<void> addReaction(ReactionResult result);
  Future<void> clearAll();
  SessionRecord? findSession(String id);
}
```
Every mutation updates memory, notifies, then persists; a failed persist sets `error` ("Could
not save history") and notifies again. The in-memory list is the truth for the session.

### Date helpers
`DateTime startOfDay(DateTime d)`, `bool isSameDay(DateTime a, DateTime b)`,
`DateTime startOfWeek(DateTime d)` (Monday 00:00). Pure.

### `TrainingStats` (`lib/utils/training_stats.dart`)
```dart
class TrainingStats {
  const TrainingStats({required this.weekRounds, required this.weekMinutes, required this.streakDays,
    required this.totalRounds, required this.totalMinutes, required this.totalSessions,
    required this.weekRoundsByType, required this.minutesByDay, required this.lastTrainedByType});
  factory TrainingStats.fromSessions(List<SessionRecord> sessions, {required DateTime now});
}
```
- Only sessions with `roundsCompleted > 0` count. Minutes are `SessionRecord.workMinutes`.
- `weekRounds`, `weekMinutes`: sessions with `startedAt >= startOfWeek(now)`.
- `streakDays`: consecutive calendar days with at least one counted session, walking back from
  today; if today has none, start from yesterday (a streak survives until midnight tomorrow).
  0 when neither today nor yesterday trained.
- `weekRoundsByType`: `Map<TrainingType, int>` for the week (only types present).
- `minutesByDay`: `List<int>` of 7 entries, index 0 = six days ago, index 6 = today.
- `lastTrainedByType`: `Map<TrainingType, DateTime>` over all sessions.
- Pure and fast enough for a few hundred records.

### `RatingInput`
`const RatingInput({required int? value, required ValueChanged<int> onChanged})`. Five
`sessionTapTarget`-sized round targets in a row (`surfaceRaised`; selected and lower ones
`accent`), numbers 1 to 5 in `displaySmall`. Below, a `caption` reading the selected label:
1 "Rough", 2 "Flat", 3 "Solid", 4 "Sharp", 5 "On fire", or "How did it go?" when null.

### `JournalField`
`const JournalField({required String label, required TextEditingController controller, String? hint, int maxLines = 3})`.
Eyebrow label in `label` uppercase over a `TextField` styled from the theme: add an
`inputDecorationTheme` to `AppTheme.dark` (filled `surface`, `radiusMd`, no border line,
hint in `bodyMuted`, content padding `spaceMd`), the one permitted `AppTheme` edit.

### `SessionCompletePage` (rewrite, `StatefulWidget`)
Reads `SessionProvider.record` once in `initState` (null-safe: show "No session" + Done). If
the record has `roundsCompleted == 0` and `durationSeconds < 60`, do not offer the journal:
show "Nothing to log" in `bodyMuted` and a Done button that resets and pops (nothing saved).
Otherwise, `ListView`: eyebrow "SESSION COMPLETE" / "SESSION ENDED", workout name in
`displayLarge`, the three stat cells from today, `spaceXl`, `RatingInput`, `spaceLg`,
`JournalField('What worked')`, `JournalField('What needs work')`, and when
`record.type == TrainingType.sparring` also `JournalField('Opponent', maxLines: 1)` and a
`SegmentedButton<Stance>` for the opponent's stance (default orthodox). Bottom pinned
`PillButton('Save', filled, 56)`: builds `record.copyWith(...)` (empty strings become null),
`await history.addSession(...)`, then `session.reset()` and `popUntil(isFirst)`. No skip button:
Save with nothing filled in is the skip. Controllers disposed.

### `ReactionPage`
When the provider reaches `complete`, save `result` through `HistoryProvider.addReaction`
exactly once per result (guard with the result's `completedAt`). Not in build: use a listener
added in `initState` and removed in `dispose`.

### `main.dart`
`final history = HistoryProvider(); await history.load();` next to settings; provide with
`ChangeNotifierProvider.value`. `BoxerOsApp` gains a `history` parameter; update
`test/pages/app_shell_test.dart` accordingly (one line).

### docs/architecture.md
Persistence: add the two keys to the table and a "History schema" list of the
`SessionRecord` and `ReactionResult` JSON fields. Module rows for the new files. Note the
journal flow in "Navigation".

## Out of scope
- Progress and journal list UI (task-02), Home and Settings (task-03).
- Editing a saved session later (task-02 shows it read-only with delete).

## Acceptance criteria
- [ ] `HistoryStore` round-trips sessions and reactions through mocked prefs; corrupt JSON
      yields an empty list; a corrupt entry inside a valid list is skipped.
- [ ] `HistoryProvider.addSession` twice with the same id keeps one entry; lists are newest first.
- [ ] `TrainingStats`: given sessions today, yesterday and 3 days ago, streak is 2; with
      sessions yesterday and the day before but none today, streak is 2; with none today or
      yesterday, 0; `weekRounds` excludes last week; `minutesByDay` has 7 entries with today last.
- [ ] Journal sheet: rating tap selects; Save persists rating and texts on the record;
      sparring shows the opponent fields, other types do not; a 0-round 30-second session
      shows "Nothing to log" and saves nothing.
- [ ] Reaction result is saved once on completion.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/services/history_store_test.dart`, `test/providers/history_provider_test.dart`,
  `test/utils/training_stats_test.dart`, `test/utils/date_helpers_test.dart`,
  `test/pages/session_complete_page_test.dart` (pump with real providers over mock prefs, drive
  a session to complete with the fake clock, fill the sheet, tap Save, assert on the provider).
