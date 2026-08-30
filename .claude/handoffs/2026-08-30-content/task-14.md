# Task 14 - Gym Wall Live: auto-shuffle on every screen-on

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-13
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The boxer picks a few posters, or all of them, and the wallpaper changes to the next one every
time the screen turns on. Android only tells a *live wallpaper* about screen-on events, so
this is a native `WallpaperService` that cycles through posters Flutter has pre-rendered to
app storage; the boxer activates it once through the system's live wallpaper screen.

## Context the worker needs
- `MainActivity.kt` already hosts the `boxer_os/wallpaper` channel (task-10); extend it, keep
  it a thin bridge, no `!!`.
- Live wallpapers: `android.service.wallpaper.WallpaperService` with an `Engine`;
  `onVisibilityChanged(true)` fires when the screen turns on or the launcher becomes visible;
  `onSurfaceChanged` gives the size. Declare the service in the manifest with the
  `BIND_WALLPAPER` permission and `@xml/gym_wall` metadata. Users activate it via
  `Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)` with
  `EXTRA_LIVE_WALLPAPER_COMPONENT`. `WallpaperManager.getWallpaperInfo()` tells whether it is
  active. Android 14+ lets the user apply a live wallpaper to the lock screen as well from
  that system screen; the app cannot force it.
- Rendering all 148 posters takes minutes and PNGs are large, so the channel receives PNG
  bytes and Kotlin re-encodes to JPEG quality 90 in `filesDir/gym_wall/`. Expect roughly
  400 KB per poster.
- Prefs keys live on the provider as `static const`.

## Files
- `android/app/src/main/kotlin/com/prdy/boxer_os/GymWallService.kt` - create.
- `android/app/src/main/kotlin/com/prdy/boxer_os/MainActivity.kt` - modify - three methods.
- `android/app/src/main/res/xml/gym_wall.xml` - create - `<wallpaper android:thumbnail="@mipmap/ic_launcher" android:description="@string/gym_wall_description"/>`; add `res/values/strings.xml` with that string ("Boxer OS posters, a new one every time the screen wakes.") and the app label if the manifest references one.
- `android/app/src/main/AndroidManifest.xml` - modify - the service.
- `lib/services/wallpaper_service.dart` - modify - new methods.
- `lib/providers/wall_provider.dart` - create.
- `lib/pages/shuffle_page.dart` - create.
- `lib/pages/gym_wall_page.dart` - modify - entry to the shuffle page; selection mode.
- `lib/widgets/poster_renderer.dart` - create - offscreen batch renderer.
- `lib/main.dart` - modify - provide `WallProvider`.
- `docs/architecture.md` - modify - channel table, service, prefs keys.

## Spec

### Channel methods (`boxer_os/wallpaper`)
| method | args | returns |
|---|---|---|
| `saveRotation` | `index: int`, `count: int`, `bytes: Uint8List` (PNG) | `true`; writes `filesDir/gym_wall/<index padded 3>.jpg`; when `index == 0` first deletes the folder's contents; when `index == count - 1` writes `count` to the shared preference `gym_wall_count` and resets `gym_wall_index` to 0 |
| `openLiveWallpaperPicker` | none | `true` if the intent resolved and was started, `false` otherwise |
| `isLiveWallpaperActive` | none | `bool`: the current wallpaper info's component equals `GymWallService` |
| `setWallpaper` | unchanged | |
Prefs are a Kotlin `SharedPreferences` named `gym_wall` (read by both the activity and the service).

### `GymWallService`
`Engine`: keeps `surfaceWidth/Height` from `onSurfaceChanged`; on `onVisibilityChanged(true)`
advances `gym_wall_index` (modulo `gym_wall_count`, both from the prefs), loads the JPEG,
draws it centre-cropped to the surface with `Canvas.drawBitmap` inside `lockCanvas` /
`unlockCanvasAndPost`, and stores the index. If the folder is empty or the file is missing,
paints `#0A0A0B`. Decoding uses `BitmapFactory.Options.inSampleSize` so a 1080x2400 JPEG does
not allocate more than needed for the surface. Also redraw (without advancing) on
`onSurfaceChanged` and `onSurfaceRedrawNeeded`. No threads needed: decoding a single JPEG on
visibility change is fast enough; if it exceeds 50 ms on the device in the assistant's check,
move it to a `HandlerThread`.

### `WallpaperService` (Dart)
`Future<bool> saveRotationFrame({required int index, required int count, required Uint8List png})`,
`Future<bool> openLivePicker()`, `Future<bool> isLiveActive()`; false on any error.

### `WallProvider`
Keys: `wallShuffleAllKey = 'wall_shuffle_all'` (bool, true), `wallShuffleIdsKey = 'wall_shuffle_ids'`
(String list of poster ids, empty). API: `load()`, `bool get shuffleAll`, `Set<String> get selectedIds`,
`setShuffleAll(bool)`, `toggle(String id)`, `clearSelection()`, `List<Poster> get rotation`
(all posters when `shuffleAll`, else the selected ones in `posters()` order),
`bool get isRendering`, `int get renderedCount`, `int get renderTotal`, `String? get error`,
`Future<bool> applyRotation(Future<Uint8List> Function(Poster) render, WallpaperService service)`:
shuffles `rotation` with `Random()`, renders and sends one frame at a time updating progress,
returns false and sets `error` on the first failure; cancellable via `cancelRender()` (checked
between frames).

### `PosterRenderer`
A widget placed once in `ShufflePage`'s tree, offstage-but-painting: a `SizedBox` of the
device's logical size wrapped in a `RepaintBoundary`, positioned in an `Overlay` entry or a
`Stack` behind the page so it paints (an `Offstage` never paints; task-10 learned this). It
exposes `Future<Uint8List> render(Poster)` that sets the poster, waits one frame, calls
`toImage(pixelRatio: devicePixelRatio)` and returns PNG bytes. Keep it in `lib/widgets/`.

### `ShufflePage`
Reached from Gym Wall by a `PillButton('Auto-shuffle', outlined)` under the intro line.
`SectionHeader(title: 'Auto-shuffle', eyebrow: 'A NEW POSTER EVERY TIME THE SCREEN WAKES')`.
A `SegmentedButton<bool>`: "Everything" / "Pick a few". When "Pick a few": the Gym Wall grid
in selection mode (each cell gets a check circle top-right; tap toggles; counter "{n} selected";
the six chips filter). Below: a `bodyMuted` explanation "Boxer OS renders your posters once,
then Android shows the next one each time the screen turns on. On the system screen that
opens, choose Set wallpaper; on Android 14 and later you can pick Home, Lock or both."
`PillButton('Render and set', filled, 56)`: disabled when nothing selected; runs
`applyRotation` with a progress bar (`renderedCount / renderTotal`) and a "Cancel" ghost pill;
on success calls `openLivePicker()`; on false shows a `SnackBar` with the error. A status line
at the top: "Live wallpaper: on" / "off" from `isLiveActive()` (refreshed on page open and
after returning from the picker via `WidgetsBindingObserver.didChangeAppLifecycleState`).
Rendering 148 posters is allowed but the page warns "About {estimate} minutes" where the
estimate is `count * 1.2 s`.

### Gym Wall page
Gains the Auto-shuffle pill; selection mode is only on the shuffle page.

## Out of scope
- Time-based rotation; per-target selections; sharing.

## Acceptance criteria
- [ ] `WallProvider` persists both keys, `rotation` follows `shuffleAll`, `applyRotation` calls
      the renderer and the service once per poster in a shuffled order and reports progress;
      cancel stops it; a service failure sets `error`.
- [ ] Shuffle page: segment toggles selection mode; the pill is disabled with nothing selected;
      progress shows while rendering (fake renderer with a delay).
- [ ] Device (assistant): pick three posters, render and set, choose the live wallpaper on the
      system screen, then sleep/wake twice: the lock/home wallpaper changes between wakes
      (capture after each wake). Decode time logged by the service (`Log.d("GymWall", ...)`,
      one line per draw) stays under 50 ms.
- [ ] `flutter build apk --debug` succeeds; `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/providers/wall_provider_test.dart`, `test/pages/shuffle_page_test.dart`,
  extend `test/services/wallpaper_service_test.dart`.
