class NotificationModel {
  NotificationModel({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: (json['title'] ?? json['notification_title'] ?? 'New Notification')
          .toString(),
      body: (json['body'] ?? json['message'] ?? json['notification_body'] ?? '')
          .toString(),
      time: (json['time'] ?? json['created_at'] ?? json['date'] ?? 'Just now')
          .toString(),
    );
  }
}
