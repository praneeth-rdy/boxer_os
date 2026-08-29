import 'package:flutter_tts/flutter_tts.dart';

/// Speaks cues and phase announcements through the device TTS engine.
class VoiceService {
  static const String _testLine =
      'Round one. Jab, cross, lead hook, rear uppercut. '
      'Slip, roll, pivot. Thirty seconds.';

  final FlutterTts _tts = FlutterTts();

  bool _isAvailable = false;
  String? _voiceName;

  /// False until [init] succeeds, so callers can skip speaking entirely.
  bool get isAvailable => _isAvailable;

  /// The US voice picked at init, or null when the engine's own choice stands.
  String? get voiceName => _voiceName;

  Future<bool> init() async {
    try {
      await _tts.setLanguage('en-US');
      _isAvailable = true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      _isAvailable = false;
      return false;
    }
    try {
      await _selectUsVoice();
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.awaitSpeakCompletion(false);
    } catch (failure) {
      // The engine still speaks with its defaults, so keep availability.
    }
    return _isAvailable;
  }

  /// Interrupts whatever is being said so the newest cue is the one heard.
  Future<bool> speak(String text) async {
    if (text.isEmpty) return false;
    try {
      await _tts.stop();
      await _tts.speak(text);
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }

  /// Speaks a fixed line of boxing terms so the chosen voice can be judged.
  Future<bool> sayTest() => speak(_testLine);

  Future<bool> stop() async {
    try {
      await _tts.stop();
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }

  Future<void> dispose() => stop();

  /// The device locale is en-IN, whose voice mispronounces the punch names.
  Future<void> _selectUsVoice() async {
    final voices = await _tts.getVoices;
    if (voices is! List) return;
    final names = <String>[];
    for (final voice in voices) {
      if (voice is! Map) continue;
      final name = voice['name']?.toString() ?? '';
      final locale = voice['locale']?.toString().toLowerCase().replaceAll(
        '_',
        '-',
      );
      if (name.isEmpty || locale == null || !locale.startsWith('en-us')) {
        continue;
      }
      names.add(name);
    }
    if (names.isEmpty) return;
    final chosen = names.firstWhere(
      (name) => !name.toLowerCase().contains('network'),
      orElse: () => names.first,
    );
    await _tts.setVoice({'name': chosen, 'locale': 'en-US'});
    _voiceName = chosen;
  }
}
