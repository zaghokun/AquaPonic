import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final User user;

  const ProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.pink.shade100,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: Colors.pink.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
