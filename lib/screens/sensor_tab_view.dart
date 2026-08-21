import 'dart:async';
import 'package:flutter/material.dart';
import '../models/actuator_state_model.dart';
import '../models/sensor_data_model.dart';
import '../services/api_client.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';

class SensorTabView extends StatefulWidget {
  final SensorDataModel sensorData;
  final ActuatorStateModel actuatorState;
  final Function(SensorDataModel) onUpdateSensors;
  final Function(ActuatorStateModel) onUpdateActuators;

  const SensorTabView({
    super.key,
    required this.sensorData,
    required this.actuatorState,
    required this.onUpdateSensors,
    required this.onUpdateActuators,
  });

  @override
  State<SensorTabView> createState() => _SensorTabViewState();
}

class _SensorTabViewState extends State<SensorTabView> {
  String _selectedMetric = 'soil';
  bool _isLoading = false;
  String? _lastError;
  Timer? _autoRefreshTimer;

  final List<double> _soilTrend = [52, 54, 50, 48, 65, 62, 60, 62];
  final List<double> _tempTrend = [22, 23, 25, 29, 31, 28, 27, 28];
  final List<double> _humidityTrend = [80, 78, 75, 70, 68, 72, 76, 74];

  @override
  void initState() {
    super.initState();
    _fetchFromApi();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchFromApi());
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchFromApi() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _lastError = null; });

    try {
      final reading = await ApiClient().fetchLatestSensorReading();
      if (!mounted) return;

      if (reading != null) {
        widget.onUpdateSensors(reading);
        setState(() { _isLoading = false; _lastError = null; });
      } else {
        // Tidak ada data di server, tetap pakai data lokal
        setState(() { _isLoading = false; _lastError = null; });
      }

      final actuators = await ApiClient().fetchActuatorState();
      if (!mounted) return;
      if (actuators != null) {
        widget.onUpdateActuators(actuators);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _lastError = 'Gagal mengambil data dari server';
      });
    }
  }

  void _togglePump() {
    final nextState = !widget.actuatorState.pumpActive;
    final newState = widget.actuatorState.copyWith(pumpActive: nextState);
    widget.onUpdateActuators(newState);
    EspService.instance.toggleActuator('pump', nextState);
    ApiClient().updateActuatorState(newState);
  }

  void _togglePesticide() {
    final nextState = !widget.actuatorState.pesticideActive;
    final newState = widget.actuatorState.copyWith(pesticideActive: nextState);
    widget.onUpdateActuators(newState);
    EspService.instance.toggleActuator('pesticide', nextState);
    ApiClient().updateActuatorState(newState);
  }

  void _toggleLaser() {
    final nextState = !widget.actuatorState.laserActive;
    final newState = widget.actuatorState.copyWith(laserActive: nextState);
    widget.onUpdateActuators(newState);
    EspService.instance.toggleActuator('laser', nextState);
    ApiClient().updateActuatorState(newState);
  }

  void _toggleLed() {
    final nextState = !widget.actuatorState.ledActive;
    final newState = widget.actuatorState.copyWith(ledActive: nextState);
    widget.onUpdateActuators(newState);
    EspService.instance.toggleActuator('led', nextState);
    ApiClient().updateActuatorState(newState);
  }

  @override
  Widget build(BuildContext context) {
    final currentTrend = _selectedMetric == 'soil'
        ? _soilTrend
        : _selectedMetric == 'temp'
            ? _tempTrend
            : _humidityTrend;

    return RefreshIndicator(
      onRefresh: _fetchFromApi,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header & Refresh Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telemetri & Kontrol IoT',
                      style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                    ),
                    Text(
                      'Monitoring Sensor Real-time & Sakelar Aktuator',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _fetchFromApi,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _lastError != null
                        ? const Color(0xFFFEF2F2)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _lastError != null
                          ? const Color(0xFFFECACA)
                          : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _lastError != null
                                  ? Icons.cloud_off_rounded
                                  : Icons.cloud_done_rounded,
                              size: 16,
                              color: _lastError != null
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _lastError != null ? 'Offline' : 'Live',
                              style: AppTextStyles.labelMd(
                                color: _lastError != null
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF22C55E),
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sakelar Aktuator Center Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.power_settings_new_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'SAKELAR AKTUATOR GREENHOUSE',
                      style: AppTextStyles.labelMd(color: AppColors.primary)
                          .copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Row(
                  children: [
                    // Pompa Irigasi
                    Expanded(
                      child: _ActuatorTile(
                        title: 'Pompa Irigasi',
                        status: widget.actuatorState.pumpActive ? 'ON (Menyiram)' : 'Standby',
                        isActive: widget.actuatorState.pumpActive,
                        activeColor: const Color(0xFF0288D1),
                        onToggle: _togglePump,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Pompa Pestisida
                    Expanded(
                      child: _ActuatorTile(
                        title: 'Pompa Pestisida',
                        status: widget.actuatorState.pesticideActive ? 'ON (Menyemprot)' : 'Standby',
                        isActive: widget.actuatorState.pesticideActive,
                        activeColor: const Color(0xFF0288D1),
                        onToggle: _togglePesticide,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Laser Penunjuk
                    Expanded(
                      child: _ActuatorTile(
                        title: 'Laser Penunjuk',
                        status: widget.actuatorState.laserActive ? 'ON (Menyala)' : 'Off',
                        isActive: widget.actuatorState.laserActive,
                        activeColor: const Color(0xFF0288D1),
                        onToggle: _toggleLaser,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Lampu LED
                    Expanded(
                      child: _ActuatorTile(
                        title: 'Lampu LED',
                        status: widget.actuatorState.ledActive ? 'ON (Menyala)' : 'Off',
                        isActive: widget.actuatorState.ledActive,
                        activeColor: const Color(0xFF0288D1),
                        onToggle: _toggleLed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Laser (GPIO 15) & Lampu LED (GPIO 32) aktif pada code.ino. Pompa Irigasi & Pestisida tersedia untuk firmware berikutnya.',
                        style: TextStyle(fontSize: 10, color: AppColors.outline, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sensor Metrics Grid (2x2)
          Row(
            children: [
              // Kelembapan Tanah
              Expanded(
                child: _SensorMetricTile(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF0288D1),
                  label: 'Kelembapan Tanah',
                  value: '${widget.sensorData.soilMoisture.round()}%',
                  progress: widget.sensorData.soilMoisture / 100,
                  progressColor: const Color(0xFF0288D1),
                  status: 'GPIO 34 • Kalibrasi 3200/1500',
                ),
              ),
              const SizedBox(width: 8),
              // Suhu Udara
              Expanded(
                child: _SensorMetricTile(
                  icon: Icons.thermostat_rounded,
                  iconColor: const Color(0xFFF57C00),
                  label: 'Suhu Udara',
                  value: '${widget.sensorData.temperature.round()}°C',
                  progress: widget.sensorData.temperature / 40,
                  progressColor: const Color(0xFFF57C00),
                  status: 'DHT11/22 • GPIO 4',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Kelembapan Udara
              Expanded(
                child: _SensorMetricTile(
                  icon: Icons.air_rounded,
                  iconColor: const Color(0xFF00796B),
                  label: 'Kelembapan Udara',
                  value: '${widget.sensorData.airHumidity.round()}%',
                  progress: widget.sensorData.airHumidity / 100,
                  progressColor: const Color(0xFF00796B),
                  status: 'DHT11/22 • GPIO 4',
                ),
              ),
              const SizedBox(width: 8),
              // Jarak Daun (Ultrasonik)
              Expanded(
                child: _SensorMetricTile(
                  icon: Icons.straighten_rounded,
                  iconColor: const Color(0xFF7C3AED),
                  label: 'Jarak Daun ke Kamera',
                  value: '${widget.sensorData.leafDistance.round()} cm',
                  progress: widget.sensorData.leafDistance / 100,
                  progressColor: const Color(0xFF7C3AED),
                  status: 'HC-SR04 • TRIG 5 / ECHO 18',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grafik Tren 24 Jam Card
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
                    Row(
                      children: [
                        const Icon(Icons.show_chart_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Grafik Tren 24 Jam',
                          style: AppTextStyles.titleMd(color: AppColors.onSurface),
                        ),
                      ],
                    ),

                    // Metric Switcher Chips
                    Row(
                      children: [
                        _ChartTabChip(
                          label: 'K. Tanah',
                          isSelected: _selectedMetric == 'soil',
                          onTap: () => setState(() => _selectedMetric = 'soil'),
                        ),
                        const SizedBox(width: 4),
                        _ChartTabChip(
                          label: 'Suhu',
                          isSelected: _selectedMetric == 'temp',
                          onTap: () => setState(() => _selectedMetric = 'temp'),
                        ),
                        const SizedBox(width: 4),
                        _ChartTabChip(
                          label: 'K. Udara',
                          isSelected: _selectedMetric == 'humidity',
                          onTap: () => setState(() => _selectedMetric = 'humidity'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Sparkline Custom Painter
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _SparklinePainter(data: currentTrend),
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('00:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    Text('06:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    Text('12:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    Text('18:00', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                    Text('Sekarang', style: TextStyle(fontSize: 10, color: AppColors.outline)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // IoT Node Connectivity Status List
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wifi_rounded, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Status Dual Node ESP32 (Kebun Cabai)',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Node 1: ESP32-CAM
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Node 1: ESP32 Sensor (Bedeng)',
                              style: AppTextStyles.labelLg(color: AppColors.onSurface)
                                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              'IP: ${EspService.instance.espIp} • DHT, Soil, Ultrasonik',
                              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Aktif (30 FPS)',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Node 2: ESP32 Sensor
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: Color(0xFF4CAF50), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Node 2: ESP32-CAM (menyusul)',
                              style: AppTextStyles.labelLg(color: AppColors.onSurfaceVariant)
                                  .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            Text(
                              'ESP32-CAM belum terpasang. Akan aktif saat ditambahkan.',
                              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Telemetri OK',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _ActuatorTile extends StatelessWidget {
  final String title;
  final String status;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onToggle;

  const _ActuatorTile({
    required this.title,
    required this.status,
    required this.isActive,
    required this.activeColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? activeColor.withValues(alpha: 0.10) : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? activeColor.withValues(alpha: 0.40) : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg(color: AppColors.onSurface)
                      .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? activeColor : AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: (_) => onToggle(),
            activeTrackColor: activeColor,
          ),
        ],
      ),
    );
  }
}

class _SensorMetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final double progress;
  final Color progressColor;
  final String status;

  const _SensorMetricTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.progress,
    required this.progressColor,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 18, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineSm(color: AppColors.primary)
                .copyWith(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceContainerHigh,
              color: progressColor,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            status,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: progressColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ChartTabChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChartTabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;

  _SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (((data[i] - minVal) / range) * (size.height - 20) + 10);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill Gradient
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withValues(alpha: 0.25),
          AppColors.primary.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line Paint
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Points
    final pointPaint = Paint()..color = Colors.white;
    final pointBorderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final p in points) {
      canvas.drawCircle(p, 4, pointPaint);
      canvas.drawCircle(p, 4, pointBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => true;
}
