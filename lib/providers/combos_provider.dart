import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/combination.dart';

/// Bookmarked combinations, persisted in `shared_preferences`.
class CombosProvider extends ChangeNotifier {
  static const String savedKey = 'saved_combinations';

  final List<Combination> _saved = [];
  bool _isLoaded = false;
  String? _error;

  /// Oldest bookmark first.
  List<Combination> get saved => List.unmodifiable(_saved);

  bool get isLoaded => _isLoaded;
  String? get error => _error;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _saved
        ..clear()
        ..addAll(_decode(prefs.getString(savedKey)));
      _error = null;
    } catch (failure) {
      _error = 'Could not read saved combinations: $failure';
    }
    _isLoaded = true;
    notifyListeners();
  }

  bool isSaved(Combination combination) => _saved.contains(combination);

  Future<void> toggleSaved(Combination combination) async {
    if (isSaved(combination)) {
      return remove(combination);
    }
    _saved.add(combination);
    notifyListeners();
    await _persist();
  }

  Future<void> remove(Combination combination) async {
    _saved.remove(combination);
    notifyListeners();
    await _persist();
  }

  /// Keeps the in-memory bookmarks whatever the platform does; failures surface on [error].
  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode([
        for (final combination in _saved) combination.toJson(),
      ]);
      await prefs.setString(savedKey, encoded);
      _setError(null);
    } catch (failure) {
      _setError('Could not save combinations: $failure');
    }
  }

  void _setError(String? message) {
    if (_error == message) {
      return;
    }
    _error = message;
    notifyListeners();
  }

  static List<Combination> _decode(String? stored) {
    if (stored == null) {
      return const [];
    }
    final decoded = jsonDecode(stored);
    if (decoded is! List) {
      return const [];
    }
    final combinations = <Combination>[];
    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      try {
        combinations.add(Combination.fromJson(entry));
      } catch (_) {
        // One unreadable entry must not cost the rest of the bookmarks.
      }
    }
    return combinations;
  }
}
