enum SensorStatus { baik, peringatan, bahaya }

class SensorReading {
  final double value;
  final DateTime timestamp;

  const SensorReading({
    required this.value,
    required this.timestamp,
  });

  SensorReading copyWith({
    double? value,
    DateTime? timestamp,
  }) {
    return SensorReading(
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class SensorData {
  final double suhu;
  final double pH;
  final SensorStatus suhuStatus;
  final SensorStatus pHStatus;
  final List<SensorReading> suhuHistory;
  final List<SensorReading> pHHistory;

  const SensorData({
    required this.suhu,
    required this.pH,
    required this.suhuStatus,
    required this.pHStatus,
    required this.suhuHistory,
    required this.pHHistory,
  });

  SensorData copyWith({
    double? suhu,
    double? pH,
    SensorStatus? suhuStatus,
    SensorStatus? pHStatus,
    List<SensorReading>? suhuHistory,
    List<SensorReading>? pHHistory,
  }) {
    return SensorData(
      suhu: suhu ?? this.suhu,
      pH: pH ?? this.pH,
      suhuStatus: suhuStatus ?? this.suhuStatus,
      pHStatus: pHStatus ?? this.pHStatus,
      suhuHistory: suhuHistory ?? this.suhuHistory,
      pHHistory: pHHistory ?? this.pHHistory,
    );
  }
}

class Kolam {
  final String id;
  final String name;
  final String controllerCode;
  final SensorData sensorData;
  final SensorStatus overallStatus;

  const Kolam({
    required this.id,
    required this.name,
    required this.controllerCode,
    required this.sensorData,
    required this.overallStatus,
  });

  Kolam copyWith({
    String? id,
    String? name,
    String? controllerCode,
    SensorData? sensorData,
    SensorStatus? overallStatus,
  }) {
    return Kolam(
      id: id ?? this.id,
      name: name ?? this.name,
      controllerCode: controllerCode ?? this.controllerCode,
      sensorData: sensorData ?? this.sensorData,
      overallStatus: overallStatus ?? this.overallStatus,
    );
  }
}
