import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.secondary : AppColors.onSurfaceVariant;
    final fontWeight = isActive ? FontWeight.w600 : FontWeight.w500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelMd(color: color).copyWith(
                fontWeight: fontWeight,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
