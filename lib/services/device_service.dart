import 'package:aquaponic/core/network/api_client.dart';

/// Service for fetching sensor device data and thresholds from the Worker API.
class DeviceService {
  /// Get all devices with their latest readings and thresholds.
  /// Endpoint: GET /api/devices
  static Future<List<Map<String, dynamic>>> getDevices() async {
    final data = await ApiClient.get('/devices');
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// Get live data for a single device.
  /// Endpoint: GET /api/devices/:id/live
  static Future<Map<String, dynamic>> getDeviceLive(String deviceId) async {
    final data = await ApiClient.get('/devices/$deviceId/live');
    return Map<String, dynamic>.from(data);
  }

  /// Get chart series data (aggregated) for a device.
  /// Endpoint: GET /api/devices/:id/series
  ///
  /// [bucket] can be: minute, hour, day, month, year
  static Future<List<Map<String, dynamic>>> getDeviceSeries(
    String deviceId, {
    String bucket = 'hour',
    String? from,
    String? to,
  }) async {
    final params = <String, String>{'bucket': bucket};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final data = await ApiClient.get(
      '/devices/$deviceId/series',
      queryParams: params,
    );
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// Get thresholds for all devices.
  /// Endpoint: GET /api/thresholds
  static Future<List<Map<String, dynamic>>> getThresholds() async {
    final data = await ApiClient.get('/thresholds');
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }
}
