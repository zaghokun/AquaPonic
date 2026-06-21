enum NotificationType { warning, danger, info }

class NotificationData {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationType type;
  final bool isRead;
  final DateTime date;

  const NotificationData({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.isRead,
    required this.date,
  });

  NotificationData copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    NotificationType? type,
    bool? isRead,
    DateTime? date,
  }) {
    return NotificationData(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      date: date ?? this.date,
    );
  }
}
