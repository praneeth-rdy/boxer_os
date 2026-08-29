# Task 01 - Bells on the media stream, US voice, test button

- **Run:** `.claude/handoffs/2026-08-29-experience/`
- **Depends on:** run 3 complete
- **Worker:** developer (Opus)
- **Tests:** yes (assistant)

## Goal
The bell is loud and follows the phone's media volume; spoken cues use a US-English voice
chosen explicitly (the phone's locale is en-IN and the default voice mispronounces "jab");
Settings gets a "Test voice" button so the owner can hear the result.

## Context the worker needs
- Findings: on the test phone `STREAM_SYSTEM` is aliased to the ring stream, so the
  `assistanceSonification` usage in `AudioService` ignored the media volume. The WAVs in
  `assets/audio/` were also quiet; they have been regenerated at 0.95 peak (no code change).
- `lib/services/audio_service.dart`, `lib/services/voice_service.dart`,
  `lib/services/cue_controller.dart`, `lib/pages/settings_page.dart` (run 3),
  `lib/main.dart`.
- flutter_tts API: `getVoices` returns a `List<dynamic>` of maps with `name` and `locale`
  (verify in `~/.pub-cache/hosted/pub.dev/flutter_tts-*/lib/flutter_tts.dart`), `setVoice`
  takes `Map<String, String>` with `name` and `locale`.

## Files
- `lib/services/audio_service.dart` - modify - audio context and volume.
- `lib/services/voice_service.dart` - modify - voice selection, `voiceName`, `sayTest`.
- `lib/main.dart` - modify - provide `VoiceService` to the tree.
- `lib/pages/settings_page.dart` - modify - "Test voice" button and the voice name caption.
- `docs/architecture.md` - modify - the audio and voice rows; a line in Layers about
  `Provider<VoiceService>`.
- `docs/decisions.md` - do not edit (Architect records the decision).

## Spec

### `AudioService`
Audio context: `usageType: AndroidUsageType.media`, `contentType: AndroidContentType.sonification`,
`audioFocus: AndroidAudioFocus.gainTransientMayDuck`. After the context, `await player.setVolume(1.0)`
on both players. Nothing else changes.

### `VoiceService`
`init()` after `setLanguage('en-US')`: call `getVoices()`, keep entries whose `locale`
(case-insensitive, `-` or `_`) starts with `en-US`; prefer a name that does not contain
`network`; if any, `setVoice({'name': name, 'locale': 'en-US'})` and store
`String? voiceName`. If none, leave the engine's choice and `voiceName = null`. Speech rate
`0.5`. Any throw here is caught, `isAvailable` stays whatever `setLanguage` produced (true if
it did not throw). New `Future<bool> sayTest()` that speaks
`'Round one. Jab, cross, lead hook, rear uppercut. Slip, roll, pivot. Thirty seconds.'`.

### `main.dart`
Add `Provider<VoiceService>.value(value: voice)` to the providers list (plain `Provider`, the
service is not a `ChangeNotifier`). This is the one service exposed to pages, for a one-off
action; do not expose the others.

### Settings page
Under the CUES section, after the four switches: a `PillButton('Test voice', ghost)` that calls
`context.read<VoiceService>().sayTest()`; beneath it a `caption` reading
"Voice: {voiceName}" or "Voice: system default" (read once at build). Disabled (onPressed null)
when `voiceEnabled` is false.

## Out of scope
- Bundled voice clips; pronunciation respelling tables (revisit only if the US voice is still
  wrong after the owner tests it).
- Any change to the cue mapping or timing.

## Acceptance criteria
- [ ] `AudioService.init()` sets the media usage and volume 1.0 (test via the audioplayers
      method channel mock: assert the `setAudioContext` and `setVolume` calls, or, if the
      plugin's global channel makes that impractical, a unit test on a small pure helper
      `audioContextForCues()` that returns the context).
- [ ] `VoiceService.init()` with a mocked `flutter_tts` channel returning two voices
      (`en-IN` local, `en-US` local) selects the `en-US` one; with only `en-US-network` it selects
      that; with none it leaves `voiceName` null.
- [ ] Settings shows the button and caption; tapping calls `sayTest` (fake `VoiceService`
      subclass injected through `Provider<VoiceService>.value`).
- [ ] `flutter analyze` 0 issues.

## Verification
- Assistant tests: `test/services/voice_service_test.dart` (mock the `flutter_tts` method
  channel with `TestDefaultBinaryMessengerBinding`), `test/pages/settings_page_test.dart` (extend).
