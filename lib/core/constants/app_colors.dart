import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryBlue = Color(0xFF4A6CF7);
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color lightBlue = Color(0xFF87CEEB);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF4A6CF7);
  static const Color gradientEnd = Color(0xFF4DD0E1);

  // Status Colors
  static const Color statusGood = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFF9800);
  static const Color statusDanger = Color(0xFFF44336);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFF8F9FD);
  static const Color textPrimary = Color(0xFF1D1D35);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient verticalGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );
}
