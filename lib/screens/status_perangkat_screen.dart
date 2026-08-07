import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Halaman Status Perangkat (ESP32-CAM)
/// Dipanggil dari card "Status Perangkat" di Beranda
class StatusPerangkatScreen extends StatelessWidget {
  const StatusPerangkatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.onSurface),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Status Perangkat',
                      style:
                          AppTextStyles.headlineLgMobile(color: AppColors.onSurface)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: [
                    // ESP32 Status Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        children: [
                          // Status Circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryContainer
                                      .withValues(alpha: 0.20),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryContainer
                                      .withValues(alpha: 0.40),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.tertiaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle_rounded,
                                    color: AppColors.onTertiaryContainer, size: 32),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text('ESP32-CAM Sektor B-04',
                              style: AppTextStyles.titleLg(color: AppColors.onSurface),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryFixed,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: AppColors.tertiary,
                                      shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 6),
                                Text('Terhubung & Stabil',
                                    style: AppTextStyles.labelMd(
                                        color: AppColors.onTertiaryFixed)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Info Grid 2x2
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.8,
                            children: [
                              _InfoTile(
                                  icon: Icons.wifi,
                                  iconColor: AppColors.primaryContainer,
                                  label: 'Sinyal',
                                  value: '-65 dBm'),
                              _InfoTile(
                                  icon: Icons.battery_5_bar,
                                  iconColor: AppColors.onSecondaryFixedVariant,
                                  label: 'Daya',
                                  value: 'Mains (AC)'),
                              _InfoTile(
                                  icon: Icons.router_rounded,
                                  iconColor: AppColors.onSurfaceVariant,
                                  label: 'IP Address',
                                  value: '192.168.1.104'),
                              _InfoTile(
                                  icon: Icons.sync_rounded,
                                  iconColor: AppColors.onSurfaceVariant,
                                  label: 'Sinkronisasi',
                                  value: '2 mnt lalu'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            label: const Text('Hubungkan Perangkat Baru'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.restart_alt_rounded, size: 20),
                            label: const Text('Reset Koneksi'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryContainer,
                              side: BorderSide(
                                  color: AppColors.outlineVariant),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Help Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.help_outline_rounded,
                                  size: 20, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 8),
                              Text('Bantuan Perangkat',
                                  style: AppTextStyles.titleMd(
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _HelpItem('Pastikan power supply terhubung dengan baik (LED indikator menyala).'),
                          const SizedBox(height: 8),
                          _HelpItem('Periksa jangkauan router WiFi di area rumah kaca.'),
                          const SizedBox(height: 8),
                          _HelpItem("Gunakan fungsi 'Reset Koneksi' jika data tidak update lebih dari 15 menit."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.50),
                shape: BoxShape.circle),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
                Text(value,
                    style: AppTextStyles.titleMd(color: AppColors.onSurface)
                        .copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String text;
  const _HelpItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            size: 16, color: AppColors.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
        ),
      ],
    );
  }
}
