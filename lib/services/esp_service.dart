import 'package:http/http.dart' as http;

class EspService {
  static final EspService instance = EspService._internal();

  EspService._internal();

  // ══════════════════════════════════════════════════════════════
  //  KONFIGURASI IP — GANTI DI SINI sesuai jaringan WiFi kamu
  // ══════════════════════════════════════════════════════════════

  /// IP ESP32-CAM di jaringan WiFi (diatur lewat dialog).
  String camIp = '192.168.1.50';

  /// IP server Laravel & FastAPI. Ganti sesuai IP PC/komputer kamu.
  /// Cek dengan: ipconfig (Windows) atau ifconfig (Mac/Linux).
  /// Untuk testing lokal, semua harus satu jaringan WiFi yang sama.
  static const String _serverIp = '192.168.1.100';

  // ══════════════════════════════════════════════════════════════

  String get serverIp => _serverIp;

  /// Menjadi true setelah user menyimpan konfigurasi di EspConfigDialog.
  bool isServerConfigured = false;

  final http.Client _client = http.Client();

  String get streamUrl => 'http://$camIp:81/stream';
  String get captureUrl => 'http://$camIp/capture';

  /// Base URL API LeafGuard (Laravel) — berjalan di PC yang sama.
  String get apiBaseUrl => 'http://$_serverIp:8000/api';

  /// Server kamera/robot arm (FastAPI app.py).
  /// Endpoint /set-servo untuk menggerakkan servo lengan (Base/Shoulder/Elbow).
  String get armServerUrl => 'http://$_serverIp:8000';

  /// Kirim posisi 3 servo lengan robot (Base/Shoulder/Elbow) ke FastAPI.
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

  /// Toggle aktuator via ESP32-CAM (UART relay ke ESP32 sensor).
  /// Catatan: firmware ESP32-CAM belum memproses endpoint ini.
  /// Saat ini hanya update status UI lokal.
  Future<bool> toggleActuator(String actuator, bool state) async {
    try {
      final uri = Uri.parse('http://$camIp/actuator?$actuator=${state ? 1 : 0}');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
