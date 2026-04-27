class SessionModel {
  final String id;
  final String label;
  final String hostId;
  final String status;
  final DateTime createdAt;
  final int participantCount;
  final int questionCount;
  final int playersReady;

  SessionModel({
    required this.id,
    required this.label,
    required this.hostId,
    required this.status,
    required this.createdAt,
    this.participantCount = 0,
    this.questionCount = 0,
    this.playersReady = 0,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      id: map['id'],
      label: map['label'],
      hostId: map['host_id'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      participantCount: map['participant_count'] ?? 0,
      questionCount: map['question_count'] ?? 0,
      playersReady: map['players_ready'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'host_id': hostId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'participant_count': participantCount,
      'question_count': questionCount,
      'players_ready': playersReady,
    };
  }

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
  bool get isFinished => status == 'finished';

  // Changed to 10 questions and 2 participants minimum
  bool get canActivate => participantCount >= 2 && questionCount >= 10;
}