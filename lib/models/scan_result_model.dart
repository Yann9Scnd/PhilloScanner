class ScanResultModel {
  final int? id;
  final String deviceId;
  final String imageUrl;
  final String diseaseName;
  final String scientificName;
  final String severity; // Rendah, Sedang, Tinggi, Sehat
  final int confidence; // e.g. 92%
  final String timestamp;
  final String soilMoisture;
  final String sector;
  final double temperatureAtScan;
  final List<String> aiRecommendations;

  const ScanResultModel({
    this.id,
    required this.deviceId,
    required this.imageUrl,
    required this.diseaseName,
    required this.scientificName,
    required this.severity,
    required this.confidence,
    required this.timestamp,
    required this.soilMoisture,
    this.sector = 'Greenhouse Sektor A',
    this.temperatureAtScan = 28.0,
    required this.aiRecommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'device_id': deviceId,
      'image_url': imageUrl,
      'disease_name': diseaseName,
      'scientific_name': scientificName,
      'severity': severity,
      'confidence': confidence,
      'timestamp': timestamp,
      'soil_moisture': soilMoisture,
      'sector': sector,
      'temperature_at_scan': temperatureAtScan.toString(),
      'ai_recommendations': aiRecommendations.join('||'),
    };
  }

  factory ScanResultModel.fromMap(Map<String, dynamic> map) {
    final recsString = map['ai_recommendations'] as String? ?? '';
    return ScanResultModel(
      id: map['id'] as int?,
      deviceId: map['device_id'] as String? ?? 'ESP32-CAM',
      imageUrl: map['image_url'] as String? ?? '',
      diseaseName: map['disease_name'] as String? ?? 'Tidak Teridentifikasi',
      scientificName: map['scientific_name'] as String? ?? '',
      severity: map['severity'] as String? ?? 'Sedang',
      confidence: map['confidence'] as int? ?? 0,
      timestamp: map['timestamp'] as String? ?? '',
      soilMoisture: map['soil_moisture'] as String? ?? '0%',
      sector: map['sector'] as String? ?? 'Greenhouse Sektor A',
      temperatureAtScan: double.tryParse(
              (map['temperature_at_scan'] as String? ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ??
          28.0,
      aiRecommendations: recsString.isNotEmpty ? recsString.split('||') : [],
    );
  }
}
