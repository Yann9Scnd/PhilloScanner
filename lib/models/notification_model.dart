class AppNotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final String type; // 'alert', 'info', 'success'

  const AppNotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
    required this.type,
  });

  AppNotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? time,
    bool? unread,
    String? type,
  }) {
    return AppNotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      unread: unread ?? this.unread,
      type: type ?? this.type,
    );
  }

  static List<AppNotificationModel> initialList() {
    return const [
      AppNotificationModel(
        id: 'notif-1',
        title: 'Monitoring Daun Cabai (Node 1)',
        message: 'Kamera Node 1 ESP32-CAM menangkap citra daun cabai di Bedeng Barat. Hasil scan: Sehat / Bercak Ringan.',
        time: '12:30 WIB',
        unread: true,
        type: 'info',
      ),
      AppNotificationModel(
        id: 'notif-2',
        title: 'Irigasi Tetes Selesai (Node 2)',
        message: 'Pompa irigasi Node 2 ESP32 telah menyiram bedeng cabai hingga kelembapan 65%.',
        time: '14:15 WIB',
        unread: true,
        type: 'success',
      ),
      AppNotificationModel(
        id: 'notif-3',
        title: 'Dual ESP32 Telemetry OK',
        message: 'Node 1 (ESP32-CAM Bedeng Barat) dan Node 2 (ESP32 Sensor Bedeng Timur) terhubung stabil.',
        time: '09:00 WIB',
        unread: false,
        type: 'info',
      ),
    ];
  }
}
