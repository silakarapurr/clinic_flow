import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../doctors/domain/models/doctor.dart';
import '../../../doctors/domain/repositories/doctors_repository.dart';
import '../../../patients/domain/models/patient.dart';
import '../../../patients/domain/repositories/patients_repository.dart';

class CreateAppointmentDialog extends StatefulWidget {
  final DateTime initialDate;
  final void Function({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
    required String patientPhone,
    required String serviceName,
    required DateTime startTime,
    required DateTime endTime,
    String? clinicalNote,
  }) onSave;

  const CreateAppointmentDialog({
    super.key,
    required this.initialDate,
    required this.onSave,
  });

  @override
  State<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  List<Doctor> _doctors = [];
  List<Patient> _patients = [];
  bool _isLoadingData = true;

  Doctor? _selectedDoctor;
  Patient? _selectedPatient;
  String _selectedService = 'Genel Muayene & Kontrol';
  late DateTime _selectedDate;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _services = [
    'Genel Muayene & Kontrol',
    'Aylık Seans / Kontrol',
    'Diş Temizliği / Profilaksi',
    'Konsültasyon',
    'Protez & İmplant Takibi',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _fetchDoctorsAndPatients();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _fetchDoctorsAndPatients() async {
    final docs = await sl<DoctorsRepository>().getDoctors();
    final pats = await sl<PatientsRepository>().getPatients();

    if (mounted) {
      setState(() {
        _doctors = docs;
        _patients = pats;
        if (docs.isNotEmpty) _selectedDoctor = docs.first;
        if (pats.isNotEmpty) _selectedPatient = pats.first;
        _isLoadingData = false;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedDoctor == null || _selectedPatient == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lütfen hekim ve hasta seçimini tamamlayın.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final durationMinutes = _selectedDoctor!.slotDurationMinutes;
      final end = start.add(Duration(minutes: durationMinutes));

      widget.onSave(
        doctorId: _selectedDoctor!.id,
        doctorName: _selectedDoctor!.fullName,
        patientId: _selectedPatient!.id,
        patientName: _selectedPatient!.fullName,
        patientPhone: _selectedPatient!.phone,
        serviceName: _selectedService,
        startTime: start,
        endTime: end,
        clinicalNote: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: _isLoadingData
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              AppStrings.newAppointment,
                              style: AppTypography.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Select Patient
                        Text(
                          AppStrings.selectPatient,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<Patient>(
                          initialValue: _selectedPatient,
                          decoration: const InputDecoration(),
                          items: _patients.map((p) {
                            return DropdownMenuItem(
                              value: p,
                              child: Text('${p.fullName} (${p.phone})'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedPatient = val;
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Select Doctor
                        Text(
                          AppStrings.selectDoctor,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<Doctor>(
                          initialValue: _selectedDoctor,
                          decoration: const InputDecoration(),
                          items: _doctors.map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text('${d.fullName} - ${d.specialty}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedDoctor = val;
                            });
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Service / Procedure
                        Text(
                          AppStrings.selectService,
                          style: AppTypography.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedService,
                          decoration: const InputDecoration(),
                          items: _services.map((s) {
                            return DropdownMenuItem(value: s, child: Text(s));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedService = val;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Date & Time Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.appointmentDate,
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: DateTime.now()
                                            .subtract(const Duration(days: 30)),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 365)),
                                        locale: const Locale('tr', 'TR'),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedDate = picked;
                                        });
                                      }
                                    },
                                    borderRadius: AppRadius.roundedMd,
                                    child: Container(
                                      padding: AppSpacing.inputPadding,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: AppRadius.roundedMd,
                                        border:
                                            Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.appointmentTime,
                                    style: AppTypography.labelMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  InkWell(
                                    onTap: () async {
                                      final picked = await showTimePicker(
                                        context: context,
                                        initialTime: _selectedTime,
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _selectedTime = picked;
                                        });
                                      }
                                    },
                                    borderRadius: AppRadius.roundedMd,
                                    child: Container(
                                      padding: AppSpacing.inputPadding,
                                      decoration: BoxDecoration(
                                        color: AppColors.surface,
                                        borderRadius: AppRadius.roundedMd,
                                        border:
                                            Border.all(color: AppColors.border),
                                      ),
                                      child: Text(
                                        _selectedTime.format(context),
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        AppTextField(
                          label: AppStrings.clinicalNote,
                          hint: 'Randevu ile ilgili ön notlar (opsiyonel)',
                          controller: _noteController,
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
