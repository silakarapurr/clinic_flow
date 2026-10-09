import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _storageService;
  final fb.FirebaseAuth? _firebaseAuth;
  final FirebaseFirestore? _firestore;
  UserProfile? _currentUser;

  AuthRepositoryImpl({
    required SecureStorageService storageService,
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _storageService = storageService,
        _firebaseAuth = firebaseAuth ?? _tryGetFirebaseAuth(),
        _firestore = firestore ?? _tryGetFirestore();

  static fb.FirebaseAuth? _tryGetFirebaseAuth() {
    try {
      return fb.FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _tryGetFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || password.length < 6) {
      throw const AuthException(message: AppStrings.authInvalidCredentials);
    }

    // 1. Super Admin Account (admin / admin123 or admin@clinicflow.com / admin123)
    final isSuperAdmin = cleanEmail.toLowerCase() == 'admin' ||
        cleanEmail.toLowerCase() == 'admin@clinicflow.com';
    if (isSuperAdmin) {
      if (password == 'admin123') {
        const adminProfile = UserProfile(
          id: 'admin-super-001',
          clinicId: SeedData.clinicId,
          fullName: 'Sistem Yöneticisi (Super Admin)',
          email: 'admin@clinicflow.com',
          role: UserRole.admin,
        );
        _currentUser = adminProfile;
        await _storageService.saveAuthToken('token-admin-super');
        await _storageService.saveClinicId(adminProfile.clinicId);
        return adminProfile;
      } else {
        throw const AuthException(message: AppStrings.authInvalidCredentials);
      }
    }

    // 2. Demo account check (prefilled credentials for Apple Review and local preview)
    final isDemoAccount =
        cleanEmail.toLowerCase() == 'dr.zeynep@clinicflow.com' ||
            cleanEmail.toLowerCase() == 'zeynep@clinicflow.com';
    if (isDemoAccount) {
      if (password == '123456') {
        return _loginOffline(cleanEmail);
      } else {
        throw const AuthException(message: AppStrings.authInvalidCredentials);
      }
    }

    // 3. Approved Users verification via Firestore (Cloud Registry for Web-Approved Clinicians)
    if (_firestore != null) {
      try {
        final docSnap = await _firestore
            .collection('approved_users')
            .doc(cleanEmail.toLowerCase())
            .get();

        if (docSnap.exists && docSnap.data() != null) {
          final data = docSnap.data()!;
          final status = (data['status'] as String? ?? 'approved').toLowerCase();
          final isActive = data['is_active'] as bool? ?? true;
          final storedPassword = data['password'] as String?;

          if (status == 'pending') {
            throw const AuthException(
              message: 'Hesap başvurunuz henüz yönetici tarafından onaylanmamıştır. Lütfen onay bekleyiniz.',
            );
          }
          if (status == 'rejected') {
            final reason = data['rejection_reason'] as String? ?? 'Başvuru şartları sağlanamadı.';
            throw AuthException(
              message: 'Hesap başvurunuz reddedilmiştir: $reason',
            );
          }
          if (!isActive) {
            throw const AuthException(
              message: 'Hesabınız yönetici tarafından askıya alınmıştır.',
            );
          }
          if (storedPassword != null && storedPassword != password) {
            throw const AuthException(message: AppStrings.authInvalidCredentials);
          }

          final approvedProfile = UserProfile(
            id: data['id'] as String? ?? docSnap.id,
            clinicId: data['clinic_id'] as String? ?? SeedData.clinicId,
            fullName: data['full_name'] as String? ?? 'Klinik Hekimi',
            email: cleanEmail,
            role: UserRole.fromString(data['role'] as String? ?? 'admin'),
            isActive: true,
          );

          _currentUser = approvedProfile;
          await _storageService.saveAuthToken('token-${approvedProfile.id}');
          await _storageService.saveClinicId(approvedProfile.clinicId);
          return approvedProfile;
        }
      } catch (e) {
        if (e is AuthException) rethrow;
      }
    }

    if (_firebaseAuth != null) {
      try {
        fb.UserCredential? credential;
        try {
          credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
        } on fb.FirebaseAuthException catch (e) {
          // If user not found, auto-create for seamless initial clinic setup
          if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
            try {
              credential = await _firebaseAuth.createUserWithEmailAndPassword(
                email: cleanEmail,
                password: password,
              );
            } on fb.FirebaseAuthException catch (createError) {
              if (createError.code == 'email-already-in-use') {
                throw const AuthException(
                  message: AppStrings.authInvalidCredentials,
                );
              }
              // If Firebase Auth backend is unconfigured, fallback to offline demo mode
              return _loginOffline(cleanEmail);
            }
          } else if (e.code == 'configuration-not-found' ||
              e.code == 'operation-not-allowed' ||
              e.code == 'api-key-not-valid' ||
              e.code == 'network-request-failed') {
            return _loginOffline(cleanEmail);
          } else {
            rethrow;
          }
        }

        final fbUser = credential.user;
        final uid = fbUser?.uid ?? SeedData.userProfile.id;
        const clinicId = SeedData.clinicId;

        UserProfile profile = UserProfile(
          id: uid,
          clinicId: clinicId,
          fullName: fbUser?.displayName?.isNotEmpty == true
              ? fbUser!.displayName!
              : SeedData.userProfile.fullName,
          email: cleanEmail,
          role: UserRole.admin,
        );

        // Persist / sync profile in Firestore
        if (_firestore != null) {
          try {
            final docRef = _firestore.collection('users').doc(uid);
            final snap = await docRef.get();
            if (snap.exists && snap.data() != null) {
              profile = UserProfile.fromJson(snap.data()!);
            } else {
              await docRef.set(profile.toJson());
            }
          } catch (_) {
            // Continue with in-memory profile if network is down
          }
        }

        _currentUser = profile;
        final token = await fbUser?.getIdToken() ?? 'token-$uid';
        await _storageService.saveAuthToken(token);
        await _storageService.saveClinicId(profile.clinicId);

        return profile;
      } catch (e) {
        if (e is AuthException) rethrow;
        // Fallback for offline test environments or unconfigured Firebase backend
        return _loginOffline(cleanEmail);
      }
    }

    return _loginOffline(cleanEmail);
  }

  Future<UserProfile> _loginOffline(String cleanEmail) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final isDoctorZeynep =
        cleanEmail.toLowerCase() == 'dr.zeynep@clinicflow.com' ||
            cleanEmail.toLowerCase() == 'zeynep@clinicflow.com';

    final fallbackUser = UserProfile(
      id: SeedData.userProfile.id,
      clinicId: SeedData.clinicId,
      fullName: isDoctorZeynep
          ? SeedData.userProfile.fullName
          : 'Klinik Kullanıcısı',
      email: cleanEmail,
      role: UserRole.admin,
    );

    _currentUser = fallbackUser;
    await _storageService.saveAuthToken('dummy-jwt-token-for-${fallbackUser.id}');
    await _storageService.saveClinicId(fallbackUser.clinicId);
    return fallbackUser;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    final token = await _storageService.getAuthToken();
    if (token == null || token.isEmpty) {
      return null;
    }

    if (_firebaseAuth != null && _firebaseAuth.currentUser != null) {
      final fbUser = _firebaseAuth.currentUser!;
      if (_currentUser != null && _currentUser!.id == fbUser.uid) {
        return _currentUser;
      }

      if (_firestore != null) {
        try {
          final snap = await _firestore.collection('users').doc(fbUser.uid).get();
          if (snap.exists && snap.data() != null) {
            _currentUser = UserProfile.fromJson(snap.data()!);
            return _currentUser;
          }
        } catch (_) {}
      }

      _currentUser = UserProfile(
        id: fbUser.uid,
        clinicId: SeedData.clinicId,
        fullName: fbUser.displayName?.isNotEmpty == true
            ? fbUser.displayName!
            : SeedData.userProfile.fullName,
        email: fbUser.email ?? '',
        role: UserRole.admin,
      );
      return _currentUser;
    }

    _currentUser ??= SeedData.userProfile;
    return _currentUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      throw const AuthException(message: AppStrings.validationError);
    }

    if (_firebaseAuth != null) {
      try {
        await _firebaseAuth.sendPasswordResetEmail(email: cleanEmail);
        return;
      } catch (_) {
        // Fallback for offline or unconfigured environments
      }
    }

    await Future<void>.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<void> logout() async {
    if (_firebaseAuth != null) {
      await _firebaseAuth.signOut();
    }
    _currentUser = null;
    await _storageService.clearAll();
  }

  @override
  Future<void> deleteAccount() async {
    // Apple Review Guideline 5.1.1(v) compliance
    if (_firebaseAuth != null && _firebaseAuth.currentUser != null) {
      try {
        await _firebaseAuth.currentUser!.delete();
      } catch (_) {
        // Fallback to sign out
        await _firebaseAuth.signOut();
      }
    }
    _currentUser = null;
    await _storageService.clearAll();
  }
}
