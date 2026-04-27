class LeaderboardEntryModel {
  final String playerId;
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int rank;

  LeaderboardEntryModel({
    required this.playerId,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.rank,
  });

  factory LeaderboardEntryModel.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntryModel(
      playerId: map['player_id'],
      displayName: map['users']['display_name'],
      avatarUrl: map['users']['avatar_url'],
      score: map['score'] ?? 0,
      rank: rank,
    );
  }
}