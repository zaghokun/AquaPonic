import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/section_header.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/data/dummy_data.dart';
import 'package:intl/intl.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = DummyData.user;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _usernameController = TextEditingController(text: user.username);
    _phoneController = TextEditingController(text: user.phone.replaceAll('+62 ', ''));
    _selectedDate = user.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
          const SectionHeader(title: 'Edit Profil'),
          Expanded(
            child: Container(
              color: AppColors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink.shade100,
                            border: Border.all(color: AppColors.primaryBlue, width: 2),
                          ),
                          child: Icon(Icons.person, size: 60, color: Colors.pink.shade400),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: AppColors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(child: AppTextField(label: 'Nama Depan', controller: _firstNameController)),
                        const SizedBox(width: 16),
                        Expanded(child: AppTextField(label: 'Nama Belakang', controller: _lastNameController)),
                      ],
                    ),
                    AppTextField(label: 'Username', controller: _usernameController),
                    AppTextField(
                      label: 'Nomor Telepon',
                      controller: _phoneController,
                      prefix: Text('+62', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ),
                    AppTextField(
                      label: 'Tanggal Lahir',
                      hint: DateFormat('dd/MM/yyyy').format(_selectedDate),
                      readOnly: true,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 150,
                        child: AppButton(
                          text: 'Simpan',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil berhasil disimpan!')),
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
          ),
        ],
      ),
    );
  }
}
