import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget reusable untuk quick stat card (3 kolom di halaman Beranda)
class QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final String value;

  const QuickStatCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          Text(label,
              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.titleLg(color: AppColors.onSurface),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
