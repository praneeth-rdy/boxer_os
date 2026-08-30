import 'package:flutter/services.dart';

/// Which screen a poster is set on.
enum WallpaperTarget { home, lock, both }

/// Sets a rendered poster as the device wallpaper.
class WallpaperService {
  const WallpaperService();

  static const MethodChannel _channel = MethodChannel('boxer_os/wallpaper');

  /// Sets [png] on [target], and reports whether Android took it.
  Future<bool> set(Uint8List png, WallpaperTarget target) async {
    try {
      final isSet = await _channel.invokeMethod<bool>('setWallpaper', {
        'bytes': png,
        'target': target.name,
      });
      return isSet ?? false;
    } catch (failure) {
      // The platform refused the bitmap; the page tells the boxer it failed.
      return false;
    }
  }

  /// Stores one poster of the live wallpaper rotation, and reports whether it was written.
  Future<bool> saveRotationFrame({
    required int index,
    required int count,
    required Uint8List png,
  }) async {
    try {
      final isSaved = await _channel.invokeMethod<bool>('saveRotation', {
        'index': index,
        'count': count,
        'bytes': png,
      });
      return isSaved ?? false;
    } catch (failure) {
      // A poster that cannot be stored stops the rotation; the provider reports it.
      return false;
    }
  }

  /// Opens Android's live wallpaper screen on Gym Wall, and reports whether it opened.
  Future<bool> openLivePicker() async {
    try {
      final isOpen = await _channel.invokeMethod<bool>(
        'openLiveWallpaperPicker',
      );
      return isOpen ?? false;
    } catch (failure) {
      // No live wallpaper picker on this device; the page keeps its status line.
      return false;
    }
  }

  /// Whether Gym Wall is the wallpaper Android is currently showing.
  Future<bool> isLiveActive() async {
    try {
      final isActive = await _channel.invokeMethod<bool>(
        'isLiveWallpaperActive',
      );
      return isActive ?? false;
    } catch (failure) {
      // Unknown counts as off, which is what the status line then shows.
      return false;
    }
  }
}
