import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/widgets/colored_bar_indicator.dart';

class SensorCard extends StatelessWidget {
  final Kolam kolam;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.kolam,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (kolam.overallStatus) {
      case SensorStatus.baik:
        statusColor = AppColors.statusGood;
        statusText = 'Baik';
        statusIcon = Icons.check_circle;
        break;
      case SensorStatus.peringatan:
        statusColor = AppColors.statusWarning;
        statusText = 'Peringatan';
        statusIcon = Icons.warning;
        break;
      case SensorStatus.bahaya:
        statusColor = AppColors.statusDanger;
        statusText = 'Bahaya';
        statusIcon = Icons.error;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  kolam.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _buildSensorRow(
              'Suhu',
              '${kolam.sensorData.suhu.toStringAsFixed(1)}° C',
              Icons.thermostat,
              Colors.redAccent,
              kolam.sensorData.suhu,
              BarType.suhu,
            ),
            const SizedBox(height: 16),
            _buildSensorRow(
              'pH',
              kolam.sensorData.pH.toStringAsFixed(2),
              Icons.science,
              Colors.blueAccent,
              kolam.sensorData.pH,
              BarType.pH,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow(
      String title, String valueStr, IconData icon, Color iconColor, double value, BarType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              valueStr,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ColoredBarIndicator(
          value: value,
          minValue: type == BarType.suhu ? 0 : 0,
          maxValue: type == BarType.suhu ? 50 : 14,
          barType: type,
        ),
      ],
    );
  }
}
