import 'package:http/http.dart' as http;

class EspService {
  static final EspService instance = EspService._internal();

  EspService._internal();

  String camIp = '192.168.4.1';
  String sensorIp = '192.168.4.2';

  /// IP komputer yang menjalankan server Laravel LeafGuard
  /// (tempat histori scan & telemetri ESP32 disimpan ke database)
  String serverIp = '192.168.1.100';

  /// Menjadi true setelah user menyimpan konfigurasi di EspConfigDialog,
  /// sehingga ApiClient otomatis memakai serverIp untuk koneksi API.
  bool isServerConfigured = false;

  final http.Client _client = http.Client();

  String get streamUrl => 'http://$camIp:81/stream';
  String get captureUrl => 'http://$camIp/capture';

  /// Base URL API LeafGuard (Laravel)
  String get apiBaseUrl => 'http://$serverIp:8000/api';

  /// Kirim perintah servo pan-tilt ke ESP32-CAM
  Future<bool> sendServoCommand(String action) async {
    try {
      final uri = Uri.parse('http://$camIp/action?go=$action');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Kirim perintah toggle aktuator ke Node 2 (ESP32 Sensor)
  Future<bool> toggleActuator(String actuator, bool state) async {
    try {
      final uri = Uri.parse('http://$sensorIp/actuator?$actuator=${state ? 1 : 0}');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
