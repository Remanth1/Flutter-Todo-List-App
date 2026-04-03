class UserProfile {
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatarEmoji,
    required this.themeId,
    required this.dailyGoal,
    required this.joinedAt,
  });

  final String id;
  final String fullName;
  final String username;
  final String avatarEmoji;
  final String themeId;
  final int dailyGoal;
  final DateTime joinedAt;

  String get firstName => fullName.split(' ').first;

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? username,
    String? avatarEmoji,
    String? themeId,
    int? dailyGoal,
    DateTime? joinedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      themeId: themeId ?? this.themeId,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          username == other.username &&
          avatarEmoji == other.avatarEmoji &&
          themeId == other.themeId &&
          dailyGoal == other.dailyGoal &&
          joinedAt == other.joinedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      username.hashCode ^
      avatarEmoji.hashCode ^
      themeId.hashCode ^
      dailyGoal.hashCode ^
      joinedAt.hashCode;
}

