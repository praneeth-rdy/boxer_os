import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen awake while a session is running.
class WakeLockService {
  Future<bool> enable() async {
    try {
      await WakelockPlus.enable();
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }

  Future<bool> disable() async {
    try {
      await WakelockPlus.disable();
      return true;
    } catch (failure) {
      // Plugin failures are non-fatal during a session.
      return false;
    }
  }
}
