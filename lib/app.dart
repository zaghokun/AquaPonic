import 'package:flutter/material.dart';
import 'package:aquaponic/core/theme/app_theme.dart';
import 'package:aquaponic/routes/app_routes.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/models/weather_model.dart';

import 'package:aquaponic/screens/auth/login_screen.dart';
import 'package:aquaponic/screens/auth/register_screen.dart';
import 'package:aquaponic/screens/main_navigation.dart';
import 'package:aquaponic/screens/sensor/sensor_detail_screen.dart';
import 'package:aquaponic/screens/sensor/add_sensor_screen.dart';
import 'package:aquaponic/screens/weather/weather_daily_detail_screen.dart';
import 'package:aquaponic/screens/account/edit_profile_screen.dart';
import 'package:aquaponic/screens/account/change_password_screen.dart';
import 'package:aquaponic/screens/account/change_email_screen.dart';
import 'package:aquaponic/screens/account/change_phone_screen.dart';

class AquaPonic extends StatelessWidget {
  const AquaPonic({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaPonic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.main: (context) => const MainNavigation(),
        AppRoutes.addSensor: (context) => const AddSensorScreen(),
        AppRoutes.editProfile: (context) => const EditProfileScreen(),
        AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
        AppRoutes.changeEmail: (context) => const ChangeEmailScreen(),
        AppRoutes.changePhone: (context) => const ChangePhoneScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.sensorDetail) {
          final kolam = settings.arguments as Kolam;
          return MaterialPageRoute(builder: (_) => SensorDetailScreen(kolam: kolam));
        }
        if (settings.name == AppRoutes.weatherDaily) {
          final forecast = settings.arguments as DailyForecast;
          return MaterialPageRoute(builder: (_) => WeatherDailyDetailScreen(forecast: forecast));
        }
        return null;
      },
    );
  }
}
