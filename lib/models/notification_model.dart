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
    // Data dummy dihapus — kosong, siap diisi notifikasi real.
    return const [];
  }
}
