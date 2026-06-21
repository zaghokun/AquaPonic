import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Daftar',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Expanded(child: AppTextField(label: 'Nama Depan')),
                        const SizedBox(width: 16),
                        const Expanded(child: AppTextField(label: 'Nama Belakang')),
                      ],
                    ),
                    const AppTextField(label: 'Email'),
                    const AppTextField(label: 'Username'),
                    AppTextField(
                      label: 'Nomor Telepon',
                      prefix: Text('+62', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                    AppTextField(
                      label: 'Tanggal Lahir',
                      hint: 'DD/MM/YYYY',
                      readOnly: true,
                      onTap: () async {
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                      },
                    ),
                    const AppTextField(label: 'Kata Sandi', obscureText: true),
                    const AppTextField(label: 'Konfirmasi Kata Sandi', obscureText: true),
                    const SizedBox(height: 16),
                    AppButton(
                      text: 'Daftar',
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('atau'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppOutlinedButton(
                      text: 'Daftar dengan Google',
                      icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Sudah punya akun? ', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                          child: Text(
                            'Masuk',
                            style: GoogleFonts.poppins(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
