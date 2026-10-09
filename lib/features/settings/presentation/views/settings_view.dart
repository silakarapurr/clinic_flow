import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/seed_data.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.roundedXxl,
        ),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                AppStrings.logoutConfirmTitle,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.logoutConfirmMessage,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        AppStrings.cancel,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthCubit>().logout();
                      },
                      child: const Text(
                        AppStrings.logout,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.roundedXxl,
        ),
        backgroundColor: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                AppStrings.deleteAccount,
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                AppStrings.deleteAccountWarning,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text(
                        AppStrings.cancel,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedMd,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        context.read<AuthCubit>().deleteAccount();
                      },
                      child: const Text(
                        'Kalıcı Olarak Sil',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const clinic = SeedData.clinic;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.settings,
              style: AppTypography.titleLarge,
            ),
            Text(
              'Klinik parametreleri ve hesap yönetimi',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user =
              state is Authenticated ? state.user : SeedData.userProfile;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.sm,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl * 2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // User Profile Hero Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user.fullName.isNotEmpty
                                ? user.fullName[0].toUpperCase()
                                : 'U',
                            style: AppTypography.displayMedium.copyWith(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user.fullName,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: AppRadius.roundedFull,
                              ),
                              child: Text(
                                user.role.label,
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Clinic Information Group
                _buildSectionHeader(AppStrings.clinicProfile),
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.local_hospital_rounded,
                        iconColor: AppColors.primary,
                        title: 'Klinik Adı',
                        subtitle: clinic.name,
                      ),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      _buildInfoTile(
                        icon: Icons.phone_rounded,
                        iconColor: AppColors.info,
                        title: 'İletişim Numarası',
                        subtitle: clinic.phone,
                      ),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      _buildInfoTile(
                        icon: Icons.location_on_rounded,
                        iconColor: AppColors.warning,
                        title: 'Klinik Adresi',
                        subtitle: clinic.address,
                      ),
                      const Divider(height: 16, color: AppColors.borderSubtle),
                      _buildInfoTile(
                        icon: Icons.schedule_rounded,
                        iconColor: AppColors.statusCompleted,
                        title: 'Çalışma Saatleri',
                        subtitle: 'Hafta içi 09:00 - 18:00',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // App Preferences & Legal
                _buildSectionHeader('Uygulama & Tercihler'),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        secondary: _buildSquircleIcon(
                          Icons.notifications_active_rounded,
                          AppColors.warning,
                        ),
                        title: const Text(
                          'Randevu Bildirimleri',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Yaklaşan seanslar ve iptal uyarıları',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        value: _notificationsEnabled,
                        onChanged: (val) {
                          setState(() => _notificationsEnabled = val);
                        },
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      SwitchListTile.adaptive(
                        secondary: _buildSquircleIcon(
                          Icons.fingerprint_rounded,
                          AppColors.primary,
                        ),
                        title: const Text(
                          'Biyometrik Giriş (Face ID)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Hızlı ve güvenli hekim doğrulama',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        activeColor: AppColors.primary,
                        value: _biometricEnabled,
                        onChanged: (val) {
                          setState(() => _biometricEnabled = val);
                        },
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      ListTile(
                        leading: _buildSquircleIcon(
                          Icons.shield_outlined,
                          AppColors.info,
                        ),
                        title: const Text(
                          'KVKK & Gizlilik Politikası',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '256-Bit SSL ve KVKK standartlarında veri koruma',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.slateLight,
                          size: 20,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'ClinicFlow hasta verilerini KVKK mevzuatına tam uyumlu saklamaktadır.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppColors.borderSubtle),
                      ListTile(
                        leading: _buildSquircleIcon(
                          Icons.verified_user_outlined,
                          AppColors.slateDark,
                        ),
                        title: const Text(
                          'Uygulama Sürümü',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.roundedFull,
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Text(
                            'v1.0.0 (Build 12)',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Logout Button
                AppButton(
                  text: AppStrings.logout,
                  variant: AppButtonVariant.outline,
                  icon: Icons.logout_rounded,
                  onPressed: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Apple Guideline 5.1.1(v) Account Deletion Action
                Center(
                  child: TextButton.icon(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: AppColors.error,
                    ),
                    onPressed: () => _showDeleteAccountDialog(context),
                    label: Text(
                      AppStrings.deleteAccount,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildSquircleIcon(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        _buildSquircleIcon(icon, iconColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
