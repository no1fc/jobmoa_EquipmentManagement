import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary (Notion Blue)
  static const Color primary = Color(0xFF2383E2);
  static const Color primaryLight = Color(0xFFE8F0FE);
  static const Color primaryDark = Color(0xFF1A6BC4);

  // Neutral
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Asset Status
  static const Color statusInUse = Color(0xFF3B82F6);
  static const Color statusRented = Color(0xFF8B5CF6);
  static const Color statusBroken = Color(0xFFEF4444);
  static const Color statusInStorage = Color(0xFF6B7280);
  static const Color statusDisposed = Color(0xFFF59E0B);

  // Rental Status
  static const Color rentalActive = Color(0xFF3B82F6);
  static const Color rentalOverdue = Color(0xFFEF4444);
  static const Color rentalReturned = Color(0xFF10B981);
  static const Color rentalCancelled = Color(0xFF6B7280);
}