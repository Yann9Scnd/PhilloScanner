import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/detail_scan_screen.dart';
import '../screens/status_perangkat_screen.dart';
import '../widgets/quick_stat_card.dart';
import '../widgets/recent_activity_item.dart';

class BerandaTabView extends StatelessWidget {
  final VoidCallback onNavigateToDaun;

  const BerandaTabView({super.key, required this.onNavigateToDaun});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Greeting
          Row(
            children: [
              Text('Halo, Petani!',
                  style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
              const SizedBox(width: 8),
              // Animated online indicator
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
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.cloud_done_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text('Sistem Terhubung & Stabil',
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Section: Greenhouse Status
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
                  // Background image
                  Positioned.fill(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBhcB4wvj13TRz4oOrXamaCSj6hpQUo0FNUX4WwUCvr11jQ585NCadLLTKch3NfFB2cwRPhn3bdaZkGoNDApCTU7Wu9BJ0SBk2Fz5CysGV1XI-Udb-1iS3b7jd1uBj7ZLtM8mbc9y8oRSOUsD2Pp9kEG5x1_ITkONzzIB-rEyUNcrS9O9goD2tBHZxAdJmG0DCpAYledD9iFDctMctJ-y0Zuns5dLMp5GGGhtrioDSj5JPC3UfW5G6fBg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, s) => Container(
                        color: AppColors.primaryContainer,
                        child: const Center(
                            child: Icon(Icons.landscape, size: 64, color: AppColors.onPrimary)),
                      ),
                    ),
                  ),
                  // Gradient overlay
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
                  // Content
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
                        Text('Greenhouse Sektor A',
                            style: AppTextStyles.headlineSm(color: AppColors.onPrimary)),
                        const SizedBox(height: 8),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              Text('Kondisi Ideal',
                                  style: AppTextStyles.labelMd(color: AppColors.tertiaryFixed)
                                      .copyWith(fontWeight: FontWeight.w500)),
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
            children: const [
              Expanded(
                child: QuickStatCard(
                  icon: Icons.water_drop_outlined,
                  iconBgColor: Color(0x1A003B58),
                  iconColor: AppColors.primary,
                  label: 'Tanah',
                  value: '62%',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: QuickStatCard(
                  icon: Icons.thermostat,
                  iconBgColor: Color(0x1A835500),
                  iconColor: AppColors.secondary,
                  label: 'Suhu',
                  value: '28°C',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: QuickStatCard(
                  icon: Icons.settings_input_component,
                  iconBgColor: Color(0x1A003D48),
                  iconColor: AppColors.tertiary,
                  label: 'Pompa',
                  value: 'Oto',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Leaf Health Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 24, color: AppColors.error),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deteksi Waspada',
                          style: AppTextStyles.titleMd(color: AppColors.onErrorContainer)),
                      const SizedBox(height: 2),
                      Text('Potensi Bercak Daun terdeteksi.',
                          style: AppTextStyles.bodyMd(
                                  color: AppColors.onErrorContainer.withValues(alpha: 0.80))
                              .copyWith(fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DetailScanScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.onError,
                    elevation: 2,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Detail',
                      style: AppTextStyles.labelLg(color: AppColors.onError)
                          .copyWith(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
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
                  onTap: onNavigateToDaun,
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
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NavCard(
                  icon: Icons.router_rounded,
                  iconBgColor: AppColors.secondaryContainer,
                  iconColor: AppColors.onSecondaryContainer,
                  title: 'Status Perangkat',
                  subtitle: '',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const StatusPerangkatScreen()));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Activity List
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aktivitas Terakhir',
                  style: AppTextStyles.titleMd(color: AppColors.onSurface)),
              TextButton(
                onPressed: () {},
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
              border:
                  Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 1))
              ],
            ),
            child: Column(
              children: [
                const RecentActivityItem(
                  icon: Icons.water_drop,
                  iconColor: AppColors.primary,
                  iconBgColor: Color(0x1A003B58),
                  title: 'Penyiraman Selesai',
                  subtitle: 'Sektor A • 15 menit yang lalu',
                  hasDivider: true,
                ),
                RecentActivityItem(
                  icon: Icons.document_scanner_rounded,
                  iconColor: AppColors.error,
                  iconBgColor: AppColors.error.withValues(alpha: 0.10),
                  title: 'Deteksi Bercak Daun',
                  subtitle: 'Sektor B • 2 jam yang lalu',
                  hasDivider: false,
                ),
              ],
            ),
          ),
        ],
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
        padding: const EdgeInsets.all(14),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(title,
                style: AppTextStyles.labelLg(color: AppColors.onSurface)
                    .copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
