import 'package:flutter/material.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: _isObscured,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          enabled: widget.enabled,
          style: GoogleFonts.poppins(),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.textHint,
            ),
            prefixIcon: widget.prefix != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: widget.prefix,
                  )
                : null,
            prefixIconConstraints: widget.prefix != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textHint,
                      size: 22,
                    ),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  )
                : widget.suffix != null
                    ? Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: widget.suffix,
                      )
                    : null,
            suffixIconConstraints: widget.suffix != null && !widget.obscureText
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.statusDanger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.statusDanger, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: !widget.enabled,
            fillColor: Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 16), // Tambahkan spacing sedikit
      ],
    );
  }
}
