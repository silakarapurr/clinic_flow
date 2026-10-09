import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../domain/models/doctor.dart';
import '../cubit/doctors_cubit.dart';
import '../cubit/doctors_state.dart';

class DoctorsListView extends StatefulWidget {
  const DoctorsListView({super.key});

  @override
  State<DoctorsListView> createState() => _DoctorsListViewState();
}

class _DoctorsListViewState extends State<DoctorsListView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'Tümü';

  @override
  void initState() {
    super.initState();
    context.read<DoctorsCubit>().loadDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatWorkDays(List<int> days) {
    if (days.isEmpty) return 'Belirtilmedi';
    final sorted = List<int>.from(days)..sort();
    if (sorted.length == 5 && sorted.first == 1 && sorted.last == 5) {
      return 'Hafta İçi (Pzt-Cum)';
    }
    if (sorted.length == 6 && sorted.first == 1 && sorted.last == 6) {
      return 'Pzt - Cts (6 Gün)';
    }
    if (sorted.length == 7) {
      return 'Her Gün';
    }
    const dayNames = {
      1: 'Pzt',
      2: 'Sal',
      3: 'Çar',
      4: 'Per',
      5: 'Cum',
      6: 'Cts',
      7: 'Paz',
    };
    return sorted.map((d) => dayNames[d] ?? '$d').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.doctors,
              style: AppTypography.titleLarge,
            ),
            Text(
              'Klinik hekimleri ve randevu planları',
              style: AppTypography.caption.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<DoctorsCubit, DoctorsState>(
        builder: (context, state) {
          if (state is DoctorsLoading) {
            return const LoadingIndicator();
          }

          if (state is DoctorsError) {
            return ErrorStateView(
              message: state.message,
              onRetry: () => context.read<DoctorsCubit>().loadDoctors(),
            );
          }

          if (state is DoctorsLoaded) {
            final allDoctors = state.doctors;
            final specialties = [
              'Tümü',
              ...allDoctors.map((d) => d.specialty).toSet(),
            ];

            final query = _searchController.text.trim().toLowerCase();
            final filteredDoctors = allDoctors.where((doctor) {
              final matchesQuery = query.isEmpty ||
                  doctor.fullName.toLowerCase().contains(query) ||
                  doctor.specialty.toLowerCase().contains(query) ||
                  doctor.phone.contains(query);
              final matchesSpecialty = _selectedSpecialty == 'Tümü' ||
                  doctor.specialty == _selectedSpecialty;
              return matchesQuery && matchesSpecialty;
            }).toList();

            final activeCount = allDoctors.where((d) => d.isActive).length;

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => context.read<DoctorsCubit>().loadDoctors(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePaddingHorizontal,
                  AppSpacing.sm,
                  AppSpacing.pagePaddingHorizontal,
                  AppSpacing.xxl * 2,
                ),
                children: [
                  // KPI Quick Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.badge_outlined,
                          label: 'Toplam Kadro',
                          value: '${allDoctors.length}',
                          tintColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_outline_rounded,
                          label: 'Aktif Görevde',
                          value: '$activeCount',
                          tintColor: AppColors.statusCompleted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.medical_services_outlined,
                          label: 'Uzmanlık',
                          value: '${specialties.length - 1}',
                          tintColor: AppColors.info,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(color: AppColors.borderSubtle),
                      boxShadow: AppShadows.card,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Hekim adı veya uzmanlık ara...',
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.slateLight,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                  color: AppColors.slateLight,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Specialty Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: specialties.map((specialty) {
                        final isSelected = _selectedSpecialty == specialty;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            label: Text(specialty),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSpecialty = specialty;
                              });
                            },
                            showCheckmark: false,
                            labelStyle: AppTypography.labelSmall.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                            backgroundColor: AppColors.surface,
                            selectedColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.roundedFull,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Doctor List
                  if (filteredDoctors.isEmpty)
                    EmptyStateView(
                      icon: Icons.person_search_rounded,
                      title: 'Hekim Bulunamadı',
                      message: _searchController.text.isNotEmpty
                          ? '"${_searchController.text}" aramasına uygun hekim bulunamadı.'
                          : 'Seçili uzmanlık kategorisinde hekim bulunmamaktadır.',
                    )
                  else
                    ...filteredDoctors.map((doctor) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildDoctorCard(context, doctor),
                        )),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color tintColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: tintColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: tintColor),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    final initials = doctor.fullName
        .replaceAll('Dr.', '')
        .replaceAll('Uzm.', '')
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase())
        .take(2)
        .join();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with subtle ring
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppRadius.roundedLg,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials.isNotEmpty ? initials : 'DR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            doctor.fullName,
                            style: AppTypography.titleMedium.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Status badge with pulsating dot
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: doctor.isActive
                                ? AppColors.statusCompletedBg
                                : AppColors.borderSubtle,
                            borderRadius: AppRadius.roundedFull,
                            border: Border.all(
                              color: doctor.isActive
                                  ? AppColors.statusCompleted
                                      .withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: doctor.isActive
                                      ? AppColors.statusCompleted
                                      : AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                doctor.isActive
                                    ? AppStrings.activeStatus
                                    : AppStrings.inactiveStatus,
                                style: AppTypography.labelSmall.copyWith(
                                  color: doctor.isActive
                                      ? AppColors.statusCompleted
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Specialty tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Text(
                        doctor.specialty,
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

          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.sm),

          // Schedule Details Grid
          Row(
            children: [
              Expanded(
                child: _buildDetailPill(
                  icon: Icons.schedule_rounded,
                  label: 'Saatler',
                  value: '${doctor.startHour} - ${doctor.endHour}',
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildDetailPill(
                  icon: Icons.timelapse_rounded,
                  label: 'Seans',
                  value: '${doctor.slotDurationMinutes} dk',
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Working Days
          _buildDetailPill(
            icon: Icons.calendar_today_rounded,
            label: 'Çalışma Günleri',
            value: _formatWorkDays(doctor.workDays),
          ),

          if (doctor.phone.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              borderRadius: AppRadius.roundedSm,
              onTap: () {
                Clipboard.setData(ClipboardData(text: doctor.phone));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${doctor.phone} panoya kopyalandı'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: AppRadius.roundedSm,
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doctor.phone,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.copy_rounded,
                      size: 13,
                      color: AppColors.slateLight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.roundedSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.slateLight,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    fontSize: 9,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

