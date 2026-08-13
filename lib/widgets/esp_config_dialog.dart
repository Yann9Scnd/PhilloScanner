import 'package:flutter/material.dart';
import '../services/esp_service.dart';
import '../theme/app_theme.dart';

/// Dialog sederhana untuk mengisi alamat IP perangkat IoT kebun (ESP32)
/// dan alamat server aplikasi. Dirancang ramah petani: cukup isi 3 alamat IP.
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
  late TextEditingController _node1IpController;
  late TextEditingController _node2IpController;
  late TextEditingController _serverIpController;

  @override
  void initState() {
    super.initState();
    _node1IpController = TextEditingController(text: EspService.instance.camIp);
    _node2IpController = TextEditingController(text: EspService.instance.sensorIp);
    _serverIpController =
        TextEditingController(text: EspService.instance.serverIp);
  }

  @override
  void dispose() {
    _node1IpController.dispose();
    _node2IpController.dispose();
    _serverIpController.dispose();
    super.dispose();
  }

  void _save() {
    EspService.instance.camIp = _node1IpController.text.trim();
    EspService.instance.sensorIp = _node2IpController.text.trim();
    EspService.instance.serverIp = _serverIpController.text.trim();
    EspService.instance.isServerConfigured = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('Alamat perangkat IoT berhasil disimpan!')),
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
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
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
                          'Hubungkan Perangkat IoT Kebun',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Isi alamat IP sesuai perangkat di kebun Anda',
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
                    // Petunjuk singkat
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Angka IP biasanya terlihat di layar ponsel, kartu petunjuk dari teknisi, atau tampilan Serial Monitor di komputer. Jika tidak tahu, tanyakan kepada teknisi atau lihat panduan di menu Beranda.',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                                  .copyWith(fontSize: 11, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Daftar alamat IP
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wifi_rounded, size: 15, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                'Alamat IP Perangkat Kebun Anda',
                                style: AppTextStyles.labelLg(color: AppColors.onSurface)
                                    .copyWith(fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _ipField(
                            label: 'Kamera (Node 1)',
                            helper: 'ESP32-CAM untuk melihat tanaman',
                            controller: _node1IpController,
                            icon: Icons.videocam_rounded,
                          ),
                          const SizedBox(height: 12),
                          _ipField(
                            label: 'Sensor (Node 2)',
                            helper: 'ESP32 sensor tanah & suhu',
                            controller: _node2IpController,
                            icon: Icons.sensors_rounded,
                          ),
                          const SizedBox(height: 12),
                          _ipField(
                            label: 'Server Aplikasi',
                            helper: 'Komputer tempat data tersimpan',
                            controller: _serverIpController,
                            icon: Icons.dns_rounded,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tombol Simpan
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F5F9),
                              foregroundColor: AppColors.onSurfaceVariant,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _save,
                            icon: const Icon(Icons.check_rounded, size: 16),
                            label: const Text('Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _ipField({
    required String label,
    required String helper,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
              .copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Contoh: 192.168.1.20',
            helperText: helper,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      ],
    );
  }
}
