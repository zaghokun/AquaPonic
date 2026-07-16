import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';
import 'package:aquaponic/core/network/api_client.dart';

/// Key for SharedPreferences toggle
const String weatherNotifKey = 'weather_notifications_enabled';

/// Unique task name for Workmanager
const String weatherTaskName = 'weatherForecastNotification';

/// Background callback — must be top-level function.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == weatherTaskName) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final enabled = prefs.getBool(weatherNotifKey) ?? true;
        if (!enabled) {
          debugPrint('[WeatherNotif] Weather notifications disabled. Skipping.');
          return Future.value(true);
        }

        // Fetch weather data directly from the worker API
        final token = prefs.getString('access_token');
        if (token == null) {
          debugPrint('[WeatherNotif] No access token. Skipping.');
          return Future.value(true);
        }

        final uri = Uri.parse('${ApiClient.baseUrl}/weather/current');
        final response = await http.get(uri, headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        });

        if (response.statusCode != 200) {
          debugPrint('[WeatherNotif] API returned ${response.statusCode}. Skipping.');
          return Future.value(true);
        }

        final data = jsonDecode(response.body);
        final cur = data['current'] as Map<String, dynamic>?;
        if (cur == null) return Future.value(true);

        final temp = (cur['temperature_2m'] as num?)?.toDouble() ?? 0;
        final humidity = (cur['relative_humidity_2m'] as num?)?.toInt() ?? 0;
        final weatherCode = (cur['weather_code'] as num?)?.toInt() ?? 0;
        final condition = _weatherCodeToCondition(weatherCode);

        final title = '🌤️ Prakiraan Cuaca';
        final body = '$condition, Suhu ${temp.toInt()}°C, Kelembapan $humidity%';

        // Show local notification
        final localNotifications = FlutterLocalNotificationsPlugin();
        const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
        const initSettings = InitializationSettings(android: androidInit);
        await localNotifications.initialize(settings: initSettings);

        const channel = AndroidNotificationChannel(
          'weather_channel',
          'Notifikasi Cuaca',
          description: 'Notifikasi prakiraan cuaca berkala',
          importance: Importance.defaultImportance,
        );

        await localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(channel);

        await localNotifications.show(
          id: 9999,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
          ),
        );

        debugPrint('[WeatherNotif] Notification shown: $body');
      } catch (e) {
        debugPrint('[WeatherNotif] Error: $e');
      }
    }
    return Future.value(true);
  });
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

/// Service to manage weather notification scheduling.
class WeatherNotificationService {
  /// Initialize Workmanager and register the periodic task.
  static Future<void> init() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await registerPeriodicTask();
  }

  /// Register the periodic weather notification task (every 6 hours).
  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      'weatherNotif_periodic',
      weatherTaskName,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    debugPrint('[WeatherNotif] Periodic task registered (every 6 hours)');
  }

  /// Cancel the periodic task.
  static Future<void> cancelPeriodicTask() async {
    await Workmanager().cancelByUniqueName('weatherNotif_periodic');
    debugPrint('[WeatherNotif] Periodic task cancelled');
  }

  /// Toggle weather notifications on/off.
  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(weatherNotifKey, enabled);
    if (enabled) {
      await registerPeriodicTask();
    } else {
      await cancelPeriodicTask();
    }
  }

  /// Check if weather notifications are enabled.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(weatherNotifKey) ?? true;
  }
}
