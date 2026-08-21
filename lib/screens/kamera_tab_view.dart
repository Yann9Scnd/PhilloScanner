import 'package:flutter/material.dart';
import '../models/scan_result_model.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';
import 'detail_scan_screen.dart';

class KameraTabView extends StatefulWidget {
  final Function(ScanResultModel)? onCaptureForAi;

  const KameraTabView({super.key, this.onCaptureForAi});

  @override
  State<KameraTabView> createState() => _KameraTabViewState();
}

class _KameraTabViewState extends State<KameraTabView> {
  final EspService _espService = EspService.instance;

  int _baseAngle = 90;
  int _shoulderAngle = 90;
  int _elbowAngle = 90;
  bool _flashOn = false;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  static const bool _isCameraOnline = false;

  static const Map<String, String> _streamImages = {
    'center': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb23659?auto=format&fit=crop&w=800&q=80',
    'left': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
    'right': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=800&q=80',
  };

  String get _activeStreamUrl {
    if (_baseAngle < 60) return _streamImages['left']!;
    if (_baseAngle > 120) return _streamImages['right']!;
    return _streamImages['center']!;
  }

  void _triggerToast(String message, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.info_rounded,
              color: success ? const Color(0xFF34D399) : const Color(0xFFFFD54F),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _sendArmServo() async {
    final ok = await _espService.setArmServo(
      base: _baseAngle,
      shoulder: _shoulderAngle,
      elbow: _elbowAngle,
    );
    if (!ok && mounted) {
      _triggerToast('Gagal terhubung ke server lengan (${_espService.armServerUrl})');
    }
  }

  void _onBaseChanged(double value) {
    setState(() => _baseAngle = value.round());
    _sendArmServo();
  }

  void _onShoulderChanged(double value) {
    setState(() => _shoulderAngle = value.round());
    _sendArmServo();
  }

  void _onElbowChanged(double value) {
    setState(() => _elbowAngle = value.round());
    _sendArmServo();
  }

  void _handlePreset(int base, int shoulder, int elbow, String label) {
    setState(() {
      _baseAngle = base;
      _shoulderAngle = shoulder;
      _elbowAngle = elbow;
    });
    _triggerToast('Lengan: $label');
    _sendArmServo();
  }

  Future<void> _captureAndAnalyze() async {
    setState(() {
      _isCapturing = true;
    });
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      _isCapturing = false;
      _isAnalyzing = true;
    });
    _triggerToast('Foto berhasil ditangkap dari ESP32-CAM! Menganalisis via Gemini AI...');

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    final newScan = ScanResultModel(
      deviceId: 'Node 1: ESP32-CAM (Bedeng Barat)',
      imageUrl: _activeStreamUrl,
      diseaseName: 'Bercak Daun Cercospora',
      scientificName: 'Cercospora capsici',
      severity: 'Sedang',
      confidence: 94,
      timestamp: 'Baru saja',
      soilMoisture: '64%',
      sector: 'Greenhouse Sektor A',
      temperatureAtScan: 27.5,
      aiRecommendations: [
        'Semprotkan bio-fungisida tembaga hidroksida pada permukaan bawah daun cabai pada pagi hari.',
        'Pangkas daun cabai tua di area bawah yang bersentuhan dengan tanah atau mulsa.',
        'Nyalakan kipas ventilasi lewat Node 2 ESP32 untuk menurunkan kelembapan udara mikro.',
      ],
    );

    setState(() {
      _isAnalyzing = false;
    });

    widget.onCaptureForAi?.call(newScan);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailScanScreen(scan: newScan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kontrol Kamera ESP32-CAM',
                      style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                    ),
                    Text(
                      'Monitoring Jarak Jauh & Kendali Lengan Robot (3 Servo)',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCameraOnline
                      ? AppColors.tertiaryContainer.withValues(alpha: 0.20)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isCameraOnline ? const Color(0xFF4CAF50) : const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCameraOnline ? '30 FPS Live' : 'Offline',
                      style: TextStyle(
                        color: _isCameraOnline ? AppColors.primary : const Color(0xFFEF4444),
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Live Video Stream View Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Stream Top Status Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isCameraOnline
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isCameraOnline ? 'LIVE STREAM' : 'CAMERA OFFLINE',
                          style: TextStyle(
                            color: _isCameraOnline
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _isCameraOnline ? '30 FPS • SVGA' : 'Menyusul',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          EspService.instance.espIp,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.wifi_rounded,
                          size: 14,
                          color: _isCameraOnline
                              ? const Color(0xFF34D399)
                              : const Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),

                  // Video Canvas
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background
                        if (!_isCameraOnline)
                          Container(
                            color: const Color(0xFF0F172A),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videocam_off_rounded,
                                    size: 48,
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'ESP32-CAM Belum Terpasang',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.50),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Sambungkan ESP32-CAM untuk melihat live stream',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.30),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Image.network(
                            _activeStreamUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, e, st) => const Center(
                              child: Icon(Icons.videocam_off_rounded, size: 48, color: Colors.white54),
                            ),
                          ),

                        // Flash Effect Overlay
                        if (_flashOn)
                          Positioned.fill(
                            child: Container(color: const Color(0xFFFFF3C4).withValues(alpha: 0.25)),
                          ),

                        // Overlay Gradient
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.30),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.50),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Center Crosshair Guide (only when camera online)
                        if (_isCameraOnline) ...[
                          Center(
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.50)),
                              ),
                              child: Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Center(
                            child: SizedBox(
                              width: 160,
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Color(0x804CAF50), height: 1)),
                                ],
                              ),
                            ),
                          ),
                          const Center(
                            child: SizedBox(
                              height: 160,
                              child: Column(
                                children: [
                                  Expanded(child: VerticalDivider(color: Color(0x804CAF50), width: 1)),
                                ],
                              ),
                            ),
                          ),
                        ],

                        // Angle Overlay Info Badge
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.explore_rounded, size: 14, color: Color(0xFFFFC53D)),
                                const SizedBox(width: 6),
                                Text(
                                  'Base: $_baseAngle°  Shoulder: $_shoulderAngle°  Elbow: $_elbowAngle°',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // LED Flash Toggle (only when online)
                        if (_isCameraOnline)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _flashOn = !_flashOn);
                                _triggerToast(
                                  _flashOn ? 'Lampu Flash ESP32 Dinyalakan' : 'Lampu Flash ESP32 Dimatikan',
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _flashOn
                                      ? const Color(0xFFFFC53D)
                                      : Colors.black.withValues(alpha: 0.70),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_rounded,
                                      size: 14,
                                      color: _flashOn ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _flashOn ? 'LED FLASH ON' : 'LED FLASH',
                                      style: TextStyle(
                                        color: _flashOn ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Flash Capture Animation
                        if (_isCapturing)
                          Positioned.fill(
                            child: AnimatedOpacity(
                              opacity: 1,
                              duration: const Duration(milliseconds: 300),
                              child: Container(color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Capture Action Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF0F172A),
                    child: SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: !_isCameraOnline || _isCapturing || _isAnalyzing ? null : _captureAndAnalyze,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Icon(
                                _isCameraOnline ? Icons.camera_alt_rounded : Icons.videocam_off_rounded,
                                size: 18,
                              ),
                        label: Text(
                          !_isCameraOnline
                              ? 'Kamera Tidak Terhubung'
                              : _isAnalyzing
                                  ? 'Menganalisis via Gemini AI...'
                                  : 'Tangkap Foto & Analisa AI',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isCameraOnline
                              ? const Color(0xFFFEAA13)
                              : const Color(0xFF475569),
                          foregroundColor: _isCameraOnline
                              ? const Color(0xFF0F172A)
                              : Colors.white.withValues(alpha: 0.6),
                          disabledBackgroundColor: const Color(0xFF475569),
                          disabledForegroundColor: Colors.white.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Servo Lengan Robot (Base / Shoulder / Elbow)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kendali Lengan Robot (3 Servo)',
                            style: AppTextStyles.titleMd(color: AppColors.onSurface),
                          ),
                          Text(
                            'Geser slider untuk menggerakkan Base, Shoulder & Elbow secara real-time',
                            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _baseAngle = 90;
                          _shoulderAngle = 90;
                          _elbowAngle = 90;
                        });
                        _triggerToast('Lengan: Posisi Tengah (Default)');
                        _sendArmServo();
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Slider Base (rotasi horizontal)
                _ServoSlider(
                  label: 'Base',
                  subtitle: 'Rotasi horizontal lengan',
                  icon: Icons.sync_rounded,
                  color: const Color(0xFF0288D1),
                  value: _baseAngle,
                  onChanged: _onBaseChanged,
                ),
                const SizedBox(height: 10),

                // Slider Shoulder (angkat/turun)
                _ServoSlider(
                  label: 'Shoulder',
                  subtitle: 'Naik & turun bagian atas lengan',
                  icon: Icons.vertical_align_center_rounded,
                  color: const Color(0xFFF57C00),
                  value: _shoulderAngle,
                  onChanged: _onShoulderChanged,
                ),
                const SizedBox(height: 10),

                // Slider Elbow (tekuk jangkauan)
                _ServoSlider(
                  label: 'Elbow',
                  subtitle: 'Menekuk jangkauan ke daun',
                  icon: Icons.architecture_rounded,
                  color: const Color(0xFF7C3AED),
                  value: _elbowAngle,
                  onChanged: _onElbowChanged,
                ),
                const SizedBox(height: 16),

                // Quick Angle Presets
                Text(
                  'Preset Sudut Tanaman Cabai:',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _presetChip(
                      label: 'Bedeng Barat (Cabai Keriting)',
                      onTap: () => _handlePreset(40, 50, 60, 'Bedeng Barat (Cabai Keriting)'),
                    ),
                    _presetChip(
                      label: 'Bedeng Timur (Cabai Rawit)',
                      onTap: () => _handlePreset(140, 45, 55, 'Bedeng Timur (Cabai Rawit)'),
                    ),
                    _presetChip(
                      label: 'Kanopi Daun Cabai',
                      onTap: () => _handlePreset(90, 70, 45, 'Kanopi Daun Cabai'),
                    ),
                    _presetChip(
                      label: 'Pintu Kebun Cabai',
                      onTap: () => _handlePreset(180, 30, 40, 'Pintu Kebun Cabai'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ESP32-CAM Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: _isCameraOnline ? AppColors.primary : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Status ESP32-CAM',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _isCameraOnline
                        ? const Color(0xFFF0FDF4)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isCameraOnline
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isCameraOnline
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 20,
                        color: _isCameraOnline
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _isCameraOnline
                              ? 'ESP32-CAM terhubung. Live stream aktif.'
                              : 'ESP32-CAM belum terpasang. Fitur kamera & AI akan tersedia setelah ESP32-CAM terhubung.',
                          style: TextStyle(
                            color: _isCameraOnline
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Kapan ESP32-CAM tersedia?',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'ESP32-CAM akan mengirimkan live stream video ke aplikasi ini. '
                  'Kamu bisa mengontrol lengan robot dan mengambil foto daun untuk dianalisis dengan AI.',
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetChip({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.my_location_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServoSlider extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int value;
  final ValueChanged<double> onChanged;

  const _ServoSlider({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '$value°',
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: color,
                    thumbColor: color,
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    overlayColor: color.withValues(alpha: 0.12),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    min: 0,
                    max: 180,
                    value: value.toDouble(),
                    onChanged: onChanged,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
