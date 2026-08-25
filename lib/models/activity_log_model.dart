class ActivityLogModel {
  final String id;
  final String title;
  final String subtitle;
  final String timestamp;
  final String type; // 'watering', 'scan_alert', 'sensor_warning', 'system_info'
  final String sector;
  final String iconName;

  const ActivityLogModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    required this.sector,
    required this.iconName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp,
      'type': type,
      'sector': sector,
      'icon_name': iconName,
    };
  }

  factory ActivityLogModel.fromMap(Map<String, dynamic> map) {
    return ActivityLogModel(
      id: (map['id'] as Object?)?.toString() ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      timestamp: map['timestamp'] as String? ?? 'Baru saja',
      type: map['type'] as String? ?? 'system_info',
      sector: map['sector'] as String? ?? 'Kebun Cabai',
      iconName: map['icon_name'] as String? ?? 'router',
    );
  }

  static List<ActivityLogModel> initialList() {
    return const [
      ActivityLogModel(
        id: 'act-1',
        title: 'Irigasi Tetes Otomatis',
        subtitle: 'Node 2 ESP32 (Bedeng Timur) • Siram 10L • Kelembapan tanah naik ke 65%',
        timestamp: '14:15 WIB',
        type: 'watering',
        sector: 'Kebun Cabai',
        iconName: 'water_drop',
      ),
      ActivityLogModel(
        id: 'act-2',
        title: 'AI Scan Kamera Visual',
        subtitle: 'Node 1 ESP32-CAM (Bedeng Barat) • Deteksi bercak daun ringan',
        timestamp: '12:30 WIB',
        type: 'scan_alert',
        sector: 'Kebun Cabai',
        iconName: 'scan',
      ),
      ActivityLogModel(
        id: 'act-3',
        title: 'Misting Pengabut Aktif',
        subtitle: 'Node 2 ESP32 • Misting menyala 5 menit untuk mendinginkan suhu bedeng (27°C)',
        timestamp: '10:10 WIB',
        type: 'sensor_warning',
        sector: 'Kebun Cabai',
        iconName: 'thermostat',
      ),
      ActivityLogModel(
        id: 'act-4',
        title: 'Dual Node ESP32 Terhubung',
        subtitle: 'Node 1 (CAM) & Node 2 (Sensor) Online',
        timestamp: '08:00 WIB',
        type: 'system_info',
        sector: 'Kebun Cabai',
        iconName: 'router',
      ),
    ];
  }
}
