import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/section_header.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/app_button.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Kembali',
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
      ),
      child: Column(
        children: [
          const SectionHeader(title: 'Ganti Kata Sandi'),
          Expanded(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const AppTextField(label: 'Kata Sandi Lama', obscureText: true),
                  const SizedBox(height: 8),
                  const AppTextField(label: 'Kata Sandi Baru', obscureText: true),
                  const SizedBox(height: 8),
                  const AppTextField(label: 'Konfirmasi Kata Sandi Baru', obscureText: true),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Lupa Kata Sandi?',
                          style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: AppButton(
                          text: 'Selanjutnya',
                          onPressed: () => _showSuccessDialog(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.statusGood.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: AppColors.statusGood, size: 64),
              ),
              const SizedBox(height: 24),
              Text('Ganti Password Berhasil!', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Password Anda berhasil diubah. Silahkan gunakan password baru Anda untuk masuk.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              AppButton(text: 'Kembali', onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              }),
            ],
          ),
        ),
      ),
    );
  }
}
