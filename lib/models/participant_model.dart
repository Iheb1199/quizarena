class ParticipantModel {
  final String id;
  final String sessionId;
  final String playerId;
  final int score;
  final DateTime joinedAt;

  ParticipantModel({
    required this.id,
    required this.sessionId,
    required this.playerId,
    required this.score,
    required this.joinedAt,
  });

  factory ParticipantModel.fromMap(Map<String, dynamic> map) {
    return ParticipantModel(
      id: map['id'],
      sessionId: map['session_id'],
      playerId: map['player_id'],
      score: map['score'] ?? 0,
      joinedAt: DateTime.parse(map['joined_at']),
    );
  }
}