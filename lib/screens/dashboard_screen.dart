import 'package:flutter/material.dart';
import '../models/activity_log_model.dart';
import '../models/actuator_state_model.dart';
import '../models/notification_model.dart';
import '../models/scan_result_model.dart';
import '../models/sensor_data_model.dart';
import '../repositories/scan_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/bottom_nav_item.dart';
import 'beranda_tab_view.dart';
import 'daun_tab_view.dart';
import 'kamera_tab_view.dart';
import 'riwayat_tab_view.dart';
import 'sensor_tab_view.dart';

/// Shell utama aplikasi Phylloscanner (5 Tab Navigation)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final ScanRepository _scanRepository = ScanRepository();

  SensorDataModel _sensorData = SensorDataModel.initial();
  ActuatorStateModel _actuatorState = ActuatorStateModel.initial();
  List<ActivityLogModel> _activities = ActivityLogModel.initialList();
  List<AppNotificationModel> _notifications = AppNotificationModel.initialList();
  List<ScanResultModel> _savedScans = const [
    ScanResultModel(
      deviceId: 'Node 1: ESP32-CAM (Bedeng Barat)',
      imageUrl:
          'https://images.unsplash.com/photo-1592417817098-8f3d6eb231fc?q=80&w=800&auto=format&fit=crop',
      diseaseName: 'Bercak Daun Cabai',
      scientificName: 'Cercospora capsici',
      severity: 'Sedang',
      confidence: 94,
      timestamp: '12 Okt 2026 • 14:30 WIB',
      soilMoisture: '64%',
      aiRecommendations: [
        'Semprotkan bio-fungisida tembaga hidroksida pada permukaan bawah daun cabai pada pagi hari.',
        'Pangkas daun cabai tua di area bawah yang bersentuhan dengan tanah atau mulsa.',
        'Nyalakan kipas ventilasi lewat Node 2 ESP32 untuk menurunkan kelembapan udara mikro.',
      ],
    ),
  ];

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  /// Simpan hasil scan ke riwayat (memory + API Laravel + SQLite fallback)
  void _handleSaveScan(ScanResultModel scan) {
    setState(() {
      _savedScans = [scan, ..._savedScans];
      _activities = [
        ActivityLogModel(
          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Scan AI: ${scan.diseaseName}',
          subtitle: 'Akurasi ${scan.confidence}% (${scan.severity})',
          timestamp: 'Baru saja',
          type: 'scan_alert',
          sector: scan.sector,
          iconName: 'scan',
        ),
        ..._activities,
      ];
    });
    // Sinkronkan ke server Laravel; jika offline simpan ke SQLite lokal.
    _scanRepository.addEspScanResult(scan).ignore();
  }

  void _handleNewScan(ScanResultModel scan) {
    _handleSaveScan(scan);
  }

  void _handleUpdateSensors(SensorDataModel newSensors) {
    setState(() {
      _sensorData = newSensors;
    });
  }

  void _handleUpdateActuators(ActuatorStateModel newActuators) {
    setState(() {
      _actuatorState = newActuators;
    });
  }

  void _handleTogglePumpMode() {
    setState(() {
      final isAuto = !_actuatorState.pumpAutoMode;
      _actuatorState = _actuatorState.copyWith(
        pumpAutoMode: isAuto,
        pumpActive: !isAuto,
      );
    });
  }

  void _handleMarkAllNotificationsRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(unread: false))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        notifications: _notifications,
        onMarkAllRead: _handleMarkAllNotificationsRead,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BerandaTabView(
            sensorData: _sensorData,
            actuatorState: _actuatorState,
            activities: _activities,
            onNavigateToTab: _navigateToTab,
            onTogglePumpMode: _handleTogglePumpMode,
          ),
          DaunTabView(onSaveToHistory: _handleSaveScan),
          KameraTabView(onCaptureForAi: _handleNewScan),
          SensorTabView(
            sensorData: _sensorData,
            actuatorState: _actuatorState,
            onUpdateSensors: _handleUpdateSensors,
            onUpdateActuators: _handleUpdateActuators,
          ),
          RiwayatTabView(
            activities: _activities,
            savedScans: _savedScans,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
                color: AppColors.outlineVariant.withValues(alpha: 0.20)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                  onTap: () => _navigateToTab(0),
                ),
                BottomNavItem(
                  icon: Icons.eco_rounded,
                  label: 'Daun',
                  isActive: _currentIndex == 1,
                  onTap: () => _navigateToTab(1),
                ),
                BottomNavItem(
                  icon: Icons.camera_alt_rounded,
                  label: 'Kamera',
                  isActive: _currentIndex == 2,
                  onTap: () => _navigateToTab(2),
                ),
                BottomNavItem(
                  icon: Icons.sensors_rounded,
                  label: 'Sensor',
                  isActive: _currentIndex == 3,
                  onTap: () => _navigateToTab(3),
                ),
                BottomNavItem(
                  icon: Icons.history_rounded,
                  label: 'Riwayat',
                  isActive: _currentIndex == 4,
                  onTap: () => _navigateToTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
