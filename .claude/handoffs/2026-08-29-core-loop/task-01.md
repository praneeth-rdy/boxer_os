# Task 01 - Design system, app shell, settings

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** none
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Replace the counter scaffold with the Boxer OS foundation: `AppTheme` (every colour, spacing,
radius and text style the app will ever use), the dark `ThemeData`, the `BoxerOsApp` root, a
four-tab shell (Home, Train, Skills, Progress) with placeholder pages, and a `SettingsProvider`
persisted in `shared_preferences`. When this is done the app launches to a dark, branded shell
that already looks like the finished product's chrome.

## Context the worker needs
- `.claude/CLAUDE.md` "Conventions" and "Code guidelines": `AppTheme` is the only source of
  styling; `.withValues(alpha:)`; one widget per file; no leading underscore on locals.
- `docs/product.md` "Look and feel": blackout + one hot accent, Bebas Neue for display, Inter
  for text. `docs/architecture.md` "Target layout" for where files go.
- Fonts are already in `assets/fonts/` (`BebasNeue-Regular.ttf`, `Inter-Regular.ttf`,
  `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf`). Audio in `assets/audio/` is
  declared here so later packages need not touch `pubspec.yaml`.
- Device: Android 16, 1080x2400 at 440 dpi (about 393x873 dp). Design for that phone in portrait.

## Files
- `pubspec.yaml` - modify - add `provider: ^6.1.5`, `shared_preferences: ^2.5.5`; remove
  `cupertino_icons`; declare `assets/audio/` and the two font families (see Spec).
- `lib/main.dart` - rewrite - `main()` and `BoxerOsApp`.
- `lib/theme/app_theme.dart` - create - `AppTheme`.
- `lib/models/stance.dart` - create - `Stance` enum.
- `lib/models/difficulty.dart` - create - `Difficulty` enum.
- `lib/providers/settings_provider.dart` - create - `SettingsProvider`.
- `lib/pages/app_shell.dart` - create - `AppShell`.
- `lib/pages/home_page.dart`, `lib/pages/train_page.dart`, `lib/pages/skills_page.dart`,
  `lib/pages/progress_page.dart` - create - placeholder pages.
- `lib/widgets/section_header.dart` - create - `SectionHeader`.
- `test/widget_test.dart` - delete (the assistant writes replacement tests).
- `android/app/src/main/AndroidManifest.xml` - modify - `android:label="Boxer OS"`.
- `android/app/src/main/res/drawable/launch_background.xml`,
  `android/app/src/main/res/drawable-v21/launch_background.xml` - modify - solid `#0A0A0B`.
- `android/app/src/main/res/values/styles.xml`, `values-night/styles.xml` - modify - the
  `LaunchTheme` and `NormalTheme` window backgrounds point at the same dark colour.
- `docs/architecture.md` - modify - module map, persistence table, styling section.

## Spec

### pubspec.yaml
```yaml
dependencies:
  flutter: { sdk: flutter }
  provider: ^6.1.5
  shared_preferences: ^2.5.5
flutter:
  uses-material-design: true
  assets:
    - assets/audio/
  fonts:
    - family: BebasNeue
      fonts:
        - asset: assets/fonts/BebasNeue-Regular.ttf
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```
Keep the existing `version: 0.1.0+1`, `environment`, `dev_dependencies`. Strip the template
comment blocks from the file; keep it short. Run `flutter pub get` after editing.

### `AppTheme` (`lib/theme/app_theme.dart`)
A class with a private constructor and only `static const` / `static final` members.

Colours (`Color`):
| Name | Value | Use |
|---|---|---|
| `ink` | `0xFF0A0A0B` | scaffold background |
| `surface` | `0xFF141416` | cards, sheets |
| `surfaceRaised` | `0xFF1C1C1F` | pressed / elevated cards, nav bar |
| `line` | `0xFF2A2A2E` | hairline borders and dividers |
| `chalk` | `0xFFF4F2EE` | primary text |
| `chalkMuted` | `0xFF9A9A9F` | secondary text |
| `chalkFaint` | `0xFF5C5C62` | disabled, tertiary |
| `accent` | `0xFFFF3D2E` | live state: work phase, primary CTA, active tab |
| `accentDeep` | `0xFFB8261C` | pressed accent |
| `rest` | `0xFF2ED3A5` | rest phase, positive stats |
| `warning` | `0xFFFFB020` | prepare phase, 10-second warning |
| `onAccent` | `0xFF0A0A0B` | text on accent-filled surfaces |

Spacing (`double`): `spaceXs = 4`, `spaceSm = 8`, `spaceMd = 16`, `spaceLg = 24`,
`spaceXl = 32`, `spaceXxl = 48`. Page horizontal padding is `spaceLg`.

Radii (`double`): `radiusSm = 8`, `radiusMd = 14`, `radiusLg = 22`, `radiusPill = 999`.

Sizes (`double`): `minTapTarget = 48`, `sessionTapTarget = 72`, `hairline = 1`.

Type (`TextStyle`, all `const`):
- Display family `'BebasNeue'`, colour `chalk`, `height: 0.9`:
  `displayHero` 168 (session countdown), `displayLarge` 64, `displayMedium` 40,
  `displaySmall` 28, letterSpacing 1 on the three smaller ones.
- Text family `'Inter'`, colour `chalk` unless noted:
  `titleLarge` 22 w600, `title` 17 w600, `body` 15 w400 height 1.4, `bodyStrong` 15 w600,
  `bodyMuted` 15 w400 `chalkMuted`, `label` 13 w500 letterSpacing 1.2 `chalkMuted`
  (used uppercase for eyebrows such as "ROUND 3 OF 6"), `caption` 12 w400 `chalkMuted`.

`static const String appVersion = '0.1.0';` (keep in step with `pubspec.yaml`).

`static final ThemeData dark`: `useMaterial3: true`, `brightness: Brightness.dark`,
`scaffoldBackgroundColor: ink`, `fontFamily: 'Inter'`, a `ColorScheme.dark(...)` with
`primary: accent`, `onPrimary: onAccent`, `secondary: rest`, `surface: surface`,
`onSurface: chalk`, `outline: line`, `error: accent`. Also set: `appBarTheme`
(background `ink`, no elevation, `centerTitle: false`, title style `displaySmall`),
`navigationBarTheme` (background `surfaceRaised`, indicator `accent.withValues(alpha: 0.18)`,
selected icon `accent`, unselected icon `chalkMuted`, label style `label` with the selected
state in `chalk`, height 72), `cardTheme` (colour `surface`, `radiusLg`, no elevation, zero
margin), `dividerTheme` (`line`, thickness `hairline`), `filledButtonTheme` (accent background,
`onAccent` foreground, min height `minTapTarget`, `radiusPill`, `bodyStrong`), `snackBarTheme`
(`surfaceRaised` background, `chalk` text), `splashFactory: InkSparkle.splashFactory`.

### Enums
`Stance { orthodox, southpaw }` and `Difficulty { beginner, intermediate, advanced }`, each with
a `String get label` ("Orthodox", "Beginner", ...) and a
`static X fromName(String? name)` returning the matching value or the first value when the
name is null or unknown (prefs may hold garbage).

### `SettingsProvider` (`lib/providers/settings_provider.dart`)
`ChangeNotifier`. Prefs keys as `static const String`:
`stance` (`'stance'`, String enum name, default orthodox), `difficulty` (`'difficulty'`,
default beginner), `soundEnabled` (`'sound_enabled'`, bool, default true), `hapticsEnabled`
(`'haptics_enabled'`, true), `voiceEnabled` (`'voice_enabled'`, true), `keepScreenOn`
(`'keep_screen_on'`, true).
API: getters for each value; `bool get isLoaded`; `Future<void> load()` reads all keys from
`SharedPreferences.getInstance()`; one setter per value (`Future<void> setStance(Stance)`,
`setDifficulty`, `setSoundEnabled(bool)`, `setHapticsEnabled`, `setVoiceEnabled`,
`setKeepScreenOn`) that updates the field, notifies, then writes. If `getInstance()` or a
write throws, catch it, keep the in-memory value, set `String? error` (exposed, cleared on the
next successful call) and notify. Never throw.

### `main.dart`
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final settings = SettingsProvider();
  await settings.load();
  runApp(BoxerOsApp(settings: settings));
}
```
`BoxerOsApp` is a `StatelessWidget` taking `settings` and building
`MultiProvider(providers: [ChangeNotifierProvider.value(value: settings)], child: MaterialApp(
title: 'Boxer OS', theme: AppTheme.dark, debugShowCheckedModeBanner: false, home: AppShell()))`.
Later packages add providers to that list; keep it a list literal. Also set the system UI
overlay style once (status bar transparent, light icons) via `SystemChrome.setSystemUIOverlayStyle`
or an `AnnotatedRegion` in `AppShell`.

### `AppShell` (`lib/pages/app_shell.dart`)
`StatefulWidget` holding `int tabIndex`. Body is an `IndexedStack` of the four pages so each
keeps its scroll state. Bottom: `NavigationBar` with destinations, in order:
Home `Icons.home_rounded`, Train `Icons.sports_mma_rounded`, Skills `Icons.bolt_rounded`,
Progress `Icons.insights_rounded`. Labels always shown.

### Placeholder pages
Each is a `StatelessWidget` returning a `Scaffold` (background `ink`) with a `SafeArea` and a
`ListView` padded `spaceLg` horizontally containing a `SectionHeader` and, below it, a
`bodyMuted` line. Titles and lines:
- Home: title "Boxer OS", eyebrow "TRAIN. FIGHT. IMPROVE. REPEAT.", line "Your session, your
  streak and your week will live here."
- Train: title "Train", eyebrow "WORKOUTS AND TIMER", line "Guided workouts and the round timer
  land in the next package."
- Skills: title "Skills", eyebrow "COMBOS, REACTION, FOOTWORK", line "Drills arrive in run 2."
- Progress: title "Progress", eyebrow "ROUNDS, MINUTES, STREAK", line "Analytics arrive in run 3."
Train and Home are rewritten in task-05; keep them trivial.

### `SectionHeader` (`lib/widgets/section_header.dart`)
`const SectionHeader({required String title, String? eyebrow, Widget? trailing})`. Column:
eyebrow in `label` uppercase (if given), then a `Row` with `title` in `displayLarge` and
`trailing` at the end. Bottom padding `spaceMd`.

### Android
Manifest label `Boxer OS`. Launch background drawables: a single `<item android:drawable="@color/...">`
is fine, or an inline `<color>`; the visible result is a solid `#0A0A0B` splash with no image.
`styles.xml` in both `values/` and `values-night/`: `LaunchTheme` uses the dark launch
background and `NormalTheme` `android:windowBackground` is `#0A0A0B` (define
`@color/boxer_ink` in `res/values/colors.xml`, create that file).

### docs/architecture.md
Module map: one row per file created above. Persistence: a table row per prefs key
(`key | type | owner | meaning`). Styling: replace the "target" paragraph with the actual palette
and type names. Remove the "State of the code: scaffold" paragraph.

## Out of scope
- No session, workout, audio, haptics or wake-lock code (tasks 02 to 05).
- No settings UI (run 3); the provider only.
- No launcher icon, no signing (run 4).
- Do not add any dependency beyond the two listed.

## Acceptance criteria
- [ ] `flutter run` (or the debug APK) launches to a dark shell with four tabs; tapping each
      shows its placeholder; the status bar is dark with light icons; splash is dark, no white flash.
- [ ] `AppTheme` exposes every token named above and `lib/` contains no colour or size literal
      outside `app_theme.dart` (the Android XML colour is the one exception).
- [ ] `SettingsProvider.load()` with empty prefs yields orthodox / beginner / all flags true;
      with stored values yields them; each setter persists to the matching key; an unknown
      stance name falls back to orthodox; a failing prefs write leaves the value set and `error` non-null.
- [ ] `Stance.fromName(null)` is orthodox, `Difficulty.fromName('nope')` is beginner.
- [ ] `test/widget_test.dart` is deleted.
- [ ] `flutter analyze` reports 0 issues.

## Verification
- `flutter analyze`, `flutter pub get`.
- Assistant tests: `test/providers/settings_provider_test.dart` (defaults, load from stored
  values, each setter writes its key, bad enum names fall back),
  `test/models/stance_test.dart`, `test/models/difficulty_test.dart`,
  `test/pages/app_shell_test.dart` (pumps `BoxerOsApp` with a loaded `SettingsProvider` over
  `SharedPreferences.setMockInitialValues({})`, finds four destinations, taps Train and finds
  "Train").
