class SensorDataModel {
  final int? id;
  final String deviceId;
  final double soilMoisture; // %
  final double temperature; // °C
  final double airHumidity; // %
  final double lightIntensity; // Lux
  final double waterTankLevel; // %
  final double soilPh; // pH value
  final double batteryLevel; // % kapasitas baterai
  final double leafDistance; // cm jarak daun ke ESP-CAM (ultrasonik)
  final String pumpStatus;
  final String timestamp;

  const SensorDataModel({
    this.id,
    required this.deviceId,
    required this.soilMoisture,
    required this.temperature,
    required this.airHumidity,
    required this.lightIntensity,
    required this.waterTankLevel,
    required this.soilPh,
    required this.batteryLevel,
    required this.leafDistance,
    required this.pumpStatus,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'soil_moisture': soilMoisture.toString(),
      'temperature': temperature.toString(),
      'air_humidity': airHumidity.toString(),
      'light_intensity': lightIntensity.toString(),
      'water_tank_level': waterTankLevel.toString(),
      'soil_ph': soilPh.toString(),
      'battery_level': batteryLevel.toString(),
      'leaf_distance': leafDistance.toString(),
      'pump_status': pumpStatus,
      'timestamp': timestamp,
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    double parseNum(dynamic val, double fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toDouble();
      if (val is String) {
        final cleaned = val.replaceAll(RegExp(r'[^0-9.]'), '');
        return double.tryParse(cleaned) ?? fallback;
      }
      return fallback;
    }

    return SensorDataModel(
      id: map['id'] as int?,
      deviceId: map['device_id'] as String? ?? 'Node 2: ESP32 Sensor',
      soilMoisture: parseNum(map['soil_moisture'], 0),
      temperature: parseNum(map['temperature'], 0),
      airHumidity: parseNum(map['air_humidity'], 0),
      lightIntensity: parseNum(map['light_intensity'], 0),
      waterTankLevel: parseNum(map['water_tank_level'], 0),
      soilPh: parseNum(map['soil_ph'], 0),
      batteryLevel: parseNum(map['battery_level'], 0),
      leafDistance: parseNum(map['leaf_distance'], 0),
      pumpStatus: map['pump_status'] as String? ?? 'Standby',
      timestamp: map['timestamp'] as String? ?? 'Baru saja',
    );
  }

  factory SensorDataModel.initial() {
    return const SensorDataModel(
      deviceId: 'Node 2: ESP32 Sensor',
      soilMoisture: 0,
      temperature: 0,
      airHumidity: 0,
      lightIntensity: 0,
      waterTankLevel: 0,
      soilPh: 0,
      batteryLevel: 0,
      leafDistance: 0,
      pumpStatus: 'Standby',
      timestamp: 'Baru saja',
    );
  }

  SensorDataModel copyWith({
    int? id,
    String? deviceId,
    double? soilMoisture,
    double? temperature,
    double? airHumidity,
    double? lightIntensity,
    double? waterTankLevel,
    double? soilPh,
    double? batteryLevel,
    double? leafDistance,
    String? pumpStatus,
    String? timestamp,
  }) {
    return SensorDataModel(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      airHumidity: airHumidity ?? this.airHumidity,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      waterTankLevel: waterTankLevel ?? this.waterTankLevel,
      soilPh: soilPh ?? this.soilPh,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      leafDistance: leafDistance ?? this.leafDistance,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
