Analyze all UI mockup images inside:

./AquaPonic UI/

This folder contains the complete UI design for an AquaPonic mobile application.

Your task is to build a complete Flutter application from these UI images.

Requirements:

1. Scan and analyze ALL PNG files inside the AquaPonic UI folder.

2. Identify screens automatically from filenames:
   - Login
   - Register
   - Account
   - Edit Profile
   - Change Password
   - Weather Main
   - Weather Daily Forecast
   - Weather Hourly Forecast
   - Sensor Main
   - Sensor Detail
   - Add New Sensor
   - Notifications
   - Settings
   - Change Email Flow
   - Change Phone Number Flow
   - Logout

3. Create Flutter screens matching the design as closely as possible.

4. Use Material 3.

5. Create reusable widgets:
   - AppButton
   - AppTextField
   - SensorCard
   - WeatherCard
   - NotificationCard
   - SettingTile
   - ProfileHeader

6. Generate project structure:

lib/
├── main.dart
├── app.dart
├── routes/
│   └── app_routes.dart
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
├── models/
├── services/
├── data/
│   └── dummy_data.dart
├── screens/
│   ├── auth/
│   ├── weather/
│   ├── sensor/
│   ├── notification/
│   ├── settings/
│   └── account/
├── widgets/
└── assets/

7. Create dummy models:

User
Sensor
WeatherData
NotificationData

8. Create realistic dummy data for testing.

9. Navigation should work between all screens.

10. Implement:
    - Login flow
    - Register flow
    - Sensor list
    - Sensor detail
    - Add sensor page
    - Weather dashboard
    - Notifications page
    - Settings page
    - Profile page

11. No backend integration yet.
Use local dummy data only.

12. Create responsive layouts.

13. Use clean architecture principles.

14. Use named routes.

15. Create a bottom navigation bar if required by the design.

16. Add comments explaining generated code.

17. Generate complete runnable Flutter code.

18. Ensure:
    flutter pub get
    flutter run

works without modification.

Start by analyzing all PNG files in the AquaPonic UI folder and then generate the Flutter project automatically.