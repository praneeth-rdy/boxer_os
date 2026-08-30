# Task 10 - Gym Wall: wallpapers for the home and lock screen

- **Run:** `.claude/handoffs/2026-08-30-content/`
- **Depends on:** task-09
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
A "Gym Wall" gallery under Corner: posters in the app's style (quote posters, legend posters,
a tagline set) rendered by the app at the phone's resolution, previewed in a phone frame, and
set as the home screen, lock screen or both through Android's `WallpaperManager`.

## Context the worker needs
- First native code in the repo: `.claude/CLAUDE.md` says a MethodChannel is named
  `boxer_os/<area>` and documented in `docs/architecture.md` with `method | args | returns`.
  `MainActivity.kt` stays a thin bridge; no `!!`.
- `WallpaperManager.setBitmap(bitmap, null, true, FLAG_SYSTEM | FLAG_LOCK)` exists from API
  24; our minSdk is above that (check `flutter.minSdkVersion`). Permission
  `android.permission.SET_WALLPAPER` is a normal permission (manifest only).
- Rendering: `RepaintBoundary` + `toImage(pixelRatio)` on an offscreen poster widget sized to
  the device's physical resolution (`MediaQuery` size times `devicePixelRatio`), then
  `ByteFormat.png` bytes to the channel. Do not add a dependency.
- Fonts render via the normal widget tree, so posters use `AppTheme` styles unchanged.
- Attribution: CC BY and CC BY-SA legend photos need the credit on the image; public-domain
  and CC0 do not, but bake a small credit for every photo poster anyway (consistent, safe).

## Files
- `android/app/src/main/kotlin/com/prdy/boxer_os/MainActivity.kt` - modify - channel.
- `android/app/src/main/AndroidManifest.xml` - modify - `SET_WALLPAPER`.
- `lib/services/wallpaper_service.dart` - create.
- `lib/models/poster.dart` - create - `Poster`, `PosterKind`.
- `lib/data/posters.dart` - create - the catalogue builders.
- `lib/widgets/poster_canvas.dart` - create - the poster widget.
- `lib/widgets/phone_preview.dart` - create.
- `lib/pages/gym_wall_page.dart` - create - grid.
- `lib/pages/poster_page.dart` - create - preview and set.
- `lib/pages/corner_page.dart` - modify - "Gym Wall" card in a new "WALL" section.
- `lib/main.dart` - modify - `Provider<WallpaperService>.value`.
- `docs/architecture.md` - modify - rows, native bridge table, permission.

## Spec

### Channel `boxer_os/wallpaper`
| method | args | returns |
|---|---|---|
| `setWallpaper` | `bytes: Uint8List` (PNG), `target: String` (`home`, `lock`, `both`) | `true` on success; a `PlatformException` with code `wallpaper_failed` otherwise |
Kotlin: decode with `BitmapFactory.decodeByteArray`, then `WallpaperManager.getInstance(this)`
`.setBitmap(bitmap, null, true, flags)` with `FLAG_SYSTEM`, `FLAG_LOCK` or both. Run on a
background thread (`Thread { }` or coroutine-free executor) and post the result to the main
thread. Catch everything, no `!!`.

### `WallpaperService`
`Future<bool> set(Uint8List png, WallpaperTarget target)`; false on any error, one-line comment.

### Posters
`enum PosterKind { quote, legend, tagline }`.
`class Poster { const Poster({required this.id, required this.kind, required this.title, this.quote, this.legend, this.variant}); }`
`posters()` builds: one tagline poster per variant (`variant` 0 to 3: "TRAIN. FIGHT. IMPROVE.
REPEAT." large; the corner-ropes mark large with the tagline small; "ROUND ONE IS WAITING.";
"PHONE DOWN. GLOVES UP."), one legend poster per legend (photo, name in `displayHero`
sized to fit, nickname and years, credit at the bottom in `caption`; Pacquiao's poster uses his
first gallery photo because his portrait is too small for a wallpaper, Johnson's uses his
portrait with `FilterQuality.high`), one quote poster per
quote (quote text in `displayLarge` scaled to fit within 80 percent height, author and sport
below, the red corner mark top-left). Ordering on the page: tagline, legends, quotes.

### `PosterCanvas`
`const PosterCanvas({required Poster poster, required Size size})`: paints at `size`
(logical pixels; the caller wraps it in a `RepaintBoundary` and renders with the device
pixel ratio). Ink ground; the red corner post and three ropes as the brand mark (drawn with
`Container`s, no assets) in the top-left with `spaceXl` margins; content per kind as above;
text sizes derived from `size.width` (for example `displayHero` at `size.width * 0.34`) so a
1080-wide render and a 360-wide preview look the same.

### `PhonePreview`
`const PhonePreview({required Widget child})`: a rounded phone bezel (`surfaceRaised`, 3 dp
`line` border, `radiusLg` times 2), a punch-hole dot, and the child scaled to fit with
`FittedBox`; keeps the device aspect ratio from `MediaQuery`.

### `GymWallPage`
Transparent app bar; `SectionHeader(title: 'Gym Wall', eyebrow: 'WALLPAPERS')`; a
`bodyMuted` line "Posters in the Boxer OS style for your home and lock screen."; a
`FilterChipRow<PosterKind?>` (All, Taglines, Legends, Quotes); a `GridView.builder` with 2
columns, each cell a `PhonePreview` of a `PosterCanvas` at a small size (`AspectRatio` of the
device), tap -> `PosterPage`.

### `PosterPage`
Full preview (`PhonePreview` at 70 percent of the width), then three `PillButton`s:
"Set as home screen" (filled), "Set as lock screen" (outlined), "Set both" (outlined). On
tap: render offscreen at the physical resolution (`RepaintBoundary` inside an `Offstage`
or `OverlayEntry`, `toImage(pixelRatio: devicePixelRatio)`), send to the service, show a
`SnackBar` "Wallpaper set" or "Could not set wallpaper". Buttons disabled while rendering
(progress indicator in the pressed button's label).

### Corner
New eyebrow "WALL" after WORDS: `SkillCard('Gym Wall', 'Posters for your home and lock screen.', Icons.wallpaper_rounded)` -> `GymWallPage`.

## Out of scope
- Sharing or saving to the photo library; custom text; live wallpapers.

## Acceptance criteria
- [ ] `posters().length == 4 + 12 + 84`; every legend poster's credit text contains the
      author and license.
- [ ] `PosterCanvas` renders each kind at 360 x 780 without overflow (widget test), and a
      `RepaintBoundary.toImage` in a test produces a PNG with the expected size.
- [ ] `WallpaperService.set` returns true when the channel mock answers true, false when it
      throws; `PosterPage` calls it with the chosen target and shows the SnackBar.
- [ ] Device: setting a quote poster as the lock screen changes the lock screen (assistant
      captures the lock screen with `adb shell input keyevent KEYCODE_SLEEP`, then
      `KEYCODE_WAKEUP`, screencap).
- [ ] `flutter analyze` 0 issues; `flutter build apk --debug` succeeds with the Kotlin change.

## Verification
- Assistant tests: `test/data/posters_test.dart`, `test/widgets/poster_canvas_test.dart`,
  `test/services/wallpaper_service_test.dart`, `test/pages/gym_wall_page_test.dart`,
  `test/pages/poster_page_test.dart`.
