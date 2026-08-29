import 'package:audioplayers/audioplayers.dart';

/// The context the cue players run on: media usage, so the bells follow the
/// phone's media volume, ducking music instead of stopping it.
AudioContext audioContextForCues() => AudioContext(
  android: const AudioContextAndroid(
    contentType: AndroidContentType.sonification,
    usageType: AndroidUsageType.media,
    audioFocus: AndroidAudioFocus.gainTransientMayDuck,
  ),
);

/// Plays the bundled bells and beeps that mark the phases of a session.
class AudioService {
  static const String _assetFolder = 'audio';

  final AudioPlayer _bells = AudioPlayer(playerId: 'boxer_os_bells');
  final AudioPlayer _beeps = AudioPlayer(playerId: 'boxer_os_beeps');

  bool _isInitialized = false;

  /// Configures both players; safe to call repeatedly, does the work once.
  Future<bool> init() async {
    if (_isInitialized) return true;
    final context = audioContextForCues();
    try {
      for (final player in [_bells, _beeps]) {
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setAudioContext(context);
        await player.setVolume(1.0);
      }
      _isInitialized = true;
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }

  Future<bool> playRoundStart() => _play(_bells, 'bell_start.wav');

  Future<bool> playRoundEnd() => _play(_bells, 'bell_end.wav');

  Future<bool> playWarning() => _play(_beeps, 'beep_warning.wav');

  Future<bool> playFinalThirty() => _play(_beeps, 'beep_final.wav');

  Future<bool> playTick() => _play(_beeps, 'tick_cue.wav');

  Future<void> dispose() async {
    try {
      await _bells.dispose();
      await _beeps.dispose();
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
    }
  }

  Future<bool> _play(AudioPlayer player, String file) async {
    if (!await init()) return false;
    try {
      await player.stop();
      await player.play(AssetSource('$_assetFolder/$file'));
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }
}
