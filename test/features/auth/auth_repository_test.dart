import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinic_flow/core/constants/app_strings.dart';
import 'package:clinic_flow/core/error/exceptions.dart';
import 'package:clinic_flow/core/storage/secure_storage_service.dart';
import 'package:clinic_flow/features/auth/data/repositories/auth_repository_impl.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorageService mockStorageService;
  late AuthRepositoryImpl authRepository;

  setUp(() {
    mockStorageService = MockSecureStorageService();
    when(() => mockStorageService.saveAuthToken(any())).thenAnswer((_) async {});
    when(() => mockStorageService.saveClinicId(any())).thenAnswer((_) async {});
    when(() => mockStorageService.getAuthToken()).thenAnswer((_) async => null);
    when(() => mockStorageService.clearAll()).thenAnswer((_) async {});

    authRepository = AuthRepositoryImpl(
      storageService: mockStorageService,
      firebaseAuth: null,
      firestore: null,
    );
  });

  group('AuthRepositoryImpl Tests', () {
    test('should login successfully with demo credentials (dr.zeynep@clinicflow.com / 123456)', () async {
      final user = await authRepository.login(
        email: 'dr.zeynep@clinicflow.com',
        password: '123456',
      );

      expect(user.email, equals('dr.zeynep@clinicflow.com'));
      expect(user.fullName, equals('Dr. Zeynep Kaya'));
      verify(() => mockStorageService.saveAuthToken(any())).called(1);
      verify(() => mockStorageService.saveClinicId(any())).called(1);
    });

    test('should login successfully with super admin credentials (admin / admin123)', () async {
      final user = await authRepository.login(
        email: 'admin',
        password: 'admin123',
      );

      expect(user.email, equals('admin@clinicflow.com'));
      expect(user.fullName, equals('Sistem Yöneticisi (Super Admin)'));
      expect(user.isAdmin, isTrue);
      verify(() => mockStorageService.saveAuthToken(any())).called(1);
      verify(() => mockStorageService.saveClinicId(any())).called(1);
    });

    test('should reject super admin with incorrect password', () async {
      expect(
        () => authRepository.login(
          email: 'admin',
          password: 'wrong_password',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          AppStrings.authInvalidCredentials,
        )),
      );
    });

    test('should reject demo account with incorrect password', () async {
      expect(
        () => authRepository.login(
          email: 'dr.zeynep@clinicflow.com',
          password: 'wrong_password',
        ),
        throwsA(isA<AuthException>().having(
          (e) => e.message,
          'message',
          AppStrings.authInvalidCredentials,
        )),
      );
    });

    test('should reject empty email or password shorter than 6 characters', () async {
      expect(
        () => authRepository.login(email: '', password: '123456'),
        throwsA(isA<AuthException>()),
      );

      expect(
        () => authRepository.login(email: 'user@clinic.com', password: '123'),
        throwsA(isA<AuthException>()),
      );
    });

    test('should login offline when firebase is not available', () async {
      final user = await authRepository.login(
        email: 'doktor@clinicflow.com',
        password: 'password123',
      );

      expect(user.email, equals('doktor@clinicflow.com'));
      verify(() => mockStorageService.saveAuthToken(any())).called(1);
    });

    test('should clear storage and user on logout', () async {
      await authRepository.login(
        email: 'dr.zeynep@clinicflow.com',
        password: '123456',
      );

      await authRepository.logout();
      verify(() => mockStorageService.clearAll()).called(1);

      final current = await authRepository.getCurrentUser();
      expect(current, isNull);
    });
  });
}
