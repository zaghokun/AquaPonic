import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'Masuk',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selamat datang kembali!',
                  style: GoogleFonts.poppins(color: AppColors.white.withValues(alpha: 0.9)),
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
                      const AppTextField(
                        label: 'Email atau Username',
                        hint: 'Email atau Username',
                        prefix: Icon(Icons.person_outline),
                      ),
                      const AppTextField(
                        label: 'Kata Sandi',
                        hint: 'Masukkan kata sandi',
                        obscureText: true,
                        prefix: Icon(Icons.lock_outline),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Lupa kata sandi?',
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        text: 'Masuk',
                        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.main),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('atau', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      AppOutlinedButton(
                        text: 'Masuk dengan Google',
                        icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.red),
                        onPressed: () {},
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Belum punya akun? ', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.register),
                            child: Text(
                              'Daftar',
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
      ),
    );
  }
}
