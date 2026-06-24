import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/core/network/api_client.dart';
import 'package:aquaponic/services/device_service.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/app_text_field.dart';
import 'package:aquaponic/widgets/app_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map<String, dynamic>> _devices = [];
  String? _selectedDevice;
  bool _loading = true;
  bool _saving = false;

  final _tempMinCtrl = TextEditingController();
  final _tempMaxCtrl = TextEditingController();
  final _phMinCtrl = TextEditingController();
  final _phMaxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final devices = await DeviceService.getDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          if (devices.isNotEmpty) {
            _selectedDevice = devices.first['device'];
            _updateFieldsForSelected();
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateFieldsForSelected() {
    if (_selectedDevice == null) return;
    final device = _devices.firstWhere((d) => d['device'] == _selectedDevice);
    final th = device['threshold'] ?? {};
    _tempMinCtrl.text = (th['temp_min'] ?? 25.0).toString();
    _tempMaxCtrl.text = (th['temp_max'] ?? 32.0).toString();
    _phMinCtrl.text = (th['ph_min'] ?? 6.5).toString();
    _phMaxCtrl.text = (th['ph_max'] ?? 8.5).toString();
  }

  @override
  void dispose() {
    _tempMinCtrl.dispose();
    _tempMaxCtrl.dispose();
    _phMinCtrl.dispose();
    _phMaxCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveThresholds() async {
    if (_selectedDevice == null) return;
    setState(() => _saving = true);

    try {
      final tMin = double.tryParse(_tempMinCtrl.text);
      final tMax = double.tryParse(_tempMaxCtrl.text);
      final pMin = double.tryParse(_phMinCtrl.text);
      final pMax = double.tryParse(_phMaxCtrl.text);

      await DeviceService.updateThreshold(
        _selectedDevice!,
        tempMin: tMin,
        tempMax: tMax,
        phMin: pMin,
        phMax: pMax,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batas Aman berhasil disimpan'), backgroundColor: AppColors.statusGood),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: AppColors.statusDanger),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan. Periksa jaringan.'), backgroundColor: AppColors.statusDanger),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.white))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_devices.isNotEmpty) ...[
                      _buildSectionTitle('Pilih Kolam'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDevice,
                            isExpanded: true,
                            items: _devices.map((d) {
                              return DropdownMenuItem<String>(
                                value: d['device'],
                                child: Text(d['label'] ?? d['device'], style: GoogleFonts.poppins()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDevice = val;
                                _updateFieldsForSelected();
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Sensor Suhu'),
                      _buildSensorSettingCard(
                        'Suhu Air (°C)',
                        Icons.thermostat,
                        _tempMinCtrl,
                        _tempMaxCtrl,
                        '-10',
                        '80',
                      ),
                      const SizedBox(height: 16),
                      _buildSectionTitle('Sensor pH'),
                      _buildSensorSettingCard(
                        'Tingkat Keasaman (pH)',
                        Icons.science,
                        _phMinCtrl,
                        _phMaxCtrl,
                        '0',
                        '14',
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: _saving
                            ? const Center(child: CircularProgressIndicator(color: AppColors.white))
                            : ElevatedButton(
                                onPressed: _saveThresholds,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  'Simpan Perubahan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                      ),
                    ] else ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Belum ada kolam terdaftar.',
                            style: GoogleFonts.poppins(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
      ),
    );
  }

  Widget _buildSensorSettingCard(
      String name, IconData icon, TextEditingController minCtrl, TextEditingController maxCtrl, String hintBawah, String hintAtas) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Batas Bawah',
                  hint: hintBawah,
                  controller: minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppTextField(
                  label: 'Batas Atas',
                  hint: hintAtas,
                  controller: maxCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
