import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Panduan sederhana: cara menghubungkan aplikasi ke perangkat ESP
/// dan cara menggunakan fitur aplikasi. Ditulis ramah petani.
class AppGuideDialog extends StatelessWidget {
  const AppGuideDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AppGuideDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0F172A), AppColors.primary],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC53D).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFC53D).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.menu_book_rounded, color: Color(0xFFFFC53D), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Panduan Aplikasi',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Cara koneksi perangkat & memakai fitur',
                          style: const TextStyle(color: Color(0xFFB3D9FF), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            // Modal Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. Menghubungkan Aplikasi ke ESP',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _stepCard(
                      number: '1',
                      title: 'Buka menu Beranda',
                      description:
                          'Ketuk banner berwarna "Hubungkan Modul ESP32" di bagian atas halaman Beranda.',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      number: '2',
                      title: 'Isi 3 alamat IP',
                      description:
                          'Masukkan alamat IP Kamera, Sensor, dan Server Aplikasi. Angka IP bisa dilihat di kartu dari teknisi atau tampilan Serial Monitor.',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      number: '3',
                      title: 'Tekan Simpan',
                      description:
                          'Setelah disimpan, aplikasi otomatis terhubung ke perangkat dan server kebun Anda.',
                      color: AppColors.primary,
                      bgColor: AppColors.primaryContainer.withValues(alpha: 0.35),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      '2. Menggunakan Aplikasi',
                      style: AppTextStyles.titleMd(color: AppColors.onSurface)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    _stepCard(
                      number: '1',
                      title: 'Tab Daun',
                      description:
                          'Foto daun cabai untuk dideteksi penyakitnya secara otomatis oleh AI.',
                      color: const Color(0xFF10B981),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      number: '2',
                      title: 'Tab Kamera',
                      description:
                          'Lihat kondisi kebun secara langsung dan arahkan kamera lewat aplikasi.',
                      color: const Color(0xFF3B82F6),
                      bgColor: const Color(0xFFEFF6FF),
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      number: '3',
                      title: 'Tab Sensor',
                      description:
                          'Pantau kelembapan tanah, suhu udara, baterai, dan jarak daun, lalu nyalakan/matikan pompa irigasi dan pompa pestisida.',
                      color: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      number: '4',
                      title: 'Tab Riwayat',
                      description:
                          'Lihat catatan penyiraman dan hasil scan penyakit daun sebelumnya.',
                      color: const Color(0xFF7C3AED),
                      bgColor: const Color(0xFFF5F3FF),
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

  Widget _stepCard({
    required String number,
    required String title,
    required String description,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLg(color: AppColors.onSurface)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                      .copyWith(fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
