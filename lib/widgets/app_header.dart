import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';
import 'esp_node_dialog.dart';

/// Shared AppBar / Header for all screens
/// Mirrors the React `Header.tsx`:
///  - Logo + Brand "Phylloscanner" + "Smart Greenhouse v2.4"
///  - Tombol ESP32 (buka EspNodeDialog)
///  - Bel notifikasi dengan badge jumlah belum dibaca -> drawer notifikasi
///  - Avatar profil petani -> modal profil
class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final List<AppNotificationModel> notifications;
  final VoidCallback? onMarkAllRead;

  const AppHeader({
    super.key,
    this.notifications = const [],
    this.onMarkAllRead,
  });

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _AppHeaderState extends State<AppHeader> {
  int get _unreadCount =>
      widget.notifications.where((n) => n.unread).length;

  void _openNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _NotificationDrawer(
          notifications: widget.notifications,
          unreadCount: _unreadCount,
          onMarkAllRead: () {
            widget.onMarkAllRead?.call();
          },
        );
      },
    );
  }

  void _openProfile() {
    showDialog(
      context: context,
      builder: (dialogContext) => const _ProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo dari asset lokal
          Image.asset(
            'assets/images/Logo-Phylloscanner.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.eco_rounded, size: 32, color: AppColors.primary);
            },
          ),
          const SizedBox(width: 8),
          // Brand Name + Subtitle
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PhylloScanner',
                  style: AppTextStyles.titleMd(color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Smart Greenhouse v2.4',
                        style: AppTextStyles.labelMd(color: AppColors.outline)
                            .copyWith(fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol ESP32
          InkWell(
            onTap: () => EspNodeDialog.show(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.memory_rounded, size: 14, color: Color(0xFF34D399)),
                  SizedBox(width: 4),
                  Text(
                    'ESP32',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Tombol Notifikasi dengan badge
          Stack(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: _openNotifications,
                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.50),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
              if (_unreadCount > 0)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF59E0B),
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(
                        BorderSide(color: Colors.white, width: 1.5),
                      ),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
          // Avatar Profil
          InkWell(
            onTap: _openProfile,
            customBorder: const CircleBorder(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20, color: AppColors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer notifikasi (modal bottom sheet)
class _NotificationDrawer extends StatelessWidget {
  final List<AppNotificationModel> notifications;
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const _NotificationDrawer({
    required this.notifications,
    required this.unreadCount,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_outlined, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text('Notifikasi Sistem', style: AppTextStyles.titleMd(color: AppColors.onSurface)),
                if (unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '$unreadCount Baru',
                      style: AppTextStyles.labelMd(color: const Color(0xFF92400E))
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.outline),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Text('Tidak ada notifikasi saat ini.',
                        style: AppTextStyles.bodyMd(color: AppColors.outline)),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: n.unread
                              ? const Color(0xFFFFF8E1).withValues(alpha: 0.80)
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: n.unread
                                ? const Color(0xFFFDE68A)
                                : AppColors.outlineVariant.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(n.title,
                                      style: AppTextStyles.labelLg(
                                              color: AppColors.onSurface)
                                          .copyWith(fontWeight: FontWeight.w600, fontSize: 13)),
                                ),
                                const SizedBox(width: 8),
                                Text(n.time,
                                    style: AppTextStyles.labelMd(color: AppColors.outline)
                                        .copyWith(fontSize: 10)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(n.message,
                                style: AppTextStyles.labelMd(
                                        color: AppColors.onSurfaceVariant)
                                    .copyWith(fontSize: 12, height: 1.4)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    onMarkAllRead();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_rounded, size: 18, color: AppColors.primary),
                  label: Text('Tandai Semua Dibaca',
                      style: AppTextStyles.labelLg(color: AppColors.primary)
                          .copyWith(fontWeight: FontWeight.w600)),
                ),
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Tutup'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal profil operator IoT
class _ProfileModal extends StatelessWidget {
  const _ProfileModal();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profil Operator IoT', style: AppTextStyles.titleMd(color: AppColors.onSurface)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.outline),
                ),
              ],
            ),
            const Divider(height: 1),
            const SizedBox(height: 20),
            // Avatar + Identity
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('P',
                          style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onPrimary)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Pengelola Kebun',
                      style: AppTextStyles.titleLg(color: AppColors.onSurface)),
                  Text('Akun ChiliGuard',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _ProfileInfoRow(label: 'Lokasi Kebun', value: '—'),
                  const SizedBox(height: 8),
                  _ProfileInfoRow(label: 'Node Hardware Terhubung', value: '—'),
                  const SizedBox(height: 8),
                  _ProfileInfoRow(
                      label: 'Status Server Cloud',
                      value: '—'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: AppTextStyles.labelMd(color: AppColors.onSurface)
                  .copyWith(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
