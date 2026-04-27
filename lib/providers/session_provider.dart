import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../services/player_service.dart';

class SessionProvider extends ChangeNotifier {
  final SessionService _sessionService = SessionService();
  final PlayerService _playerService = PlayerService();

  List<SessionModel> _allSessions = [];
  List<String> _enrolledSessionIds = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;

  List<SessionModel> get sessions {
    final query = _searchQuery.toLowerCase().trim();
    final queryNoHyphens = query.replaceAll('-', '');

    if (query.isEmpty) {
      return [..._allSessions]..sort((a, b) => a.label.compareTo(b.label));
    }

    return _allSessions.where((s) {
      final labelMatch = s.label.toLowerCase().contains(query);
      final idMatch = s.id.toLowerCase().contains(query);
      final idNoHyphensMatch = s.id
          .replaceAll('-', '')
          .toLowerCase()
          .contains(queryNoHyphens);
      return labelMatch || idMatch || idNoHyphensMatch;
    }).toList()
      ..sort((a, b) => a.label.compareTo(b.label));
  }

  bool isEnrolled(String sessionId) =>
      _enrolledSessionIds.contains(sessionId);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  Future<void> loadHostSessions(String hostId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSessions = await _sessionService.getHostSessions(hostId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendingSessions({String? playerId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Pass playerId so active enrolled sessions are included
      _allSessions = await _sessionService.getPendingSessions(
        playerId: playerId,
      );
      print('✅ Sessions loaded: ${_allSessions.length}');

      if (playerId != null) {
        try {
          _enrolledSessionIds =
          await _playerService.getEnrolledSessionIds(playerId);
          print('✅ Enrolled sessions: $_enrolledSessionIds');
        } catch (e) {
          print('❌ getEnrolledSessionIds error: $e');
          _enrolledSessionIds = [];
        }
      }
    } catch (e) {
      print('❌ loadPendingSessions error: $e');
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> leaveSession({
    required String sessionId,
    required String playerId,
  }) async {
    try {
      await _playerService.leaveSession(
        sessionId: sessionId,
        playerId: playerId,
      );
      _enrolledSessionIds.remove(sessionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<SessionModel?> createSession({
    required String label,
    required String hostId,
  }) async {
    try {
      final session = await _sessionService.createSession(
        label: label,
        hostId: hostId,
      );
      _allSessions.add(session);
      notifyListeners();
      return session;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
}