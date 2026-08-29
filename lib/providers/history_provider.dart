import 'package:flutter/foundation.dart';

import '../models/reaction_result.dart';
import '../models/session_record.dart';
import '../services/history_store.dart';

/// Training history in memory, persisted through [HistoryStore] after every change.
class HistoryProvider extends ChangeNotifier {
  HistoryProvider({HistoryStore? store}) : _store = store ?? HistoryStore();

  static const String _saveError = 'Could not save history';

  final HistoryStore _store;
  final List<SessionRecord> _sessions = [];
  final List<ReactionResult> _reactions = [];
  bool _isLoaded = false;
  String? _error;

  bool get isLoaded => _isLoaded;
  String? get error => _error;

  /// Newest first.
  List<SessionRecord> get sessions => List.unmodifiable(_sessions);

  /// Newest first.
  List<ReactionResult> get reactions => List.unmodifiable(_reactions);

  Future<void> load() async {
    final storedSessions = await _store.loadSessions();
    final storedReactions = await _store.loadReactions();
    _sessions
      ..clear()
      ..addAll(storedSessions);
    _reactions
      ..clear()
      ..addAll(storedReactions);
    _sortSessions();
    _sortReactions();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addSession(SessionRecord record) async {
    _sessions.removeWhere((stored) => stored.id == record.id);
    _sessions.add(record);
    _sortSessions();
    notifyListeners();
    await _persistSessions();
  }

  Future<void> updateSession(SessionRecord record) => addSession(record);

  Future<void> deleteSession(String id) async {
    _sessions.removeWhere((stored) => stored.id == id);
    notifyListeners();
    await _persistSessions();
  }

  Future<void> addReaction(ReactionResult result) async {
    _reactions.add(result);
    _sortReactions();
    notifyListeners();
    await _persistReactions();
  }

  Future<void> clearAll() async {
    _sessions.clear();
    _reactions.clear();
    notifyListeners();
    final savedSessions = await _store.saveSessions(_sessions);
    final savedReactions = await _store.saveReactions(_reactions);
    _setError(savedSessions && savedReactions ? null : _saveError);
  }

  SessionRecord? findSession(String id) {
    for (final record in _sessions) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  Future<void> _persistSessions() async {
    _setError(await _store.saveSessions(_sessions) ? null : _saveError);
  }

  Future<void> _persistReactions() async {
    _setError(await _store.saveReactions(_reactions) ? null : _saveError);
  }

  void _sortSessions() =>
      _sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));

  void _sortReactions() =>
      _reactions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  void _setError(String? message) {
    if (_error == message) {
      return;
    }
    _error = message;
    notifyListeners();
  }
}
