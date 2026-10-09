import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/shell/main_shell_view.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'dr.zeynep@clinicflow.com');
  final _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            email: _emailController.text,
            password: _passwordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is Authenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const MainShellView(),
                ),
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Stack(
              children: [
                // Ambient background glows
                Positioned(
                  top: -80,
                  right: -80,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -60,
                  left: -60,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.statusArrivedBg.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    padding: AppSpacing.pagePadding,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Medical Brand Header
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: AppRadius.roundedXl,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_hospital_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const Text(
                            AppStrings.appName,
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            AppStrings.loginSubtitle,
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.slateLight,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Form Container
                          AppCard(
                            borderRadius: AppRadius.roundedXl,
                            boxShadow: AppShadows.cardElevated,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    label: AppStrings.emailLabel,
                                    hint: 'ornek@klinik.com',
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: AppColors.slateLight,
                                      size: 20,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'E-posta adresi gereklidir.';
                                      }
                                      if (!AppConstants.emailRegex.hasMatch(val.trim())) {
                                        return 'Geçerli bir e-posta adresi giriniz.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  AppTextField(
                                    label: AppStrings.passwordLabel,
                                    hint: '••••••••',
                                    controller: _passwordController,
                                    isPassword: true,
                                    prefixIcon: const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.slateLight,
                                      size: 20,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.length < AppConstants.minPasswordLength) {
                                        return 'Şifre en az 6 karakter olmalıdır.';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const ForgotPasswordView(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.forgotPassword,
                                        style: AppTypography.labelMedium.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  AppButton(
                                    text: AppStrings.loginButton,
                                    onPressed: _submit,
                                    isLoading: isLoading,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),

                                  // Quick demo login chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTint,
                                      borderRadius: AppRadius.roundedMd,
                                      border: Border.all(
                                        color: AppColors.primary.withValues(alpha: 0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline_rounded,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: Text(
                                            'Demo: dr.zeynep@clinicflow.com (123456)',
                                            style: AppTypography.bodySmall.copyWith(
                                              color: AppColors.primaryDark,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: AppColors.slateMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '256-bit SSL & KVKK Uyumlu Güvenli Sistem',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.slateMuted,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
