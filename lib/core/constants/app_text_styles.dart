import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle body = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle bodyBold = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle label = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
