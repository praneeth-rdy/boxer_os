# Task 16 - Live wallpaper page: instructions that match OEM screens

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-15
- **Worker:** developer (Opus)
- **Tests:** yes (developer adjusts `test/pages/live_wallpaper_page_test.dart` if a string is asserted)

## Goal
On the test phone (Vivo, Android 16) the system screen shows a preview with one "Apply"
button and only then asks "Apply to: Lock screen / Home screen / both". Stock Android shows
"Set wallpaper" with a similar choice. The page copy must cover both, and the page must refresh
its status when the boxer comes back.

## Files
- `lib/pages/live_wallpaper_page.dart` - modify - copy and status refresh.

## Spec
Explanation paragraph becomes: "Boxer OS renders your posters once. On the system screen that
opens, tap Apply or Set wallpaper, then choose Lock screen, Home screen or both. From then on
Android shows the next poster every time the screen wakes." After a successful render, show a
`SnackBar` "Choose where to apply it on the next screen" before opening the picker. The status
line must re-check `isLiveActive()` on `AppLifecycleState.resumed` (verify the observer exists
from task-14; add it if missing) and read "Live wallpaper: on" once the service is bound.

## Acceptance criteria
- [ ] Copy as above; status refresh on resume covered by a test that fakes the service
      returning false then true across a simulated lifecycle change.
- [ ] `flutter analyze` 0 issues; suite green.
