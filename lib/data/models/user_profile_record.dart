import '../../domain/entities/user_profile.dart';

class UserProfileRecord {
  const UserProfileRecord({
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

  factory UserProfileRecord.fromEntity(UserProfile profile) {
    return UserProfileRecord(
      id: profile.id,
      fullName: profile.fullName,
      username: profile.username,
      avatarEmoji: profile.avatarEmoji,
      themeId: profile.themeId,
      dailyGoal: profile.dailyGoal,
      joinedAt: profile.joinedAt,
    );
  }

  factory UserProfileRecord.fromMap(Map<String, dynamic> map) {
    return UserProfileRecord(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      username: map['username'] as String,
      avatarEmoji: map['avatarEmoji'] as String? ?? '🙂',
      themeId: map['themeId'] as String? ?? 'midnight',
      dailyGoal: map['dailyGoal'] as int? ?? 5,
      joinedAt: map['joinedAt'] is DateTime
          ? map['joinedAt'] as DateTime
          : DateTime.parse(map['joinedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      'avatarEmoji': avatarEmoji,
      'themeId': themeId,
      'dailyGoal': dailyGoal,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      fullName: fullName,
      username: username,
      avatarEmoji: avatarEmoji,
      themeId: themeId,
      dailyGoal: dailyGoal,
      joinedAt: joinedAt,
    );
  }
}

