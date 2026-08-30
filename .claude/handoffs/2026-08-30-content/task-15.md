# Task 15 - "Auto-shuffle" becomes "Live wallpaper"

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-14
- **Worker:** developer (Opus)
- **Tests:** yes (developer updates the affected tests)

## Goal
Use Android's own term so the app and the system screen agree.

## Files
- `lib/pages/shuffle_page.dart` -> rename to `lib/pages/live_wallpaper_page.dart`, class `LiveWallpaperPage`.
- `lib/pages/gym_wall_page.dart` - the entry pill reads "Live wallpaper".
- `test/pages/shuffle_page_test.dart` -> `test/pages/live_wallpaper_page_test.dart`.
- `docs/architecture.md` - rows and navigation.

## Spec
Strings: header `SectionHeader(title: 'Live wallpaper', eyebrow: 'A NEW POSTER EVERY TIME THE
SCREEN WAKES')`; segments stay "Everything" / "Pick a few"; the status line stays "Live
wallpaper: on/off"; the action pill stays "Render and set". Provider name and prefs keys are
unchanged (`WallProvider`, `wall_shuffle_all`, `wall_shuffle_ids`); only user-facing words and
the page name change. Grep `lib test` for "shuffle" afterwards: only the provider, its keys and
the Dart `shuffle()` call may remain.

## Acceptance criteria
- [ ] No user-facing "Auto-shuffle" / "shuffle" string remains; tests green; analyze clean.
