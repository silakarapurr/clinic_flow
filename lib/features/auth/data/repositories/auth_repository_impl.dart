import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _storageService;
  UserProfile? _currentUser;

  AuthRepositoryImpl({required SecureStorageService storageService})
      : _storageService = storageService;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    // Basic validation
    if (email.trim().isEmpty || password.length < 6) {
      throw const AuthException(message: AppStrings.authInvalidCredentials);
    }

    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Support demo credentials or any valid email for test
    final user = UserProfile(
      id: SeedData.userProfile.id,
      clinicId: SeedData.clinicId,
      fullName: SeedData.userProfile.fullName,
      email: email.trim(),
      role: UserRole.admin,
    );

    _currentUser = user;
    await _storageService.saveAuthToken('dummy-jwt-token-for-${user.id}');
    await _storageService.saveClinicId(user.clinicId);

    return user;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final token = await _storageService.getAuthToken();
    if (token != null && token.isNotEmpty) {
      _currentUser ??= SeedData.userProfile;
      return _currentUser;
    }
    return null;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      throw const AuthException(message: AppStrings.validationError);
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
    await _storageService.clearAll();
  }

  @override
  Future<void> deleteAccount() async {
    // Apple Guideline 5.1.1(v) compliance:
    // Wipes all user local sessions and simulates permanent account removal.
    _currentUser = null;
    await _storageService.clearAll();
  }
}
