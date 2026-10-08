import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(AuthError(failure.message));
    }
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthLoading());
    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(const PasswordResetSent());
    } catch (e) {
      final failure = ErrorHandler.handleException(e);
      emit(AuthError(failure.message));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const Unauthenticated());
  }

  Future<void> deleteAccount() async {
    emit(const AuthLoading());
    await _authRepository.deleteAccount();
    emit(const Unauthenticated());
  }
}
