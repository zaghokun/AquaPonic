import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/services/weather_notification_service.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/widgets/setting_tile.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;
  bool _weatherNotifEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadWeatherNotifPref();
  }

  Future<void> _loadWeatherNotifPref() async {
    final enabled = await WeatherNotificationService.isEnabled();
    if (mounted) setState(() { _weatherNotifEnabled = enabled; _loading = false; });
  }

  Future<void> _toggleWeatherNotif(bool value) async {
    setState(() => _weatherNotifEnabled = value);
    await WeatherNotificationService.setEnabled(value);
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

                    // ── Notifikasi Section ──
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Notifikasi',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SettingToggleTile(
                        title: 'Notifikasi Cuaca',
                        icon: Icons.cloud_outlined,
                        value: _weatherNotifEnabled,
                        onChanged: _toggleWeatherNotif,
                        hideDivider: true,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4, bottom: 24),
                      child: Text(
                        'Dapatkan prakiraan cuaca setiap 6 jam',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
