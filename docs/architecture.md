# Architecture

Local-first boxing training companion in Flutter, Android-only. Four tabs (Home, Train, Skills,
Progress), a session screen that runs round timers with bells and haptics, and local storage for
preferences and training history.

Last verified against the code: 2026-08-29. Update this file in the same change that makes it wrong.

**State of the code:** `flutter create` scaffold. `lib/main.dart` is the counter template and
`test/widget_test.dart` its smoke test. Everything under "Target layout" is the plan; the module
map lists only files that exist.

## Stack

- Flutter 3.41.2 stable, Dart SDK `^3.11.0`.
- Android only (created with `--platforms android`). `flutter create .` regenerates the other
  platform folders if ever needed.
- Application id and Kotlin package: `com.prdy.boxer_os`. `minSdk`/`targetSdk`/`compileSdk` come
  from the Flutter defaults (`flutter.minSdkVersion` etc. in `android/app/build.gradle.kts`).
- Release builds currently sign with the debug key (`build.gradle.kts` `release` block). Backlog
  B-04 wires `android/key.properties` with a debug fallback; `docs/release.md` describes it.
- Dependencies today: `cupertino_icons` (scaffold), `flutter_lints`, `flutter_test`. The intended
  additions (`provider`, `shared_preferences`, a history store, an audio player, a wake lock) are
  adopted by the handoff package that first needs each one.

## Layers (target)

```
pages/widgets  ->  providers  ->  services  ->  platform (prefs, history store, audio, haptics, wake lock)
                       |
                     data/  (bundled workouts, drills, combination vocabulary)
```

Rules: widgets talk to providers, providers talk to services and read `data/`, services talk to
the platform. Nothing under `widgets/`, `pages/` or `utils/` imports a service. Providers never
import widgets or `BuildContext`. The session engine (`SessionProvider`) advances on one
`Timer.periodic` and exposes plain state (phase, round, seconds left); widgets only render it and
cue services react to its transitions.

## Target layout (`lib/`)

| Folder | Holds |
|---|---|
| `main.dart` | `BoxerOsApp`: `MultiProvider` -> `MaterialApp` with `AppTheme.dark` -> the app shell. |
| `theme/` | `app_theme.dart`: `AppTheme`, the single source of colours, spacing, radii, type and `appVersion`. |
| `models/` | Immutable value types: workout, round spec, session record, combination, drill, reaction result, journal entry, fighter profile. |
| `data/` | Bundled definitions: the workout library, drill catalogue, punch and defense vocabulary used by the combination generator. Dart constants or JSON under `assets/`. |
| `services/` | Platform and storage boundaries: preferences, history store, audio cues, haptics, wake lock. Static or single-instance, return null/false or throw `Exception`, never leak platform errors. |
| `providers/` | `ChangeNotifier`s: settings, session engine, history, progress, skills. State and orchestration only. |
| `pages/` | One file per screen: app shell, home, train, session, skills, reaction trainer, progress, journal, settings. |
| `widgets/` | Reusable pieces: round clock, cue banner, big pill buttons, stat tiles, streak strip, rating input. |
| `utils/` | Pure helpers: duration formatting, date helpers, streak maths. |

## Module map (`lib/`)

| File | Role |
|---|---|
| `main.dart` | `flutter create` counter template (`MyApp`, `MyHomePage`). Replaced by backlog B-01. |

## Persistence

No keys yet. When a provider adds a `shared_preferences` key, list it here as
`key | type | owner (static const) | meaning`. The history store (decision D-01 in the backlog)
gets its own section with the schema once chosen.

## Native bridge (`android/app/src/main/kotlin/com/prdy/boxer_os/`)

`MainActivity.kt` is the stock `FlutterActivity`. No MethodChannel exists. If one is added, name
it `boxer_os/<area>`, keep `MainActivity` a thin dispatcher, and list each method here as
`method | args | returns`.

Manifest (`android/app/src/main/AndroidManifest.xml`): stock. Label `boxer_os` (B-01 sets
`Boxer OS`), MAIN/LAUNCHER intent filter, `<queries>` for `PROCESS_TEXT` only. No permissions
declared yet; `WAKE_LOCK`, `VIBRATE`, `FOREGROUND_SERVICE` and `POST_NOTIFICATIONS` are the
candidates, each added by the package that needs it.

## Styling (target)

`lib/theme/app_theme.dart` (B-01) is the single source of colours, type and spacing; new UI
references `AppTheme` tokens rather than literals. Direction from `product.md`: dark, high
contrast, big controls, numbers legible from arm's length, one accent reserved for the active
round state. The exact palette and typefaces are chosen in B-01 and recorded here and in
`decisions.md` when they land.

## Tests

`test/` mirrors `lib/`. Today: `test/widget_test.dart`, the scaffold counter test (replaced in
B-01). Prefs are mocked with `SharedPreferences.setMockInitialValues`, channels with
`TestDefaultBinaryMessengerBinding`, timers with `FakeAsync` / `tester.pump`; widget tests pump
inside `MultiProvider` with the real providers.
