import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isDark;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            child: Icon(Icons.notifications),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(body),
                const SizedBox(height: 8),
                Text(time),
              ],
            ),
          ),
        ],
      ),
    );
  }
}