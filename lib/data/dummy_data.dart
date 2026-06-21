import 'package:aquaponic/models/user_model.dart';
import 'package:aquaponic/models/sensor_model.dart';
import 'package:aquaponic/models/weather_model.dart';
import 'package:aquaponic/models/notification_model.dart';

class DummyData {
  DummyData._();

  static final User user = User(
    id: '1',
    firstName: 'Budi',
    lastName: 'Widjaja',
    email: 'budi.widjaja@gmail.com',
    username: 'budiwidjaja1990',
    phone: '+62 899 1234 4321',
    birthDate: DateTime(1990, 4, 19),
  );

  static List<SensorReading> _generateHistory(double base, double variance, int count) {
    final now = DateTime.now();
    return List.generate(count, (i) {
      final offset = (i - count / 2) * variance / count;
      return SensorReading(
        value: base + offset + (i % 3 == 0 ? variance * 0.3 : -variance * 0.2),
        timestamp: now.subtract(Duration(minutes: (count - i) * 5)),
      );
    });
  }

  static final List<Kolam> kolamList = [
    Kolam(
      id: '1',
      name: 'Kolam 1',
      controllerCode: 'MW278X',
      sensorData: SensorData(
        suhu: 25,
        pH: 7.55,
        suhuStatus: SensorStatus.baik,
        pHStatus: SensorStatus.baik,
        suhuHistory: _generateHistory(25, 8, 12),
        pHHistory: _generateHistory(7.5, 1.5, 12),
      ),
      overallStatus: SensorStatus.baik,
    ),
    Kolam(
      id: '2',
      name: 'Kolam 2',
      controllerCode: 'KL392Y',
      sensorData: SensorData(
        suhu: 15,
        pH: 8.0,
        suhuStatus: SensorStatus.peringatan,
        pHStatus: SensorStatus.peringatan,
        suhuHistory: _generateHistory(15, 6, 12),
        pHHistory: _generateHistory(8.0, 1.2, 12),
      ),
      overallStatus: SensorStatus.peringatan,
    ),
    Kolam(
      id: '3',
      name: 'Kolam 3',
      controllerCode: 'BN514Z',
      sensorData: SensorData(
        suhu: 10,
        pH: 9.5,
        suhuStatus: SensorStatus.bahaya,
        pHStatus: SensorStatus.bahaya,
        suhuHistory: _generateHistory(10, 5, 12),
        pHHistory: _generateHistory(9.5, 2.0, 12),
      ),
      overallStatus: SensorStatus.bahaya,
    ),
  ];

  static final WeatherData weatherData = WeatherData(
    condition: 'Cerah',
    temperature: 30,
    feelsLike: 35,
    windSpeed: 6,
    humidity: 62,
    rainProbability: 20,
    location: 'Gunungpati',
    date: DateTime(2026, 4, 30),
    hourlyForecast: [
      const HourlyForecast(time: '09:00', temperature: 30, condition: 'Berawan', icon: 'cloud'),
      const HourlyForecast(time: '10:00', temperature: 31, condition: 'Cerah', icon: 'sunny'),
      const HourlyForecast(time: '11:00', temperature: 31, condition: 'Cerah', icon: 'sunny'),
      const HourlyForecast(time: '12:00', temperature: 32, condition: 'Cerah', icon: 'sunny'),
      const HourlyForecast(time: '13:00', temperature: 33, condition: 'Cerah', icon: 'sunny'),
    ],
    dailyForecast: [
      DailyForecast(
        date: DateTime(2026, 4, 30),
        highTemp: 31,
        lowTemp: 24,
        conditionDay: 'Cerah',
        conditionNight: 'Cerah',
        dayDetail: const WeatherDetail(condition: 'Cerah', temperature: 30, feelsLike: 35, windSpeed: 6, humidity: 62, rainProbability: 20),
        nightDetail: const WeatherDetail(condition: 'Cerah', temperature: 24, feelsLike: 26, windSpeed: 4, humidity: 70, rainProbability: 10),
      ),
      DailyForecast(
        date: DateTime(2026, 5, 1),
        highTemp: 32,
        lowTemp: 25,
        conditionDay: 'Berawan',
        conditionNight: 'Cerah',
        dayDetail: const WeatherDetail(condition: 'Berawan', temperature: 32, feelsLike: 36, windSpeed: 5, humidity: 58, rainProbability: 30),
        nightDetail: const WeatherDetail(condition: 'Cerah', temperature: 25, feelsLike: 27, windSpeed: 3, humidity: 68, rainProbability: 15),
      ),
      DailyForecast(
        date: DateTime(2026, 5, 2),
        highTemp: 29,
        lowTemp: 23,
        conditionDay: 'Hujan',
        conditionNight: 'Berawan',
        dayDetail: const WeatherDetail(condition: 'Hujan', temperature: 29, feelsLike: 32, windSpeed: 8, humidity: 75, rainProbability: 60),
        nightDetail: const WeatherDetail(condition: 'Berawan', temperature: 23, feelsLike: 25, windSpeed: 5, humidity: 72, rainProbability: 25),
      ),
      DailyForecast(
        date: DateTime(2026, 5, 3),
        highTemp: 30,
        lowTemp: 24,
        conditionDay: 'Cerah',
        conditionNight: 'Cerah',
        dayDetail: const WeatherDetail(condition: 'Cerah', temperature: 30, feelsLike: 34, windSpeed: 7, humidity: 55, rainProbability: 10),
        nightDetail: const WeatherDetail(condition: 'Cerah', temperature: 24, feelsLike: 26, windSpeed: 4, humidity: 65, rainProbability: 5),
      ),
      DailyForecast(
        date: DateTime(2026, 5, 4),
        highTemp: 31,
        lowTemp: 25,
        conditionDay: 'Berawan',
        conditionNight: 'Hujan',
        dayDetail: const WeatherDetail(condition: 'Berawan', temperature: 31, feelsLike: 35, windSpeed: 6, humidity: 60, rainProbability: 40),
        nightDetail: const WeatherDetail(condition: 'Hujan', temperature: 25, feelsLike: 27, windSpeed: 9, humidity: 80, rainProbability: 70),
      ),
    ],
  );

  static final List<NotificationData> todayNotifications = [
    NotificationData(id: '1', title: 'Suhu Rendah - Kolam 2', description: 'Suhu pada Kolam 2 terdeteksi menurun ke 15° C, waspada terhadap penurunan suhu lebih lanjut dan terus monitor suhu.', time: '09:15', type: NotificationType.warning, isRead: false, date: DateTime.now()),
    NotificationData(id: '2', title: 'pH Terlalu Tinggi - Kolam 3', description: 'Nilai pH pada Kolam 3 terlalu tinggi! Segera lakukan tindakan untuk menurunkan pH agar kembali normal.', time: '09:30', type: NotificationType.danger, isRead: false, date: DateTime.now()),
    NotificationData(id: '3', title: 'Besok Akan Hujan', description: 'Terdapat probabilitas Hujan sekitar 60% esok hari. Persiapkan diri agar Suhu Kolam tidak meningkat.', time: '07:15', type: NotificationType.info, isRead: false, date: DateTime.now()),
  ];

  static final List<NotificationData> yesterdayNotifications = [
    NotificationData(id: '4', title: 'Suhu Rendah - Kolam 2', description: 'Suhu pada Kolam 2 terdeteksi menurun ke 15° C, waspada terhadap penurunan suhu lebih lanjut dan terus monitor suhu.', time: '09:15', type: NotificationType.warning, isRead: true, date: DateTime.now().subtract(const Duration(days: 1))),
    NotificationData(id: '5', title: 'pH Terlalu Tinggi - Kolam 3', description: 'Nilai pH pada Kolam 3 terlalu tinggi! Segera lakukan tindakan untuk menurunkan pH agar kembali normal.', time: '09:30', type: NotificationType.danger, isRead: true, date: DateTime.now().subtract(const Duration(days: 1))),
    NotificationData(id: '6', title: 'Besok Akan Hujan', description: 'Terdapat probabilitas Hujan sekitar 60% esok hari. Persiapkan diri agar Suhu Kolam tidak meningkat.', time: '07:15', type: NotificationType.info, isRead: true, date: DateTime.now().subtract(const Duration(days: 1))),
    NotificationData(id: '7', title: 'Suhu Rendah - Kolam 2', description: 'Suhu pada Kolam 2 terdeteksi menurun ke 15° C, waspada terhadap penurunan suhu lebih lanjut dan terus monitor suhu.', time: '09:15', type: NotificationType.warning, isRead: true, date: DateTime.now().subtract(const Duration(days: 1))),
    NotificationData(id: '8', title: 'pH Terlalu Tinggi - Kolam 3', description: 'Nilai pH pada Kolam 3 terlalu tinggi! Segera lakukan tindakan untuk menurunkan pH agar kembali normal.', time: '09:30', type: NotificationType.danger, isRead: true, date: DateTime.now().subtract(const Duration(days: 1))),
  ];
}
