import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/user_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class UserState {
  const UserState({
    this.profile,
    this.isLoaded = false,
  });

  final UserProfile? profile;
  final bool isLoaded;

  bool get isOnboardingComplete => profile != null;

  UserState copyWith({
    UserProfile? profile,
    bool clearProfile = false,
    bool? isLoaded,
  }) {
    return UserState(
      profile: clearProfile ? null : (profile ?? this.profile),
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class UserNotifier extends Notifier<UserState> {
  late UserRepository _repository;

  @override
  UserState build() {
    // Obtain the repository through the domain-facing provider.
    // No data layer import needed here.
    _repository = ref.watch(userRepositoryProvider);

    // UserRepositoryImpl.getProfile() is async, but we need a sync return.
    // Reading from Hive is effectively instant, so we use a postBuild trick:
    // return a loading state and schedule the async load for after build.
    _loadProfile();
    return const UserState(isLoaded: false);
  }

  Future<void> _loadProfile() async {
    final profile = await _repository.getProfile();
    state = UserState(profile: profile, isLoaded: true);
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _repository.saveProfile(profile);
    state = state.copyWith(profile: profile, isLoaded: true);
  }

  Future<void> updateProfile({
    String? fullName,
    String? username,
    String? avatarEmoji,
    String? themeId,
    int? dailyGoal,
  }) async {
    final current = state.profile;
    if (current == null) return;

    final updated = current.copyWith(
      fullName: fullName,
      username: username,
      avatarEmoji: avatarEmoji,
      themeId: themeId,
      dailyGoal: dailyGoal,
    );

    await saveProfile(updated);
  }

  Future<void> createNewProfile({
    required String fullName,
    required String username,
    String avatarEmoji = '🙂',
    String themeId = 'midnight',
    int dailyGoal = 5,
  }) async {
    const uuid = Uuid();
    final profile = UserProfile(
      id: uuid.v4(),
      fullName: fullName,
      username: username,
      avatarEmoji: avatarEmoji,
      themeId: themeId,
      dailyGoal: dailyGoal,
      joinedAt: DateTime.now(),
    );

    await saveProfile(profile);
  }

  Future<void> resetAllData() async {
    await _repository.deleteProfile();
    state = const UserState(profile: null, isLoaded: true);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final userProvider = NotifierProvider<UserNotifier, UserState>(
  UserNotifier.new,
);
