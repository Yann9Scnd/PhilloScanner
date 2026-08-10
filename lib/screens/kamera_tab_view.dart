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

  int _panAngle = 90;
  int _tiltAngle = 45;
  bool _flashOn = false;
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  String _streamResolution = 'SVGA (800x600)';
  String _ipAddress = EspService.instance.camIp;

  static const Map<String, String> _streamImages = {
    'center': 'https://images.unsplash.com/photo-1592417817098-8f3d6eb23659?auto=format&fit=crop&w=800&q=80',
    'left': 'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?auto=format&fit=crop&w=800&q=80',
    'right': 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?auto=format&fit=crop&w=800&q=80',
    'up': 'https://images.unsplash.com/photo-1588628566587-dbd176de5774?auto=format&fit=crop&w=800&q=80',
  };

  String get _activeStreamUrl {
    if (_panAngle < 60) return _streamImages['left']!;
    if (_panAngle > 120) return _streamImages['right']!;
    if (_tiltAngle > 65) return _streamImages['up']!;
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

  void _handlePanTilt(String direction, {String? positionLabel}) {
    setState(() {
      switch (direction) {
        case 'up':
          _tiltAngle = (_tiltAngle + 10).clamp(0, 90);
        case 'down':
          _tiltAngle = (_tiltAngle - 10).clamp(0, 90);
        case 'left':
          _panAngle = (_panAngle - 15).clamp(0, 180);
        case 'right':
          _panAngle = (_panAngle + 15).clamp(0, 180);
        case 'center':
          _panAngle = 90;
          _tiltAngle = 45;
      }
    });
    if (positionLabel != null) {
      _triggerToast('Posisi Kamera: $positionLabel');
    }
    _espService.sendServoCommand(direction);
  }

  void _handlePreset(int pan, int tilt, String label) {
    setState(() {
      _panAngle = pan;
      _tiltAngle = tilt;
    });
    _triggerToast('Arah Kamera: $label');
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
      deviceId: 'Node 1: ESP32-CAM (Pan-Tilt Bedeng Barat)',
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
                      'Monitoring Jarak Jauh & Servo Pan-Tilt Analog',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryContainer.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '30 FPS Live',
                      style: AppTextStyles.labelMd(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
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
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE STREAM',
                          style: AppTextStyles.labelMd(color: const Color(0xFF4CAF50))
                              .copyWith(fontWeight: FontWeight.w800, letterSpacing: 1),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '30 FPS • $_streamResolution',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _ipAddress,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.wifi_rounded, size: 14, color: Color(0xFF34D399)),
                      ],
                    ),
                  ),

                  // Video Canvas
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
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

                        // Center Crosshair Guide
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
                                  'Pan: $_panAngle°  Tilt: $_tiltAngle°',
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

                        // LED Flash Toggle
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
                        onPressed: _isCapturing || _isAnalyzing ? null : _captureAndAnalyze,
                        icon: _isAnalyzing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.camera_alt_rounded, size: 18),
                        label: Text(
                          _isAnalyzing
                              ? 'Menganalisis via Gemini AI...'
                              : 'Tangkap Foto & Analisa AI',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEAA13),
                          foregroundColor: const Color(0xFF0F172A),
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

          // Servo Pan-Tilt Control Pad
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
                            'Pengontrol Arah Kamera (Pan-Tilt Servo)',
                            style: AppTextStyles.titleMd(color: AppColors.onSurface),
                          ),
                          Text(
                            'Arahkan lensa kamera ESP32 secara real-time',
                            style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _handlePanTilt('center', positionLabel: 'Depan (Default)'),
                      icon: const Icon(Icons.restart_alt_rounded, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Analog D-Pad
                Center(
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$_panAngle°',
                                style: AppTextStyles.titleMd(color: AppColors.primary)
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'PAN',
                                style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                    .copyWith(fontSize: 9, letterSpacing: 1),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_tiltAngle°',
                                style: AppTextStyles.titleMd(color: AppColors.secondary)
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'TILT',
                                style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                    .copyWith(fontSize: 9, letterSpacing: 1),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _dPadButton(
                              icon: Icons.keyboard_arrow_up_rounded,
                              onTap: () => _handlePanTilt('up', positionLabel: 'Tilt Up'),
                              radius: const BorderRadius.vertical(top: Radius.circular(14)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _dPadButton(
                              icon: Icons.keyboard_arrow_down_rounded,
                              onTap: () => _handlePanTilt('down', positionLabel: 'Tilt Down'),
                              radius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _dPadButton(
                              icon: Icons.keyboard_arrow_left_rounded,
                              onTap: () => _handlePanTilt('left', positionLabel: 'Pan Kiri'),
                              radius: const BorderRadius.horizontal(left: Radius.circular(14)),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 8,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: _dPadButton(
                              icon: Icons.keyboard_arrow_right_rounded,
                              onTap: () => _handlePanTilt('right', positionLabel: 'Pan Kanan'),
                              radius: const BorderRadius.horizontal(right: Radius.circular(14)),
                            ),
                          ),
                        ),
                        // Center Joystick Ball
                        Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => _handlePanTilt('center', positionLabel: 'Center'),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.center_focus_weak_rounded,
                                      size: 18, color: Color(0xFFFFC53D)),
                                  Text(
                                    'CENTER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 7,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                      onTap: () => _handlePreset(40, 50, 'Bedeng Barat (Cabai Keriting)'),
                    ),
                    _presetChip(
                      label: 'Bedeng Timur (Cabai Rawit)',
                      onTap: () => _handlePreset(140, 45, 'Bedeng Timur (Cabai Rawit)'),
                    ),
                    _presetChip(
                      label: 'Kanopi Daun Cabai',
                      onTap: () => _handlePreset(90, 70, 'Kanopi Daun Cabai'),
                    ),
                    _presetChip(
                      label: 'Pintu Kebun Cabai',
                      onTap: () => _handlePreset(180, 20, 'Pintu Kebun Cabai'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stream Config & ESP32 Node Info
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
                    const Icon(Icons.settings_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pengaturan Koneksi ESP32-CAM',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // IP Address
                Text(
                  'IP Address ESP32 Stream:',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: _ipAddress)
                    ..selection = TextSelection.collapsed(offset: _ipAddress.length),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    prefixIcon: const Icon(Icons.router_rounded, size: 18),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  onChanged: (value) {
                    _ipAddress = value.trim();
                    _espService.camIp = value.trim();
                  },
                ),
                const SizedBox(height: 12),

                // Resolution Dropdown
                Text(
                  'Kualitas Resolusi Gambar:',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _streamResolution,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      items: const [
                        DropdownMenuItem(
                          value: 'VGA (640x480)',
                          child: Text('VGA (640x480) - Cepat', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'SVGA (800x600)',
                          child: Text('SVGA (800x600) - Standar', style: TextStyle(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'UXGA (1600x1200)',
                          child: Text('UXGA (1600x1200) - HD', style: TextStyle(fontSize: 13)),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _streamResolution = value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dPadButton({
    required IconData icon,
    required VoidCallback onTap,
    required BorderRadius radius,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
          border: Border.all(color: const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(icon, size: 24, color: AppColors.primary),
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
