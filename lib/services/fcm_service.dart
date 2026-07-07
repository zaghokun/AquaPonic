import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aquaponic/core/network/api_client.dart';

/// Handler untuk notifikasi yang diterima saat aplikasi di-background/terminated.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Handling a background message: ${message.messageId}");

  final title = message.notification?.title ?? message.data['title'];
  final body = message.notification?.body ?? message.data['body'];
  final deviceId = message.data['device'];

  if (title != null || body != null) {
    if (deviceId != null) {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('notifications_enabled_$deviceId') ?? true;
      if (!isEnabled) {
        debugPrint("Notification for $deviceId is disabled locally. Skipping.");
        return;
      }
    }

    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidInit);
    
    await localNotifications.initialize(settings: initSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

/// Service for managing FCM (Firebase Cloud Messaging) push notification tokens.
class FcmService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  /// Inisialisasi Firebase Messaging dan request permission.
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission (terutama untuk iOS)
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Buat channel untuk Android
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Inisialisasi Local Notifications untuk menampilkan popup saat aplikasi dibuka
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    // Daftarkan background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Dengarkan pesan saat aplikasi di-foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];
      final deviceId = message.data['device'];

      if ((title != null || body != null) && !kIsWeb) {
        if (deviceId != null) {
          final prefs = await SharedPreferences.getInstance();
          final isEnabled = prefs.getBool('notifications_enabled_$deviceId') ?? true;
          if (!isEnabled) {
            debugPrint("Foreground notification for $deviceId is disabled locally. Skipping.");
            return;
          }
        }

        _localNotifications.show(
          id: message.hashCode,
          title: title,
          body: body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    // Ambil token saat ini
    String? token = await messaging.getToken();
    if (token != null) {
      await saveToken(token);
    }

    // Dengarkan jika token berubah
    messaging.onTokenRefresh.listen((newToken) {
      saveToken(newToken);
    });
  }

  /// Simpan token FCM ke backend.
  /// Endpoint: POST /api/fcm-token
  static Future<void> saveToken(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      await ApiClient.post('/fcm-token', body: {
        'token': token,
        'platform': platform,
      });
      debugPrint("FCM token saved to backend.");
    } catch (e) {
      debugPrint("Gagal menyimpan FCM token: $e");
    }
  }
}
