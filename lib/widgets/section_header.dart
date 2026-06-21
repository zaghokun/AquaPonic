import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
      ),
    );
  }
}
