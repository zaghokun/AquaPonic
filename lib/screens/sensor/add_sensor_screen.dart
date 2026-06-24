import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/core/network/api_client.dart';
import 'package:aquaponic/services/device_service.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/app_button.dart';
import 'package:aquaponic/widgets/section_header.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class AddSensorScreen extends StatefulWidget {
  const AddSensorScreen({super.key});

  @override
  State<AddSensorScreen> createState() => _AddSensorScreenState();
}

class _AddSensorScreenState extends State<AddSensorScreen> {
  final _labelCtrl = TextEditingController();
  final _deviceCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _deviceCtrl.dispose();
    super.dispose();
  }

  Future<void> _addSensor() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final label = _labelCtrl.text.trim();
    final deviceId = _deviceCtrl.text.trim().toLowerCase();

    if (deviceId.isEmpty) {
      setState(() {
        _error = 'Kode Kontroller (Device ID) wajib diisi';
        _loading = false;
      });
      return;
    }

    try {
      await DeviceService.addDevice(
        deviceId: deviceId,
        label: label.isNotEmpty ? label : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kolam berhasil ditambahkan!'),
            backgroundColor: AppColors.statusGood,
          ),
        );
        Navigator.pop(context, true); // Return true indicating success to refresh the previous page
      }
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Terjadi kesalahan jaringan.';
      });
    } finally {
      if (mounted) setState(() { _loading = false; });
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
                  AppTextField(
                    controller: _labelCtrl,
                    label: 'Nama Kolam (Opsional)',
                    hint: 'Kolam Baru',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _deviceCtrl,
                    label: 'Kode Kontroller (Format: esp-XX)',
                    hint: 'esp-05',
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusDanger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.statusDanger, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(color: AppColors.statusDanger, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 150,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : AppButton(
                              text: 'Konfirmasi',
                              onPressed: _addSensor,
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
