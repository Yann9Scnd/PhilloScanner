import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../models/scan_result_model.dart';
import '../repositories/scan_repository.dart';
import '../theme/app_theme.dart';
import 'detail_scan_screen.dart';

class RiwayatTabView extends StatefulWidget {
  final List<ActivityLogModel>? activities;
  final List<ScanResultModel>? savedScans;

  const RiwayatTabView({
    super.key,
    this.activities,
    this.savedScans,
  });

  @override
  State<RiwayatTabView> createState() => _RiwayatTabViewState();
}

class _RiwayatTabViewState extends State<RiwayatTabView> {
  final ScanRepository _scanRepository = ScanRepository();

  String _filterType = 'semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<ScanResultModel> _scans = [];
  bool _isLoading = true;
  String _source = '';

  static const List<({String id, String label, IconData icon})> _filterOptions = [
    (id: 'semua', label: 'Semua Log', icon: Icons.list_rounded),
    (id: 'scan', label: 'Penyakit Daun', icon: Icons.eco_rounded),
    (id: 'penyiraman', label: 'Penyiraman', icon: Icons.water_drop_rounded),
    (id: 'sensor', label: 'Sensor Alert', icon: Icons.warning_amber_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _loadScans();
  }

  /// Ambil histori dari server Laravel (GET /api/scans).
  /// Jika server offline, fallback ke SQLite lokal (phylloscanner.db).
  Future<void> _loadScans() async {
    setState(() => _isLoading = true);
    try {
      final remote = await _scanRepository.getScanHistory();
      final local = widget.savedScans ?? const <ScanResultModel>[];
      final merged = <ScanResultModel>[...remote];
      for (final scan in local) {
        if (!merged.any((s) => s.timestamp == scan.timestamp && s.deviceId == scan.deviceId)) {
          merged.add(scan);
        }
      }
      if (mounted) {
        setState(() {
          _scans = merged;
          _source = remote.isEmpty ? 'SQLite lokal' : 'Server LeafGuard API';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _scans = widget.savedScans ?? const [];
          _source = 'SQLite lokal';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'watering':
        return Icons.water_drop_rounded;
      case 'scan_alert':
        return Icons.eco_rounded;
      case 'sensor_warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconBgColor(String type) {
    switch (type) {
      case 'watering':
        return const Color(0xFFE3F2FD);
      case 'scan_alert':
        return const Color(0xFFFFEBEE);
      case 'sensor_warning':
        return const Color(0xFFFFF3E0);
      default:
        return const Color(0xFFE0F2F1);
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'watering':
        return const Color(0xFF0288D1);
      case 'scan_alert':
        return const Color(0xFFD32F2F);
      case 'sensor_warning':
        return const Color(0xFFE65100);
      default:
        return const Color(0xFF00796B);
    }
  }

  bool _activityMatches(ActivityLogModel act) {
    final matchesFilter =
        _filterType == 'semua' ||
        (_filterType == 'penyiraman' && act.type == 'watering') ||
        (_filterType == 'scan' && act.type == 'scan_alert') ||
        (_filterType == 'sensor' && act.type == 'sensor_warning');

    final q = _searchQuery.toLowerCase();
    final matchesSearch =
        q.isEmpty ||
        act.title.toLowerCase().contains(q) ||
        act.subtitle.toLowerCase().contains(q) ||
        act.sector.toLowerCase().contains(q);

    return matchesFilter && matchesSearch;
  }

  void _showActivityDetail(ActivityLogModel act) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rincian Aktivitas Kebun',
                    style: AppTextStyles.titleMd(color: AppColors.onSurface),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBgColor(act.type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIconData(act.type), color: _getIconColor(act.type), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Judul Event', style: AppTextStyles.labelMd(color: AppColors.outline)),
                      Text(
                        act.title,
                        style: AppTextStyles.titleMd(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Rincian & Lokasi', style: AppTextStyles.labelMd(color: AppColors.outline)),
            const SizedBox(height: 4),
            Text(act.subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Waktu Eksekusi', style: AppTextStyles.labelMd(color: AppColors.outline)),
                        const SizedBox(height: 2),
                        Text(
                          act.timestamp,
                          style: AppTextStyles.labelLg(color: AppColors.onSurface)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sektor Greenhouse', style: AppTextStyles.labelMd(color: AppColors.outline)),
                        const SizedBox(height: 2),
                        Text(
                          act.sector,
                          style: AppTextStyles.labelLg(color: AppColors.onSurface)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Tutup Log', style: AppTextStyles.labelLg(color: AppColors.onPrimary)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activityList = widget.activities ?? ActivityLogModel.initialList();
    final scanList = _scans;

    final filteredActivities = activityList.where(_activityMatches).toList();

    return RefreshIndicator(
      onRefresh: _loadScans,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Kebun & Log AI',
                        style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                      ),
                      Text(
                        'Catatan Aktivitas, Peringatan & Scan Daun',
                        style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                if (!_isLoading && _source.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _source.contains('Server') ? Icons.cloud_done_rounded : Icons.offline_pin_rounded,
                          size: 13,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _source,
                            style: AppTextStyles.labelMd(color: const Color(0xFF2E7D32))
                                .copyWith(fontSize: 9, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

          // Search Input
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari aktivitas, penyakit, atau sektor...',
              hintStyle: AppTextStyles.labelMd(color: AppColors.outline),
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.outline),
              suffixIcon: _searchQuery.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.outline),
                    ),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.40)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.40)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filterOptions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final opt = _filterOptions[index];
                final isActive = _filterType == opt.id;
                return GestureDetector(
                  onTap: () => setState(() => _filterType = opt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          opt.icon,
                          size: 14,
                          color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          opt.label,
                          style: AppTextStyles.labelMd(
                            color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Saved AI Scans Quick Gallery
          if (scanList.isNotEmpty) ...[
            Container(
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
                    children: [
                      const Icon(Icons.folder_open_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Scan Daun Tersimpan (${scanList.length})',
                        style: AppTextStyles.labelLg(color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scanList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 3.1,
                    ),
                    itemBuilder: (context, index) {
                      final scan = scanList[index];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScanScreen(scan: scan),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.30)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  scan.imageUrl,
                                  width: 38,
                                  height: 38,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, st) => Container(
                                    width: 38,
                                    height: 38,
                                    color: AppColors.surfaceContainer,
                                    child: const Icon(Icons.eco, color: AppColors.primary, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      scan.diseaseName,
                                      style: AppTextStyles.labelMd(color: AppColors.onSurface)
                                          .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      scan.timestamp,
                                      style: AppTextStyles.labelMd(color: AppColors.outline)
                                          .copyWith(fontSize: 9),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Activities Timeline Log
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
            ),
            child: filteredActivities.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 32, color: AppColors.outline),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada catatan aktivitas yang cocok dengan pencarian.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMd(color: AppColors.outline),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: List.generate(filteredActivities.length, (index) {
                      final act = filteredActivities[index];
                      final isLast = index == filteredActivities.length - 1;
                      return InkWell(
                        onTap: () => _showActivityDetail(act),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : Border(
                                    bottom: BorderSide(
                                      color: AppColors.outlineVariant.withValues(alpha: 0.20),
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _getIconBgColor(act.type),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_getIconData(act.type), color: _getIconColor(act.type), size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      act.title,
                                      style: AppTextStyles.labelLg(color: AppColors.onSurface)
                                          .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      act.subtitle,
                                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                          .copyWith(fontSize: 10),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                act.timestamp,
                                style: AppTextStyles.labelMd(color: AppColors.outline).copyWith(fontSize: 9),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.outline),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
