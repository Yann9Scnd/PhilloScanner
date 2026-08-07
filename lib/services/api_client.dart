import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/disease_model.dart';
import '../models/scan_result_model.dart';
import '../models/sensor_data_model.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client untuk komunikasi dengan backend Laravel.
///
/// URL server dikonfigurasi saat build/run:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : _baseUrl = baseUrl ?? defaultBaseUrl,
        _client = client ?? http.Client();

  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  final String _baseUrl;
  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_baseUrl/api/$path');
    return query == null || query.isEmpty ? uri : uri.replace(queryParameters: query);
  }

  Map<String, dynamic>? _data(Object? decoded) {
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  List<dynamic>? _list(Object? decoded) {
    if (decoded is List) return decoded;
    return null;
  }

  Never _throw(http.Response res) {
    var message = 'Server error (${res.statusCode})';
    try {
      final decoded = jsonDecode(res.body);
      final data = _data(decoded);
      if (data != null && data['message'] is String) {
        message = data['message'] as String;
      }
    } catch (_) {}
    throw ApiException(res.statusCode, message);
  }

  /// GET /api/diseases?category=...
  Future<List<DiseaseModel>> fetchDiseases({String? category}) async {
    final uri = _uri('diseases',
        (category == null || category == 'Semua') ? null : {'category': category});
    final res = await _client.get(uri);
    if (res.statusCode != 200) _throw(res);
    final list = _list(jsonDecode(res.body)) ?? [];
    return list
        .map((e) => DiseaseModel.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// GET /api/scans
  Future<List<ScanResultModel>> fetchScans() async {
    final res = await _client.get(_uri('scans'));
    if (res.statusCode != 200) _throw(res);
    final list = _list(jsonDecode(res.body)) ?? [];
    return list
        .map((e) => ScanResultModel.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }

  /// GET /api/scans/latest
  Future<ScanResultModel?> fetchLatestScan() async {
    final res = await _client.get(_uri('scans/latest'));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) _throw(res);
    return ScanResultModel.fromMap(
        (jsonDecode(res.body) as Map).cast<String, dynamic>());
  }

  /// POST /api/scans
  Future<int> addScan(ScanResultModel scan) async {
    final res = await _client.post(
      _uri('scans'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(scan.toMap()),
    );
    if (res.statusCode != 200 && res.statusCode != 201) _throw(res);
    final data = _data(jsonDecode(res.body)) ?? {};
    return data['id'] as int? ?? 1;
  }

  /// GET /api/sensor-readings
  Future<List<SensorDataModel>> fetchSensorReadings() async {
    final res = await _client.get(_uri('sensor-readings'));
    if (res.statusCode != 200) _throw(res);
    final list = _list(jsonDecode(res.body)) ?? [];
    return list
        .map((e) => SensorDataModel.fromMap((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
