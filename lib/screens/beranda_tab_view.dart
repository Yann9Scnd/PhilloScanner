import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../models/actuator_state_model.dart';
import '../models/sensor_data_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bmkg_weather_card.dart';
import '../widgets/esp_config_dialog.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_activity_item.dart';

class BerandaTabView extends StatefulWidget {
  final SensorDataModel sensorData;
  final ActuatorStateModel actuatorState;
  final List<ActivityLogModel> activities;
  final Function(int tabIndex) onNavigateToTab;
  final VoidCallback? onTogglePumpMode;

  const BerandaTabView({
    super.key,
    required this.sensorData,
    required this.actuatorState,
    required this.activities,
    required this.onNavigateToTab,
    this.onTogglePumpMode,
  });

  @override
  State<BerandaTabView> createState() => _BerandaTabViewState();
}

class _BerandaTabViewState extends State<BerandaTabView> {
  String _selectedSector = 'Kebun Cabai Presisi (2 Node ESP32)';

  final List<String> _sectors = [
    'Kebun Cabai Presisi (2 Node ESP32)',
    'Sektor A - Bedeng Barat',
    'Sektor B - Bedeng Timur',
  ];

  @override
  Widget build(BuildContext context) {
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
                              style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text('Sistem Terhubung & Stabil',
                              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Sector Switcher Dropdown
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.30)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSector,
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      style: AppTextStyles.labelMd(color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                      items: _sectors.map((s) {
                        return DropdownMenuItem<String>(
                          value: s,
                          child: Text(s, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedSector = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Section: Greenhouse Banner
          Container(
            height: 208,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
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
                            AppColors.primary.withValues(alpha: 0.40),
                            AppColors.primary.withValues(alpha: 0.95),
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
                            style: AppTextStyles.labelMd(color: AppColors.primaryFixedDim)
                                .copyWith(letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(_selectedSector,
                            style: AppTextStyles.headlineSm(color: AppColors.onPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.tertiaryContainer.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 16, color: AppColors.tertiaryFixed),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('Kondisi Ideal (650 Tanaman Cabai)',
                                    style: AppTextStyles.labelMd(color: AppColors.tertiaryFixed)
                                        .copyWith(fontWeight: FontWeight.w500, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
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

          // Quick Stats Grid (3 columns)
          Row(
            children: [
              Expanded(
                child: QuickStatCard(
                  icon: Icons.water_drop_outlined,
                  iconBgColor: const Color(0x1A003B58),
                  iconColor: AppColors.primary,
                  label: 'Tanah',
                  value: '${widget.sensorData.soilMoisture.round()}%',
                  subtitle: 'Optimal',
                  subtitleColor: const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickStatCard(
                  icon: Icons.thermostat,
                  iconBgColor: const Color(0x1A835500),
                  iconColor: AppColors.secondary,
                  label: 'Suhu',
                  value: '${widget.sensorData.temperature.round()}°C',
                  subtitle: 'Ideal 24-30°',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickStatCard(
                  icon: Icons.settings_input_component,
                  iconBgColor: widget.actuatorState.pumpAutoMode
                      ? const Color(0x33F59E0B)
                      : const Color(0x3304A96B),
                  iconColor: widget.actuatorState.pumpAutoMode
                      ? const Color(0xFFB45309)
                      : const Color(0xFF059669),
                  label: 'Pompa',
                  value: widget.actuatorState.pumpAutoMode ? 'Oto' : 'Man',
                  subtitle: widget.actuatorState.pumpAutoMode
                      ? 'Sensor Active'
                      : 'Manual ON',
                  subtitleColor: widget.actuatorState.pumpAutoMode
                      ? const Color(0xFFB45309)
                      : const Color(0xFF059669),
                  onTap: widget.onTogglePumpMode,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ESP32 Hardware Hub Config Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.router_rounded, color: Colors.amberAccent, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hubungkan Modul ESP32',
                        style: AppTextStyles.labelLg(color: Colors.white)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Input IP & Wi-Fi Node Hardware',
                        style: AppTextStyles.labelMd(color: Colors.white70).copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => EspConfigDialog.show(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Input IP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // BMKG Weather Monitoring Widget
          const BmkgWeatherCard(),
          const SizedBox(height: 16),

          // Primary Action Buttons (Kontrol Kamera & Database Penyakit)
          Row(
            children: [
              Expanded(
                child: _BigActionButton(
                  icon: Icons.camera_alt_rounded,
                  iconBgColor: const Color(0xFF10B981),
                  title: 'Kontrol Kamera ESP32',
                  subtitle: 'Live Stream & Pan-Tilt Servo',
                  onTap: () => widget.onNavigateToTab(2), // Tab Kamera
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _BigActionButton(
                  icon: Icons.document_scanner_rounded,
                  iconBgColor: AppColors.secondaryContainer,
                  title: 'Database Penyakit',
                  subtitle: 'Katalog & Scan AI',
                  onTap: () => widget.onNavigateToTab(1), // Tab Daun
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Secondary Navigation Cards
          Row(
            children: [
              Expanded(
                child: _NavCard(
                  icon: Icons.menu_book_rounded,
                  iconBgColor: AppColors.primaryContainer,
                  iconColor: AppColors.onPrimaryContainer,
                  title: 'Ensiklopedia',
                  subtitle: 'Info Penyakit',
                  onTap: () => widget.onNavigateToTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavCard(
                  icon: Icons.analytics_outlined,
                  iconBgColor: AppColors.tertiaryContainer,
                  iconColor: AppColors.onTertiaryContainer,
                  title: 'Data Sensor',
                  subtitle: 'Cek Detail',
                  onTap: () => widget.onNavigateToTab(3),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavCard(
                  icon: Icons.router_rounded,
                  iconBgColor: AppColors.secondaryContainer,
                  iconColor: AppColors.onSecondaryContainer,
                  title: 'Status IoT',
                  subtitle: 'Node Connect',
                  onTap: () => EspConfigDialog.show(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Aktivitas Terakhir',
                    style: AppTextStyles.titleMd(color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToTab(4), // Tab Riwayat
                child: Text('Lihat Semua',
                    style: AppTextStyles.labelLg(color: AppColors.primary)
                        .copyWith(fontWeight: FontWeight.w600)),
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
                      ? const Color(0x1A003B58)
                      : act.type == 'scan_alert'
                          ? AppColors.error.withValues(alpha: 0.10)
                          : AppColors.secondary.withValues(alpha: 0.10),
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
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _BigActionButton({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTextStyles.labelLg(color: AppColors.onSurface)
                  .copyWith(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                textAlign: TextAlign.center),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontSize: 10),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
