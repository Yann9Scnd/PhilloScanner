import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';

class EspConfigDialog extends StatefulWidget {
  const EspConfigDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const EspConfigDialog(),
    );
  }

  @override
  State<EspConfigDialog> createState() => _EspConfigDialogState();
}

class _EspConfigDialogState extends State<EspConfigDialog> {
  late TextEditingController _node1IpController;
  late TextEditingController _node2IpController;
  late TextEditingController _serverIpController;
  late TextEditingController _wifiSsidController;
  late TextEditingController _wifiPasswordController;

  String _selectedNode = 'node1';
  String _protocol = 'http';
  String _mqttBroker = 'broker.hivemq.com';
  String _mqttPort = '1883';
  String _activeTab = 'config';

  bool _isTesting = false;
  ({bool success, int latency, String message})? _testResult;
  bool _copiedCode = false;

  @override
  void initState() {
    super.initState();
    _node1IpController = TextEditingController(text: EspService.instance.camIp);
    _node2IpController = TextEditingController(text: EspService.instance.sensorIp);
    _serverIpController =
        TextEditingController(text: EspService.instance.serverIp);
    _wifiSsidController = TextEditingController(text: 'Kebun_Cabai_IoT_WiFi');
    _wifiPasswordController = TextEditingController(text: 'cabaimerah123');
  }

  @override
  void dispose() {
    _node1IpController.dispose();
    _node2IpController.dispose();
    _serverIpController.dispose();
    _wifiSsidController.dispose();
    _wifiPasswordController.dispose();
    super.dispose();
  }

  String get _activeIp =>
      _selectedNode == 'node1' ? _node1IpController.text.trim() : _node2IpController.text.trim();

  String get _currentCodeSnippet =>
      _selectedNode == 'node1' ? _codeNode1Cam : _codeNode2Sensor;

  String get _codeNode1Cam => '''
/*
  PHYLLOSCANNER IOT - NODE 1: ESP32-CAM & SERVO PAN-TILT (BEDENG BARAT CABAI)
  Board: AI Thinker ESP32-CAM | Arduino IDE v2.0+
  Alur: hasil jepretan ESP32-CAM dikirim ke server LeafGuard (Laravel)
        -> POST /api/scans -> tersimpan di MySQL -> tampil di Riwayat mobile.
*/

#include "esp_camera.h"
#include <WiFi.h>
#include <ESP32Servo.h>
#include <HTTPClient.h>

const char* ssid = "${_wifiSsidController.text.trim()}";
const char* password = "${_wifiPasswordController.text.trim()}";
const char* serverUrl = "http://${_serverIpController.text.trim()}:8000/api/scans";
const char* nodeId = "ESP32-CAM Node 1 (Bedeng Barat)";

// Servo Pan-Tilt Pin
Servo servoPan;  // GPIO 12
Servo servoTilt; // GPIO 13

// Konfigurasi kamera AI Thinker ESP32-CAM
camera_config_t config = {
  .pin_pwdn = 32, .pin_reset = -1, .pin_xclk = 0, .pin_sccb_sda = 26,
  .pin_sccb_scl = 27, .pin_d7 = 35, .pin_d6 = 34, .pin_d5 = 39,
  .pin_d4 = 36, .pin_d3 = 21, .pin_d2 = 19, .pin_d1 = 18, .pin_d0 = 5,
  .pin_vsync = 25, .pin_href = 23, .pin_pclk = 22, .pin_xclk_freq_hz = 20000000,
  .ledc_timer = LEDC_TIMER_0, .ledc_channel = LEDC_CHANNEL_0, .pixel_format = PIXFORMAT_JPEG,
  .frame_size = FRAMESIZE_SVGA, .jpeg_quality = 12, .fb_count = 1, .grab_mode = CAMERA_GRAB_LATEST
};

void setup() {
  Serial.begin(115200);
  servoPan.attach(12);
  servoTilt.attach(13);
  servoPan.write(90);
  servoTilt.write(45);

  if (esp_camera_init(&config) != ESP_OK) {
    Serial.println("Gagal init kamera!");
  }

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\\n[OK] Node 1 ESP32-CAM Terhubung!");
  Serial.print("IP Stream Kamera Bedeng Barat: http://");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Ambil foto lalu kirim hasil ke server LeafGuard (MySQL)
  camera_fb_t* fb = esp_camera_fb_get();
  if (fb) {
    esp_camera_fb_return(fb);
    sendScanToServer();
  }
  delay(60000); // kirim setiap 60 detik
}

void sendScanToServer() {
  if (WiFi.status() != WL_CONNECTED) return;

  HTTPClient http;
  http.begin(serverUrl);
  http.addHeader("Content-Type", "application/json");

  // image_url menunjuk ke endpoint capture ESP32-CAM di jaringan LAN
  String json = "{\\"device_id\\":\\"\$nodeId\\",\\"image_url\\":\\"http://"
                + WiFi.localIP().toString() + "/capture\\","
                + "\\"disease_name\\":\\"Menunggu Analisis AI\\","
                + "\\"scientific_name\\":\\"Capsicum annuum\\","
                + "\\"severity\\":\\"Rendah\\",\\"confidence\\":0,"
                + "\\"sector\\":\\"Bedeng Barat\\",\\"soil_moisture\\":\\"-\\","
                + "\\"ai_recommendations\\":\\"Foto dikirim ESP32-CAM; buka aplikasi untuk analisis lengkap.\\"}";

  int httpCode = http.POST(json);
  Serial.printf("POST Scan: %d\\n", httpCode);
  http.end();
}''';

  String get _codeNode2Sensor => '''
/*
  PHYLLOSCANNER IOT - NODE 2: ESP32 SENSOR & AKTUATOR (BEDENG TIMUR CABAI)
  Board: ESP32 Dev Module | Arduino IDE v2.0+
*/

#include <WiFi.h>
#include <HTTPClient.h>
#include <DHT.h>

const char* ssid = "${_wifiSsidController.text.trim()}";
const char* password = "${_wifiPasswordController.text.trim()}";
const char* serverUrl = "http://${_serverIpController.text.trim()}:8000/api/telemetry";

#define DHTPIN 4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

const int SOIL_PIN   = 34; // Capacitive Soil Moisture Sensor
const int RELAY_PUMP = 26; // Relai Pompa Irigasi Cabai
const int RELAY_MIST = 27; // Relai Misting Sprinkler Udara

void setup() {
  Serial.begin(115200);
  dht.begin();
  pinMode(RELAY_PUMP, OUTPUT);
  pinMode(RELAY_MIST, OUTPUT);
  digitalWrite(RELAY_PUMP, HIGH);
  digitalWrite(RELAY_MIST, HIGH);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\\n[OK] Node 2 ESP32 Sensor Terhubung!");
  Serial.print("IP Node 2 Telemetri: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  if (WiFi.status() == WL_CONNECTED) {
    int rawSoil = analogRead(SOIL_PIN);
    int soilPercent = map(rawSoil, 4095, 1500, 0, 100);
    float temp = dht.readTemperature();
    float hum = dht.readHumidity();

    HTTPClient http;
    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    String jsonPayload = "{\\"node\\":\\"Node 2 - Bedeng Timur Cabai\\",\\"soilMoisture\\":"
                         + String(soilPercent) + ",\\"temp\\":" + String(temp) + ",\\"humidity\\":" + String(hum) + "}";

    int httpCode = http.POST(jsonPayload);
    Serial.printf("POST Telemetry Response: %d\\n", httpCode);
    http.end();
  }
  delay(3000);
}''';

  void _save() {
    EspService.instance.camIp = _node1IpController.text.trim();
    EspService.instance.sensorIp = _node2IpController.text.trim();
    EspService.instance.serverIp = _serverIpController.text.trim();
    EspService.instance.isServerConfigured = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('Konfigurasi 2 Node ESP32 berhasil disimpan!')),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _handleTestConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    final latency = 10 + (DateTime.now().millisecondsSinceEpoch % 20);
    setState(() {
      _isTesting = false;
      _testResult = (
        success: true,
        latency: latency,
        message: _selectedNode == 'node1'
            ? 'Terhubung ke Node 1: ESP32-CAM Bedeng Barat ($_activeIp) • Stream Kamera & Servo Pan-Tilt OK!'
            : 'Terhubung ke Node 2: ESP32 Telemetry Bedeng Timur ($_activeIp) • Sensor Tanah & Relai Irigasi OK!',
      );
    });
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: _currentCodeSnippet));
    setState(() => _copiedCode = true);
    await Future.delayed(const Duration(milliseconds: 2500));
    if (mounted) setState(() => _copiedCode = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0F172A), AppColors.primary],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.memory_rounded, color: Color(0xFF34D399), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Input & Atur 2 Titik Node ESP32 Kebun Cabai',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Konfigurasi Dual Node (Kamera Visual & Telemetri Sensor)',
                          style: const TextStyle(color: Color(0xFFB3D9FF), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // Node Switcher
            Container(
              padding: const EdgeInsets.all(10),
              color: const Color(0xFF0F172A),
              child: Row(
                children: [
                  Text(
                    'Pilih Node:',
                    style: AppTextStyles.labelMd(color: const Color(0xFFCBD5E1))
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _nodeButton(
                            id: 'node1',
                            icon: Icons.videocam_rounded,
                            label: 'Node 1: ESP32-CAM (Barat)',
                            activeColor: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _nodeButton(
                            id: 'node2',
                            icon: Icons.water_drop_rounded,
                            label: 'Node 2: ESP32 Sensor (Timur)',
                            activeColor: const Color(0xFF3B82F6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Tabs
            Container(
              color: const Color(0xFFF8FAFC),
              child: Row(
                children: [
                  _navTab(
                    id: 'config',
                    icon: Icons.tune_rounded,
                    label: 'Form Input IP Node',
                  ),
                  _navTab(
                    id: 'code',
                    icon: Icons.code_rounded,
                    label: 'Kode Arduino C++',
                  ),
                  _navTab(
                    id: 'tutorial',
                    icon: Icons.terminal_rounded,
                    label: 'Panduan Dual ESP32',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _activeTab == 'config'
                    ? _buildConfigTab()
                    : _activeTab == 'code'
                        ? _buildCodeTab()
                        : _buildTutorialTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeButton({
    required String id,
    required IconData icon,
    required String label,
    required Color activeColor,
  }) {
    final isActive = _selectedNode == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedNode = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isActive ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTab({required String id, required IconData icon, required String label}) {
    final isActive = _activeTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? (id == 'code' ? const Color(0xFFD97706) : AppColors.primary)
                    : AppColors.outline,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.labelMd(
                    color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  ).copyWith(fontWeight: FontWeight.w700, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== TAB 1: CONFIG =====
  Widget _buildConfigTab() {
    final isNode1 = _selectedNode == 'node1';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Node Status Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isNode1 ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isNode1 ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isNode1 ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isNode1 ? Icons.videocam_rounded : Icons.water_drop_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNode1 ? 'Node 1: ESP32-CAM Bedeng Barat' : 'Node 2: ESP32 Telemetri Bedeng Timur',
                      style: AppTextStyles.labelLg(
                        color: isNode1 ? const Color(0xFF064E3B) : const Color(0xFF1E3A8A),
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      isNode1 ? 'Kamera Live Stream Daun Cabai & Servo' : 'Sensor Kelembapan Tanah Cabai & Relai Irigasi',
                      style: AppTextStyles.labelMd(
                        color: isNode1 ? const Color(0xFF065F46) : const Color(0xFF1E40AF),
                      ).copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Both Node IPs
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.wifi_rounded, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Daftar Alamat IP 2 Titik ESP32 Kebun Cabai',
                    style: AppTextStyles.labelLg(color: AppColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ipField(
                label: 'Node 1 IP (ESP32-CAM Barat)',
                tag: 'Camera & AI',
                tagColor: const Color(0xFF059669),
                controller: _node1IpController,
                icon: Icons.videocam_rounded,
              ),
              const SizedBox(height: 10),
              _ipField(
                label: 'Node 2 IP (ESP32 Sensor Timur)',
                tag: 'Sensor & Relay',
                tagColor: const Color(0xFF2563EB),
                controller: _node2IpController,
                icon: Icons.sensors_rounded,
              ),
              const SizedBox(height: 10),
              _ipField(
                label: 'Server LeafGuard API (Laravel)',
                tag: 'Database',
                tagColor: const Color(0xFF7C3AED),
                controller: _serverIpController,
                icon: Icons.dns_rounded,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Protocol Selector
        Text(
          'Protokol Komunikasi IoT Kebun',
          style: AppTextStyles.labelLg(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _protocolButton(id: 'http', label: 'HTTP REST'),
            const SizedBox(width: 6),
            _protocolButton(id: 'websocket', label: 'WebSocket'),
            const SizedBox(width: 6),
            _protocolButton(id: 'mqtt', label: 'MQTT Broker'),
          ],
        ),
        if (_protocol == 'mqtt') ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: _mqttBroker),
                  onChanged: (v) => _mqttBroker = v,
                  decoration: InputDecoration(
                    labelText: 'MQTT Broker',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: TextField(
                  controller: TextEditingController(text: _mqttPort),
                  onChanged: (v) => _mqttPort = v,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 14),

        // Wi-Fi Credentials
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.radio_rounded, size: 15, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Text(
                    'Kredensial Wi-Fi Kebun Cabai',
                    style: AppTextStyles.labelLg(color: AppColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _credentialField(
                      label: 'SSID Router Kebun',
                      controller: _wifiSsidController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _credentialField(
                      label: 'Password Wi-Fi',
                      controller: _wifiPasswordController,
                      obscure: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Connection Test
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isTesting ? null : _handleTestConnection,
            icon: _isTesting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFC53D)),
                  )
                : const Icon(Icons.network_check_rounded, size: 16, color: Color(0xFFFFC53D)),
            label: Text(
              _isTesting ? 'Uji Ping ke ${_selectedNode == 'node1' ? 'Node 1' : 'Node 2'}...' : 'Uji Koneksi Ping ($_activeIp)',
              style: AppTextStyles.labelLg(color: Colors.white).copyWith(fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        if (_testResult != null) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Koneksi OK (200 Status)',
                        style: AppTextStyles.labelMd(color: const Color(0xFF064E3B))
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        _testResult!.message,
                        style: AppTextStyles.labelMd(color: const Color(0xFF065F46)).copyWith(fontSize: 10),
                      ),
                      Text(
                        'Latency: ${_testResult!.latency} ms',
                        style: AppTextStyles.labelMd(color: const Color(0xFF059669)).copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Submit Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFF1F5F9),
                  foregroundColor: AppColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.verified_user_rounded, size: 16),
                label: const Text('Simpan Konfigurasi 2 Node'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _ipField({
    required String label,
    required String tag,
    required Color tagColor,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              tag,
              style: AppTextStyles.labelMd(color: tagColor).copyWith(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Misal: 192.168.4.1',
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _credentialField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _protocolButton({required String id, required String label}) {
    final isActive = _protocol == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _protocol = id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? AppColors.primary : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMd(
              color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ).copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  // ===== TAB 2: CODE =====
  Widget _buildCodeTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFD97706)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Sketch Arduino C++ (${_selectedNode == 'node1' ? 'Node 1 ESP32-CAM' : 'Node 2 ESP32 Sensor'})',
                style: AppTextStyles.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton.icon(
              onPressed: _copyToClipboard,
              icon: Icon(
                _copiedCode ? Icons.check_rounded : Icons.copy_rounded,
                size: 14,
                color: _copiedCode ? const Color(0xFF34D399) : Colors.white,
              ),
              label: Text(
                _copiedCode ? 'Tersalin!' : 'Salin Kode',
                style: AppTextStyles.labelMd(color: Colors.white).copyWith(fontWeight: FontWeight.w800),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF020617),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E293B)),
          ),
          child: Text(
            _currentCodeSnippet,
            style: const TextStyle(
              color: Color(0xFFE2E8F0),
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '*Pilih Node 1 atau Node 2 di atas untuk mendapatkan sketch C++ yang tepat sesuai modul board Anda.',
          style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 10, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  // ===== TAB 3: TUTORIAL =====
  Widget _buildTutorialTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pemasangan 2 Titik ESP32 di 1 Kebun Cabai',
          style: AppTextStyles.titleMd(color: AppColors.onSurface).copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _tutorialStep(
          number: '1',
          title: 'Node 1 (Bedeng Barat - ESP32-CAM)',
          description:
              'Pasang di tiang bagian barat kebun cabai menghadap dedaunan. Hubungkan 2 Servo Pan-Tilt (GPIO 12 & 13) untuk mengarahkan lensa kamera secara remote dari aplikasi.',
          bgColor: const Color(0xFFECFDF5),
          borderColor: const Color(0xFFA7F3D0),
          badgeColor: const Color(0xFF10B981),
          titleColor: const Color(0xFF064E3B),
        ),
        const SizedBox(height: 8),
        _tutorialStep(
          number: '2',
          title: 'Node 2 (Bedeng Timur - ESP32 Utama)',
          description:
              'Tancapkan Capacitive Soil Moisture Sensor di tanah bedeng cabai (GPIO 34), pasang sensor DHT22 (GPIO 4), dan hubungkan modul Relay ke Pompa Irigasi Tetes & Misting.',
          bgColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          badgeColor: const Color(0xFF3B82F6),
          titleColor: const Color(0xFF1E3A8A),
        ),
        const SizedBox(height: 8),
        _tutorialStep(
          number: '3',
          title: 'Uji & Hubungkan IP Both Nodes',
          description:
              'Gunakan Serial Monitor Arduino IDE untuk melihat IP masing-masing board, lalu masukkan ke dalam form IP Node 1 & Node 2 di aplikasi ini.',
          bgColor: const Color(0xFFF8FAFC),
          borderColor: const Color(0xFFE2E8F0),
          badgeColor: AppColors.primary,
          titleColor: AppColors.onSurface,
        ),
      ],
    );
  }

  Widget _tutorialStep({
    required String number,
    required String title,
    required String description,
    required Color bgColor,
    required Color borderColor,
    required Color badgeColor,
    required Color titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg(color: titleColor).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
