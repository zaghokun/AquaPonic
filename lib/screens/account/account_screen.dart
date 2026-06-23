import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/data/dummy_data.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/profile_header.dart';
import 'package:aquaponic/widgets/setting_tile.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            ProfileHeader(user: DummyData.user),
            Expanded(
              child: Container(
                color: AppColors.cardBackground,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan Akun',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            SettingTile(
                              title: 'Edit Profil',
                              icon: Icons.person_outline,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.editProfile),
                            ),
                            SettingTile(
                              title: 'Ganti Kata Sandi',
                              icon: Icons.lock_outline,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
                            ),
                            SettingTile(
                              title: 'Ganti Email',
                              icon: Icons.email_outlined,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.changeEmail),
                            ),
                            SettingTile(
                              title: 'Ganti Nomor Telepon',
                              icon: Icons.phone_outlined,
                              onTap: () => Navigator.pushNamed(context, AppRoutes.changePhone),
                              hideDivider: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SettingTile(
                          title: 'Keluar',
                          icon: Icons.logout,
                          iconColor: AppColors.statusDanger,
                          textColor: AppColors.statusDanger,
                          onTap: () {
                            _showLogoutDialog(context);
                          },
                          hideDivider: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Keluar',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDanger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
