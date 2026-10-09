import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CreatePatientDialog extends StatefulWidget {
  final void Function(String name, String phone, DateTime? birthDate, String? notes) onSave;

  const CreatePatientDialog({super.key, required this.onSave});

  @override
  State<CreatePatientDialog> createState() => _CreatePatientDialogState();
}

class _CreatePatientDialogState extends State<CreatePatientDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedBirthDate;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _selectedBirthDate,
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: const Icon(
                              Icons.person_add_rounded,
                              size: 20,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          const Text(
                            AppStrings.newPatient,
                            style: AppTypography.titleLarge,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: AppStrings.patientName,
                    hint: 'Ad ve Soyad',
                    controller: _nameController,
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: AppColors.slateLight,
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Hasta adı zorunludur.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: AppStrings.patientPhone,
                    hint: '05XX XXX XX XX',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Telefon numarası zorunludur.';
                      }
                      if (!AppConstants.phoneRegex.hasMatch(val.trim())) {
                        return 'Geçerli bir telefon numarası giriniz.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Birthdate picker
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.patientBirthDate,
                        style: AppTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      InkWell(
                        onTap: _pickBirthDate,
                        borderRadius: AppRadius.roundedMd,
                        child: Container(
                          padding: AppSpacing.inputPadding,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.roundedMd,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedBirthDate != null
                                    ? '${_selectedBirthDate!.day}.${_selectedBirthDate!.month}.${_selectedBirthDate!.year}'
                                    : 'Tarih seçin (opsiyonel)',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: _selectedBirthDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.slateMuted,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: AppColors.slateLight,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Klinik & Özel Notlar',
                    hint: 'Alerji, kronik rahatsızlık veya notlar (opsiyonel)',
                    controller: _notesController,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: AppStrings.cancel,
                          variant: AppButtonVariant.outline,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          text: AppStrings.save,
                          onPressed: _submit,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
