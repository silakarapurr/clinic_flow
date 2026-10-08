import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> login({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<UserProfile?> getCurrentUser();

  Future<void> logout();

  Future<void> deleteAccount();
}
