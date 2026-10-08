import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../app/shell/main_shell_view.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _safetyTimer;

  @override
  void initState() {
    super.initState();
    // Safety timeout: Never stay on splash longer than 1.5 seconds under any circumstance
    _safetyTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final state = context.read<AuthCubit>().state;
        if (state is Authenticated) {
          _navigateTo(const MainShellView());
        } else {
          _navigateTo(const LoginView());
        }
      }
    });

    // Check auth status
    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  void _navigateTo(Widget target) {
    _safetyTimer?.cancel();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => target,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          _navigateTo(const MainShellView());
        } else if (state is Unauthenticated || state is AuthError) {
          _navigateTo(const LoginView());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppRadius.roundedXl,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                AppStrings.appName,
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.appTagline,
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xxl),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
