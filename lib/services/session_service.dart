import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/session_model.dart';

class SessionService {
  final _supabase = Supabase.instance.client;

  Future<SessionModel> createSession({
    required String label,
    required String hostId,
  }) async {
    final data = await _supabase.from('sessions').insert({
      'label': label,
      'host_id': hostId,
      'status': 'pending',
      'players_ready': 0,
      'participant_count': 0, // ← initialize it
    }).select().single();

    return SessionModel.fromMap(data);
  }

  Future<List<SessionModel>> getHostSessions(String hostId) async {
    final data = await _supabase
        .from('sessions')
        .select('*, questions(count)')
        .eq('host_id', hostId)
        .order('label', ascending: true);

    return (data as List).map((s) {
      s['question_count'] = s['questions'][0]['count'];
      return SessionModel.fromMap(s);
    }).toList();
  }

  Future<List<SessionModel>> getPendingSessions({String? playerId}) async {
    final pendingData = await _supabase
        .from('sessions')
        .select('*')
        .eq('status', 'pending');

    final pendingSessions = (pendingData as List)
        .map((s) {
      s['question_count'] = 0;
      return SessionModel.fromMap(s);
    })
        .toList();

    if (playerId != null) {
      final enrolledData = await _supabase
          .from('participants')
          .select('session_id')
          .eq('player_id', playerId);

      final enrolledIds = (enrolledData as List)
          .map<String>((r) => r['session_id'].toString())
          .toList();

      if (enrolledIds.isNotEmpty) {
        final activeData = await _supabase
            .from('sessions')
            .select('*')
            .eq('status', 'active')
            .inFilter('id', enrolledIds);

        final activeSessions = (activeData as List).map((s) {
          s['question_count'] = 0;
          return SessionModel.fromMap(s);
        }).toList();

        final allIds = pendingSessions.map((s) => s.id).toSet();
        for (final s in activeSessions) {
          if (!allIds.contains(s.id)) {
            pendingSessions.add(s);
          }
        }
      }
    }

    return pendingSessions;
  }

  Future<void> activateSession(String sessionId) async {
    await _supabase
        .from('sessions')
        .update({'status': 'active'}).eq('id', sessionId);
  }

  Future<void> finishSession(String sessionId) async {
    await _supabase
        .from('sessions')
        .update({'status': 'finished'}).eq('id', sessionId);
  }

  Future<void> deleteSession(String sessionId) async {
    await _supabase.from('sessions').delete().eq('id', sessionId);
  }

  // Called when player enrolls in a session
  Future<void> enrollPlayer(String sessionId) async {
    await _supabase.rpc('increment_participant_count',
        params: {'session_id_input': sessionId});
  }

  // Called when player leaves a session entirely
  Future<void> unenrollPlayer(String sessionId) async {
    await _supabase.rpc('decrement_participant_count',
        params: {'session_id_input': sessionId});
  }

  // Called when player enters the waiting room (session is active)
  Future<void> playerEnteredRoom(String sessionId) async {
    await _supabase.rpc('increment_players_ready',
        params: {'session_id_input': sessionId});
  }

  // Called when player leaves the waiting room
  Future<void> playerLeftRoom(String sessionId) async {
    await _supabase.rpc('decrement_players_ready',
        params: {'session_id_input': sessionId});
  }

  Stream<Map<String, dynamic>> listenToSession(String sessionId) {
    return _supabase
        .from('sessions')
        .stream(primaryKey: ['id'])
        .eq('id', sessionId)
        .map((rows) => rows.isNotEmpty ? rows.first : {});
  }

  Future<Map<String, dynamic>> getSessionOnce(String sessionId) async {
    final data = await _supabase
        .from('sessions')
        .select()
        .eq('id', sessionId)
        .single();
    return data;
  }

  // Enter room — upsert so it's safe to call twice
  Future<void> enterRoom({
    required String sessionId,
    required String playerId,
  }) async {
    await _supabase.from('room_presence').upsert({
      'session_id': sessionId,
      'player_id': playerId,
    }, onConflict: 'session_id,player_id');
  }

  // Stream count of enrolled participants for a session
  Stream<int> listenToParticipantCount(String sessionId) {
    return _supabase
        .from('participants')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .map((rows) => rows.length);
  }

// Leave room — called only when quiz ends
  Future<void> leaveRoom({
    required String sessionId,
    required String playerId,
  }) async {
    await _supabase
        .from('room_presence')
        .delete()
        .eq('session_id', sessionId)
        .eq('player_id', playerId);
  }

// Stream the live count of players in the room
  Stream<int> listenToRoomCount(String sessionId) {
    return _supabase
        .from('participants')
        .stream(primaryKey: ['session_id', 'player_id']) // composite PK!
        .eq('session_id', sessionId)
        .map((rows) => rows.length);
  }

// Already exists — keep as-is
  Future<int> getParticipantCount(String sessionId) async {
    final data = await _supabase
        .from('participants')
        .select()
        .eq('session_id', sessionId);
    return (data as List).length;
  }

  Future<int> getRoomCount(String sessionId) async {
    final data = await _supabase
        .from('room_presence')
        .select()
        .eq('session_id', sessionId);
    return (data as List).length;
  }

  Future<void> setQuizStartTime(String sessionId) async {
    try {
      final result = await _supabase.rpc('set_quiz_start_time', params: {
        'session_id_input': sessionId,
      });
      print('✅ setQuizStartTime result: $result');
    } catch (e) {
      print('❌ setQuizStartTime error: $e');
    }
  }




}