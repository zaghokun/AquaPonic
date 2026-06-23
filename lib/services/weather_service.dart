import 'package:aquaponic/core/network/api_client.dart';

/// Service for fetching weather data from the Worker API.
class WeatherService {
  /// Get current weather conditions.
  /// Endpoint: GET /api/weather/current
  static Future<Map<String, dynamic>> getCurrent() async {
    final data = await ApiClient.get('/weather/current');
    return Map<String, dynamic>.from(data);
  }

  /// Get hourly weather forecast.
  /// Endpoint: GET /api/weather/hourly
  static Future<Map<String, dynamic>> getHourly() async {
    final data = await ApiClient.get('/weather/hourly');
    return Map<String, dynamic>.from(data);
  }

  /// Get daily weather forecast (7 days).
  /// Endpoint: GET /api/weather/daily
  static Future<Map<String, dynamic>> getDaily() async {
    final data = await ApiClient.get('/weather/daily');
    return Map<String, dynamic>.from(data);
  }
}
