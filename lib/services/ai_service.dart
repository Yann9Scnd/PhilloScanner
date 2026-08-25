import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scan_result_model.dart';

/// Layanan AI untuk analisis foto daun cabai.
/// Mendukung OpenAI Vision API dan Google Gemini API.
class AiService {
  static final AiService instance = AiService._internal();
  AiService._internal();

  // ══════════════════════════════════════════════════════════════
  //  KONFIGURASI
  // ══════════════════════════════════════════════════════════════

  /// Provider AI: 'openai' atau 'gemini'
  String provider = 'gemini';

  /// API Key untuk OpenAI atau Gemini
  String apiKey = '';

  /// Model OpenAI (default: gpt-4o)
  String openaiModel = 'gpt-4o';

  /// Model Gemini (default: gemini-1.5-flash)
  String geminiModel = 'gemini-1.5-flash';

  /// Base URL OpenAI
  static const String _openaiBaseUrl = 'https://api.openai.com/v1';

  /// Base URL Gemini
  static const String _geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  bool get isConfigured => apiKey.isNotEmpty;

  // ══════════════════════════════════════════════════════════════
  //  PROMPT UNTUK AI
  // ══════════════════════════════════════════════════════════════

  static const String _systemPrompt = '''
Kamu adalah ahli patologi tanaman cabai (Capsicum annuum).
Tugas: analisis foto daun cabai dan identifikasi penyakitnya.

Kamu WAJIB merespons HANYA dalam format JSON valid (tanpa markdown, tanpa code block) seperti ini:
{
  "disease_name": "Nama penyakit dalam Bahasa Indonesia",
  "scientific_name": "Nama latin penyakit",
  "severity": "Rendah atau Sedang atau Tinggi",
  "confidence": 85,
  "recommendations": [
    "Rekomendasi pertama yang spesifik dan actionable",
    "Rekomendasi kedua",
    "Rekomendasi ketiga"
  ]
}

Aturan:
- confidence adalah integer 0-100
- severity: "Rendah" (gejala ringan, area kecil), "Sedang" (gejala menengah), "Tinggi" (parah, luas)
- Jika daun sehat: disease_name="Daun Sehat", severity="Rendah", confidence>90
- Berikan 3-5 rekomendasi penanganan yang praktis untuk petani cabai
- Selalu gunakan Bahasa Indonesia
''';

  // ══════════════════════════════════════════════════════════════
  //  ANALISIS FOTO
  // ══════════════════════════════════════════════════════════════

  /// Analisis foto daun dari file path atau base64 data URL.
  Future<ScanResultModel> analyzeLeaf({
    required String imageUrl,
    String deviceSource = 'Kamera Smartphone',
    String sector = 'Upload Foto',
    double temperatureAtScan = 28,
    String soilMoisture = '-',
  }) async {
    if (!isConfigured) {
      throw AiException('API Key belum diatur. Buka Pengaturan AI untuk mengisi.');
    }

    try {
      if (provider == 'openai') {
        return await _analyzeWithOpenAI(
          imageUrl: imageUrl,
          deviceSource: deviceSource,
          sector: sector,
          temperatureAtScan: temperatureAtScan,
          soilMoisture: soilMoisture,
        );
      } else {
        return await _analyzeWithGemini(
          imageUrl: imageUrl,
          deviceSource: deviceSource,
          sector: sector,
          temperatureAtScan: temperatureAtScan,
          soilMoisture: soilMoisture,
        );
      }
    } catch (e) {
      throw AiException('Gagal menganalisis: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  OPENAI VISION
  // ══════════════════════════════════════════════════════════════

  Future<ScanResultModel> _analyzeWithOpenAI({
    required String imageUrl,
    required String deviceSource,
    required String sector,
    required double temperatureAtScan,
    required String soilMoisture,
  }) async {
    final base64Image = await _resolveBase64(imageUrl);

    final body = jsonEncode({
      'model': openaiModel,
      'max_tokens': 600,
      'messages': [
        {'role': 'system', 'content': _systemPrompt},
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Analisis foto daun cabai ini. Identifikasi penyakit, tingkat keparahan, dan berikan rekomendasi penanganan.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:image/jpeg;base64,$base64Image',
              },
            },
          ],
        },
      ],
    });

    final response = await http.post(
      Uri.parse('$_openaiBaseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['choices'][0]['message']['content'] as String;
    return _parseAiResponse(content, imageUrl, deviceSource, sector, temperatureAtScan, soilMoisture);
  }

  // ══════════════════════════════════════════════════════════════
  //  GOOGLE GEMINI
  // ══════════════════════════════════════════════════════════════

  Future<ScanResultModel> _analyzeWithGemini({
    required String imageUrl,
    required String deviceSource,
    required String sector,
    required double temperatureAtScan,
    required String soilMoisture,
  }) async {
    final base64Image = await _resolveBase64(imageUrl);

    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': '$_systemPrompt\n\nAnalisis foto daun cabai ini. Identifikasi penyakit, tingkat keparahan, dan berikan rekomendasi penanganan.'},
            {
              'inline_data': {
                'mime_type': 'image/jpeg',
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 600,
      },
    });

    final url = '$_geminiBaseUrl/models/$geminiModel:generateContent?key=$apiKey';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error: ${response.statusCode} ${response.body}');
    }

    final data = jsonDecode(response.body);
    final content = data['candidates'][0]['content']['parts'][0]['text'] as String;
    return _parseAiResponse(content, imageUrl, deviceSource, sector, temperatureAtScan, soilMoisture);
  }

  // ══════════════════════════════════════════════════════════════
  //  PARSER
  // ══════════════════════════════════════════════════════════════

  ScanResultModel _parseAiResponse(
    String raw,
    String imageUrl,
    String deviceSource,
    String sector,
    double temperatureAtScan,
    String soilMoisture,
  ) {
    // Bersihkan dari markdown code block jika ada
    String cleaned = raw.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```(json)?\s*\n?'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\n?```\s*$'), '');
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // Jika JSON parsing gagal, coba extract dari teks
      throw AiException('Respons AI tidak valid. Coba lagi.\n\nRespons: $cleaned');
    }

    final recommendations = <String>[];
    final recs = json['recommendations'];
    if (recs is List) {
      for (final r in recs) {
        recommendations.add(r.toString());
      }
    }

    return ScanResultModel(
      deviceId: deviceSource,
      imageUrl: imageUrl,
      diseaseName: json['disease_name']?.toString() ?? 'Tidak Diketahui',
      scientificName: json['scientific_name']?.toString() ?? '-',
      severity: json['severity']?.toString() ?? 'Sedang',
      confidence: (json['confidence'] as num?)?.toInt() ?? 0,
      timestamp: 'Baru saja',
      soilMoisture: soilMoisture,
      sector: sector,
      temperatureAtScan: temperatureAtScan,
      aiRecommendations: recommendations.isEmpty
          ? ['Tidak ada rekomendasi tersedia.']
          : recommendations,
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  HELPER: resolve image to base64
  // ══════════════════════════════════════════════════════════════

  Future<String> _resolveBase64(String imageUrl) async {
    // Jika sudah base64 data URL, extract
    if (imageUrl.startsWith('data:image')) {
      return imageUrl.split(',')[1];
    }

    // Jika file path lokal
    if (!imageUrl.startsWith('http')) {
      final bytes = await File(imageUrl).readAsBytes();
      return base64Encode(bytes);
    }

    // Jika URL network, download dulu
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      return base64Encode(response.bodyBytes);
    }
    throw Exception('Gagal download gambar: ${response.statusCode}');
  }
}

/// Exception khusus AI service.
class AiException implements Exception {
  final String message;
  AiException(this.message);

  @override
  String toString() => message;
}
