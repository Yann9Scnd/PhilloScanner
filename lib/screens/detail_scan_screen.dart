import 'package:flutter/material.dart';
import '../models/scan_result_model.dart';
import '../theme/app_theme.dart';

/// Halaman Detail Hasil Scan Daun
class DetailScanScreen extends StatelessWidget {
  final ScanResultModel? scan;

  const DetailScanScreen({super.key, this.scan});

  static const _defaultScan = ScanResultModel(
    deviceId: 'ESP32-CAM Sektor B-04',
    imageUrl:
        'https://lh3.googleusercontent.com/aida/AP1WRLsJNUTrlybw3NU7q_uVkGQ2i6ryWi7lAXAGkOSvK_H2Ptj28d2-iZ--leefUeHsmVULchMwRDed-DsFju613H_X7TztLlQM821oZKXYF_4PrWPd8DFjAvWQHWXhrFAGvB5Rrw8anPY1K0deDmtaCTLCD2H1WG9eT53kZBJqRDVh8-u1C4d2vm72Hr24gioVwOVzH9sz-OHjukpoyBkBBiPKQKF9t-eGPhcSyBcjKjHvrcTbgs5jR9GWKMok',
    diseaseName: 'Bercak Daun',
    scientificName: 'Cercospora capsici',
    severity: 'Sedang',
    confidence: 92,
    timestamp: '12 Okt 2023 • 14:30',
    soilMoisture: '58%',
    aiRecommendations: [
      'Kurangi kelembapan di sekitar area terdampak.',
      'Buang bagian daun yang rusak parah agar tidak menular.',
      'Berikan pupuk tambahan untuk memperkuat imun tanaman.',
    ],
  );

  @override
  Widget build(BuildContext context) {
    final activeScan = scan ?? _defaultScan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
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
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Detail Hasil Scan',
                      style:
                          AppTextStyles.headlineSm(color: AppColors.onSurface)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Image Card (Square 1:1)
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Scan Image
                              Positioned.fill(
                                child: Image.network(
                                  activeScan.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, st) => Container(
                                    color: AppColors.surfaceContainer,
                                    child: const Center(
                                        child: Icon(Icons.eco,
                                            size: 64,
                                            color: AppColors.primary)),
                                  ),
                                ),
                              ),
                              // Severity Badge
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_rounded,
                                          size: 18,
                                          color:
                                              AppColors.onSecondaryContainer),
                                      const SizedBox(width: 4),
                                      Text(
                                        activeScan.severity.toUpperCase(),
                                        style: AppTextStyles.labelLg(
                                                color: AppColors
                                                    .onSecondaryContainer)
                                            .copyWith(letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Animated scan line hint (static decoration)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 100,
                                child: Opacity(
                                  opacity: 0.30,
                                  child: Container(
                                    height: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Result Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('IDENTIFIKASI',
                                        style: AppTextStyles.labelMd(
                                                color: AppColors.secondary)
                                            .copyWith(letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Text(activeScan.diseaseName,
                                        style: AppTextStyles.headlineLgMobile(
                                            color: AppColors.primary)),
                                    if (activeScan.scientificName.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(activeScan.scientificName,
                                          style: AppTextStyles.labelMd(
                                              color: AppColors.onSurfaceVariant)),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Kepercayaan',
                                      style: AppTextStyles.labelMd(
                                          color: AppColors.outline)),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${activeScan.confidence}',
                                          style: AppTextStyles.dataDisplay(
                                              color: AppColors.primary)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Text('%',
                                            style: AppTextStyles.titleMd(
                                                color: AppColors.primary)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.outline),
                              const SizedBox(width: 6),
                              Text(activeScan.timestamp,
                                  style: AppTextStyles.bodyMd(
                                      color: AppColors.outline)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Recommendations Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.lightbulb_rounded,
                                    size: 20, color: AppColors.onPrimary),
                              ),
                              const SizedBox(width: 12),
                              Text('Saran AI',
                                  style: AppTextStyles.titleMd(
                                      color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            activeScan.aiRecommendations.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StepItem(
                                step: index + 1,
                                text: activeScan.aiRecommendations[index],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Technical Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _TechInfoCard(
                            icon: Icons.videocam_rounded,
                            label: 'Sumber Perangkat',
                            value: activeScan.deviceId,
                            subtitle: 'ESP32-CAM',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TechInfoCard(
                            icon: Icons.water_drop_outlined,
                            label: 'Kelembapan',
                            value: activeScan.soilMoisture,
                            subtitle: 'Waktu Scan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Footer Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Bagikan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainer,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
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

class _StepItem extends StatelessWidget {
  final int step;
  final String text;
  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
              color: AppColors.secondaryContainer, shape: BoxShape.circle),
          child: Center(
            child: Text(
              '$step',
              style:
                  AppTextStyles.labelMd(color: AppColors.onSecondaryContainer),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }
}

class _TechInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  const _TechInfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.labelMd(color: AppColors.outline),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.titleMd(color: AppColors.primary),
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: AppTextStyles.labelMd(color: AppColors.outlineVariant)),
        ],
      ),
    );
  }
}
