import 'dart:async';
import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../models/actuator_state_model.dart';
import '../models/sensor_data_model.dart';
import '../services/api_client.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_guide_dialog.dart';
import '../widgets/bmkg_weather_card.dart';
import '../widgets/esp_node_dialog.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_activity_item.dart';

class BerandaTabView extends StatefulWidget {
  final SensorDataModel sensorData;
  final List<ActivityLogModel> activities;
  final Function(int tabIndex) onNavigateToTab;

  const BerandaTabView({
    super.key,
    required this.sensorData,
    required this.activities,
    required this.onNavigateToTab,
  });

  @override
  State<BerandaTabView> createState() => _BerandaTabViewState();
}

class _BerandaTabViewState extends State<BerandaTabView> {
  bool _isOnline = false;
  int _todayScanCount = 0;

  SensorDataModel _sensorData = SensorDataModel.initial();
  ActuatorStateModel _actuatorState = ActuatorStateModel.initial();

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _sensorData = widget.sensorData;
    _fetchDashboardData();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchDashboardData());
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    final client = ApiClient();
    SensorDataModel? reading;
    ActuatorStateModel? actuators;
    int scanCount = 0;

    try {
      final results = await Future.wait([
        client.fetchLatestSensorReading(),
        client.fetchActuatorState(),
        client.fetchTodayScanCount(),
      ]);
      reading = results[0] as SensorDataModel?;
      actuators = results[1] as ActuatorStateModel?;
      scanCount = results[2] as int;
    } catch (_) {}

    // Fallback: fetch sensor langsung dari ESP32 jika Laravel offline
    if (reading == null) {
      final espData = await EspService.instance.fetchSensorFromEsp();
      if (espData != null) {
        reading = SensorDataModel(
          deviceId: 'Node 2: ESP32 Sensor',
          soilMoisture: (espData['soil'] as num?)?.toDouble() ?? 0,
          temperature: (espData['temperature'] as num?)?.toDouble() ?? 0,
          airHumidity: (espData['humidity'] as num?)?.toDouble() ?? 0,
          lightIntensity: 0,
          waterTankLevel: 0,
          soilPh: 0,
          batteryLevel: 0,
          leafDistance: (espData['distance'] as num?)?.toDouble() ?? 0,
          pumpStatus: (espData['pump'] as bool?) ?? false ? 'Aktif' : 'Standby',
          timestamp: 'Langsung dari ESP32',
        );
      }
    }

    if (!mounted) return;

    setState(() {
      if (reading != null) _sensorData = reading;
      if (actuators != null) _actuatorState = actuators;
      _todayScanCount = scanCount;
      _isOnline = reading != null || actuators != null;
    });
  }

  Widget _buildActuatorStatCard() {
    final active = <String>[
      if (_actuatorState.pumpActive) 'Pompa',
      if (_actuatorState.pesticideActive) 'Pestisida',
      if (_actuatorState.laserActive) 'Laser',
      if (_actuatorState.ledActive) 'LED',
    ];
    final anyActive = active.isNotEmpty;

    return QuickStatCard(
      icon: Icons.power_settings_new_rounded,
      iconBgColor: const Color(0xFFD6F2FE),
      iconGradient: const LinearGradient(
        colors: [Color(0xFFD6F2FE), Color(0xFFA8E8F9)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      iconColor: AppColors.primary,
      label: 'Aktuator Aktif',
      value: '${active.length}/4',
      subtitle: anyActive ? active.join(' • ') : 'Semua standby',
      subtitleColor: anyActive ? const Color(0xFF10B981) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final nodes = EspService.instance.nodes;
    final selectedNode = EspService.instance.selectedNode;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Greeting Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text('Halo, Petani!',
                              style: AppTextStyles.headlineSm(color: AppColors.primary)
                                  .copyWith(fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          _isOnline
                              ? Icons.cloud_done_rounded
                              : Icons.cloud_off_rounded,
                          size: 16,
                          color: _isOnline
                              ? AppColors.primary
                              : AppColors.outline,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                              _isOnline
                                  ? 'Sistem Terhubung & Stabil'
                                  : 'Menghubungkan ke server...',
                              style: AppTextStyles.labelMd(
                                  color: _isOnline
                                      ? AppColors.onSurfaceVariant
                                      : AppColors.outline)
                                  .copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ESP32 Node Chips
          _buildNodeChips(nodes, selectedNode),
          const SizedBox(height: 16),

          // Hero Section: Greenhouse Banner
          Container(
            height: 208,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1592417817098-8f3d6eb231fc?q=80&w=1000&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) => Container(
                        color: AppColors.primaryContainer,
                        child: const Center(
                            child: Icon(Icons.landscape, size: 64, color: AppColors.onPrimary)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF002B40).withValues(alpha: 0.50),
                            const Color(0xFF00537A).withValues(alpha: 0.96),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LOKASI UTAMA',
                            style: AppTextStyles.labelMd(color: AppColors.tertiaryFixed)
                                .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          selectedNode?.name ?? 'Belum ada ESP32',
                          style: AppTextStyles.headlineSm(color: AppColors.onPrimary)
                              .copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00537A), Color(0xFF0076AC)],
                            ),
                            border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.6)),
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isOnline
                                    ? Icons.check_circle_rounded
                                    : Icons.help_outline_rounded,
                                size: 16,
                                color: AppColors.tertiary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  _isOnline
                                      ? '${nodes.length} Node Aktif'
                                      : 'Menunggu koneksi...',
                                  style: AppTextStyles.labelMd(color: AppColors.tertiary)
                                      .copyWith(fontWeight: FontWeight.w800, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(height: 16),

          // Quick Stats Grid (2 kolom: Tanah & Suhu)
          Row(
            children: [
              Expanded(
                child: QuickStatCard(
                  icon: Icons.water_drop_outlined,
                  iconBgColor: const Color(0xFFE0F7FE),
                  iconGradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FE), Color(0xFFBAE6FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: AppColors.primary,
                  label: 'Kelembapan Tanah',
                  value: '${_sensorData.soilMoisture.round()}%',
                  subtitle: 'Optimal',
                  subtitleColor: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickStatCard(
                  icon: Icons.thermostat_rounded,
                  iconBgColor: const Color(0xFFFEF3C7),
                  iconGradient: const LinearGradient(
                    colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: const Color(0xFFD97706),
                  label: 'Suhu Udara',
                  value: '${_sensorData.temperature.round()}°C',
                  subtitle: 'Ideal 24-30°',
                  subtitleColor: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Quick Stats Baris 2 (Scan Hari Ini & Status Aktuator dari API)
          Row(
            children: [
              Expanded(
                child: QuickStatCard(
                  icon: Icons.document_scanner_rounded,
                  iconBgColor: const Color(0xFFFEE2E2),
                  iconGradient: const LinearGradient(
                    colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  iconColor: AppColors.error,
                  label: 'Scan Hari Ini',
                  value: '$_todayScanCount',
                  subtitle: _todayScanCount > 0
                      ? 'Hasil deteksi AI'
                      : 'Belum ada scan',
                  subtitleColor:
                      _todayScanCount > 0 ? const Color(0xFF10B981) : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildActuatorStatCard()),
            ],
          ),
          const SizedBox(height: 16),

          // Panduan Penggunaan Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFF3D6), Color(0xFFFFE7BA)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFF5A201).withValues(alpha: 0.50)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF5A201).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00537A), Color(0xFF0076AC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00537A).withValues(alpha: 0.30),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Aplikasi',
                        style: AppTextStyles.labelLg(color: const Color(0xFF633F00))
                            .copyWith(fontWeight: FontWeight.w900),
                      ),
                      Text(
                        'Cara koneksi ESP & memakai fitur',
                        style: AppTextStyles.labelMd(color: const Color(0xFF8A5A00))
                            .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => AppGuideDialog.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Baca', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // BMKG Weather Monitoring Widget
          const BmkgWeatherCard(),
          const SizedBox(height: 24),

          // Recent Activity List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Aktivitas Terakhir',
                    style: AppTextStyles.titleMd(color: AppColors.onSurface)
                        .copyWith(fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab(4), // Tab Riwayat
                child: Text('Lihat Semua',
                    style: AppTextStyles.labelLg(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ],
            ),
            child: Column(
              children: widget.activities.take(3).map((act) {
                return RecentActivityItem(
                  icon: act.type == 'watering'
                      ? Icons.water_drop
                      : act.type == 'scan_alert'
                          ? Icons.document_scanner_rounded
                          : Icons.thermostat,
                  iconColor: act.type == 'watering'
                      ? AppColors.primary
                      : act.type == 'scan_alert'
                          ? AppColors.error
                          : AppColors.secondary,
                  iconBgColor: act.type == 'watering'
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : act.type == 'scan_alert'
                          ? AppColors.error.withValues(alpha: 0.10)
                          : AppColors.secondary.withValues(alpha: 0.12),
                  title: act.title,
                  subtitle: '${act.subtitle} • ${act.timestamp}',
                  hasDivider: act != widget.activities.take(3).last,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Horizontal scrollable list of ESP32 node chips + add button.
  Widget _buildNodeChips(List<dynamic> nodes, dynamic selectedNode) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: nodes.length + 1, // +1 untuk tombol tambah
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          // Tombol tambah
          if (i == nodes.length) {
            return GestureDetector(
              onTap: () => EspNodeDialog.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'Tambah',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final node = nodes[i];
          final isSelected = node.id == (selectedNode?.id ?? '');
          return GestureDetector(
            onTap: () {
              EspService.instance.selectNode(node.id);
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF00537A), Color(0xFF0076AC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00537A).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.outlineVariant.withValues(alpha: 0.30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    node.type == 'camera'
                        ? Icons.videocam_rounded
                        : Icons.sensors_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    node.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
