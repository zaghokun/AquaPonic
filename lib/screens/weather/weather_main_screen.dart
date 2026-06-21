import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/data/dummy_data.dart';
import 'package:aquaponic/models/weather_model.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/weather_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';

class WeatherMainScreen extends StatelessWidget {
  const WeatherMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = DummyData.user;
    final weather = DummyData.weatherData;
    
    return GradientBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Pagi,',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        user.fullName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pink.shade100,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: Icon(Icons.person, color: Colors.pink.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildChip(Icons.location_on, weather.location),
                  const SizedBox(width: 12),
                  _buildChip(null, DateFormat('EEEE, d MMMM y', 'id_ID').format(weather.date)),
                ],
              ),
              const SizedBox(height: 24),
              WeatherCard(
                condition: weather.condition,
                temperature: weather.temperature,
                feelsLike: weather.feelsLike,
                windSpeed: weather.windSpeed,
                humidity: weather.humidity,
                rainProbability: weather.rainProbability,
              ),
              const SizedBox(height: 32),
              Text(
                'Prakiraan per Jam',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: weather.hourlyForecast.length,
                  itemBuilder: (context, index) {
                    final hourly = weather.hourlyForecast[index];
                    return _buildHourlyCard(hourly);
                  },
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Prakiraan Harian',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              ...weather.dailyForecast.map((daily) => _buildDailyCard(context, daily)),
            ],
          ),
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

  Widget _buildHourlyCard(HourlyForecast hourly) {
    IconData iconData = Icons.cloud;
    if (hourly.condition.toLowerCase().contains('cerah')) iconData = Icons.wb_sunny;
    
    return Container(
      width: 75,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hourly.time,
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Icon(iconData, color: AppColors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            '${hourly.temperature.toInt()}°',
            style: GoogleFonts.poppins(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(BuildContext context, DailyForecast daily) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.weatherDaily, arguments: daily),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                DateFormat('EEEE, d MMM', 'id_ID').format(daily.date),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDailyTemp(Icons.wb_sunny, daily.highTemp, Colors.orange),
                  _buildDailyTemp(Icons.nights_stay, daily.lowTemp, AppColors.primaryBlue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTemp(IconData icon, double temp, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 4),
        Text(
          '${temp.toInt()}°',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
