import 'package:flutter/services.dart';

/// Vibration patterns for the phases and cues of a session.
class HapticsService {
  static const Duration _gap = Duration(milliseconds: 120);

  Future<bool> roundStart() => _pulse(2, HapticFeedback.heavyImpact);

  Future<bool> roundEnd() => _pulse(3, HapticFeedback.heavyImpact);

  Future<bool> warning() => _pulse(1, HapticFeedback.mediumImpact);

  Future<bool> finalThirty() => _pulse(2, HapticFeedback.mediumImpact);

  Future<bool> cue() => _pulse(1, HapticFeedback.selectionClick);

  Future<bool> _pulse(int times, Future<void> Function() impact) async {
    try {
      for (var i = 0; i < times; i++) {
        if (i > 0) await Future<void>.delayed(_gap);
        await impact();
      }
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }
}
