class UserModel {
  final String id;
  final String displayName;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      role: map['role'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isHost => role == 'host';
  bool get isPlayer => role == 'player';
}