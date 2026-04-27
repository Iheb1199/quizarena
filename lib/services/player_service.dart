import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/participant_model.dart';
import '../models/leaderboard_entry_model.dart';

class PlayerService {
  final _supabase = Supabase.instance.client;

  Future<ParticipantModel> joinSession({
    required String sessionId,
    required String playerId,
  }) async {
    final data = await _supabase.from('participants').insert({
      'session_id': sessionId,
      'player_id': playerId,
      'score': 0,
    }).select().single();

    return ParticipantModel.fromMap(data);
  }

  Future<void> leaveSession({
    required String sessionId,
    required String playerId,
  }) async {
    await _supabase
        .from('participants')
        .delete()
        .eq('session_id', sessionId)
        .eq('player_id', playerId);
  }

  Future<List<String>> getEnrolledSessionIds(String playerId) async {
    try {
      final participantData = await _supabase
          .from('participants')
          .select('session_id')
          .eq('player_id', playerId);

      if (participantData == null || (participantData as List).isEmpty) {
        return [];
      }

      final sessionIds = (participantData as List)
          .map<String>((row) => row['session_id'].toString())
          .toList();

      if (sessionIds.isEmpty) return [];

      final sessionData = await _supabase
          .from('sessions')
          .select('id, status')
          .inFilter('id', sessionIds);

      final result = (sessionData as List)
          .where((row) => row['status'] != 'finished')
          .map<String>((row) => row['id'].toString())
          .toList();

      return result;
    } catch (e) {
      print('❌ getEnrolledSessionIds error: $e');
      return [];
    }
  }

  Future<void> submitAnswer({
    required String participantId,
    required String questionId,
    String? answerId,
    required bool isCorrect,
    required int score,
  }) async {
    await _supabase.from('player_answers').insert({
      'participant_id': participantId,
      'question_id': questionId,
      'answer_id': answerId,
      'is_correct': isCorrect,
    });

    await _supabase
        .from('participants')
        .update({'score': score})
        .eq('id', participantId);
  }

  Future<List<LeaderboardEntryModel>> getLeaderboard(
      String sessionId) async {
    final data = await _supabase
        .from('participants')
        .select('*, users(display_name, avatar_url)')
        .eq('session_id', sessionId)
        .order('score', ascending: false)
        .limit(3);

    return (data as List)
        .asMap()
        .entries
        .map((e) => LeaderboardEntryModel.fromMap(e.value, e.key + 1))
        .toList();
  }

  Stream<List<Map<String, dynamic>>> listenToLeaderboard(
      String sessionId) {
    return _supabase
        .from('participants')
        .stream(primaryKey: ['id'])
        .eq('session_id', sessionId)
        .order('score', ascending: false);
  }

  Future<ParticipantModel?> getParticipant({
    required String sessionId,
    required String playerId,
  }) async {
    final data = await _supabase
        .from('participants')
        .select()
        .eq('session_id', sessionId)
        .eq('player_id', playerId)
        .maybeSingle();

    if (data == null) return null;
    return ParticipantModel.fromMap(data);
  }
}