import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget item aktivitas terakhir di halaman Beranda
class RecentActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final bool hasDivider;

  const RecentActivityItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.hasDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                child: Icon(icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.labelLg(color: AppColors.onSurface)
                            .copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                            .copyWith(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (hasDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.outlineVariant.withValues(alpha: 0.20),
            indent: 74,
          ),
      ],
    );
  }
}
