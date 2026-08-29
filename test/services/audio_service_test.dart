import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boxer_os/services/audio_service.dart';

void main() {
  group('audioContextForCues', () {
    test('uses media usage so the bells follow the media volume', () {
      final context = audioContextForCues();

      expect(context.android.usageType, AndroidUsageType.media);
    });

    test('uses sonification content type', () {
      final context = audioContextForCues();

      expect(context.android.contentType, AndroidContentType.sonification);
    });

    test('requests transient focus that may duck other audio', () {
      final context = audioContextForCues();

      expect(
        context.android.audioFocus,
        AndroidAudioFocus.gainTransientMayDuck,
      );
    });
  });
}
