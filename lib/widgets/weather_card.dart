import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aquaponic/core/constants/app_colors.dart';

class WeatherCard extends StatelessWidget {
  final String condition;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int rainProbability;

  const WeatherCard({
    super.key,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.rainProbability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _getWeatherIcon(condition),
                size: 72,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${temperature.toInt()}°',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Terasa Seperti ${feelsLike.toInt()}°',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoBar('Angin', '${windSpeed.toInt()} km/jam', Icons.air, windSpeed / 30),
          const SizedBox(height: 12),
          _buildInfoBar('Kelembapan', '$humidity%', Icons.water_drop_outlined, humidity / 100),
          const SizedBox(height: 12),
          _buildInfoBar('Probabilitas Hujan', '$rainProbability%', Icons.grain, rainProbability / 100),
        ],
      ),
    );
  }

  IconData _getWeatherIcon(String cond) {
    if (cond.toLowerCase().contains('cerah')) return Icons.wb_sunny;
    if (cond.toLowerCase().contains('hujan')) return Icons.beach_access;
    return Icons.cloud;
  }

  Widget _buildInfoBar(String label, String valueStr, IconData icon, double percentage) {
    percentage = percentage.clamp(0.0, 1.0);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          valueStr,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.yellow, Colors.red],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
