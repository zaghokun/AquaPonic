import 'package:flutter/material.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/core/constants/app_text_styles.dart';

/// Tombol utama dengan gradien biru→cyan.
///
/// Digunakan untuk aksi utama seperti Login, Daftar, Simpan, dll.
class AppButton extends StatelessWidget {
  /// Teks yang ditampilkan pada tombol.
  final String text;

  /// Callback saat tombol ditekan. Null = tombol disabled.
  final VoidCallback? onPressed;

  /// Apakah tombol sedang loading.
  final bool isLoading;

  /// Lebar tombol. Default: full width.
  final double? width;

  /// Tinggi tombol.
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
                  colors: [
                    AppColors.gradientStart.withValues(alpha: 0.5),
                    AppColors.gradientEnd.withValues(alpha: 0.5),
                  ],
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onPressed,
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.button,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol outline untuk aksi sekunder (Google sign-in, dll).
///
/// Memiliki border tanpa background, dengan ikon opsional di sisi kiri.
class AppOutlinedButton extends StatelessWidget {
  /// Teks yang ditampilkan pada tombol.
  final String text;

  /// Callback saat tombol ditekan.
  final VoidCallback? onPressed;

  /// Ikon opsional di sisi kiri teks.
  final Widget? icon;

  /// Apakah tombol sedang loading.
  final bool isLoading;

  /// Lebar tombol. Default: full width.
  final double? width;

  /// Tinggi tombol.
  final double height;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.textHint,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 12),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
