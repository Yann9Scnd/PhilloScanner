import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scan_result_model.dart';
import 'api_client.dart';

class AiService {
  static final AiService instance = AiService._internal();
  AiService._internal();

  Future<ScanResultModel> analyzeLeaf({
    required String imageUrl,
    String deviceSource = 'Kamera Smartphone',
    String sector = 'Upload Foto',
    double temperatureAtScan = 28,
    String soilMoisture = '-',
  }) async {
    final base64Image = await _resolveBase64(imageUrl);

    final client = ApiClient();
    final res = await client.postRaw('ai/analyze', body: {
      'image': base64Image,
      'device_source': deviceSource,
      'sector': sector,
      'temperature': temperatureAtScan,
      'soil_moisture': soilMoisture,
    });

    if (res.statusCode != 200) {
      throw AiException('Gagal menganalisis (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final recs = <String>[];
    final recommendations = data['recommendations'];
    if (recommendations is List) {
      for (final r in recommendations) {
        recs.add(r.toString());
      }
    }

    return ScanResultModel(
      deviceId: deviceSource,
      imageUrl: imageUrl,
      diseaseName: data['disease_name']?.toString() ?? 'Tidak Diketahui',
      scientificName: data['scientific_name']?.toString() ?? '-',
      severity: data['severity']?.toString() ?? 'Sedang',
      confidence: (data['confidence'] as num?)?.toInt() ?? 0,
      timestamp: 'Baru saja',
      soilMoisture: soilMoisture,
      sector: sector,
      temperatureAtScan: temperatureAtScan,
      aiRecommendations: recs.isEmpty ? ['Tidak ada rekomendasi tersedia.'] : recs,
    );
  }

  Future<String> _resolveBase64(String imageUrl) async {
    if (imageUrl.startsWith('data:image')) {
      return imageUrl.split(',')[1];
    }
    if (!imageUrl.startsWith('http')) {
      final bytes = await File(imageUrl).readAsBytes();
      return base64Encode(bytes);
    }
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    }
    throw Exception('Gagal download gambar: ${response.statusCode}');
  }

  Future<String> chat(String message) async {
    final client = ApiClient();
    final res = await client.postRaw('ai/chat', body: {
      'message': message,
    });

    if (res.statusCode != 200) {
      throw AiException('Gagal menghubungi AI (${res.statusCode})');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['reply']?.toString() ?? 'Maaf, tidak ada respons.';
  }
}

class AiException implements Exception {
  final String message;
  AiException(this.message);

  @override
  String toString() => message;
}
