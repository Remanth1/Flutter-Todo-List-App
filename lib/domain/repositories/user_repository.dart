import '../entities/user_profile.dart';

/// Domain contract for persisting and retrieving the user's profile.
/// Presentation must depend only on this interface — never on the data layer.
abstract class UserRepository {
  /// Returns the saved profile, or null if none exists yet.
  Future<UserProfile?> getProfile();

  /// Persists [profile], overwriting any existing entry.
  Future<void> saveProfile(UserProfile profile);

  /// Removes the stored profile (used for "reset all data").
  Future<void> deleteProfile();
}
