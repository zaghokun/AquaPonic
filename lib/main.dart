import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aquaponic/app.dart';
import 'package:aquaponic/services/fcm_service.dart';
import 'package:aquaponic/services/weather_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService.init();
  await WeatherNotificationService.init();
  await initializeDateFormatting('id_ID', null);
  runApp(const AquaPonic());
}
