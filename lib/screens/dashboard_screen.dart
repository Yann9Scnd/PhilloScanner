import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_item.dart';
import 'beranda_tab_view.dart';
import 'daun_tab_view.dart';

/// Shell utama aplikasi Phylloscanner
/// Mengelola navigasi 4 tab: Beranda, Daun (Ensiklopedia), Sensor, Riwayat
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  void _navigateToDaun() {
    setState(() => _currentIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppHeader(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BerandaTabView(onNavigateToDaun: _navigateToDaun),
          const DaunTabView(),
          _SensorPlaceholder(),
          _RiwayatPlaceholder(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.90),
          border: Border(
            top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.20)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                BottomNavItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                BottomNavItem(
                  icon: Icons.eco_rounded,
                  label: 'Daun',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                BottomNavItem(
                  icon: Icons.sensors,
                  label: 'Sensor',
                  isActive: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                BottomNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  isActive: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Placeholder halaman Sensor
class _SensorPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: AppColors.tertiaryContainer.withValues(alpha: 0.30),
                shape: BoxShape.circle),
            child: const Icon(Icons.sensors, size: 40, color: AppColors.tertiary),
          ),
          const SizedBox(height: 16),
          Text('Data Sensor',
              style: AppTextStyles.titleLg(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Fitur dalam pengembangan',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Placeholder halaman Riwayat
class _RiwayatPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.30),
                shape: BoxShape.circle),
            child: const Icon(Icons.history_rounded,
                size: 40, color: AppColors.secondary),
          ),
          const SizedBox(height: 16),
          Text('Riwayat',
              style: AppTextStyles.titleLg(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text('Fitur dalam pengembangan',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
