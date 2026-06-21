import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/weather_model.dart';
import 'package:aquaponic/widgets/weather_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class WeatherDailyDetailScreen extends StatelessWidget {
  final DailyForecast forecast;

  const WeatherDailyDetailScreen({super.key, required this.forecast});

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildChip(Icons.location_on, 'Gunungpati'),
                const SizedBox(width: 12),
                _buildChip(null, DateFormat('EEEE, d MMMM y', 'id_ID').format(forecast.date)),
              ],
            ),
            const SizedBox(height: 32),
            if (forecast.dayDetail != null) ...[
              Text(
                'Siang Hari',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              WeatherCard(
                condition: forecast.dayDetail!.condition,
                temperature: forecast.dayDetail!.temperature,
                feelsLike: forecast.dayDetail!.feelsLike,
                windSpeed: forecast.dayDetail!.windSpeed,
                humidity: forecast.dayDetail!.humidity,
                rainProbability: forecast.dayDetail!.rainProbability,
              ),
              const SizedBox(height: 32),
            ],
            if (forecast.nightDetail != null) ...[
              Text(
                'Malam Hari',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              WeatherCard(
                condition: forecast.nightDetail!.condition,
                temperature: forecast.nightDetail!.temperature,
                feelsLike: forecast.nightDetail!.feelsLike,
                windSpeed: forecast.nightDetail!.windSpeed,
                humidity: forecast.nightDetail!.humidity,
                rainProbability: forecast.nightDetail!.rainProbability,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(IconData? icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.white, size: 16),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
