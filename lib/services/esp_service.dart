import 'dart:convert';
import 'package:http/http.dart' as http;

class EspService {
  static final EspService instance = EspService._internal();

  EspService._internal();

  // ══════════════════════════════════════════════════════════════
  //  KONFIGURASI IP
  // ══════════════════════════════════════════════════════════════

  /// IP ESP32 di jaringan WiFi (diatur lewat dialog).
  String espIp = '192.168.43.44';

  /// IP server Laravel & FastAPI. Ganti sesuai IP PC/komputer kamu.
  static const String _serverIp = '192.168.43.182';

  // ══════════════════════════════════════════════════════════════

  String get serverIp => _serverIp;

  bool isServerConfigured = false;

  final http.Client _client = http.Client();

  String get streamUrl => 'http://$espIp:81/stream';
  String get captureUrl => 'http://$espIp/capture';

  /// Base URL API LeafGuard (Laravel).
  String get apiBaseUrl => 'http://$_serverIp:8000/api';

  /// Server kamera/robot arm (FastAPI app.py).
  String get armServerUrl => 'http://$_serverIp:8000';

  /// Base URL ESP32 langsung (WebServer port 80).
  String get espBaseUrl => 'http://$espIp';

  // ══════════════════════════════════════════════════════════════
  //  SERVO LENGAN ROBOT (FastAPI)
  // ══════════════════════════════════════════════════════════════

  Future<bool> setArmServo({
    int base = 90,
    int shoulder = 90,
    int elbow = 90,
  }) async {
    try {
      final uri = Uri.parse(
        '$armServerUrl/set-servo?base=$base&shoulder=$shoulder&elbow=$elbow',
      );
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  AKTUATOR — kirim langsung ke ESP32
  // ══════════════════════════════════════════════════════════════

  /// Toggle aktuator ke ESP32 via HTTP.
  /// Endpoint baru: GET /pump/on dan GET /pump/off
  Future<bool> toggleActuator(String actuator, bool state) async {
    if (actuator == 'pump') {
      return _togglePump(state);
    }
    // Aktuator lain (pestisida, laser, LED) belum ada di ESP32 firmware.
    return false;
  }

  Future<bool> _togglePump(bool state) async {
    try {
      final endpoint = state ? '/pump/on' : '/pump/off';
      final uri = Uri.parse('$espBaseUrl$endpoint');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  SENSOR — fetch langsung dari ESP32
  // ══════════════════════════════════════════════════════════════

  /// Fetch data sensor langsung dari ESP32 GET /status
  /// Berguna saat Laravel belum jalan, tapi ESP32 sudah online.
  Future<Map<String, dynamic>?> fetchSensorFromEsp() async {
    try {
      final uri = Uri.parse('$espBaseUrl/status');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
