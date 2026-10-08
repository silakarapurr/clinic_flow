import 'package:flutter/material.dart';

/// Centralized Medical / SaaS Color Palette for ClinicFlow.
/// Follows Apple Human Interface Guidelines with high contrast
/// and calming medical tones (Teal & Slate).
class AppColors {
  AppColors._();

  // Primary Medical Brand (Teal)
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFCCFBF1);
  static const Color primaryTint = Color(0xFFF0FDFA);

  // Secondary & Neutral Slates
  static const Color secondary = Color(0xFF1E293B);
  static const Color slateDark = Color(0xFF0F172A);
  static const Color slateMedium = Color(0xFF334155);
  static const Color slateLight = Color(0xFF64748B);
  static const Color slateMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status & Appointment Badges
  // 1. Scheduled / Bekliyor
  static const Color statusScheduled = Color(0xFFD97706);
  static const Color statusScheduledBg = Color(0xFFFEF3C7);

  // 2. Arrived / Geldi
  static const Color statusArrived = Color(0xFF2563EB);
  static const Color statusArrivedBg = Color(0xFFDBEAFE);

  // 3. Completed / Tamamlandı
  static const Color statusCompleted = Color(0xFF059669);
  static const Color statusCompletedBg = Color(0xFFD1FAE5);

  // 4. Cancelled / İptal
  static const Color statusCancelled = Color(0xFFDC2626);
  static const Color statusCancelledBg = Color(0xFFFEE2E2);

  // 5. No Show / Gelmedi
  static const Color statusNoShow = Color(0xFF7C3AED);
  static const Color statusNoShowBg = Color(0xFFEDE9FE);

  // System Feedback
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}
