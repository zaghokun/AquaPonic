import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'dart:async';

class OtpInput extends StatefulWidget {
  final VoidCallback onCompleted;
  final VoidCallback onResend;

  const OtpInput({
    super.key,
    required this.onCompleted,
    required this.onResend,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  Timer? _timer;
  int _start = 270; // 4 mins 30 seconds

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) => TextEditingController());
    _focusNodes = List.generate(6, (index) => FocusNode());
    startTimer();
  }

  void startTimer() {
    _start = 270;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get timerString {
    int minutes = _start ~/ 60;
    int seconds = _start % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              height: 55,
              child: TextFormField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  }
                  if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Kode akan Kadaluarsa dalam $timerString',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            GestureDetector(
              onTap: () {
                startTimer();
                widget.onResend();
              },
              child: Text(
                'Tidak menerima kode? Kirim Ulang',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        AppButton(
          text: 'Selanjutnya',
          onPressed: widget.onCompleted,
        ),
      ],
    );
  }
}
