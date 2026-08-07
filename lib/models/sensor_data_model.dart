class SensorDataModel {
  final int? id;
  final String deviceId;
  final String soilMoisture;
  final String temperature;
  final String pumpStatus;
  final String timestamp;

  const SensorDataModel({
    this.id,
    required this.deviceId,
    required this.soilMoisture,
    required this.temperature,
    required this.pumpStatus,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'soil_moisture': soilMoisture,
      'temperature': temperature,
      'pump_status': pumpStatus,
      'timestamp': timestamp,
    };
  }

  factory SensorDataModel.fromMap(Map<String, dynamic> map) {
    return SensorDataModel(
      id: map['id'] as int?,
      deviceId: map['device_id'] as String? ?? 'ESP32-Sektor-A',
      soilMoisture: map['soil_moisture'] as String? ?? '0%',
      temperature: map['temperature'] as String? ?? '0°C',
      pumpStatus: map['pump_status'] as String? ?? 'Mati',
      timestamp: map['timestamp'] as String? ?? '',
    );
  }
}
