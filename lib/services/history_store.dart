import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/reaction_result.dart';
import '../models/session_record.dart';

/// Reads and writes training history as JSON in `shared_preferences`.
class HistoryStore {
  HistoryStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const String sessionsKey = 'session_records';
  static const String reactionsKey = 'reaction_results';

  SharedPreferences? _prefs;

  Future<List<SessionRecord>> loadSessions() =>
      _load(sessionsKey, SessionRecord.fromJson);

  Future<bool> saveSessions(List<SessionRecord> sessions) =>
      _save(sessionsKey, sessions.map((record) => record.toJson()).toList());

  Future<List<ReactionResult>> loadReactions() =>
      _load(reactionsKey, ReactionResult.fromJson);

  Future<bool> saveReactions(List<ReactionResult> reactions) =>
      _save(reactionsKey, reactions.map((result) => result.toJson()).toList());

  Future<SharedPreferences> _preferences() async =>
      _prefs ??= await SharedPreferences.getInstance();

  Future<List<T>> _load<T>(
    String key,
    T Function(Map<String, dynamic>) parse,
  ) async {
    try {
      final prefs = await _preferences();
      final stored = prefs.getString(key);
      if (stored == null) {
        return <T>[];
      }
      final decoded = jsonDecode(stored);
      if (decoded is! List) {
        return <T>[];
      }
      final entries = <T>[];
      for (final entry in decoded) {
        if (entry is! Map<String, dynamic>) {
          continue;
        }
        try {
          entries.add(parse(entry));
        } catch (_) {
          // One unreadable entry must not cost the rest of the history.
        }
      }
      return entries;
    } catch (_) {
      return <T>[];
    }
  }

  Future<bool> _save(String key, List<Map<String, dynamic>> entries) async {
    try {
      final prefs = await _preferences();
      return await prefs.setString(key, jsonEncode(entries));
    } catch (_) {
      return false;
    }
  }
}
