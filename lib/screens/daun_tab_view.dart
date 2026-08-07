import 'package:flutter/material.dart';
import '../models/disease_model.dart';
import '../models/scan_result_model.dart';
import '../repositories/scan_repository.dart';
import '../theme/app_theme.dart';
import 'detail_scan_screen.dart';

/// Tab Daun — Ensiklopedia Penyakit & Hasil Analisis ESP32-CAM
class DaunTabView extends StatefulWidget {
  const DaunTabView({super.key});

  @override
  State<DaunTabView> createState() => _DaunTabViewState();
}

class _DaunTabViewState extends State<DaunTabView> {
  final ScanRepository _scanRepository = ScanRepository();
  int _selectedFilter = 0;
  String _searchQuery = '';
  final _filters = ['Semua', 'Jamur', 'Bakteri', 'Virus'];

  @override
  Widget build(BuildContext context) {
    final selectedCategory =
        _selectedFilter == 0 ? null : _filters[_selectedFilter];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. ESP32 Scan History Banner / Latest Detection
          FutureBuilder<List<ScanResultModel>>(
            future: _scanRepository.getScanHistory(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final latestScan = snapshot.data!.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.center_focus_strong_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('Hasil Analisis Foto ESP32',
                              style: AppTextStyles.titleMd(
                                  color: AppColors.primary)),
                        ],
                      ),
                    ),
                    _EspScanCard(
                      scan: latestScan,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScanScreen(scan: latestScan),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // 2. Search Bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.search, color: AppColors.outline),
                ),
                Expanded(
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari penyakit tanaman...',
                      hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) {
                final active = i == _selectedFilter;
                return Padding(
                  padding:
                      EdgeInsets.only(right: i < _filters.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        _filters[i],
                        style: AppTextStyles.labelMd(
                            color: active
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // 4. Disease Dataset Section Header
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text('Dataset Penyakit Tanaman',
                style: AppTextStyles.titleMd(color: AppColors.primary)),
          ),

          // 5. Disease Cards from Database
          FutureBuilder<List<DiseaseModel>>(
            future: _scanRepository.getDiseases(category: selectedCategory),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Gagal memuat dataset: ${snapshot.error}',
                      style: AppTextStyles.bodyMd(color: AppColors.error)),
                );
              }

              var diseases = snapshot.data ?? [];
              if (_searchQuery.isNotEmpty) {
                diseases = diseases
                    .where((d) =>
                        d.name.toLowerCase().contains(_searchQuery) ||
                        d.scientificName.toLowerCase().contains(_searchQuery))
                    .toList();
              }

              if (diseases.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('Tidak ada penyakit yang cocok.',
                        style: AppTextStyles.bodyMd(
                            color: AppColors.onSurfaceVariant)),
                  ),
                );
              }

              return Column(
                children: diseases.map((disease) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DiseaseCard(disease: disease),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EspScanCard extends StatelessWidget {
  final ScanResultModel scan;
  final VoidCallback onTap;

  const _EspScanCard({required this.scan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  scan.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, st) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.surfaceContainer,
                    child: const Icon(Icons.eco, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('IDENTIFIKASI AI',
                            style: AppTextStyles.labelMd(
                                    color: AppColors.secondary)
                                .copyWith(
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text('${scan.confidence}% Acc',
                              style: AppTextStyles.labelMd(
                                      color: AppColors.onSecondaryContainer)
                                  .copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(scan.diseaseName,
                        style: AppTextStyles.titleMd(color: AppColors.primary)),
                    Text('${scan.deviceId} • ${scan.timestamp}',
                        style: AppTextStyles.labelMd(
                            color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Lihat Hasil Analisis AI & Saran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiseaseCard extends StatelessWidget {
  final DiseaseModel disease;
  const _DiseaseCard({required this.disease});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          // Image Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              disease.imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (ctx, e, st) => Container(
                width: 64,
                height: 64,
                color: AppColors.surfaceContainer,
                child: const Icon(Icons.eco, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(disease.name,
                          style: AppTextStyles.labelLg(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                    Text(disease.category,
                        style:
                            AppTextStyles.labelMd(color: AppColors.secondary)
                                .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(disease.scientificName,
                    style: AppTextStyles.labelMd(
                        color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScanScreen(
                          scan: ScanResultModel(
                            deviceId: 'ESP32-CAM Sektor B-04',
                            imageUrl: disease.imageUrl,
                            diseaseName: disease.name,
                            scientificName: disease.scientificName,
                            severity: 'Sedang',
                            confidence: 90,
                            timestamp: 'Data Dataset',
                            soilMoisture: '60%',
                            aiRecommendations: disease.treatmentSteps,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Text('Pelajari Selengkapnya',
                          style: AppTextStyles.labelLg(color: AppColors.primary)
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 16, color: AppColors.primary),
                    ],
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
