import 'package:flutter/material.dart';
import 'package:aquaponic/core/constants/app_colors.dart';

/// Scaffold wrapper dengan latar belakang gradien biru→cyan.
///
/// Digunakan sebagai pengganti [Scaffold] biasa untuk memberikan
/// tampilan gradien yang konsisten di seluruh aplikasi.
class GradientBackground extends StatelessWidget {
  /// Widget konten utama.
  final Widget child;

  /// AppBar opsional yang ditampilkan di atas.
  final PreferredSizeWidget? appBar;

  /// Bottom navigation bar opsional.
  final Widget? bottomNavigationBar;

  /// Floating action button opsional.
  final Widget? floatingActionButton;

  /// Apakah body harus di-resize saat keyboard muncul.
  final bool resizeToAvoidBottomInset;

  const GradientBackground({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.gradientStart,
              AppColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
