import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_profile_record.dart';

class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._box);

  final Box<dynamic> _box;

  static const _key = 'current_user';

  @override
  Future<UserProfile?> getProfile() async {
    try {
      final raw = _box.get(_key);
      if (raw == null) return null;
      final map = Map<String, dynamic>.from(raw as Map);
      return UserProfileRecord.fromMap(map).toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final record = UserProfileRecord.fromEntity(profile);
    await _box.put(_key, record.toMap());
  }

  @override
  Future<void> deleteProfile() async {
    await _box.delete(_key);
  }
}
