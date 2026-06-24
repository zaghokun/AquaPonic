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

  /// Add a new device/kolam.
  /// Endpoint: POST /api/devices
  static Future<Map<String, dynamic>> addDevice({
    required String deviceId,
    String? label,
    double phMin = 6.5,
    double phMax = 8.5,
    double tempMin = 25.0,
    double tempMax = 32.0,
  }) async {
    final data = await ApiClient.post('/devices', body: {
      'device': deviceId,
      if (label != null) 'label': label,
      'ph_min': phMin,
      'ph_max': phMax,
      'temp_min': tempMin,
      'temp_max': tempMax,
    });
    return Map<String, dynamic>.from(data);
  }

  /// Update threshold for a device.
  /// Endpoint: PUT /api/thresholds/:device
  static Future<Map<String, dynamic>> updateThreshold(
    String deviceId, {
    double? phMin,
    double? phMax,
    double? tempMin,
    double? tempMax,
  }) async {
    final body = <String, dynamic>{};
    if (phMin != null) body['ph_min'] = phMin;
    if (phMax != null) body['ph_max'] = phMax;
    if (tempMin != null) body['temp_min'] = tempMin;
    if (tempMax != null) body['temp_max'] = tempMax;

    final data = await ApiClient.put('/thresholds/$deviceId', body: body);
    return Map<String, dynamic>.from(data);
  }

  /// Get notifications (warning/danger activity logs).
  /// Endpoint: GET /api/notifications
  static Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 50,
    String? deviceId,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (deviceId != null) params['device'] = deviceId;
    final data = await ApiClient.get('/notifications', queryParams: params);
    return List<Map<String, dynamic>>.from(
      (data as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// Get export CSV URL for a device.
  /// Endpoint: GET /api/devices/export
  static String exportCsvUrl({
    required String deviceId,
    required String from,
    required String to,
  }) {
    const base = 'https://sensor-monitor.aquaponic.workers.dev/api';
    return '$base/devices/export?device=${Uri.encodeComponent(deviceId)}&from=${Uri.encodeComponent(from)}&to=${Uri.encodeComponent(to)}';
  }
}
