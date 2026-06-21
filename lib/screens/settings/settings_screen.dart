import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/app_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _weatherNotif = true;
  bool _suhuWarning = true;
  bool _phWarning = false;

  final List<String> _weatherTypes = ['Cerah', 'Berawan', 'Gerimis', 'Hujan', 'Badai'];
  final List<String> _selectedWeather = ['Gerimis', 'Hujan', 'Badai'];

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
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
              
              // Cuaca Section
              _buildSectionTitle('Cuaca'),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifikasi Prakiraan Cuaca', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                        Switch(value: _weatherNotif, onChanged: (v) => setState(() => _weatherNotif = v), activeThumbColor: AppColors.primaryBlue),
                      ],
                    ),
                    const Divider(height: 32),
                    Text('Pilihan Cuaca', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _weatherTypes.map((w) => _buildWeatherChip(w, _selectedWeather.contains(w))).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Sensor Section
              _buildSectionTitle('Sensor'),
              _buildSensorSettingCard('Suhu', Icons.thermostat, _suhuWarning, (v) => setState(() => _suhuWarning = v), '0-100', '0-100'),
              const SizedBox(height: 16),
              _buildSensorSettingCard('pH', Icons.science, _phWarning, (v) => setState(() => _phWarning = v), '0-14', '0-14'),
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

  Widget _buildWeatherChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedWeather.remove(label);
          } else {
            _selectedWeather.add(label);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSensorSettingCard(String name, IconData icon, bool toggleValue, ValueChanged<bool> onToggle, String hintAtas, String hintBawah) {
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Early Warning System', style: GoogleFonts.poppins(fontSize: 14)),
              Switch(value: toggleValue, onChanged: onToggle, activeThumbColor: AppColors.primaryBlue),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppTextField(label: 'Batas Atas', hint: hintAtas)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Batas Bawah', hint: hintBawah)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(label: 'Waktu (detik)', hint: '60')),
            ],
          ),
        ],
      ),
    );
  }
}
