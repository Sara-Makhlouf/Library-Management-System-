class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String time;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      title: (json['title'] ?? json['notification_title'] ?? 'New Notification')
          .toString(),

      body: (json['body'] ?? json['message'] ?? json['notification_body'] ?? '')
          .toString(),

      time: (json['time'] ?? json['created_at'] ?? json['date'] ?? 'Just now')
          .toString(),

      isRead:
          json['is_read'] == true ||
          json['is_read'] == 1 ||
          json['is_read']?.toString() == '1' ||
          json['is_read']?.toString().toLowerCase() == 'true',
    );
  }

  NotificationModel copyWith({
    int? id,
    String? title,
    String? body,
    String? time,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
    );
  }
}
