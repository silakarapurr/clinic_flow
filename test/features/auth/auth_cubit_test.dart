import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:clinic_flow/features/auth/domain/models/user_profile.dart';
import 'package:clinic_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:clinic_flow/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:clinic_flow/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  const testUser = UserProfile(
    id: 'u-1',
    clinicId: 'c-1',
    fullName: 'Dr. Test',
    email: 'test@clinicflow.com',
    role: UserRole.admin,
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit Tests', () {
    test('initial state should be AuthInitial', () {
      expect(authCubit.state, const AuthInitial());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Authenticated] when login succeeds',
      build: () {
        when(() => mockAuthRepository.login(
              email: 'test@clinicflow.com',
              password: 'password123',
            )).thenAnswer((_) async => testUser);
        return authCubit;
      },
      act: (cubit) => cubit.login(
        email: 'test@clinicflow.com',
        password: 'password123',
      ),
      expect: () => [
        const AuthLoading(),
        const Authenticated(testUser),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, Unauthenticated] on successful logout',
      build: () {
        when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
        return authCubit;
      },
      act: (cubit) => cubit.logout(),
      expect: () => [
        const AuthLoading(),
        const Unauthenticated(),
      ],
    );
  });
}
