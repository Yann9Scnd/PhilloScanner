import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Shared AppBar / Header for all screens
/// Uses local asset logo: assets/images/Logo-Phylloscanner.png
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotification;

  const AppHeader({super.key, this.onNotification});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo from local asset
          Image.asset(
            'assets/images/Logo-Phylloscanner.png',
            height: 32,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.eco_rounded, size: 32, color: AppColors.primary);
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Phylloscanner',
            style: AppTextStyles.titleMd(color: AppColors.primary),
          ),
          const Spacer(),
          // Notification Button
          SizedBox(
            width: 40,
            height: 40,
            child: IconButton(
              onPressed: onNotification ?? () {},
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.50),
                shape: const CircleBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Profile Avatar
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 20, color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}
