import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/match_state.dart';

class MatchStore {
  static const _activeKey = 'royal_noir_active_match_v1';
  static const _historyKey = 'royal_noir_results_v1';

  Future<void> save(MatchState value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeKey, jsonEncode(value.toJson()));
  }

  Future<MatchState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_activeKey);
    if (raw == null) return null;
    try {
      return MatchState.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeKey);
  }

  Future<List<Map<String, dynamic>>> results() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> archive(MatchState state) async {
    final history = await results();
    history.insert(0, {
      'teams': state.teams,
      'scores': state.scores,
      'mode': state.settings.mode.name,
      'winner': state.winner,
      'at': DateTime.now().toIso8601String(),
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(history.take(50).toList()));
    await clear();
  }
}
