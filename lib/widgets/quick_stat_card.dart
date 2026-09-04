import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget reusable untuk quick stat card (3 kolom di halaman Beranda)
class QuickStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final Gradient? iconGradient;
  final String label;
  final String value;
  final String? subtitle;
  final Color? subtitleColor;
  final VoidCallback? onTap;

  const QuickStatCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.iconGradient,
    required this.label,
    required this.value,
    this.subtitle,
    this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              gradient: iconGradient,
              color: iconGradient == null ? iconBgColor : null,
              shape: BoxShape.circle,
              boxShadow: iconGradient != null
                  ? [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),
          Text(label,
              style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.titleLg(color: AppColors.primary)
                  .copyWith(fontWeight: FontWeight.w900),
              textAlign: TextAlign.center),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!,
                style: AppTextStyles.labelMd(
                        color: subtitleColor ?? AppColors.secondary)
                    .copyWith(fontSize: 11, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: content,
    );
  }
}
