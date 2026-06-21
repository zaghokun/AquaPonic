import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/data/dummy_data.dart';
import 'package:aquaponic/widgets/notification_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifikasi',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Hari Ini',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...DummyData.todayNotifications.map((n) => NotificationCard(notification: n)),
              
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Kemarin',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...DummyData.yesterdayNotifications.map((n) => NotificationCard(notification: n)),
            ],
          ),
        ),
      ),
    );
  }
}
