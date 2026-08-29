# Task 04 - Cue services and the cue controller

- **Run:** `.claude/handoffs/2026-08-29-core-loop/`
- **Depends on:** task-03
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
Everything the boxer hears and feels: bells and beeps from the bundled WAVs, haptic patterns,
spoken cues through the phone's TTS engine, and the wake lock that keeps the screen on for the
whole session. A `CueController` listens to `SessionProvider` events and drives the services,
respecting the settings toggles.

## Context the worker needs
- `docs/decisions.md` entries "Cue services are plain objects wired in `main()`" and "Product
  answers" (TTS, wake lock, no foreground service).
- `.claude/CLAUDE.md` "Conventions": platform errors never reach the UI; services return
  false / null or throw `Exception`; never leave an empty catch.
- Assets already present: `assets/audio/bell_start.wav` (one strike), `bell_end.wav` (three
  strikes), `beep_warning.wav` (two high beeps), `beep_final.wav` (three low beeps),
  `tick_cue.wav` (one short tick). Declared in `pubspec.yaml` by task-01.
- Verify every plugin API you call by reading the package source in `~/.pub-cache` after
  `flutter pub get`. Do not guess signatures; audioplayers 6.x moved several methods.

## Files
- `pubspec.yaml` - modify - add `audioplayers: ^6.7.1` (6.8 needs Flutter 3.44; we are on
  3.41.2), `wakelock_plus: ^1.7.0`, `flutter_tts: ^4.2.5`.
- `lib/services/audio_service.dart` - create.
- `lib/services/haptics_service.dart` - create.
- `lib/services/voice_service.dart` - create.
- `lib/services/wake_lock_service.dart` - create.
- `lib/services/cue_controller.dart` - create.
- `lib/utils/cue_speech.dart` - create - `cueToSpeech`.
- `lib/main.dart` - modify - construct the services and the controller in `main()`.
- `android/app/src/main/AndroidManifest.xml` - modify - `<queries>` entry for TTS.
- `docs/architecture.md` - modify - module map rows, native bridge section (manifest queries,
  permissions merged from plugins).

## Spec

### Common shape
Each service is a plain class with a public no-arg constructor (so tests can substitute a
subclass or a fake) and `Future<bool>` methods that return `true` on success and `false` after
catching any `Object` thrown by the plugin (one-line comment on the catch: plugin failures are
non-fatal during a session). `Future<void> dispose()` where the plugin needs it.

### `AudioService`
Two `AudioPlayer` instances (bells, beeps) so a tick can overlap a bell. On construction, or in
an idempotent `Future<bool> init()`, set `ReleaseMode.stop` and an Android audio context with
usage `assistanceSonification`, content type `sonification`, audio focus
`gainTransientMayDuck`, so music apps duck rather than stop. Methods: `playRoundStart()`
(bell_start), `playRoundEnd()` (bell_end), `playWarning()` (beep_warning), `playFinalThirty()`
(beep_final), `playTick()` (tick_cue). Each stops the player it uses, then plays
`AssetSource('audio/<file>')` (the `assets/` prefix is the default). `dispose()` disposes both.

### `HapticsService`
Uses `HapticFeedback` only. Patterns via `Future.delayed` gaps of 120 ms:
`roundStart()` = heavy, heavy; `roundEnd()` = heavy, heavy, heavy; `warning()` = medium;
`finalThirty()` = medium, medium; `cue()` = selectionClick. Return `false` on any throw.

### `VoiceService`
Wraps `FlutterTts`. `Future<bool> init()`: `setLanguage('en-US')`, `setSpeechRate(0.55)`,
`setPitch(1.0)`, `awaitSpeakCompletion(false)`; returns false on throw and records
`isAvailable = false` so callers can skip. `Future<bool> speak(String text)`: `stop()` then
`speak(text)`; ignore empty text. `Future<bool> stop()`. `dispose()` calls `stop()`.

### `cueToSpeech` (`lib/utils/cue_speech.dart`)
`String cueToSpeech(String cue)` turns the notation from task-02 into speakable text:
digits 1..6 become `jab, cross, lead hook, rear hook, lead uppercut, rear uppercut`; a `b`
suffix appends `to the body` ("2b" -> "cross to the body"); hyphens become `, `; commas and
words pass through; collapse double spaces. `'1-2, slip, pivot, exit'` ->
`'jab, cross, slip, pivot, exit'`. `'3b'` -> `'lead hook to the body'`. Unknown tokens pass
through unchanged. Pure function, no I/O.

### `WakeLockService`
`Future<bool> enable()`, `Future<bool> disable()` over `WakelockPlus.enable()` / `disable()`.

### `CueController`
```dart
class CueController {
  CueController({
    required SessionProvider session, required SettingsProvider settings,
    required AudioService audio, required HapticsService haptics,
    required VoiceService voice, required WakeLockService wakeLock,
  });
  void dispose();
}
```
Constructor subscribes to `session.events` and adds a listener to `session` for `isActive`
changes. Mapping (each guarded by the matching settings flag; `voice` also by
`voice.isAvailable`):
| Event | sound | haptics | voice |
|---|---|---|---|
| prepareStarted | playWarning | warning | speak "Get ready" |
| roundStarted | playRoundStart | roundStart | speak "Round N" then, if the round has a focus, the focus |
| tenSecondWarning | playWarning | warning | none |
| finalThirty | playFinalThirty | finalThirty | speak "Thirty seconds" |
| cue | playTick | cue | speak `cueToSpeech(text)` |
| restStarted | playRoundEnd | roundEnd | speak "Rest" |
| roundSkipped | none | cue | none |
| paused | none | cue | stop speaking |
| resumed | none | cue | none |
| sessionCompleted | playRoundEnd | roundEnd | speak "Session complete" |
| sessionEnded | none | roundEnd | stop speaking |
Wake lock: when `session.isActive` becomes true and `settings.keepScreenOn`, `enable()`;
when it becomes false, `disable()`. `dispose()` cancels the subscription, removes the listener,
disables the wake lock. Calls are fire-and-forget (`unawaited`), never awaited on the event loop
that delivers the session tick. Also `voice.init()` is called once from the constructor
(fire-and-forget).

### `main.dart`
```dart
final audio = AudioService();
final haptics = HapticsService();
final voice = VoiceService();
final wakeLock = WakeLockService();
final cues = CueController(session: session, settings: settings, audio: audio,
    haptics: haptics, voice: voice, wakeLock: wakeLock);
```
before `runApp`; `cues` is kept alive for the process lifetime (assign to a top-level
`late final` or hold it in `BoxerOsApp` as a field; it is never disposed in production). Do not
put services in the provider tree.

### Android manifest
Inside the existing `<queries>` add
`<intent><action android:name="android.intent.action.TTS_SERVICE" /></intent>` so the app can
bind the TTS engine on Android 11+. No new `<uses-permission>`: `WAKE_LOCK` comes from
`wakelock_plus`'s merged manifest and `HapticFeedback` needs none.

### docs/architecture.md
Module map rows; under "Native bridge" list the manifest `<queries>` entries and note the
permissions merged from plugins. Dependencies list in "Stack" updated.

## Out of scope
- No UI, no settings screen.
- No foreground service, no notifications, no custom vibration plugin.
- No changes to `SessionProvider`.

## Acceptance criteria
- [ ] With fake services (subclasses that record calls), a session driven through prepare ->
      round 1 -> final 30 -> 10 s -> cue -> rest -> round 2 -> complete produces exactly the
      table's calls, in order; with `soundEnabled == false` no audio calls; with
      `voiceEnabled == false` no speak calls; with `hapticsEnabled == false` no haptic calls.
- [ ] Wake lock `enable()` is called once when the session starts and `disable()` once when it
      completes or is ended; never when `keepScreenOn` is false.
- [ ] `cueToSpeech` cases above pass, and `cueToSpeech('')` is `''`.
- [ ] Each real service returns `false`, not an exception, when its platform channel is not
      mocked in a test (`TestDefaultBinaryMessengerBinding`).
- [ ] `flutter build apk --debug` succeeds with the three new plugins.
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/services/cue_controller_test.dart` (fake services as subclasses
  overriding the methods, `SessionProvider(clock: ...)` with a fake clock and `FakeAsync`,
  `SettingsProvider` over `setMockInitialValues`), `test/utils/cue_speech_test.dart`,
  `test/services/haptics_service_test.dart` (mock the `flutter/platform` channel and assert the
  method calls; unmocked channel -> `false`).
