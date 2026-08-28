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
    // Data dummy dihapus — kosong, siap diisi data real dari SQLite/API.
    return const [];
  }
}
