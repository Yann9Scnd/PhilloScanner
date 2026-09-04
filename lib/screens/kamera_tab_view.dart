import 'dart:math' show cos, sin;
import 'package:flutter/material.dart';
import '../models/scan_result_model.dart';
import '../services/ai_service.dart';
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
  int _camTiltAngle = 90;
  bool _flashOn = false;
  int _armViewTab = 0; // 0 = Simulasi DOF, 1 = 2D Pose
  bool _isCapturing = false;
  bool _isAnalyzing = false;
  static const bool _isCameraOnline = false;

  // Stream webcam real dari ESP32-CAM (MJPEG). Tidak ada gambar Unsplash dummy.
  String get _activeStreamUrl => _espService.streamUrl;

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
      camTilt: _camTiltAngle,
    );
    if (!ok && mounted) {
      _triggerToast('Gagal terhubung ke server lengan (${_espService.armServerUrl})');
    }
  }

  void _onCamTiltChanged(double value) {
    setState(() => _camTiltAngle = value.round());
    _sendArmServo();
  }

  void _adjustAngle(String servo, int delta) {
    setState(() {
      switch (servo) {
        case 'base':
          _baseAngle = (_baseAngle + delta).clamp(0, 180);
        case 'shoulder':
          _shoulderAngle = (_shoulderAngle + delta).clamp(0, 180);
        case 'elbow':
          _elbowAngle = (_elbowAngle + delta).clamp(0, 180);
        case 'camtilt':
          _camTiltAngle = (_camTiltAngle + delta).clamp(0, 180);
      }
    });
    _sendArmServo();
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

  void _handlePreset(int base, int shoulder, int elbow, String label, {int camTilt = 90}) {
    setState(() {
      _baseAngle = base;
      _shoulderAngle = shoulder;
      _elbowAngle = elbow;
      _camTiltAngle = camTilt;
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
    _triggerToast('Foto berhasil ditangkap dari ESP32-CAM! Menganalisis...');

    ScanResultModel newScan;

    try {
      newScan = await AiService.instance.analyzeLeaf(
        imageUrl: _activeStreamUrl,
        deviceSource: 'Node 1: ESP32-CAM (Bedeng Barat)',
        sector: 'Greenhouse Sektor A',
      );
    } catch (e) {
      if (mounted) {
        setState(() { _isAnalyzing = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    if (!mounted) return;
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
                                  'Base: $_baseAngle°  Shldr: $_shoulderAngle°  Elbow: $_elbowAngle°  Cam: $_camTiltAngle°',
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

          // ── Kendali Lengan Robot (4 Servo) ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kendali Lengan Robot',
                              style: AppTextStyles.titleMd(color: AppColors.onSurface),
                            ),
                            Text(
                              'Visualisasi orientasi mekanis & kalibrasi sudut',
                              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '4 Servo',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _baseAngle = 90;
                            _shoulderAngle = 90;
                            _elbowAngle = 90;
                            _camTiltAngle = 90;
                          });
                          _triggerToast('Lengan: Posisi Tengah (Default)');
                          _sendArmServo();
                        },
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        icon: const Icon(Icons.restart_alt_rounded, size: 15),
                        label: const Text('Reset', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // ── Body: Visualisasi kiri + kontrol kanan ──────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // LEFT: Arm Visualizer panel
                      Expanded(
                        flex: 5,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              // Tab selector
                              Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                                child: Row(
                                  children: [
                                    _ArmViewTab(
                                      label: 'Simulasi DOF',
                                      selected: _armViewTab == 0,
                                      onTap: () => setState(() => _armViewTab = 0),
                                    ),
                                    const SizedBox(width: 4),
                                    _ArmViewTab(
                                      label: '2D Pose',
                                      selected: _armViewTab == 1,
                                      onTap: () => setState(() => _armViewTab = 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Arm canvas
                              SizedBox(
                                height: 180,
                                child: CustomPaint(
                                  painter: _ArmPainter(
                                    baseAngle: _baseAngle,
                                    shoulderAngle: _shoulderAngle,
                                    elbowAngle: _elbowAngle,
                                    camTiltAngle: _camTiltAngle,
                                    mode: _armViewTab,
                                  ),
                                  size: const Size(double.infinity, 180),
                                ),
                              ),
                              // Angle summary bottom strip
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: const BoxDecoration(
                                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 2,
                                  children: [
                                    _angleBadge('Base', _baseAngle, const Color(0xFF0288D1)),
                                    _angleBadge('Shld', _shoulderAngle, const Color(0xFFF57C00)),
                                    _angleBadge('Elb', _elbowAngle, const Color(0xFF7C3AED)),
                                    _angleBadge('Cam', _camTiltAngle, const Color(0xFF059669)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // RIGHT: 4 servo controls
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            _ServoControlRow(
                              label: 'Base (M1)',
                              shortKey: 'B',
                              color: const Color(0xFF0288D1),
                              angle: _baseAngle,
                              onDecrement: () => _adjustAngle('base', -5),
                              onIncrement: () => _adjustAngle('base', 5),
                            ),
                            const SizedBox(height: 6),
                            _ServoControlRow(
                              label: 'Shoulder (M2)',
                              shortKey: 'S',
                              color: const Color(0xFFF57C00),
                              angle: _shoulderAngle,
                              onDecrement: () => _adjustAngle('shoulder', -5),
                              onIncrement: () => _adjustAngle('shoulder', 5),
                            ),
                            const SizedBox(height: 6),
                            _ServoControlRow(
                              label: 'Elbow (M3)',
                              shortKey: 'E',
                              color: const Color(0xFF7C3AED),
                              angle: _elbowAngle,
                              onDecrement: () => _adjustAngle('elbow', -5),
                              onIncrement: () => _adjustAngle('elbow', 5),
                            ),
                            const SizedBox(height: 6),
                            _ServoControlRow(
                              label: 'Kamera Tilt (M4)',
                              shortKey: 'C',
                              color: const Color(0xFF059669),
                              angle: _camTiltAngle,
                              onDecrement: () => _adjustAngle('camtilt', -5),
                              onIncrement: () => _adjustAngle('camtilt', 5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Slider section ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServoSlider(
                        label: 'Base',
                        subtitle: 'Rotasi horizontal lengan',
                        icon: Icons.sync_rounded,
                        color: const Color(0xFF0288D1),
                        value: _baseAngle,
                        onChanged: _onBaseChanged,
                      ),
                      const SizedBox(height: 8),
                      _ServoSlider(
                        label: 'Shoulder',
                        subtitle: 'Naik & turun bagian atas lengan',
                        icon: Icons.vertical_align_center_rounded,
                        color: const Color(0xFFF57C00),
                        value: _shoulderAngle,
                        onChanged: _onShoulderChanged,
                      ),
                      const SizedBox(height: 8),
                      _ServoSlider(
                        label: 'Elbow',
                        subtitle: 'Menekuk jangkauan ke daun',
                        icon: Icons.architecture_rounded,
                        color: const Color(0xFF7C3AED),
                        value: _elbowAngle,
                        onChanged: _onElbowChanged,
                      ),
                      const SizedBox(height: 8),
                      _ServoSlider(
                        label: 'Kamera Tilt',
                        subtitle: 'Kemiringan lensa kamera',
                        icon: Icons.videocam_rounded,
                        color: const Color(0xFF059669),
                        value: _camTiltAngle,
                        onChanged: _onCamTiltChanged,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Preset chips ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            onTap: () => _handlePreset(40, 50, 60, 'Bedeng Barat (Cabai Keriting)', camTilt: 70),
                          ),
                          _presetChip(
                            label: 'Bedeng Timur (Cabai Rawit)',
                            onTap: () => _handlePreset(140, 45, 55, 'Bedeng Timur (Cabai Rawit)', camTilt: 80),
                          ),
                          _presetChip(
                            label: 'Kanopi Daun Cabai',
                            onTap: () => _handlePreset(90, 70, 45, 'Kanopi Daun Cabai', camTilt: 60),
                          ),
                          _presetChip(
                            label: 'Pintu Kebun Cabai',
                            onTap: () => _handlePreset(180, 30, 40, 'Pintu Kebun Cabai', camTilt: 90),
                          ),
                        ],
                      ),
                    ],
                  ),
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

// ── Helper widgets ────────────────────────────────────────────────────────

Widget _angleBadge(String label, int angle, Color color) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: '$label: ',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
        TextSpan(
          text: '$angle°',
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _ArmViewTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ArmViewTab({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0F172A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ServoControlRow extends StatelessWidget {
  final String label;
  final String shortKey;
  final Color color;
  final int angle;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _ServoControlRow({
    required this.label,
    required this.shortKey,
    required this.color,
    required this.angle,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$angle°',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              _CtrlBtn(
                icon: Icons.chevron_left_rounded,
                color: color,
                onTap: onDecrement,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shortKey,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              _CtrlBtn(
                icon: Icons.chevron_right_rounded,
                color: color,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CtrlBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

// ── 2D Arm Painter ──────────────────────────────────────────────────────────
class _ArmPainter extends CustomPainter {
  final int baseAngle;      // horizontal rotation (visual: left/right tilt)
  final int shoulderAngle;  // upper arm elevation
  final int elbowAngle;     // forearm bend
  final int camTiltAngle;   // camera tilt
  final int mode;           // 0=DOF, 1=2DPose

  _ArmPainter({
    required this.baseAngle,
    required this.shoulderAngle,
    required this.elbowAngle,
    required this.camTiltAngle,
    required this.mode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.42;
    final cy = size.height * 0.84;
    final arm1Len = size.height * 0.30;
    final arm2Len = size.height * 0.28;
    final arm3Len = size.height * 0.14;

    // Convert angles to radians, mapping 0-180° servo to visual angles
    // Shoulder: 90° = straight up (-π/2), 0° = forward (0), 180° = backward (-π)
    final shoulderRad = _lerpAngle(shoulderAngle, 175.0, -10.0);
    // Elbow: relative to upper arm
    final elbowRad = _lerpAngle(elbowAngle, 20.0, 160.0);
    // CamTilt: relative to forearm
    final camRad = _lerpAngle(camTiltAngle, -80.0, 80.0);

    // Joint positions (2D side-view projection)
    final base = Offset(cx, cy);

    // Upper arm
    final shoulderEnd = Offset(
      base.dx + arm1Len * cos(shoulderRad),
      base.dy + arm1Len * sin(shoulderRad),
    );

    // Forearm — angle relative to upper arm
    final forearmAngle = shoulderRad + (elbowRad - 3.14159 / 2);
    final elbowEnd = Offset(
      shoulderEnd.dx + arm2Len * cos(forearmAngle),
      shoulderEnd.dy + arm2Len * sin(forearmAngle),
    );

    // Camera mount
    final camAngle = forearmAngle + camRad;
    final camEnd = Offset(
      elbowEnd.dx + arm3Len * cos(camAngle),
      elbowEnd.dy + arm3Len * sin(camAngle),
    );

    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // ── Draw shadow ───────────────────────────────────────────────────────
    for (final pts in [
      [base, shoulderEnd],
      [shoulderEnd, elbowEnd],
      [elbowEnd, camEnd],
    ]) {
      canvas.drawLine(
        pts[0].translate(2, 2),
        pts[1].translate(2, 2),
        shadowPaint,
      );
    }

    // ── Segment colors ────────────────────────────────────────────────────
    final colors = [
      const Color(0xFF0F172A),   // upper arm (dark)
      const Color(0xFF7C3AED),   // forearm (purple)
      const Color(0xFF059669),   // cam arm (green)
    ];
    final thicknesses = [10.0, 8.0, 6.0];
    final segments = [
      [base, shoulderEnd],
      [shoulderEnd, elbowEnd],
      [elbowEnd, camEnd],
    ];

    for (int i = 0; i < segments.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..strokeWidth = thicknesses[i]
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(segments[i][0], segments[i][1], paint);
    }

    // ── Joints ────────────────────────────────────────────────────────────
    _drawJoint(canvas, base, 10, const Color(0xFF0F172A), const Color(0xFF94A3B8), label: 'BASE');
    _drawJoint(canvas, shoulderEnd, 8, const Color(0xFFF57C00), Colors.white);
    _drawJoint(canvas, elbowEnd, 7, const Color(0xFF7C3AED), Colors.white);

    // Camera icon at camEnd
    _drawCamera(canvas, camEnd, camAngle);

    // ── Ground platform ───────────────────────────────────────────────────
    final groundPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 24, cy),
      Offset(cx + 24, cy),
      groundPaint,
    );
    // Hatch lines below
    final hatchPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.5;
    for (int i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(cx + i * 7.0, cy + 2),
        Offset(cx + i * 7.0 - 6, cy + 10),
        hatchPaint,
      );
    }

    // ── DOF mode: draw arc guides ─────────────────────────────────────────
    if (mode == 0) {
      final arcPaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: base, radius: arm1Len),
        -3.14159,
        3.14159,
        false,
        arcPaint,
      );
      canvas.drawArc(
        Rect.fromCircle(center: shoulderEnd, radius: arm2Len * 0.6),
        -3.14159,
        3.14159,
        false,
        arcPaint..color = const Color(0xFFEDE9FE),
      );
    }
  }

  double _lerpAngle(int servo, double degFrom, double degTo) {
    final t = servo / 180.0;
    final deg = degFrom + t * (degTo - degFrom);
    return deg * 3.14159 / 180.0;
  }

  void _drawJoint(Canvas canvas, Offset center, double radius, Color fill, Color border,
      {String? label}) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = border,
    );
    canvas.drawCircle(
      center,
      radius - 2,
      Paint()..color = fill,
    );
    if (label != null) {
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, center.translate(-tp.width / 2, -tp.height - radius + 2));
    }
  }

  void _drawCamera(Canvas canvas, Offset pos, double angle) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Camera body
    final bodyPaint = Paint()..color = const Color(0xFF0F172A);
    final bodyRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-10, -6, 20, 12),
      const Radius.circular(3),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // Lens
    canvas.drawCircle(
      const Offset(5, 0),
      4,
      Paint()..color = const Color(0xFF38BDF8),
    );
    canvas.drawCircle(
      const Offset(5, 0),
      2.5,
      Paint()..color = const Color(0xFF0EA5E9),
    );
    canvas.drawCircle(
      const Offset(5, 0),
      1,
      Paint()..color = Colors.white,
    );

    // Tilt indicator dot
    canvas.drawCircle(
      const Offset(0, 0),
      2.5,
      Paint()..color = const Color(0xFF059669),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ArmPainter old) =>
      old.baseAngle != baseAngle ||
      old.shoulderAngle != shoulderAngle ||
      old.elbowAngle != elbowAngle ||
      old.camTiltAngle != camTiltAngle ||
      old.mode != mode;
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
