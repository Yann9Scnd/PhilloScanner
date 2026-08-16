import 'package:flutter/material.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';

/// Dialog sederhana untuk menghubungkan aplikasi ke ESP32-CAM.
/// Server IP sudah di-hardcode di EspService (satu jaringan WiFi yang sama).
class EspConfigDialog extends StatefulWidget {
  const EspConfigDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const EspConfigDialog(),
    );
  }

  @override
  State<EspConfigDialog> createState() => _EspConfigDialogState();
}

class _EspConfigDialogState extends State<EspConfigDialog> {
  late TextEditingController _camIpController;

  @override
  void initState() {
    super.initState();
    _camIpController = TextEditingController(text: EspService.instance.camIp);
  }

  @override
  void dispose() {
    _camIpController.dispose();
    super.dispose();
  }

  void _save() {
    EspService.instance.camIp = _camIpController.text.trim();
    EspService.instance.isServerConfigured = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('ESP32-CAM berhasil dihubungkan!')),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                      color: const Color(0xFF34D399).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.memory_rounded, color: Color(0xFF34D399), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hubungkan ke ESP32-CAM',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Cukup masukkan IP kamera, server otomatis',
                          style: TextStyle(color: Color(0xFFB3D9FF), fontSize: 10),
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
                    // Alur data
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Cara Kerja',
                                style: AppTextStyles.labelLg(color: AppColors.primary)
                                    .copyWith(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. HP & ESP32-CAM harus di WiFi yang sama\n'
                            '2. Sensor tanah/suhu kirim data ke ESP32-CAM lewat kabel UART\n'
                            '3. ESP32-CAM teruskan data ke server untuk disimpan\n'
                            '4. Anda bisa lihat semua data dari mana saja di aplikasi ini',
                            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                                .copyWith(fontSize: 11, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Server info (read-only)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.dns_rounded, size: 18, color: AppColors.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Server Aplikasi',
                                  style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  EspService.instance.serverIp,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Input ESP-CAM IP
                    Text(
                      'IP ESP32-CAM (Kamera)',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _camIpController,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Contoh: 192.168.1.50',
                        helperText: 'Lihat IP di Serial Monitor Arduino atau layar OLED',
                        prefixIcon: const Icon(Icons.videocam_rounded, size: 18),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Simpan
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Hubungkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
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
