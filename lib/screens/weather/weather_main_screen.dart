import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aquaponic/core/constants/app_colors.dart';
import 'package:aquaponic/models/weather_model.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/widgets/weather_card.dart';
import 'package:aquaponic/widgets/gradient_background.dart';
import 'package:aquaponic/services/weather_service.dart';
import 'package:aquaponic/services/auth_service.dart';

class WeatherMainScreen extends StatefulWidget {
  const WeatherMainScreen({super.key});

  @override
  State<WeatherMainScreen> createState() => _WeatherMainScreenState();
}

class _WeatherMainScreenState extends State<WeatherMainScreen> {
  bool _isLoading = true;
  String? _error;

  // Current weather (base values from API)
  String _baseCondition = '';
  double _baseTemperature = 0;
  double _baseFeelsLike = 0;
  double _baseWindSpeed = 0;
  int _baseHumidity = 0;
  final int _baseRainProbability = 0;
  String _location = 'Gunungpati';

  // Display values (can be overridden by hourly selection)
  String _condition = '';
  double _temperature = 0;
  double _feelsLike = 0;
  double _windSpeed = 0;
  int _humidity = 0;
  int _rainProbability = 0;

  // User info
  String _userName = 'Pengguna';

  // Hourly
  List<HourlyForecast> _hourlyForecast = [];
  int _selectedHourIndex = 0;

  // Daily
  List<DailyForecast> _dailyForecast = [];

  // ScrollController for hourly list
  final ScrollController _hourlyScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _hourlyScrollController.dispose();
    super.dispose();
  }

  String _weatherCodeToCondition(int code) {
    if (code == 0) return 'Cerah';
    if (code <= 3) return 'Berawan';
    if (code <= 48) return 'Berkabut';
    if (code <= 55) return 'Gerimis';
    if (code <= 65) return 'Hujan';
    if (code <= 67) return 'Hujan Es';
    if (code <= 77) return 'Salju';
    if (code <= 82) return 'Hujan Lebat';
    if (code <= 86) return 'Hujan Salju';
    if (code <= 99) return 'Badai';
    return 'Tidak Diketahui';
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      // Load user info
      final me = await AuthService.me();
      if (me != null) {
        final user = me['user'] as Map<String, dynamic>? ?? {};
        final meta = user['user_metadata'] as Map<String, dynamic>? ?? {};
        final fullName = meta['full_name'] as String? ?? '';
        if (fullName.isNotEmpty) {
          // Use first name only for greeting
          _userName = fullName.split(' ').first;
        } else {
          _userName = 'Pengguna';
        }
      }

      // Load current weather
      final current = await WeatherService.getCurrent();
      final place = current['place'] as Map<String, dynamic>?;
      final cur = current['current'] as Map<String, dynamic>?;
      if (place != null) {
        _location = place['name'] ?? 'Gunungpati';
      }
      if (cur != null) {
        _baseTemperature = (cur['temperature_2m'] as num?)?.toDouble() ?? 0;
        _baseFeelsLike = (cur['apparent_temperature'] as num?)?.toDouble() ?? 0;
        _baseWindSpeed = (cur['wind_speed_10m'] as num?)?.toDouble() ?? 0;
        _baseHumidity = (cur['relative_humidity_2m'] as num?)?.toInt() ?? 0;
        final weatherCode = (cur['weather_code'] as num?)?.toInt() ?? 0;
        _baseCondition = _weatherCodeToCondition(weatherCode);
      }

      // Load hourly forecast
      final hourlyRes = await WeatherService.getHourly();
      final hourlyList = hourlyRes['hourly'] as List<dynamic>? ?? [];
      
      final now = DateTime.now();
      _hourlyForecast = hourlyList.where((h) {
        final timeStr = h['time']?.toString() ?? '';
        final dt = DateTime.tryParse(timeStr);
        if (dt == null) return false;
        final localDt = DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute);
        return localDt.isAfter(now.subtract(const Duration(hours: 1)));
      }).take(12).map((h) {
        final time = h['time'] ?? '';
        String displayTime;
        try {
          final dt = DateTime.parse(time);
          displayTime = DateFormat('HH:mm').format(dt);
        } catch (_) {
          displayTime = time.toString().length >= 16 ? time.toString().substring(11, 16) : time.toString();
        }
        final wc = (h['weather_code'] as num?)?.toInt() ?? 0;
        return HourlyForecast(
          time: displayTime,
          temperature: (h['temperature_2m'] as num?)?.toDouble() ?? 0,
          condition: _weatherCodeToCondition(wc),
          icon: wc <= 3 ? 'sunny' : 'cloud',
          feelsLike: (h['apparent_temperature'] as num?)?.toDouble() ?? 0,
          windSpeed: (h['wind_speed_10m'] as num?)?.toDouble() ?? 0,
          humidity: (h['relative_humidity_2m'] as num?)?.toInt() ?? 0,
          rainProbability: (h['precipitation_probability'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      // Default: select index 0 (current hour) and set display values from it
      _selectedHourIndex = 0;
      if (_hourlyForecast.isNotEmpty) {
        _applyHourlySelection(0);
      } else {
        // Fallback to base values
        _condition = _baseCondition;
        _temperature = _baseTemperature;
        _feelsLike = _baseFeelsLike;
        _windSpeed = _baseWindSpeed;
        _humidity = _baseHumidity;
        _rainProbability = _baseRainProbability;
      }

      // Load daily forecast
      final dailyRes = await WeatherService.getDaily();
      final dailyList = dailyRes['daily'] as List<dynamic>? ?? [];
      _dailyForecast = dailyList.map((d) {
        final date = DateTime.tryParse(d['time'] ?? '') ?? DateTime.now();
        final highTemp = (d['temperature_2m_max'] as num?)?.toDouble() ?? 0;
        final lowTemp = (d['temperature_2m_min'] as num?)?.toDouble() ?? 0;
        final wc = (d['weather_code'] as num?)?.toInt() ?? 0;
        final rainMax = (d['precipitation_probability_max'] as num?)?.toInt() ?? 0;
        final cond = _weatherCodeToCondition(wc);
        return DailyForecast(
          date: date,
          highTemp: highTemp,
          lowTemp: lowTemp,
          conditionDay: cond,
          conditionNight: cond,
          dayDetail: WeatherDetail(
            condition: cond,
            temperature: highTemp,
            feelsLike: highTemp + 2,
            windSpeed: _baseWindSpeed,
            humidity: _baseHumidity,
            rainProbability: rainMax,
          ),
          nightDetail: WeatherDetail(
            condition: cond,
            temperature: lowTemp,
            feelsLike: lowTemp + 1,
            windSpeed: _baseWindSpeed - 1,
            humidity: _baseHumidity + 5,
            rainProbability: rainMax,
          ),
        );
      }).toList();

      setState(() { _isLoading = false; });
    } catch (e) {
      setState(() { _error = 'Gagal memuat data cuaca'; _isLoading = false; });
    }
  }

  void _applyHourlySelection(int index) {
    final h = _hourlyForecast[index];
    _condition = h.condition;
    _temperature = h.temperature;
    _feelsLike = h.feelsLike;
    _windSpeed = h.windSpeed;
    _humidity = h.humidity;
    _rainProbability = h.rainProbability;
  }

  void _onHourlyTap(int index) {
    setState(() {
      _selectedHourIndex = index;
      _applyHourlySelection(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const GradientBackground(
        child: Center(child: CircularProgressIndicator(color: AppColors.white)),
      );
    }

    if (_error != null) {
      return GradientBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, color: AppColors.white, size: 64),
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: AppColors.white, fontSize: 16)),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh, color: AppColors.white),
                label: const Text('Coba Lagi', style: TextStyle(color: AppColors.white)),
              ),
            ],
          ),
        ),
      );
    }

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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          _userName,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildChip(Icons.location_on, _location),
                    const SizedBox(width: 12),
                    _buildChip(null, DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now())),
                    if (_selectedHourIndex > 0 && _hourlyForecast.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _buildChip(Icons.access_time, 'Prakiraan ${_hourlyForecast[_selectedHourIndex].time}'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              WeatherCard(
                condition: _condition,
                temperature: _temperature,
                feelsLike: _feelsLike,
                windSpeed: _windSpeed,
                humidity: _humidity,
                rainProbability: _rainProbability,
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
                height: 120,
                child: ListView.builder(
                  controller: _hourlyScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: _hourlyForecast.length,
                  itemBuilder: (context, index) {
                    final hourly = _hourlyForecast[index];
                    final isSelected = index == _selectedHourIndex;
                    return _buildHourlyCard(hourly, isSelected, index);
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
              ..._dailyForecast.map((daily) => _buildDailyCard(context, daily)),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
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

  Widget _buildHourlyCard(HourlyForecast hourly, bool isSelected, int index) {
    IconData iconData = Icons.cloud;
    if (hourly.condition.toLowerCase().contains('cerah')) iconData = Icons.wb_sunny;
    
    return GestureDetector(
      onTap: () => _onHourlyTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.white.withValues(alpha: 0.9)
              : AppColors.primaryBlue.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.white
                : AppColors.white.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.white.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 1)]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (index == 0)
              Text(
                'Saat ini',
                style: GoogleFonts.poppins(
                  color: isSelected ? AppColors.primaryBlue : AppColors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Text(
              hourly.time,
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            Icon(
              iconData,
              color: isSelected ? AppColors.primaryBlue : AppColors.white,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              '${hourly.temperature.toInt()}°',
              style: GoogleFonts.poppins(
                color: isSelected ? AppColors.primaryBlue : AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
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
