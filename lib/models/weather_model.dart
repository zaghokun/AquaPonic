class WeatherData {
  final String condition;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int rainProbability;
  final String location;
  final DateTime date;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherData({
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.rainProbability,
    required this.location,
    required this.date,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  WeatherData copyWith({
    String? condition,
    double? temperature,
    double? feelsLike,
    double? windSpeed,
    int? humidity,
    int? rainProbability,
    String? location,
    DateTime? date,
    List<HourlyForecast>? hourlyForecast,
    List<DailyForecast>? dailyForecast,
  }) {
    return WeatherData(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity ?? this.humidity,
      rainProbability: rainProbability ?? this.rainProbability,
      location: location ?? this.location,
      date: date ?? this.date,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
      dailyForecast: dailyForecast ?? this.dailyForecast,
    );
  }
}

class HourlyForecast {
  final String time;
  final double temperature;
  final String condition;
  final String icon;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  HourlyForecast copyWith({
    String? time,
    double? temperature,
    String? condition,
    String? icon,
  }) {
    return HourlyForecast(
      time: time ?? this.time,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      icon: icon ?? this.icon,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double highTemp;
  final double lowTemp;
  final String conditionDay;
  final String conditionNight;
  final WeatherDetail? dayDetail;
  final WeatherDetail? nightDetail;

  const DailyForecast({
    required this.date,
    required this.highTemp,
    required this.lowTemp,
    required this.conditionDay,
    required this.conditionNight,
    this.dayDetail,
    this.nightDetail,
  });

  DailyForecast copyWith({
    DateTime? date,
    double? highTemp,
    double? lowTemp,
    String? conditionDay,
    String? conditionNight,
    WeatherDetail? dayDetail,
    WeatherDetail? nightDetail,
  }) {
    return DailyForecast(
      date: date ?? this.date,
      highTemp: highTemp ?? this.highTemp,
      lowTemp: lowTemp ?? this.lowTemp,
      conditionDay: conditionDay ?? this.conditionDay,
      conditionNight: conditionNight ?? this.conditionNight,
      dayDetail: dayDetail ?? this.dayDetail,
      nightDetail: nightDetail ?? this.nightDetail,
    );
  }
}

class WeatherDetail {
  final String condition;
  final double temperature;
  final double feelsLike;
  final double windSpeed;
  final int humidity;
  final int rainProbability;

  const WeatherDetail({
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.windSpeed,
    required this.humidity,
    required this.rainProbability,
  });

  WeatherDetail copyWith({
    String? condition,
    double? temperature,
    double? feelsLike,
    double? windSpeed,
    int? humidity,
    int? rainProbability,
  }) {
    return WeatherDetail(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      feelsLike: feelsLike ?? this.feelsLike,
      windSpeed: windSpeed ?? this.windSpeed,
      humidity: humidity ?? this.humidity,
      rainProbability: rainProbability ?? this.rainProbability,
    );
  }
}
