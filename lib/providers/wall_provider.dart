import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/posters.dart';
import '../models/poster.dart';
import '../services/wallpaper_service.dart';

/// Which posters the live wallpaper cycles through, and the render that stores them.
class WallProvider extends ChangeNotifier {
  static const String wallShuffleAllKey = 'wall_shuffle_all';
  static const String wallShuffleIdsKey = 'wall_shuffle_ids';

  static const String _renderFailed = 'Could not render the posters';
  static const String _saveFailed = 'Could not store the posters on this phone';

  final List<Poster> _posters = posters();
  final Set<String> _selectedIds = {};
  bool _shuffleAll = true;
  bool _isRendering = false;
  bool _isCancelled = false;
  int _renderedCount = 0;
  int _renderTotal = 0;
  String? _error;

  bool get shuffleAll => _shuffleAll;
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  bool get isRendering => _isRendering;
  int get renderedCount => _renderedCount;
  int get renderTotal => _renderTotal;
  String? get error => _error;

  /// The posters the wallpaper cycles through, in gallery order.
  List<Poster> get rotation => _shuffleAll
      ? List.unmodifiable(_posters)
      : List.unmodifiable(
          _posters.where((poster) => _selectedIds.contains(poster.id)),
        );

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _shuffleAll = prefs.getBool(wallShuffleAllKey) ?? true;
      _selectedIds
        ..clear()
        ..addAll(prefs.getStringList(wallShuffleIdsKey) ?? const []);
      _error = null;
    } catch (failure) {
      _error = 'Could not read the poster selection';
    }
    notifyListeners();
  }

  Future<void> setShuffleAll(bool isAll) async {
    if (_shuffleAll == isAll) {
      return;
    }
    _shuffleAll = isAll;
    notifyListeners();
    await _persist();
  }

  Future<void> toggle(String id) async {
    if (!_selectedIds.remove(id)) {
      _selectedIds.add(id);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> clearSelection() async {
    if (_selectedIds.isEmpty) {
      return;
    }
    _selectedIds.clear();
    notifyListeners();
    await _persist();
  }

  void cancelRender() {
    _isCancelled = true;
  }

  /// Renders the rotation in a random order and hands each poster to [service],
  /// reporting whether the whole rotation was stored.
  Future<bool> applyRotation(
    Future<Uint8List> Function(Poster) render,
    WallpaperService service,
  ) async {
    final frames = [...rotation]..shuffle(Random());
    if (frames.isEmpty || _isRendering) {
      return false;
    }
    _isCancelled = false;
    _isRendering = true;
    _renderedCount = 0;
    _renderTotal = frames.length;
    _error = null;
    notifyListeners();
    for (var index = 0; index < frames.length; index++) {
      if (_isCancelled) {
        return _finishRender(false);
      }
      Uint8List png;
      try {
        png = await render(frames[index]);
      } catch (failure) {
        _error = _renderFailed;
        return _finishRender(false);
      }
      final isSaved = await service.saveRotationFrame(
        index: index,
        count: frames.length,
        png: png,
      );
      if (!isSaved) {
        _error = _saveFailed;
        return _finishRender(false);
      }
      _renderedCount = index + 1;
      notifyListeners();
    }
    return _finishRender(true);
  }

  bool _finishRender(bool isDone) {
    _isRendering = false;
    notifyListeners();
    return isDone;
  }

  /// Keeps the in-memory selection whatever the platform does; failures surface on [error].
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(wallShuffleAllKey, _shuffleAll);
      await prefs.setStringList(wallShuffleIdsKey, _selectedIds.toList());
      _setError(null);
    } catch (failure) {
      _setError('Could not save the poster selection');
    }
  }

  void _setError(String? message) {
    if (_error == message) {
      return;
    }
    _error = message;
    notifyListeners();
  }
}
