import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/esp_node_model.dart';

class EspService {
  static final EspService instance = EspService._internal();

  EspService._internal();

  // ══════════════════════════════════════════════════════════════
  //  DAFTAR ESP32 NODES
  // ══════════════════════════════════════════════════════════════

  final List<EspNodeModel> _nodes = [];

  /// Semua ESP32 yang sudah didaftarkan.
  List<EspNodeModel> get nodes => List.unmodifiable(_nodes);

  /// ID node yang sedang dipilih (ditampilkan di dashboard).
  String? _selectedNodeId;
  String? get selectedNodeId => _selectedNodeId;

  /// Node yang sedang aktif dipilih.
  EspNodeModel? get selectedNode {
    if (_selectedNodeId == null) return _nodes.isNotEmpty ? _nodes.first : null;
    try {
      return _nodes.firstWhere((n) => n.id == _selectedNodeId);
    } catch (_) {
      return _nodes.isNotEmpty ? _nodes.first : null;
    }
  }

  /// Tambah node ESP32 baru.
  void addNode(EspNodeModel node) {
    _nodes.add(node);
    _selectedNodeId ??= node.id;
  }

  /// Update node yang sudah ada.
  void updateNode(EspNodeModel updated) {
    final idx = _nodes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) _nodes[idx] = updated;
  }

  /// Hapus node berdasarkan ID.
  void removeNode(String id) {
    _nodes.removeWhere((n) => n.id == id);
    if (_selectedNodeId == id) {
      _selectedNodeId = _nodes.isNotEmpty ? _nodes.first.id : null;
    }
  }

  /// Pilih node aktif berdasarkan ID.
  void selectNode(String id) {
    _selectedNodeId = id;
    // Sync espIp lama dengan node yang dipilih
    final node = selectedNode;
    if (node != null) espIp = node.ip;
  }

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
  Future<Map<String, dynamic>?> fetchSensorFromEsp() async {
    return fetchSensorFromEspIp(espIp);
  }

  /// Fetch data sensor dari IP ESP32 tertentu.
  Future<Map<String, dynamic>?> fetchSensorFromEspIp(String ip) async {
    try {
      final uri = Uri.parse('http://$ip/status');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Cek apakah ESP32 di IP tertentu online.
  Future<bool> checkEspOnline(String ip) async {
    try {
      final uri = Uri.parse('http://$ip/status');
      final res = await _client.get(uri).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
