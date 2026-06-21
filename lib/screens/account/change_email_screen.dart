import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/section_header.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/otp_input.dart';
import 'package:aquaponic/data/dummy_data.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.white),
          onPressed: _prevStep,
        ),
        title: Text(
          'Kembali',
          style: GoogleFonts.poppins(color: AppColors.white, fontWeight: FontWeight.w500),
        ),
      ),
      child: Column(
        children: [
          const SectionHeader(title: 'Ganti Email'),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildNoticeStep(
                    'Cek Kotak Masuk Email Lama Anda',
                    'Untuk mengonfirmasi bahwa ini benar-benar anda, kami akan mengirimkan Kode OTP 6 Karakter ke Email Lama anda ${DummyData.user.email}.',
                  ),
                  _buildOtpStep('Verifikasi Kode OTP'),
                  _buildInputNewEmailStep(),
                  _buildOtpStep('Verifikasi Kode OTP Email Baru'),
                  _buildSuccessStep(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeStep(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          const Icon(Icons.mark_email_read, size: 120, color: AppColors.primaryBlue),
          const SizedBox(height: 32),
          Text(desc, style: GoogleFonts.poppins(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(width: 150, child: AppButton(text: 'Selanjutnya', onPressed: _nextStep)),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep(String title) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          OtpInput(onCompleted: _nextStep, onResend: () {}),
        ],
      ),
    );
  }

  Widget _buildInputNewEmailStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Masukkan Email Baru Anda', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          const AppTextField(label: 'Email Baru', hint: 'xxxxxx@gmail.com'),
          const SizedBox(height: 16),
          Text(
            'Kami akan mengirimkan Kode OTP 6 Karakter ke Email Baru anda sebagai bukti verifikasi.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(width: 150, child: AppButton(text: 'Selanjutnya', onPressed: _nextStep)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle, color: AppColors.primaryBlue, size: 80),
          ),
          const SizedBox(height: 32),
          Text('Ganti Email Berhasil!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Proses ganti Email berhasil! Email anda yang lama sudah digantikan dengan Email yang baru. Untuk melihat perubahan, silahkan kembali ke Menu Akun',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 48),
          AppButton(text: 'Kembali ke Menu Akun', onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
