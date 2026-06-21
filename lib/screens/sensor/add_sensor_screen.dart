import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/section_header.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class AddSensorScreen extends StatelessWidget {
  const AddSensorScreen({super.key});

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
          const SectionHeader(title: 'Tambah Kolam Baru'),
          Expanded(
            child: Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const AppTextField(
                    label: 'Nama Kolam',
                    hint: 'Kolam 1',
                  ),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Kode Kontroller Khusus (6 Karakter)',
                    hint: 'MW278X',
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 150,
                      child: AppButton(
                        text: 'Konfirmasi',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kolam berhasil ditambahkan')),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
